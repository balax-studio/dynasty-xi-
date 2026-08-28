// core/time/game_clock.dart
// Pure Dart. Handles 7-day season calendar, 3 daily match windows, fixture progression, season phases, and banking limits.

enum MatchWindow {
  morning(1, 9, 13, 'Sabah Maçı (09:00 - 13:00)'),
  afternoon(2, 14, 19, 'Öğle Maçı (14:00 - 19:00)'),
  evening(3, 20, 24, 'Akşam Maçı (20:00 - 23:59)');

  final int windowIndex;
  final int startHour;
  final int endHour;
  final String label;

  const MatchWindow(this.windowIndex, this.startHour, this.endHour, this.label);

  static MatchWindow fromHour(int hour) {
    if (hour >= 9 && hour < 14) return MatchWindow.morning;
    if (hour >= 14 && hour < 20) return MatchWindow.afternoon;
    return MatchWindow.evening;
  }

  static MatchWindow fromIndex(int index) {
    switch (index) {
      case 1:
        return MatchWindow.morning;
      case 2:
        return MatchWindow.afternoon;
      case 3:
      default:
        return MatchWindow.evening;
    }
  }
}

enum SeasonPhase {
  preSeason('SEZON ÖNCESİ & YAZ TRANSFERİ', 'Hazırlık kampı, kadro tescili ve ana transfer penceresi açık.'),
  firstHalf('1. YARI LİG MARATONU', '1-10. hafta lig maçları. Tescil penceresi kapalı.'),
  midSeasonBreak('DEVRE ARASI KAMPI & KIŞ TRANSFERİ', '10. maç sonrası devre arası kampı ve ara transfer penceresi açık.'),
  secondHalf('2. YARI & KUPA FİNALLERİ', '11-21. hafta şampiyonluk ve finaller. Tescil penceresi kapalı.'),
  seasonEvaluation('SEZON SONU BİLANÇO & ÖDÜLLER', 'Kupa töreni, lig ödülleri, mali bilanço ve lig terfi/küme düşme.');

  final String label;
  final String description;
  const SeasonPhase(this.label, this.description);

  bool get isTransferWindowOpen => this == SeasonPhase.preSeason || this == SeasonPhase.midSeasonBreak;
  bool get isBreakOrCamp => this == SeasonPhase.preSeason || this == SeasonPhase.midSeasonBreak;
}

class GameClock {
  static const int daysPerSeason = 7;
  static const int matchesPerDay = 3;
  static const int fixturesPerSeason = daysPerSeason * matchesPerDay; // 21 fixtures
  static const int midSeasonMatchday = 10; // Match 10 ends the first half
  static const int maxBankedMatches = 3;

  final int seasonNumber;
  final int dayOfSeason; // 1 (Pazartesi) to 7 (Pazar)
  final int matchday; // 1 to 21
  final MatchWindow currentWindow;
  final int bankedMatches;
  final SeasonPhase phase;

  const GameClock({
    this.seasonNumber = 1,
    this.dayOfSeason = 1,
    this.matchday = 1,
    this.currentWindow = MatchWindow.morning,
    this.bankedMatches = 0,
    this.phase = SeasonPhase.preSeason,
  });

  bool get isTransferWindowOpen => phase.isTransferWindowOpen;

  /// Starts the first half from pre-season
  GameClock startFirstHalf() {
    return GameClock(
      seasonNumber: seasonNumber,
      dayOfSeason: 1,
      matchday: 1,
      currentWindow: MatchWindow.morning,
      bankedMatches: bankedMatches,
      phase: SeasonPhase.firstHalf,
    );
  }

  /// Concludes mid-season break and starts 2nd half from match 11
  GameClock startSecondHalf() {
    return GameClock(
      seasonNumber: seasonNumber,
      dayOfSeason: 4, // Thursday afternoon/evening
      matchday: 11,
      currentWindow: MatchWindow.morning,
      bankedMatches: bankedMatches,
      phase: SeasonPhase.secondHalf,
    );
  }

  /// Concludes season evaluation and starts next season pre-season
  GameClock startNextSeason() {
    return GameClock(
      seasonNumber: seasonNumber + 1,
      dayOfSeason: 1,
      matchday: 1,
      currentWindow: MatchWindow.morning,
      bankedMatches: 0,
      phase: SeasonPhase.preSeason,
    );
  }

