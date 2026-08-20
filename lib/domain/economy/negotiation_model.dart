// domain/economy/negotiation_model.dart
// Pure Dart. Interactive transfer & contract negotiation engine with patience meters and clauses.

import 'dart:math' as math;
import '../entities/player.dart';

enum NegotiationOutcome {
  accepted,
  counterOffered,
  rejected,
  walkedAway,
}

class NegotiationState {
  final Player targetPlayer;
  final int askingFee;
  final int askingWage;
  final int currentPatience; // 0 - 100
  final int roundsPassed;
  final int lastOfferedFee;
  final int lastOfferedWage;
  final NegotiationOutcome outcome;
  final String statusMessage;

  const NegotiationState({
    required this.targetPlayer,
    required this.askingFee,
    required this.askingWage,
    this.currentPatience = 100,
    this.roundsPassed = 0,
    this.lastOfferedFee = 0,
    this.lastOfferedWage = 0,
    this.outcome = NegotiationOutcome.counterOffered,
    this.statusMessage = 'Görüşmeler başladı. Karşı taraf teklifinizi bekliyor.',
  });

  bool get isCompleted =>
      outcome == NegotiationOutcome.accepted || outcome == NegotiationOutcome.walkedAway;

  bool get isTerminated => isCompleted;

  factory NegotiationState.start({
    required Player player,
    bool hasPersuaderPerk = false,
  }) {
    var baseFee = player.marketValue;
    if (hasPersuaderPerk) {
      baseFee = (baseFee * 0.90).round();
    }
    final baseWage = (player.marketValue * 0.0038).round().clamp(150, 250000);

    return NegotiationState(
      targetPlayer: player,
      askingFee: baseFee,
      askingWage: baseWage,
      currentPatience: 100,
      roundsPassed: 0,
      lastOfferedFee: (baseFee * 0.85).round(),
      lastOfferedWage: baseWage,
      outcome: NegotiationOutcome.counterOffered,
    );
  }

  /// Teklif Sunma ve Yanıt Hesaplama — Ek C.7
  NegotiationState submitOffer({
    required int offeredFee,
    required int offeredWage,
    bool includeSellOnClause = false,
  }) {
    final feeRatio = offeredFee / math.max(1, askingFee);
    final wageRatio = offeredWage / math.max(1, askingWage);
    final averageRatio = (feeRatio * 0.6 + wageRatio * 0.4);

    // Clause bonusu
    final clauseBonus = includeSellOnClause ? 0.08 : 0.0;
    final totalRatio = averageRatio + clauseBonus;

    // Kabul Olasılığı: clamp((teklif/istenen)^2.4, 0.02, 0.97)
    final acceptChance = math.pow(totalRatio, 2.4).toDouble().clamp(0.02, 0.97);

    // Sabır Düşüşü: (1 - teklif/istenen) * 45
    final patienceLoss = math.max(5, ((1.0 - totalRatio) * 45).round());
    final nextPatience = math.max(0, currentPatience - patienceLoss);

    if (totalRatio >= 0.98 || acceptChance > 0.85) {
      return copyWith(
        lastOfferedFee: offeredFee,
        lastOfferedWage: offeredWage,
        roundsPassed: roundsPassed + 1,
        outcome: NegotiationOutcome.accepted,
        statusMessage: 'Anlaşma sağlandı! Kulüp ve oyuncu şartları kabul etti.',
      );
    }

    if (nextPatience <= 0) {
      return copyWith(
        lastOfferedFee: offeredFee,
        lastOfferedWage: offeredWage,
        currentPatience: 0,
        roundsPassed: roundsPassed + 1,
        outcome: NegotiationOutcome.walkedAway,
        statusMessage: 'Karşı taraf masadan kalktı! Teklifleriniz ciddiyetsiz bulundu.',
      );
    }

    // Karşı Teklif Üretimi
    final newAskingFee = math.max(
      offeredFee,
      (askingFee - (askingFee - offeredFee) * 0.40).round(),
    );
    final newAskingWage = math.max(
      offeredWage,
      (askingWage - (askingWage - offeredWage) * 0.35).round(),
    );

    return copyWith(
      askingFee: newAskingFee,
      askingWage: newAskingWage,
      lastOfferedFee: offeredFee,
      lastOfferedWage: offeredWage,
      currentPatience: nextPatience,
      roundsPassed: roundsPassed + 1,
      outcome: NegotiationOutcome.counterOffered,
      statusMessage:
          'Karşı taraf yeni bir teklifle döndü. Sabır: %$nextPatience. İstek: ₣${newAskingFee.toString()} bonservis, ₣${newAskingWage.toString()} maaş.',
    );
  }

  NegotiationState copyWith({
    Player? targetPlayer,
    int? askingFee,
    int? askingWage,
    int? currentPatience,
    int? roundsPassed,
    int? lastOfferedFee,
    int? lastOfferedWage,
    NegotiationOutcome? outcome,
    String? statusMessage,
  }) {
    return NegotiationState(
      targetPlayer: targetPlayer ?? this.targetPlayer,
      askingFee: askingFee ?? this.askingFee,
      askingWage: askingWage ?? this.askingWage,
      currentPatience: currentPatience ?? this.currentPatience,
      roundsPassed: roundsPassed ?? this.roundsPassed,
      lastOfferedFee: lastOfferedFee ?? this.lastOfferedFee,
      lastOfferedWage: lastOfferedWage ?? this.lastOfferedWage,
      outcome: outcome ?? this.outcome,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
