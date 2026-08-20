// domain/cards/card_selector.dart
// Pure Dart. Contextual card selection with active chains, category fatigue, novelty bonus, and meter pressure weighting (§12.4 & §12.5).

import '../../core/rng/deterministic_rng.dart';
import '../entities/card.dart';
import '../entities/game_state.dart';

class CardSelector {
  /// Bir Seans İçin Uygun Karar Kartlarını Seçer (§12.4 & §12.5)
  static List<DecisionCard> pickSessionCards({
    required List<DecisionCard> cardDatabase,
    required GameState state,
    required DeterministicRng rng,
    int count = 2,
  }) {
    if (cardDatabase.isEmpty) return [];

    final picked = <DecisionCard>[];

    // 1. AKTİF HİKAYE ZİNCİRLERİ (Story Arcs / Active Chains - D-1)
    if (state.activeChains.isNotEmpty) {
      for (final entry in state.activeChains.entries) {
        final arcId = entry.key;
        final nextStep = entry.value;

        final chainCard = cardDatabase.firstWhere(
          (c) => c.chainArcId == arcId && c.chainStep == nextStep,
          orElse: () => cardDatabase.firstWhere(
            (c) => c.id == arcId,
            orElse: () => const DecisionCard(
              id: '',
              characterName: '',
              characterRole: '',
              characterAvatar: '',
              headline: '',
              storyText: '',
              category: CardCategory.lockerRoom,
              options: [],
            ),
          ),
        );

        if (chainCard.id.isNotEmpty && !picked.any((p) => p.id == chainCard.id)) {
          picked.add(chainCard);
          if (picked.length >= count) return picked;
        }
      }
    }

    // 2. KULLANILABİLİR KART HAVUZU
    final available = cardDatabase.where((c) {
      if (picked.any((p) => p.id == c.id)) return false;
      // Lig Kademesi Uygunluğu
      if (state.userClub.leagueTier < c.minTier || state.userClub.leagueTier > c.maxTier) {
        return false;
      }
      return true;
    }).toList();

    if (available.isEmpty) {
      if (picked.isNotEmpty) return picked;
      return cardDatabase.take(count).toList();
    }

    final pool = List<DecisionCard>.from(available);

    while (picked.length < count && pool.isNotEmpty) {
      final card = rng.weightedPick<DecisionCard>(pool, (c) {
        return _calculateWeight(c, state);
      });
      picked.add(card);
      pool.removeWhere((item) => item.id == card.id);
    }

    return picked;
  }

  /// Kart Ağırlık Formülü (§12.4 & Ek C.6)
  /// kartAğırlığı = taban × kategoriYorgunluğu × bağlamBoost × göstergeBaskısı × yenilikBonusu
  static double _calculateWeight(DecisionCard card, GameState state) {
    var weight = 10.0;

    // 1. Gösterge Baskısı (Meter Pressure)
    if (state.userClub.meters.boardTrust <= 30 &&
        (card.category == CardCategory.board || card.category == CardCategory.crisis)) {
      weight *= 2.8;
    }
    if (state.userClub.meters.cash <= 10000 &&
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
