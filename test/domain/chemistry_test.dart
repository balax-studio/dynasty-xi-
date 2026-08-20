// test/domain/chemistry_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/sim/team_chemistry.dart';

void main() {
  group('Team Chemistry Matrix Tests (§9.4, Ek C.2)', () {
    const leader = Player(
      id: 'p_leader',
      firstName: 'Lider',
      lastName: 'Kaptan',
      age: 28,
      position: Position.cb,
      personality: PersonalityType.leader,
      countryCode: 'TR',
      pace: 70,
      shooting: 50,
      passing: 75,
      defending: 85,
      physical: 80,
      technique: 65,
      mentality: 85,
      potential: 85,
      weeklyWage: 3000,
    );

    const loyalTr = Player(
      id: 'p_loyal',
      firstName: 'Sadık',
      lastName: 'Yerli',
      age: 24,
      position: Position.cm,
      personality: PersonalityType.loyal,
      countryCode: 'TR',
      pace: 75,
      shooting: 70,
      passing: 80,
      defending: 70,
      physical: 75,
      technique: 75,
      mentality: 80,
      potential: 82,
      weeklyWage: 2000,
    );

    const rebelForeign = Player(
      id: 'p_rebel',
      firstName: 'Asi',
      lastName: 'Yabancı',
      age: 22,
      position: Position.st,
      personality: PersonalityType.rebel,
      countryCode: 'BR',
      pace: 88,
      shooting: 82,
      passing: 65,
      defending: 30,
      physical: 72,
      technique: 85,
      mentality: 60,
      potential: 90,
      weeklyWage: 4000,
    );

    test('Harmonious squad with leader and loyal players yields high chemistry (>75)', () {
      final squad = <Player>[leader, loyalTr, loyalTr.copyWith(id: 'p_loyal2')];
      final chemistry = TeamChemistryCalculator.calculateSquadChemistry(squad);

      expect(chemistry.score, greaterThanOrEqualTo(75));
      expect(chemistry.multiplier, greaterThanOrEqualTo(1.00));
      expect(chemistry.multiplier, lessThanOrEqualTo(1.08));
    });

    test('Conflict squad with multiple rebels and mercenaries incurs penalties', () {
      final conflictSquad = <Player>[
        rebelForeign,
        rebelForeign.copyWith(id: 'p_rebel2', personality: PersonalityType.mercenary),
        rebelForeign.copyWith(id: 'p_rebel3'),
      ];
      final chemistry = TeamChemistryCalculator.calculateSquadChemistry(conflictSquad);

      expect(chemistry.score, lessThan(70));
      expect(chemistry.multiplier, greaterThanOrEqualTo(0.88));
      expect(chemistry.hasPersonalityConflict, isTrue);
    });
  });
}
