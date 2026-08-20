// test/domain/card_selector_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/rng/deterministic_rng.dart';
import 'package:futbol/core/time/game_clock.dart';
import 'package:futbol/data/assets/card_database.dart';
import 'package:futbol/domain/cards/card_effects.dart';
import 'package:futbol/domain/cards/card_selector.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/league.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/meter.dart';

void main() {
  group('CardSelector and CardEffectRunner Tests', () {
    late GameState sampleState;

    setUp(() {
      sampleState = const GameState(
        userClub: Club(
          id: 'user_c',
          name: 'Dynasty FC',
          city: 'Angora',
          meters: ClubMeters(cash: 12000, fans: 40, lockerRoom: 35, boardTrust: 50),
        ),
        manager: Manager(name: 'Test Menajer'),
        clock: GameClock(),
        currentLeague: League(
          tier: 20,
          name: '20. Lig',
          clubIds: ['user_c'],
        ),
      );
    });

    test('CardSelector picks 2 valid decision cards from database', () {
      final rng = DeterministicRng(42);
      final picked = CardSelector.pickSessionCards(
        cardDatabase: CardDatabase.mvpCards,
        state: sampleState,
        rng: rng,
        count: 2,
      );

      expect(picked.length, equals(2));
      expect(picked[0].id, isNot(equals(picked[1].id)));
    });

    test('CardEffectRunner applies choice and updates meters and logs', () {
      final card = CardDatabase.mvpCards.first;
      final option = card.options.first;

      final updatedState = CardEffectRunner.applyCardChoice(
        state: sampleState,
        card: card,
        option: option,
      );

      expect(
        updatedState.userClub.meters.cash,
        equals(sampleState.userClub.meters.cash + option.deltaCash),
      );
      expect(
        updatedState.userClub.meters.fans,
        equals((sampleState.userClub.meters.fans + option.deltaFans).clamp(0, 100)),
      );
      expect(updatedState.notificationLog.isNotEmpty, isTrue);
      expect(updatedState.recentCardIds.contains(card.id), isTrue);
    });
  });
}
