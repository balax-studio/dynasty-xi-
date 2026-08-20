// test/domain/player_presidential_features_test.dart
// Unit tests for Player presidential attributes, factions, coach chemistry, bonuses, and disciplinary fines.

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/local/save_repository.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/application/providers/game_state_provider.dart';

class FakeSaveRepository extends SaveRepository {
  GameState? inMemoryState;

  @override
  Future<void> save(GameState state) async {
    inMemoryState = state;
  }

  @override
  Future<GameState?> load() async {
    return inMemoryState;
  }

  @override
  Future<int?> getLastExitEpochMs() async {
    return null;
  }
}

void main() {
  group('Player Presidential Features & Domain Tests', () {
    late Player testPlayer;

    setUp(() {
      testPlayer = const Player(
        id: 'p_101',
        firstName: 'Alex',
        lastName: 'De Souza',
        countryCode: 'BR',
        age: 28,
        position: Position.am,
        pace: 78,
        technique: 94,
        shooting: 88,
        passing: 95,
        defending: 45,
        physical: 72,
        mentality: 90,
        potential: 96,
        personality: PersonalityType.leader,
        weeklyWage: 25000,
        jerseyNumber: 10,
        faction: LockerRoomFaction.foreignLegion,
      );
    });

    test('Player defaults and presidential fields initialized correctly', () {
      expect(testPlayer.jerseyNumber, 10);
      expect(testPlayer.faction, LockerRoomFaction.foreignLegion);
      expect(testPlayer.matchBonusOffered, 0);
      expect(testPlayer.hasLuxuryGift, isFalse);
      expect(testPlayer.disciplinaryFinesCount, 0);
      expect(testPlayer.loyaltyBonus, 0);
      expect(testPlayer.goalBonus, 0);
      expect(testPlayer.cleanSheetBonus, 0);
    });

    test('getCoachChemistry correctly evaluates compatibility based on tactical style', () {
      // Ofansif style suits AM / Leader
      final offensiveChem = testPlayer.getCoachChemistry('Ofansif');
      expect(offensiveChem, greaterThanOrEqualTo(85));

      // Defansif style has lower bonus for AM
      final defensiveChem = testPlayer.getCoachChemistry('Defansif');
      expect(defensiveChem, lessThan(offensiveChem));
    });

    test('Player serialization handles new fields cleanly', () {
      final json = testPlayer.toJson();
      expect(json['jerseyNumber'], 10);
      expect(json['faction'], 'foreignLegion');
      expect(json['hasLuxuryGift'], false);

      final deserialized = Player.fromJson(json);
      expect(deserialized.id, testPlayer.id);
      expect(deserialized.jerseyNumber, 10);
      expect(deserialized.faction, LockerRoomFaction.foreignLegion);
      expect(deserialized.technique, 94);
    });

    test('GameStateNotifier gives presidential bonus and luxury gift', () async {
      final initialClub = Club(
        id: 'club_1',
        name: 'Fenerbahçe',
        city: 'İstanbul',
        meters: const ClubMeters(cash: 50000, fans: 80, lockerRoom: 80, boardTrust: 80),
        squad: [testPlayer],
      );

      final fakeRepo = FakeSaveRepository();
      fakeRepo.inMemoryState = GameState(
        userClub: initialClub,
        manager: const Manager(name: 'Başkan'),
      );

      final notifier = GameStateNotifier(fakeRepo);
      // Wait for notifier._init() to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // 1. Prim vaat et (₣5.000)
      final bonusOk = await notifier.givePresidentialBonus(testPlayer.id, 5000, false);
      expect(bonusOk, isTrue);

      var state = notifier.currentState!;
      var updatedPlayer = state.userClub.squad.first;
      expect(updatedPlayer.matchBonusOffered, 5000);
      expect(updatedPlayer.morale, greaterThan(testPlayer.morale));
      expect(state.userClub.meters.cash, 45000);

      // 2. Lüks Hediye Sun (₣7.500)
      final giftOk = await notifier.givePresidentialBonus(testPlayer.id, 7500, true);
      expect(giftOk, isTrue);

      state = notifier.currentState!;
      updatedPlayer = state.userClub.squad.first;
      expect(updatedPlayer.hasLuxuryGift, isTrue);
      expect(state.userClub.meters.cash, 37500);

      // 3. Sırt Numarası Ata (#10 -> #7)
      await notifier.assignJerseyNumber(testPlayer.id, 7);
      state = notifier.currentState!;
      updatedPlayer = state.userClub.squad.first;
      expect(updatedPlayer.jerseyNumber, 7);

      // 4. Disiplin Cezası Kes
      final fineOk = await notifier.finePlayer(testPlayer.id, 2000);
      expect(fineOk, isTrue);
      state = notifier.currentState!;
      updatedPlayer = state.userClub.squad.first;
      expect(updatedPlayer.disciplinaryFinesCount, 1);
      expect(state.userClub.meters.cash, 39500); // 37500 + 2000
    });
  });
}
