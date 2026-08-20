// domain/cards/card_effects.dart
// Pure Dart. Executes decision card option choices and applies changes to game state.

import '../entities/card.dart';
import '../entities/game_state.dart';

class CardEffectRunner {
  /// Karar Kartı Seçimini Uygular
  static GameState applyCardChoice({
    required GameState state,
    required DecisionCard card,
    required CardOption option,
  }) {
    // 1. Metre ve Kasa Değişimlerini Uygula
    final updatedMeters = state.userClub.meters.applyDeltas(
      deltaCash: option.deltaCash,
      deltaFans: option.deltaFans,
      deltaLockerRoom: option.deltaLockerRoom,
      deltaBoardTrust: option.deltaBoardTrust,
    );

    final updatedClub = state.userClub.copyWith(meters: updatedMeters);

    // 2. XP ve Menajer Gelişimi (+15 XP her karar için)
    final updatedManager = state.manager.addXp(15);

    // 3. Hafıza ve Zincir Güncellemeleri
    final updatedRecentCards = [
      card.id,
      ...state.recentCardIds.take(39),
    ];

    final updatedChains = Map<String, int>.from(state.activeChains);
    if (option.nextChainCardId != null) {
      final chainId = option.nextChainCardId!;
      updatedChains[chainId] = (updatedChains[chainId] ?? 0) + 1;
    }

    // 4. Kalan Bekleyen Kartlar
    final remainingCards = state.pendingCards.where((c) => c.id != card.id).toList();

    // 5. Bildirim Günlüğü
    final logMessage = '${card.characterName} (${card.headline}): "${option.text}" seçildi. ${option.resultText}';

    // 6. Kovulma Durumu Kontrolü
    final isGameOver = updatedMeters.isSacked;
    final gameOverReason = isGameOver ? 'Yönetim güveni sıfırlandı. Görevden alındınız!' : null;

    return state.copyWith(
      userClub: updatedClub,
      manager: updatedManager,
      pendingCards: remainingCards,
      recentCardIds: updatedRecentCards,
      activeChains: updatedChains,
      notificationLog: [logMessage, ...state.notificationLog.take(20)],
      isGameOver: isGameOver,
      gameOverReason: gameOverReason,
    );
  }
}
