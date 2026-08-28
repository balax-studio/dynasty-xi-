// test/domain/behavior_tree_tactics_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/tactics/behavior_tree_tactics.dart';

void main() {
  group('TacticalBehaviorTree Tests', () {
    const shooter = Player(
      id: 'p_striker',
      firstName: 'Mauro',
      lastName: 'Icardi',
      countryCode: 'AR',
      age: 31,
      position: Position.st,
      pace: 78,
      shooting: 88,
      passing: 72,
      technique: 82,
      defending: 40,
      physical: 75,
      mentality: 85,
      potential: 88,
      weeklyWage: 30000,
    );

    const winger = Player(
      id: 'p_winger',
      firstName: 'Barış',
      lastName: 'Alper',
      countryCode: 'TR',
      age: 24,
      position: Position.rw,
      pace: 92,
      shooting: 75,
      passing: 74,
      technique: 80,
      defending: 55,
      physical: 86,
      mentality: 82,
      potential: 85,
      weeklyWage: 15000,
    );

    test('Chooses shoot when close to goal with few defenders', () {
      const ctx = TacticalContext(
        actor: shooter,
        distanceToGoal: 15.0,
        defendersInFront: 1,
        passingLaneOpenness: 0.3,
        hasSupportRunner: false,
        matchMomentum: 0.8,
      );

      final action = TacticalBehaviorTree.evaluateBestAction(ctx);
      expect(action, equals(TacticalActionType.shoot));
    });

    test('Chooses throughBall when support runner exists and passing lane is open', () {
      const ctx = TacticalContext(
        actor: shooter,
        distanceToGoal: 32.0,
        defendersInFront: 3,
        passingLaneOpenness: 0.85,
        hasSupportRunner: true,
        matchMomentum: 0.5,
      );

      final action = TacticalBehaviorTree.evaluateBestAction(ctx);
      expect(action, equals(TacticalActionType.throughBall));
    });

    test('Chooses wingCross for winger on wide attack', () {
      const ctx = TacticalContext(
        actor: winger,
        distanceToGoal: 28.0,
        defendersInFront: 2,
        passingLaneOpenness: 0.4,
        hasSupportRunner: false,
        matchMomentum: 0.5,
      );

      final action = TacticalBehaviorTree.evaluateBestAction(ctx);
      expect(action, equals(TacticalActionType.wingCross));
    });
  });
}
