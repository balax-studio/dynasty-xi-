// test/domain/injury_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/sim/injury_engine.dart';

void main() {
  group('InjuryEngine (§9.6 & Section A)', () {
    test('Criterion #4 & #5: Injury proneness impacts injury probability', () {
      const lowRiskPlayer = Player(
        id: 'p_low_risk',
        firstName: 'Demir',
        lastName: 'Adam',
        countryCode: 'TR',
        age: 22,
        position: Position.cb,
        pace: 75,
        technique: 65,
        shooting: 40,
        passing: 65,
        defending: 80,
        physical: 85,
        mentality: 80,
        potential: 82,
        weeklyWage: 2000,
        injuryProneness: 10,
        fitness: 100,
      );

      const highRiskPlayer = Player(
        id: 'p_high_risk',
        firstName: 'Cam',
        lastName: 'Adam',
        countryCode: 'TR',
        age: 32,
        position: Position.st,
        pace: 75,
        technique: 80,
        shooting: 80,
        passing: 65,
        defending: 30,
        physical: 60,
        mentality: 75,
        potential: 80,
        weeklyWage: 5000,
        injuryProneness: 90,
        fitness: 60,
      );

      int highRiskInjuries = 0;
      int lowRiskInjuries = 0;
      const iterations = 1000;

      for (int i = 0; i < iterations; i++) {
        final resLow = InjuryEngine.processMatchInjuries(
          currentSquad: [lowRiskPlayer],
          matchParticipants: {'p_low_risk'},
          randomSeed: i,
        );
        if (resLow.newInjuries.isNotEmpty) lowRiskInjuries++;

        final resHigh = InjuryEngine.processMatchInjuries(
          currentSquad: [highRiskPlayer],
          matchParticipants: {'p_high_risk'},
          randomSeed: i,
        );
        if (resHigh.newInjuries.isNotEmpty) highRiskInjuries++;
      }

      expect(highRiskInjuries, greaterThan(lowRiskInjuries * 2),
          reason: 'High injury proneness and fatigue must suffer >=2x more injuries');
    });

    test('Injured players recover tick by tick', () {
      const injuredPlayer = Player(
        id: 'p_inj',
        firstName: 'Ahmet',
        lastName: 'Yılmaz',
        countryCode: 'TR',
        age: 24,
        position: Position.cm,
        pace: 70,
        technique: 70,
        shooting: 70,
        passing: 70,
        defending: 70,
        physical: 70,
        mentality: 70,
        potential: 75,
        weeklyWage: 2000,
        injuryMatchesLeft: 2,
        injuryType: 'Hamstring',
        injurySeverity: InjurySeverity.moderate,
      );

      // Tick 1
      final res1 = InjuryEngine.processMatchInjuries(
        currentSquad: [injuredPlayer],
        matchParticipants: {},
        randomSeed: 1,
      );
      expect(res1.squad.first.injuryMatchesLeft, equals(1));
      expect(res1.recoveredPlayers, isEmpty);

      // Tick 2
      final res2 = InjuryEngine.processMatchInjuries(
        currentSquad: res1.squad,
        matchParticipants: {},
        randomSeed: 2,
      );
      expect(res2.squad.first.injuryMatchesLeft, equals(0));
      expect(res2.squad.first.isInjured, isFalse);
      expect(res2.recoveredPlayers.length, equals(1));
    });
  });
}
