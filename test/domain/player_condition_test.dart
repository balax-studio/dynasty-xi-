// test/domain/player_condition_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/sim/match_stats_applier.dart';
import 'package:futbol/domain/sim/player_condition.dart';

void main() {
  group('PlayerConditionApplier (§9.5 & Section A)', () {
    test('Criterion #3: Playing 3 consecutive matches depletes fitness significantly', () {
      Player player = const Player(
        id: 'p_mid_1',
        firstName: 'Lucas',
        lastName: 'Torreira',
        countryCode: 'UY',
        age: 28,
        position: Position.dm,
        pace: 75,
        technique: 78,
        shooting: 65,
        passing: 80,
        defending: 82,
        physical: 76,
        mentality: 85,
        potential: 82,
        weeklyWage: 8000,
        fitness: 100,
        sharpness: 70,
        morale: 80,
      );

      final dummyPerf = <String, PlayerMatchPerformance>{
        'p_mid_1': const PlayerMatchPerformance(
          playerId: 'p_mid_1',
          rating: 6.8,
          goals: 0,
          assists: 0,
          cleanSheet: false,
          minutesPlayed: 90,
        ),
      };

      // Match 1
      var squad = PlayerConditionApplier.applyPostMatchCondition(
        squad: [player],
        starting11Ids: {'p_mid_1'},
        userGoals: 1,
        opponentGoals: 0,
        performances: dummyPerf,
      );
      player = squad.first;
      expect(player.fitness, lessThan(90));

      // Match 2
      squad = PlayerConditionApplier.applyPostMatchCondition(
        squad: [player],
        starting11Ids: {'p_mid_1'},
        userGoals: 1,
        opponentGoals: 1,
        performances: dummyPerf,
      );
      player = squad.first;
      expect(player.fitness, lessThan(75));

      // Match 3
      squad = PlayerConditionApplier.applyPostMatchCondition(
        squad: [player],
        starting11Ids: {'p_mid_1'},
        userGoals: 0,
        opponentGoals: 2,
        performances: dummyPerf,
      );
      player = squad.first;
      expect(player.fitness, lessThanOrEqualTo(60));
    });
  });
}
