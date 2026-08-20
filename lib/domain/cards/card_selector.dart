// domain/cards/card_selector.dart
// Pure Dart. Contextual card selection with category fatigue, novelty bonus, and meter pressure weighting.

import '../../core/rng/deterministic_rng.dart';
import '../entities/card.dart';
import '../entities/game_state.dart';

class CardSelector {
  /// Bir Seans İçin 2 Adet Uygun Karar Kartı Seçer — Ek C.6
  static List<DecisionCard> pickSessionCards({
    required List<DecisionCard> cardDatabase,
    required GameState state,
    required DeterministicRng rng,
    int count = 2,
  }) {
    if (cardDatabase.isEmpty) return [];

    final available = cardDatabase.where((c) {
      // 1. Lig Kademesi Uygunluğu
      if (state.userClub.leagueTier < c.minTier || state.userClub.leagueTier > c.maxTier) {
        return false;
      }
      return true;
    }).toList();

    if (available.isEmpty) return cardDatabase.take(count).toList();

    final picked = <DecisionCard>[];
    final pool = List<DecisionCard>.from(available);

    for (var i = 0; i < count && pool.isNotEmpty; i++) {
      final card = rng.weightedPick<DecisionCard>(pool, (c) {
        return _calculateWeight(c, state);
      });
      picked.add(card);
      pool.removeWhere((item) => item.id == card.id);
    }

    return picked;
  }

  /// Kart Ağırlık Formülü — Ek C.6
  /// kartAğırlığı = taban × kategoriYorgunluğu × bağlamBoost × göstergeBaskısı × yenilikBonusu
  static double _calculateWeight(DecisionCard card, GameState state) {
    var weight = 10.0;

    // 1. Gösterge Baskısı (Meter Pressure)
    if (state.userClub.meters.boardTrust <= 30 &&
        (card.category == CardCategory.board || card.category == CardCategory.crisis)) {
      weight *= 2.8;
    }
    if (state.userClub.meters.cash <= 8000 &&
        (card.category == CardCategory.finance || card.category == CardCategory.sponsor)) {
      weight *= 2.5;
    }
    if (state.userClub.meters.lockerRoom <= 35 &&
        (card.category == CardCategory.lockerRoom || card.category == CardCategory.press)) {
      weight *= 2.2;
    }
    if (state.userClub.meters.fans <= 35 && card.category == CardCategory.fans) {
      weight *= 2.2;
    }

    // 2. Yenilik Bonusu (Novelty Bonus)
    final seenCount = state.recentCardIds.where((id) => id == card.id).length;
    if (seenCount == 0) {
      weight *= 1.9;
    } else if (seenCount == 1) {
      weight *= 1.3;
    } else {
      weight *= 0.7;
    }

    // 3. Kategori Yorgunluğu
    if (state.recentCardIds.isNotEmpty) {
      final lastId = state.recentCardIds.last;
      if (lastId.contains(card.category.name)) {
        weight *= 0.35;
      }
    }

    return weight.clamp(0.5, 150.0);
  }
}
