// domain/sim/match_stats_applier.dart
// Pure Dart. Calculates player match ratings (§11.5) and updates season/match statistics.

import 'dart:math' as math;
import '../entities/player.dart';
import 'match_events.dart';

class PlayerMatchPerformance {
  final String playerId;
  final double rating;
  final int goals;
  final int assists;
  final bool cleanSheet;
  final int minutesPlayed;

  const PlayerMatchPerformance({
    required this.playerId,
    required this.rating,
    required this.goals,
    required this.assists,
    required this.cleanSheet,
    required this.minutesPlayed,
  });
}

class MatchStatsResult {
  final List<Player> updatedPlayers;
  final Map<String, PlayerMatchPerformance> performances;
  final Player? manOfTheMatch;

  const MatchStatsResult({
    required this.updatedPlayers,
    required this.performances,
    this.manOfTheMatch,
  });
}

class MatchStatsApplier {
  /// Computes player ratings (§11.5) and updates player statistics after a match.
  static MatchStatsResult apply({
    required List<Player> currentSquad,
    required Set<String> starting11Ids,
    Set<String> subIds = const {},
    required int userGoals,
    required int opponentGoals,
    required int opponentOvr,
    required List<MatchGoalEvent> userGoalEvents,
    int? randomSeed,
  }) {
    final rng = math.Random(randomSeed ?? DateTime.now().millisecondsSinceEpoch);
    final isCleanSheet = opponentGoals == 0;
    final isWin = userGoals > opponentGoals;
    final isLoss = userGoals < opponentGoals;

    // Count goals and assists per player for the match
    final goalsMap = <String, int>{};
    final assistsMap = <String, int>{};

    for (final event in userGoalEvents) {
      if (event.scorerId != null && event.scorerId!.isNotEmpty) {
        goalsMap[event.scorerId!] = (goalsMap[event.scorerId!] ?? 0) + 1;
      }
      if (event.assistantId != null && event.assistantId!.isNotEmpty) {
        assistsMap[event.assistantId!] = (assistsMap[event.assistantId!] ?? 0) + 1;
      }
    }

    final performances = <String, PlayerMatchPerformance>{};
    final updatedPlayers = <Player>[];
    Player? motm;
    double highestRating = -1.0;

    for (final player in currentSquad) {
      final isStarter = starting11Ids.contains(player.id);
      final isSub = subIds.contains(player.id);

      if (!isStarter && !isSub) {
        // Player did not participate in match
        updatedPlayers.add(player);
        continue;
      }

      final minutes = isStarter ? 90 : 30;
      final playerGoals = goalsMap[player.id] ?? 0;
      final playerAssists = assistsMap[player.id] ?? 0;

      final isDefensive = player.position == Position.gk ||
          player.position == Position.cb ||
          player.position == Position.lb ||
          player.position == Position.rb ||
          player.position == Position.dm;

      final earnedCleanSheet = isCleanSheet && isDefensive;

      // Base rating calculation (§11.5)
      double rating = 6.0;

      // Goal impact (+0.7 per goal, cap +2.1)
      rating += math.min(playerGoals * 0.7, 2.1);

      // Assist impact (+0.4 per assist, cap +1.2)
      rating += math.min(playerAssists * 0.4, 1.2);

      // Clean sheet impact (+0.6 for defenders/gk)
      if (earnedCleanSheet) {
        rating += 0.6;
      }

      // Conceded penalty for defenders/gk if conceded >= 3
      if (isDefensive && opponentGoals >= 3) {
        rating -= (opponentGoals - 2) * 0.3;
      }

      // Team result bonus/penalty
      if (isWin) {
        rating += 0.4;
      } else if (isLoss) {
        rating -= 0.4;
      }

      // OVR disparity against opponent
      final ovrDiff = (player.ovr - opponentOvr) * 0.02;
      rating += ovrDiff.clamp(-0.5, 0.5);

      // Random micro-variance (-0.2 .. +0.2)
      rating += (rng.nextDouble() * 0.4) - 0.2;

      // Partial minutes dampening
      if (minutes < 90) {
        rating = 5.5 + (rating - 5.5) * (minutes / 90.0);
      }

      // Clamp rating between 3.0 and 10.0 with 1 decimal
      rating = ((rating.clamp(3.0, 10.0)) * 10).round() / 10.0;

      final perf = PlayerMatchPerformance(
        playerId: player.id,
        rating: rating,
        goals: playerGoals,
        assists: playerAssists,
        cleanSheet: earnedCleanSheet,
        minutesPlayed: minutes,
      );
      performances[player.id] = perf;

      // Rolling 5-match ratings
      final newRecentRatings = List<double>.from(player.recentRatings)..add(rating);
      if (newRecentRatings.length > 5) {
        newRecentRatings.removeAt(0);
      }

      // Season ratings (integer rounded)
      final newSeasonRatings = List<int>.from(player.seasonRatings)..add(rating.round());

      // Recalculate dynamic form based on rolling recent ratings
      final newForm = (newRecentRatings.reduce((a, b) => a + b) / newRecentRatings.length)
          .clamp(1.0, 10.0);

      final updatedPlayer = player.copyWith(
        appearances: player.appearances + 1,
        goals: player.goals + playerGoals,
        assists: player.assists + playerAssists,
        cleanSheets: player.cleanSheets + (earnedCleanSheet ? 1 : 0),
        recentRatings: newRecentRatings,
        seasonRatings: newSeasonRatings,
        form: (newForm * 10).round() / 10.0,
      );

      updatedPlayers.add(updatedPlayer);

      if (rating > highestRating) {
        highestRating = rating;
        motm = updatedPlayer;
      }
    }

    return MatchStatsResult(
      updatedPlayers: updatedPlayers,
      performances: performances,
      manOfTheMatch: motm,
    );
  }
}
