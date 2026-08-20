// domain/sim/player_condition.dart
// Pure Dart. Handles post-match fitness depletion, sharpness, morale triggers (§9.5) and squad recovery.

import '../entities/player.dart';
import 'match_stats_applier.dart';

class PlayerConditionApplier {
  /// Applies fitness decay, sharpness changes, and morale triggers after a match (§9.5).
  static List<Player> applyPostMatchCondition({
    required List<Player> squad,
    required Set<String> starting11Ids,
    Set<String> subIds = const {},
    required int userGoals,
    required int opponentGoals,
    required Map<String, PlayerMatchPerformance> performances,
    int trainingGroundLevel = 1,
  }) {
    final isWin = userGoals > opponentGoals;
    final isDraw = userGoals == opponentGoals;

    return squad.map((player) {
      final isStarter = starting11Ids.contains(player.id);
      final isSub = subIds.contains(player.id);
      final didPlay = isStarter || isSub;
      final perf = performances[player.id];

      // 1. FITNESS ADJUSTMENT
      int newFitness = player.fitness;
      if (isStarter) {
        // Starters lose ~18 fitness (reduced slightly by high physical and training facility)
        final fatigue = 18 - (player.physical * 0.05) - (trainingGroundLevel * 0.5);
        newFitness = (newFitness - fatigue.round()).clamp(10, 100);
      } else if (isSub) {
        // Subs lose ~6 fitness
        newFitness = (newFitness - 6).clamp(10, 100);
      } else {
        // Benched/Rested players recover fitness based on intensity
        int recovery;
        switch (player.trainingIntensity) {
          case TrainingIntensity.light:
            recovery = 18 + (trainingGroundLevel * 2);
            break;
          case TrainingIntensity.normal:
            recovery = 14 + (trainingGroundLevel * 2);
            break;
          case TrainingIntensity.intensive:
            recovery = 9 + (trainingGroundLevel * 2);
            break;
        }
        newFitness = (newFitness + recovery).clamp(0, 100);
      }

      // 2. SHARPNESS ADJUSTMENT
      int newSharpness = player.sharpness;
      if (isStarter) {
        newSharpness = (newSharpness + 15).clamp(0, 100);
      } else if (isSub) {
        newSharpness = (newSharpness + 8).clamp(0, 100);
      } else {
        // Reserves lose sharpness if not playing
        newSharpness = (newSharpness - 5).clamp(25, 100);
      }

      // 3. MORALE TRIGGERS (§9.5)
      double moraleSensitivity;
      switch (player.personality) {
        case PersonalityType.ambitious:
          moraleSensitivity = 1.25;
          break;
        case PersonalityType.rebel:
          moraleSensitivity = 1.40;
          break;
        case PersonalityType.professional:
        case PersonalityType.leader:
          moraleSensitivity = 0.80;
          break;
        case PersonalityType.humble:
        case PersonalityType.loyal:
          moraleSensitivity = 0.70;
          break;
        case PersonalityType.mercenary:
          moraleSensitivity = 1.00;
          break;
        default:
          moraleSensitivity = 1.00;
          break;
      }

      int moraleDelta = 0;

      // Team outcome
      if (isWin) {
        moraleDelta += 6;
      } else if (isDraw) {
        moraleDelta += 1;
      } else {
        moraleDelta -= 5;
      }

      if (didPlay && perf != null) {
        moraleDelta += 1; // Played bonus
        moraleDelta += (perf.goals * 3); // Scorer bonus
        moraleDelta += (perf.assists * 2); // Assist bonus
        if (perf.cleanSheet) {
          moraleDelta += 3; // Clean sheet bonus
        }
        if (perf.rating >= 8.0) {
          moraleDelta += 3;
        } else if (perf.rating < 5.0) {
          moraleDelta -= 3;
        }
      } else {
        // Role expectation penalty for benching
        switch (player.squadRole) {
          case SquadRole.star:
            moraleDelta -= 7;
            break;
          case SquadRole.first11:
            moraleDelta -= 4;
            break;
          case SquadRole.rotation:
            moraleDelta -= 1;
            break;
          case SquadRole.bench:
            // Content with benching
            break;
        }
      }

      final scaledDelta = (moraleDelta * moraleSensitivity).round();
      final newMorale = (player.morale + scaledDelta).clamp(0, 100);

      return player.copyWith(
        fitness: newFitness,
        sharpness: newSharpness,
        morale: newMorale,
      );
    }).toList();
  }

  /// Calculates player physical match fitness multiplier for simulation (§11.5).
  static double getFitnessStrengthFactor(int fitness) {
    return (0.70 + (fitness / 333.3)).clamp(0.70, 1.00);
  }
}
