// test/domain/crisis_trigger_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/time/game_clock.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/president/crisis_trigger_engine.dart';

void main() {
  group('CrisisTriggerEngine Tests', () {
    const defaultMeters = ClubMeters(
      cash: 50000,
      fans: 70,
      boardTrust: 75,
      lockerRoom: 75,
    );

    const defaultClub = Club(
      id: 'angora',
      name: 'Angora Gücü',
      city: 'Ankara',
      meters: defaultMeters,
    );

    const defaultManager = Manager(name: 'Başkan');

    test('returns null when club is in normal stable state', () {
      const state = GameState(
        userClub: defaultClub,
        manager: defaultManager,
        clock: GameClock(matchday: 4),
      );

      final crisis = CrisisTriggerEngine.evaluateCrisis(state);
      expect(crisis, isNull);
    });

    test('triggers financial insolvency crisis when cash < 15,000', () {
      final state = const GameState(
        userClub: defaultClub,
        manager: defaultManager,
        clock: GameClock(matchday: 4),
      ).copyWith(
        userClub: defaultClub.copyWith(
          meters: defaultMeters.copyWith(cash: 8000),
        ),
      );

      final crisis = CrisisTriggerEngine.evaluateCrisis(state);
      expect(crisis, isNotNull);
      expect(crisis!.id, 'financial_insolvency_call');
      expect(crisis.choices.length, 3);
    });

    test('triggers board no-confidence crisis when board trust < 40', () {
      final state = const GameState(
        userClub: defaultClub,
        manager: defaultManager,
        clock: GameClock(matchday: 4),
      ).copyWith(
        userClub: defaultClub.copyWith(
          meters: defaultMeters.copyWith(boardTrust: 32),
        ),
      );

      final crisis = CrisisTriggerEngine.evaluateCrisis(state);
      expect(crisis, isNotNull);
      expect(crisis!.id, 'board_no_confidence_call');
    });

    test('triggers ultra rebellion crisis when fans satisfaction < 35', () {
      final state = const GameState(
        userClub: defaultClub,
        manager: defaultManager,
        clock: GameClock(matchday: 4),
      ).copyWith(
        userClub: defaultClub.copyWith(
          meters: defaultMeters.copyWith(fans: 25),
        ),
      );

      final crisis = CrisisTriggerEngine.evaluateCrisis(state);
      expect(crisis, isNotNull);
      expect(crisis!.id, 'ultra_rebellion_call');
    });

    test('triggers locker rebellion crisis when locker room morale < 35', () {
      final state = const GameState(
        userClub: defaultClub,
        manager: defaultManager,
        clock: GameClock(matchday: 4),
      ).copyWith(
        userClub: defaultClub.copyWith(
          meters: defaultMeters.copyWith(lockerRoom: 28),
        ),
      );

      final crisis = CrisisTriggerEngine.evaluateCrisis(state);
      expect(crisis, isNotNull);
      expect(crisis!.id, 'locker_rebellion_call');
    });

    test('triggers TFF referee scandal on milestone matchdays (week 7 or 14)', () {
      const state = GameState(
        userClub: defaultClub,
        manager: defaultManager,
        clock: GameClock(matchday: 7),
      );

      final crisis = CrisisTriggerEngine.evaluateCrisis(state);
      expect(crisis, isNotNull);
      expect(crisis!.id, 'tff_referee_scandal');
    });
  });
}
