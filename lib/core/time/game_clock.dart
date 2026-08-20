// core/time/game_clock.dart
// Pure Dart. Handles 7-day season calendar, 3 daily match windows, fixture progression and banking limits.

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

class GameClock {
  static const int daysPerSeason = 7;
  static const int matchesPerDay = 3;
  static const int fixturesPerSeason = daysPerSeason * matchesPerDay; // 21 fixtures
  static const int maxBankedMatches = 3;

  final int seasonNumber;
  final int dayOfSeason; // 1 (Pazartesi) to 7 (Pazar)
  final int matchday; // 1 to 21
  final MatchWindow currentWindow;
  final int bankedMatches;

  const GameClock({
    this.seasonNumber = 1,
    this.dayOfSeason = 1,
    this.matchday = 1,
    this.currentWindow = MatchWindow.morning,
    this.bankedMatches = 0,
  });

  /// Advances to the next match in season schedule
  GameClock advanceMatch() {
    if (matchday >= fixturesPerSeason) {
      // Season finished, ready for transition
      return GameClock(
        seasonNumber: seasonNumber + 1,
        dayOfSeason: 1,
        matchday: 1,
        currentWindow: MatchWindow.morning,
        bankedMatches: 0,
      );
    }

    final nextMatchday = matchday + 1;
    final nextDayOfSeason = ((nextMatchday - 1) ~/ matchesPerDay) + 1;
    final nextWindowIndex = ((nextMatchday - 1) % matchesPerDay) + 1;

    return GameClock(
      seasonNumber: seasonNumber,
      dayOfSeason: nextDayOfSeason.clamp(1, 7),
      matchday: nextMatchday,
      currentWindow: MatchWindow.fromIndex(nextWindowIndex),
      bankedMatches: (bankedMatches > 0) ? bankedMatches - 1 : 0,
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
    return '$dayName ${currentWindow.label} — Hafta $matchday / $fixturesPerSeason';
  }

  Map<String, dynamic> toJson() => {
        'seasonNumber': seasonNumber,
        'dayOfSeason': dayOfSeason,
        'matchday': matchday,
        'currentWindow': currentWindow.windowIndex,
        'bankedMatches': bankedMatches,
      };

  factory GameClock.fromJson(Map<String, dynamic> json) => GameClock(
        seasonNumber: json['seasonNumber'] as int? ?? 1,
        dayOfSeason: json['dayOfSeason'] as int? ?? 1,
        matchday: json['matchday'] as int? ?? 1,
        currentWindow: MatchWindow.fromIndex(json['currentWindow'] as int? ?? 1),
        bankedMatches: json['bankedMatches'] as int? ?? 0,
      );
}