  /// Advances to the next match or triggers mid-season break / season evaluation
  GameClock advanceMatch() {
    if (phase == SeasonPhase.preSeason) {
      return startFirstHalf();
    }

    if (phase == SeasonPhase.firstHalf && matchday == midSeasonMatchday) {
      // Trigger mid-season break
      return GameClock(
        seasonNumber: seasonNumber,
        dayOfSeason: 4,
        matchday: midSeasonMatchday,
        currentWindow: currentWindow,
        bankedMatches: bankedMatches,
        phase: SeasonPhase.midSeasonBreak,
      );
    }

    if (phase == SeasonPhase.midSeasonBreak) {
      return startSecondHalf();
    }

    if (matchday >= fixturesPerSeason) {
      // Season finished, enter season evaluation
      return GameClock(
        seasonNumber: seasonNumber,
        dayOfSeason: 7,
        matchday: fixturesPerSeason,
        currentWindow: currentWindow,
        bankedMatches: 0,
        phase: SeasonPhase.seasonEvaluation,
      );
    }

    final nextMatchday = matchday + 1;
    final nextDayOfSeason = ((nextMatchday - 1) ~/ matchesPerDay) + 1;
    final nextWindowIndex = ((nextMatchday - 1) % matchesPerDay) + 1;
    final nextPhase = nextMatchday <= midSeasonMatchday ? SeasonPhase.firstHalf : SeasonPhase.secondHalf;

    return GameClock(
      seasonNumber: seasonNumber,
      dayOfSeason: nextDayOfSeason.clamp(1, 7),
      matchday: nextMatchday,
      currentWindow: MatchWindow.fromIndex(nextWindowIndex),
      bankedMatches: (bankedMatches > 0) ? bankedMatches - 1 : 0,
      phase: nextPhase,
    );
  }

  /// Calculates the real-world day name (Pazartesi, Salı, etc.)
  String get dayName {
    switch (dayOfSeason) {
      case 1:
        return 'Pazartesi';
      case 2:
        return 'Salı';
      case 3:
        return 'Çarşamba';
      case 4:
        return 'Perşembe';
      case 5:
        return 'Cuma';
      case 6:
        return 'Cumartesi';
      case 7:
        return 'Pazar (Sezon Finali)';
      default:
        return 'Gün $dayOfSeason';
    }
  }

  /// Whether current match is the season finale (Match 21)
  bool get isSeasonFinale => matchday == fixturesPerSeason;

  /// Next match formatted time string
  String get nextMatchSchedule {
    if (phase == SeasonPhase.preSeason) {
      return 'Sezon $seasonNumber — Sezon Öncesi & Yaz Transfer Dönemi';
    }
    if (phase == SeasonPhase.midSeasonBreak) {
      return 'Sezon $seasonNumber — Devre Arası Kampı & Kış Transfer Penceresi';
    }
    if (phase == SeasonPhase.seasonEvaluation) {
      return 'Sezon $seasonNumber — Sezon Sonu Bilanço & Kupa Töreni';
    }
    return '$dayName ${currentWindow.label} — Hafta $matchday / $fixturesPerSeason';
  }

  GameClock copyWith({
    int? seasonNumber,
    int? dayOfSeason,
    int? matchday,
    MatchWindow? currentWindow,
    int? bankedMatches,
    SeasonPhase? phase,
  }) {
    return GameClock(
      seasonNumber: seasonNumber ?? this.seasonNumber,
      dayOfSeason: dayOfSeason ?? this.dayOfSeason,
      matchday: matchday ?? this.matchday,
      currentWindow: currentWindow ?? this.currentWindow,
      bankedMatches: bankedMatches ?? this.bankedMatches,
      phase: phase ?? this.phase,
    );
  }

  Map<String, dynamic> toJson() => {
        'seasonNumber': seasonNumber,
        'dayOfSeason': dayOfSeason,
        'matchday': matchday,
        'currentWindow': currentWindow.windowIndex,
        'bankedMatches': bankedMatches,
        'phase': phase.name,
      };

  factory GameClock.fromJson(Map<String, dynamic> json) {
    final phaseName = json['phase'] as String?;
    final phase = SeasonPhase.values.firstWhere(
      (p) => p.name == phaseName,
      orElse: () => SeasonPhase.firstHalf,
    );

    return GameClock(
      seasonNumber: json['seasonNumber'] as int? ?? 1,
      dayOfSeason: json['dayOfSeason'] as int? ?? 1,
      matchday: json['matchday'] as int? ?? 1,
      currentWindow: MatchWindow.fromIndex(json['currentWindow'] as int? ?? 1),
      bankedMatches: json['bankedMatches'] as int? ?? 0,
      phase: phase,
    );
  }
}
