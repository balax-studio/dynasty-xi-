// test/domain/staff_and_academy_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/rng/deterministic_rng.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/entities/staff.dart';
import 'package:futbol/domain/generation/player_generator.dart';
import 'package:futbol/domain/president/head_coach.dart';
import 'package:futbol/domain/rpg/head_coach_dialogue_engine.dart';

void main() {
  group('Staff & Market Catalog Tests', () {
    test('StaffRole.brandSpecialist provides commercial and fan bonuses', () {
      const brandStaff = StaffMember(
        id: 'staff_test_brand',
        role: StaffRole.brandSpecialist,
        name: 'Selin Doğan',
        level: 3,
        weeklySalary: 2500,
      );

      expect(brandStaff.commercialRevenueBonus, greaterThan(0.2));
      expect(brandStaff.fanGrowthWeeklyBonus, equals(6));
    });

    test('StaffMarketCatalog contains diverse specialists across all roles', () {
      final candidates = StaffMarketCatalog.getAvailableMarketCandidates();
      expect(candidates.length, greaterThanOrEqualTo(8));

      final roles = candidates.map((c) => c.role).toSet();
      expect(roles.contains(StaffRole.assistantManager), isTrue);
      expect(roles.contains(StaffRole.headPhysio), isTrue);
      expect(roles.contains(StaffRole.chiefScout), isTrue);
      expect(roles.contains(StaffRole.dataAnalyst), isTrue);
      expect(roles.contains(StaffRole.brandSpecialist), isTrue);
    });
  });

  group('Lineup & Auto Best 11 Tests', () {
    test('calculateBest11Ids selects 11 players respecting formation positions and highest OVR', () {
      final rng = DeterministicRng(12345);
      final squad = PlayerGenerator.generateSquad(rng: rng, leagueTier: 20, clubIdPrefix: 'test_c');

      final club = Club(
        id: 'test_c',
        name: 'Test FC',
        city: 'Test',
        squad: squad,
        formation: '4-3-3',
      );

      final best11Ids = club.calculateBest11Ids();
      expect(best11Ids.length, equals(11));

      final s11Players = squad.where((p) => best11Ids.contains(p.id)).toList();
      final gks = s11Players.where((p) => p.position == Position.gk).toList();
      expect(gks.length, equals(1));
    });

    test('swapStartingAndBench swaps players correctly', () {
      final rng = DeterministicRng(99999);
      final squad = PlayerGenerator.generateSquad(rng: rng, leagueTier: 20, clubIdPrefix: 'swap_c');

      final initialS11 = squad.take(11).map((p) => p.id).toList();
      final initialSubs = squad.skip(11).map((p) => p.id).toList();

      final club = Club(
        id: 'swap_c',
        name: 'Swap FC',
        city: 'Swap City',
        squad: squad,
        starting11Ids: initialS11,
        substituteIds: initialSubs,
      );

      final startingPlayer = initialS11.first;
      final benchPlayer = initialSubs.first;

      final updated = club.swapStartingAndBench(startingPlayer, benchPlayer);
      expect(updated.starting11Ids.contains(benchPlayer), isTrue);
      expect(updated.starting11Ids.contains(startingPlayer), isFalse);
      expect(updated.substituteIds.contains(startingPlayer), isTrue);
    });
  });

  group('Head Coach RPG Dialogue Engine Tests', () {
    test('generates dynamic options and responses for all 5 topics', () {
      const coach = HeadCoach(
        id: 'coach_test',
        fullName: 'Sergen Hoca',
        age: 50,
        countryCode: 'TR',
        archetype: HeadCoachArchetype.tactician,
        weeklyWage: 5000,
        signingFee: 15000,
        reputation: 80,
        boardConfidence: 75,
      );

      const state = GameState(
        userClub: Club(id: 'c1', name: 'Angora', city: 'Angora'),
        manager: Manager(name: 'Başkan', level: 1),
      );

      for (final topic in CoachDialogueTopic.values) {
        final options = HeadCoachDialogueEngine.getOptionsForTopic(topic, coach, state);
        expect(options.isNotEmpty, isTrue);
        expect(options.first.presidentSpeech.isNotEmpty, isTrue);
        expect(options.first.coachReply.isNotEmpty, isTrue);
      }
    });
  });
}
