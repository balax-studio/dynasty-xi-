// test/domain/match_stats_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/sim/match_events.dart';
import 'package:futbol/domain/sim/match_stats_applier.dart';

void main() {
  group('MatchStatsApplier (§11.5 & Section A)', () {
    test('Criterion #2: Player scoring 2 goals has goals == 2 and appearances == 1', () {
      const striker = Player(
        id: 'p_striker_1',
        firstName: 'Mauro',
        lastName: 'Icardi',
        countryCode: 'AR',
        age: 30,
        position: Position.st,
        pace: 75,
        technique: 82,
        shooting: 88,
        passing: 70,
        defending: 35,
        physical: 78,
        mentality: 85,
        potential: 88,
        weeklyWage: 15000,
        appearances: 0,
        goals: 0,
        assists: 0,
      );

      final result = MatchStatsApplier.apply(
        currentSquad: [striker],
        starting11Ids: {'p_striker_1'},
        userGoals: 2,
        opponentGoals: 1,
        opponentOvr: 70,
        userGoalEvents: [
          const MatchGoalEvent(minute: 23, scorerName: 'Mauro Icardi', scorerId: 'p_striker_1', isHome: true),
          const MatchGoalEvent(minute: 67, scorerName: 'Mauro Icardi', scorerId: 'p_striker_1', isHome: true),
        ],
        randomSeed: 42,
      );

      final updatedStriker = result.updatedPlayers.firstWhere((p) => p.id == 'p_striker_1');
      expect(updatedStriker.goals, equals(2));
      expect(updatedStriker.appearances, equals(1));
      expect(updatedStriker.recentRatings.length, equals(1));
      expect(updatedStriker.recentRatings.first, greaterThanOrEqualTo(7.0));
      expect(result.manOfTheMatch?.id, equals('p_striker_1'));
    });
  });
}
