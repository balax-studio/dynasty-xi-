// domain/tournament/cup_tournament.dart
// National Cup (Türkiye Kupası / Hanedan Kupası) and Promotion Play-Off Bracket Engine (§14.2, §14.3)

import 'dart:math';
import '../entities/club.dart';
import '../../core/rng/deterministic_rng.dart';

enum CupRound {
  roundOf16('Son 16 Turu', 1),
  quarterFinal('Çeyrek Final', 2),
  semiFinal('Yarı Final', 3),
  finalMatch('Büyük Final', 4);

  final String title;
  final int stageNumber;
  const CupRound(this.title, this.stageNumber);
}

class CupMatch {
  final String id;
  final CupRound round;
  final String homeClubId;
  final String homeClubName;
  final String homeBadge;
  final String awayClubId;
  final String awayClubName;
  final String awayBadge;
  final bool isPlayed;
  final int homeScore;
  final int awayScore;
  final int? homePenalties;
  final int? awayPenalties;
  final String? winnerClubId;

  const CupMatch({
    required this.id,
    required this.round,
    required this.homeClubId,
    required this.homeClubName,
    required this.homeBadge,
    required this.awayClubId,
    required this.awayClubName,
    required this.awayBadge,
    this.isPlayed = false,
    this.homeScore = 0,
    this.awayScore = 0,
    this.homePenalties,
    this.awayPenalties,
    this.winnerClubId,
  });

  CupMatch copyWith({
    bool? isPlayed,
    int? homeScore,
    int? awayScore,
    int? homePenalties,
    int? awayPenalties,
    String? winnerClubId,
  }) {
    return CupMatch(
      id: id,
      round: round,
      homeClubId: homeClubId,
      homeClubName: homeClubName,
      homeBadge: homeBadge,
      awayClubId: awayClubId,
      awayClubName: awayClubName,
      awayBadge: awayBadge,
      isPlayed: isPlayed ?? this.isPlayed,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      homePenalties: homePenalties ?? this.homePenalties,
      awayPenalties: awayPenalties ?? this.awayPenalties,
      winnerClubId: winnerClubId ?? this.winnerClubId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'round': round.index,
    'homeClubId': homeClubId,
    'homeClubName': homeClubName,
    'homeBadge': homeBadge,
    'awayClubId': awayClubId,
    'awayClubName': awayClubName,
    'awayBadge': awayBadge,
    'isPlayed': isPlayed,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'homePenalties': homePenalties,
    'awayPenalties': awayPenalties,
    'winnerClubId': winnerClubId,
  };

  factory CupMatch.fromJson(Map<String, dynamic> json) => CupMatch(
    id: json['id'] as String,
    round: CupRound.values[json['round'] as int],
    homeClubId: json['homeClubId'] as String,
    homeClubName: json['homeClubName'] as String,
    homeBadge: json['homeBadge'] as String,
    awayClubId: json['awayClubId'] as String,
    awayClubName: json['awayClubName'] as String,
    awayBadge: json['awayBadge'] as String,
    isPlayed: json['isPlayed'] as bool? ?? false,
    homeScore: json['homeScore'] as int? ?? 0,
    awayScore: json['awayScore'] as int? ?? 0,
    homePenalties: json['homePenalties'] as int?,
    awayPenalties: json['awayPenalties'] as int?,
    winnerClubId: json['winnerClubId'] as String?,
  );
}

class CupTournament {
  final String tournamentName;
  final CupRound currentRound;
  final List<CupMatch> matches;
  final bool isCompleted;
  final String? championClubId;
  final String? championClubName;
  final int prizePool;

  const CupTournament({
    this.tournamentName = 'Hanedan Ulusal Kupası',
    this.currentRound = CupRound.quarterFinal,
    this.matches = const [],
    this.isCompleted = false,
    this.championClubId,
    this.championClubName,
    this.prizePool = 100000,
  });

  /// Generate a fresh 8-team Quarter Final tournament with the user club and 7 opponents
  factory CupTournament.generateQuarterFinalTournament({
    required Club userClub,
    required List<Club> opponents,
    int seed = 42,
  }) {
    final participants = <Club>[userClub, ...opponents.take(7)];
    while (participants.length < 8) {
      participants.add(Club(
        id: 'cup_bot_${participants.length}',
        name: 'Kupa FC ${participants.length}',
        city: 'Anadolu',
        leagueTier: 3,
        badgeIcon: 'SHIELD',
        squad: const [],
        starting11Ids: const [],
      ));
    }

    final shuffled = List<Club>.from(participants)..shuffle(Random(seed));
    final initialMatches = <CupMatch>[];

    for (int i = 0; i < 4; i++) {
      final home = shuffled[i * 2];
      final away = shuffled[i * 2 + 1];
      initialMatches.add(CupMatch(
        id: 'cup_qf_${i + 1}',
        round: CupRound.quarterFinal,
        homeClubId: home.id,
        homeClubName: home.name,
        homeBadge: home.badgeIcon,
        awayClubId: away.id,
        awayClubName: away.name,
        awayBadge: away.badgeIcon,
      ));
    }

    return CupTournament(
      tournamentName: 'Türkiye Hanedan Kupası',
      currentRound: CupRound.quarterFinal,
      matches: initialMatches,
    );
  }

