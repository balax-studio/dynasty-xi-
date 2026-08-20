// test/domain/player_rpg_test.dart
// Unit tests for Player RPG Depth (§9.4, §9.5, §9.6, §10.6, §10.7)

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';

void main() {
  group('Sprint 1: Player RPG & Squad Depth Tests', () {
    test('Player has extended personality types and attributes', () {
      const player = Player(
        id: 'p1',
        firstName: 'Kerem',
        lastName: 'Aktürkoğlu',
        countryCode: 'TR',
        age: 25,
        position: Position.lw,
        pace: 88,
        technique: 82,
        shooting: 78,
        passing: 75,
        defending: 40,
        physical: 70,
        mentality: 80,
        potential: 86,
        personality: PersonalityType.ambitious,
        weeklyWage: 2500,
        trainingIntensity: TrainingIntensity.intensive,
        squadRole: SquadRole.star,
        isCaptain: false,
        loyalty: 85,
        altPositions: [Position.rw, Position.am],
      );

      expect(player.personality, equals(PersonalityType.ambitious));
      expect(player.trainingIntensity, equals(TrainingIntensity.intensive));
      expect(player.squadRole, equals(SquadRole.star));
      expect(player.isCaptain, isFalse);
      expect(player.loyalty, equals(85));
      expect(player.altPositions, contains(Position.rw));
      expect(player.altPositions, contains(Position.am));
    });

    test('TrainingIntensity correctly provides growth multiplier and injury risk multiplier', () {
      expect(TrainingIntensity.light.growthMultiplier, lessThan(1.0));
      expect(TrainingIntensity.light.injuryRiskMultiplier, lessThan(1.0));

      expect(TrainingIntensity.normal.growthMultiplier, equals(1.0));
      expect(TrainingIntensity.normal.injuryRiskMultiplier, equals(1.0));

      expect(TrainingIntensity.intensive.growthMultiplier, greaterThan(1.0));
      expect(TrainingIntensity.intensive.injuryRiskMultiplier, greaterThan(1.0));
    });

    test('SquadRole defines expectation and role satisfaction', () {
      const star = Player(
        id: 'p_star',
        firstName: 'Mauro',
        lastName: 'Icardi',
        countryCode: 'AR',
        age: 31,
        position: Position.st,
        pace: 75,
        technique: 84,
        shooting: 88,
        passing: 72,
        defending: 35,
        physical: 78,
        mentality: 85,
        potential: 88,
        weeklyWage: 15000,
        squadRole: SquadRole.star,
        appearances: 0,
        morale: 30,
      );

      // Star player not playing enough develops transfer request tendency
      expect(star.wantsTransfer, isTrue);
      expect(star.naturalLanguageSummary, isNotEmpty);
    });

    test('Captaincy and Personality affect Team Chemistry', () {
      const captain = Player(
        id: 'p_cap',
        firstName: 'Fernando',
        lastName: 'Muslera',
        countryCode: 'UY',
        age: 38,
        position: Position.gk,
        pace: 50,
        technique: 60,
        shooting: 20,
        passing: 68,
        defending: 82,
        physical: 74,
        mentality: 92,
        potential: 85,
        personality: PersonalityType.leader,
        weeklyWage: 8000,
        isCaptain: true,
      );

      const rebel = Player(
        id: 'p_reb',
        firstName: 'Mario',
        lastName: 'Balotelli',
        countryCode: 'IT',
        age: 33,
        position: Position.st,
        pace: 78,
        technique: 83,
        shooting: 84,
        passing: 70,
        defending: 30,
        physical: 82,
        mentality: 50,
        potential: 86,
        personality: PersonalityType.rebel,
        weeklyWage: 7000,
      );

      // Leader captain provides locker room stability
      expect(captain.isCaptain, isTrue);
      expect(captain.personality.isLockerRoomLeader, isTrue);
      expect(rebel.personality.isHighMaintenance, isTrue);
    });

    test('Contract renewal evaluation logic accepts fair offers and updates loyalty', () {
      const player = Player(
        id: 'p1',
        firstName: 'Arda',
        lastName: 'Güler',
        countryCode: 'TR',
        age: 19,
        position: Position.am,
        pace: 78,
        technique: 88,
        shooting: 80,
        passing: 86,
        defending: 45,
        physical: 62,
        mentality: 84,
        potential: 92,
        personality: PersonalityType.ambitious,
        weeklyWage: 3000,
        contractSeasonsLeft: 1,
        loyalty: 70,
      );

      // Evaluate contract extension offer
      final offerAcceptance = player.evaluateContractOffer(
        offeredWeeklyWage: 6000,
        seasons: 3,
        signingBonus: 10000,
        promisedRole: SquadRole.star,
      );

      expect(offerAcceptance.accepted, isTrue);
      expect(offerAcceptance.moraleDelta, greaterThanOrEqualTo(0));

      final unfairOffer = player.evaluateContractOffer(
        offeredWeeklyWage: 1500, // less than current wage
        seasons: 4,
        signingBonus: 0,
        promisedRole: SquadRole.bench,
      );

      expect(unfairOffer.accepted, isFalse);
    });

    test('Detailed injury severity and recovery mechanics', () {
      const player = Player(
        id: 'p_inj',
        firstName: 'Cenk',
        lastName: 'Tosun',
        countryCode: 'TR',
        age: 32,
        position: Position.st,
        pace: 68,
        technique: 75,
        shooting: 80,
        passing: 65,
        defending: 38,
        physical: 72,
        mentality: 78,
        potential: 80,
        weeklyWage: 4000,
        injuryMatchesLeft: 3,
        injuryType: 'Diz Bağ Esnemesi',
        injurySeverity: InjurySeverity.moderate,
      );

      expect(player.isInjured, isTrue);
      expect(player.injurySeverity, equals(InjurySeverity.moderate));
      expect(player.injuryDescription, contains('Diz Bağ Esnemesi'));
    });
  });
}
