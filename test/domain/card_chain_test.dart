// test/domain/card_chain_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/rng/deterministic_rng.dart';
import 'package:futbol/data/assets/card_database.dart';
import 'package:futbol/data/local/save_repository.dart';
import 'package:futbol/domain/cards/card_selector.dart';
import 'package:futbol/domain/entities/card.dart';

void main() {
  group('CardSelector & Narrative Chains (§12.4)', () {
    test('Criterion #20: Active narrative chain prioritizes next step card', () {
      final state = SaveRepository.createNewGame().copyWith(
        activeChains: {'arc_star_unhappy': 1},
      );

      const chainCard = DecisionCard(
        id: 'star_unhappy_step_1',
        chainArcId: 'arc_star_unhappy',
        chainStep: 1,
        characterName: 'Osman Yalçın',
        characterRole: 'Kaptan',
        characterAvatar: '⭐',
        headline: 'Kaptanın Resti',
        storyText: '"Hocam zam vermedin, antrenmana çıkmıyorum."',
        category: CardCategory.lockerRoom,
        options: [
          CardOption(id: 'opt1', text: 'Özür dile ve öde', resultText: 'Ödendi'),
          CardOption(id: 'opt2', text: 'Kadro dışı bırak', resultText: 'Kadro dışı'),
        ],
      );

      final rng = DeterministicRng(12345);
      final picked = CardSelector.pickSessionCards(
        cardDatabase: [chainCard, ...CardDatabase.mvpCards],
        state: state,
        rng: rng,
        count: 2,
      );

      expect(picked.any((c) => c.id == 'star_unhappy_step_1'), isTrue);
    });
  });
}
