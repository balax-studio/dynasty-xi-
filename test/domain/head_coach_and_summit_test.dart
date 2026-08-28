// test/domain/head_coach_and_summit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/president/head_coach.dart';
import 'package:futbol/domain/president/boardroom_summit.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/manager.dart';

void main() {
  group('HeadCoach & President RPG Logic Tests', () {
    test('HeadCoach serialization and copyWith works accurately', () {
      const coach = HeadCoach(
        id: 'coach_test_1',
        fullName: 'Sergen Hoca',
        archetype: HeadCoachArchetype.tactician,
        tacticalStyle: '4-2-3-1 Hücum',
        weeklyWage: 1200,
        signingFee: 4000,
        reputation: 75,
        boardConfidence: 80,
        matchesManaged: 14,
        activeVision: CoachVision.attacking,
        countryCode: ' TR',
        age: 51,
      );

      final json = coach.toJson();
      final restored = HeadCoach.fromJson(json);

      expect(restored.id, 'coach_test_1');
      expect(restored.fullName, 'Sergen Hoca');
      expect(restored.archetype, HeadCoachArchetype.tactician);
      expect(restored.activeVision, CoachVision.attacking);
      expect(restored.severancePay, 1200 * 6);

      final updated = restored.copyWith(activeVision: CoachVision.championship, matchesManaged: 15);
      expect(updated.activeVision, CoachVision.championship);
      expect(updated.matchesManaged, 15);
    });

    test('HeadCoachCatalog provides distinct archetype candidates', () {
      final candidates = HeadCoachCatalog.getCandidateCoaches();
      expect(candidates.length, 4);
      expect(candidates.any((c) => c.archetype == HeadCoachArchetype.tactician), isTrue);
      expect(candidates.any((c) => c.archetype == HeadCoachArchetype.starName), isTrue);
      expect(candidates.any((c) => c.archetype == HeadCoachArchetype.youthDeveloper), isTrue);
      expect(candidates.any((c) => c.archetype == HeadCoachArchetype.disciplinarian), isTrue);
    });

    test('BoardroomCatalog VipBox and Capital Injections work accurately', () {
      final vipBoxes = BoardroomCatalog.getInitialVipBoxes();
      expect(vipBoxes.length, 4);
      expect(vipBoxes.first.isSold, isFalse);

      final sold = vipBoxes.first.copyWith(isSold: true);
      expect(sold.isSold, isTrue);
      expect(sold.seasonPrice, greaterThan(0));

      final injections = BoardroomCatalog.getCapitalInjections();
      expect(injections.length, 3);
      expect(injections.first.cashAmount, 50000);
      expect(injections.last.cashAmount, 300000);
    });

    test('GameState carries headCoach and vipBoxDeals accurately through json serialization', () {
      const club = Club(
        id: 'c1',
        name: 'Kadıköy FK',
        city: 'İstanbul',
        leagueTier: 20,
        meters: ClubMeters(cash: 100000, fans: 50, lockerRoom: 50, boardTrust: 65),
      );

      final coach = HeadCoachCatalog.getCandidateCoaches().first;
      final boxes = BoardroomCatalog.getInitialVipBoxes();

      final state = GameState(
        userClub: club,
        manager: const Manager(),
        headCoach: coach,
        vipBoxDeals: boxes,
      );

      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.headCoach, isNotNull);
      expect(restored.headCoach!.fullName, coach.fullName);
      expect(restored.vipBoxDeals.length, 4);
    });
  });
}
