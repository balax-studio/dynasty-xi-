import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/assets/card_database.dart';
import 'package:futbol/domain/cards/card_effects.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/meter.dart';

void main() {
  group('50-Card Database and Narrative Chain Tests', () {
    test('CardDatabase contains at least 50 cards across all 10 categories', () {
      final cards = CardDatabase.allCards;
      expect(cards.length, greaterThanOrEqualTo(50));

      final categories = cards.map((c) => c.category).toSet();
      expect(categories.length, greaterThanOrEqualTo(6));
    });

    test('Narrative chain starts and tracks step progression upon choice', () {
      final card = CardDatabase.allCards.firstWhere((c) => c.id == 'kadro_yildiz_zam');
      final rejectOpt = card.options.firstWhere((o) => o.id == 'opt_star_reject');

      const initialState = GameState(
        userClub: Club(
          id: 'user_c',
          name: 'Test Club',
          city: 'Angora',
          meters: ClubMeters(cash: 50000, fans: 50, lockerRoom: 50, boardTrust: 50),
        ),
        manager: Manager(name: 'Hoca'),
      );

      final updatedState = CardEffectRunner.applyCardChoice(
        state: initialState,
        card: card,
        option: rejectOpt,
      );

      expect(updatedState.activeChains.containsKey('star_unhappy_arc'), isTrue);
      expect(updatedState.activeChains['star_unhappy_arc'], equals(1));
    });
  });
}