  CupMatch? userNextCupMatch(String userClubId) {
    return matches.where((m) => !m.isPlayed && (m.homeClubId == userClubId || m.awayClubId == userClubId)).firstOrNull;
  }

  /// Progress tournament to next round with winner clubs
  CupTournament progressRound(int seed) {
    final unplayed = matches.where((m) => !m.isPlayed).toList();
    if (unplayed.isNotEmpty) return this;

    final currentRoundMatches = matches.where((m) => m.round == currentRound).toList();
    final winners = currentRoundMatches.map((m) => m.winnerClubId!).toList();

    if (currentRound == CupRound.finalMatch) {
      final finalMatch = currentRoundMatches.first;
      final winnerId = finalMatch.winnerClubId!;
      final winnerName = winnerId == finalMatch.homeClubId ? finalMatch.homeClubName : finalMatch.awayClubName;
      return copyWith(
        isCompleted: true,
        championClubId: winnerId,
        championClubName: winnerName,
      );
    }

    final nextRound = currentRound == CupRound.quarterFinal ? CupRound.semiFinal : CupRound.finalMatch;
    final newMatches = List<CupMatch>.from(matches);

    for (int i = 0; i < winners.length; i += 2) {
      if (i + 1 < winners.length) {
        final prevMatch1 = currentRoundMatches.firstWhere((m) => m.winnerClubId == winners[i]);
        final prevMatch2 = currentRoundMatches.firstWhere((m) => m.winnerClubId == winners[i + 1]);

        final homeName = winners[i] == prevMatch1.homeClubId ? prevMatch1.homeClubName : prevMatch1.awayClubName;
        final homeBadge = winners[i] == prevMatch1.homeClubId ? prevMatch1.homeBadge : prevMatch1.awayBadge;

        final awayName = winners[i + 1] == prevMatch2.homeClubId ? prevMatch2.homeClubName : prevMatch2.awayClubName;
        final awayBadge = winners[i + 1] == prevMatch2.homeClubId ? prevMatch2.homeBadge : prevMatch2.awayBadge;

        newMatches.add(CupMatch(
          id: 'cup_${nextRound.name}_${(i ~/ 2) + 1}',
          round: nextRound,
          homeClubId: winners[i],
          homeClubName: homeName,
          homeBadge: homeBadge,
          awayClubId: winners[i + 1],
          awayClubName: awayName,
          awayBadge: awayBadge,
        ));
      }
    }

    return copyWith(
      currentRound: nextRound,
      matches: newMatches,
    );
  }

  CupTournament copyWith({
    String? tournamentName,
    CupRound? currentRound,
    List<CupMatch>? matches,
    bool? isCompleted,
    String? championClubId,
    String? championClubName,
    int? prizePool,
  }) {
    return CupTournament(
      tournamentName: tournamentName ?? this.tournamentName,
      currentRound: currentRound ?? this.currentRound,
      matches: matches ?? this.matches,
      isCompleted: isCompleted ?? this.isCompleted,
      championClubId: championClubId ?? this.championClubId,
      championClubName: championClubName ?? this.championClubName,
      prizePool: prizePool ?? this.prizePool,
    );
  }

  Map<String, dynamic> toJson() => {
    'tournamentName': tournamentName,
    'currentRound': currentRound.index,
    'matches': matches.map((m) => m.toJson()).toList(),
    'isCompleted': isCompleted,
    'championClubId': championClubId,
    'championClubName': championClubName,
    'prizePool': prizePool,
  };

  factory CupTournament.fromJson(Map<String, dynamic> json) => CupTournament(
    tournamentName: json['tournamentName'] as String? ?? 'Türkiye Hanedan Kupası',
    currentRound: CupRound.values[json['currentRound'] as int? ?? 1],
    matches: (json['matches'] as List<dynamic>?)
            ?.map((e) => CupMatch.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    isCompleted: json['isCompleted'] as bool? ?? false,
    championClubId: json['championClubId'] as String?,
    championClubName: json['championClubName'] as String?,
    prizePool: json['prizePool'] as int? ?? 100000,
  );
}

/// Single-elimination Promotion Play-Off between 3rd and 4th place teams (§14.2)
class PlayOffMatch {
  final String seasonNumber;
  final Club team3rd;
  final Club team4th;
  final bool isPlayed;
  final int team3rdScore;
  final int team4thScore;
  final String? promotedClubId;

  const PlayOffMatch({
    required this.seasonNumber,
    required this.team3rd,
    required this.team4th,
    this.isPlayed = false,
    this.team3rdScore = 0,
    this.team4thScore = 0,
    this.promotedClubId,
  });

  PlayOffMatch resolve({int seed = 123}) {
    final rng = DeterministicRng(seed);
    int s3 = rng.nextInt(4);
    int s4 = rng.nextInt(4);
    if (s3 == s4) {
      if (rng.nextInt(2) == 1) {
        s3 += 1;
      } else {
        s4 += 1;
      }
    }
    final winnerId = s3 > s4 ? team3rd.id : team4th.id;
    return PlayOffMatch(
      seasonNumber: seasonNumber,
      team3rd: team3rd,
      team4th: team4th,
      isPlayed: true,
      team3rdScore: s3,
      team4thScore: s4,
      promotedClubId: winnerId,
    );
  }
}
