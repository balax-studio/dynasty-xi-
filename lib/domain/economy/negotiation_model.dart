// domain/economy/negotiation_model.dart
// Pure Dart. Interactive transfer & contract negotiation engine with patience meters, clauses, swap players, and agent kickbacks.

import 'dart:math' as math;
import '../entities/player.dart';

enum NegotiationOutcome {
  accepted,
  counterOffered,
  rejected,
  walkedAway,
}

class TransferOfferClauses {
  final int sellOnPercentage; // 0, 10, 20, 30%
  final int championshipBonus; // e.g. 15000
  final int goalBonus; // e.g. 5000
  final Player? swapPlayer; // Kadrodan takas verilen oyuncu
  final int contractYears; // 1 - 5 yıl
  final int signingBonus; // İmza parası

  const TransferOfferClauses({
    this.sellOnPercentage = 0,
    this.championshipBonus = 0,
    this.goalBonus = 0,
    this.swapPlayer,
    this.contractYears = 3,
    this.signingBonus = 0,
  });

  int get swapPlayerValue => swapPlayer?.marketValue ?? 0;

  Map<String, dynamic> toJson() => {
        'sellOnPercentage': sellOnPercentage,
        'championshipBonus': championshipBonus,
        'goalBonus': goalBonus,
        'swapPlayer': swapPlayer?.toJson(),
        'contractYears': contractYears,
        'signingBonus': signingBonus,
      };

  factory TransferOfferClauses.fromJson(Map<String, dynamic> json) =>
      TransferOfferClauses(
        sellOnPercentage: json['sellOnPercentage'] as int? ?? 0,
        championshipBonus: json['championshipBonus'] as int? ?? 0,
        goalBonus: json['goalBonus'] as int? ?? 0,
        swapPlayer: json['swapPlayer'] != null
            ? Player.fromJson(json['swapPlayer'] as Map<String, dynamic>)
            : null,
        contractYears: json['contractYears'] as int? ?? 3,
        signingBonus: json['signingBonus'] as int? ?? 0,
      );
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
  final TransferOfferClauses clauses;
  final bool hasPaidAgentKickback;

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
    this.clauses = const TransferOfferClauses(),
    this.hasPaidAgentKickback = false,
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
      clauses: const TransferOfferClauses(),
    );
  }

  /// Menajere Gizli Komisyon & Rüşvet Verme Mekaniği
  NegotiationState applyAgentKickback(int kickbackAmount) {
    if (hasPaidAgentKickback) return this;
    final restoredPatience = (currentPatience + 30).clamp(0, 100);
    final discountedWage = (askingWage * 0.82).round();

    return copyWith(
      currentPatience: restoredPatience,
      askingWage: discountedWage,
      hasPaidAgentKickback: true,
      statusMessage:
          ' Menajere ₣$kickbackAmount gizli komisyon ödendi! Menajer oyuncuyu ikna etti, maaş beklentisi kırıldı ve sabır tazelendi (%$restoredPatience).',
    );
  }

  /// Teklif Sunma ve Yanıt Hesaplama — Ek C.7 ve Gelişmiş Maddeler
  NegotiationState submitOffer({
    required int offeredFee,
    required int offeredWage,
    bool includeSellOnClause = false,
    TransferOfferClauses? clauses,
  }) {
    final activeClauses = clauses ??
        (includeSellOnClause
            ? const TransferOfferClauses(sellOnPercentage: 20)
            : this.clauses);

    final effectiveOfferedFee = offeredFee + activeClauses.swapPlayerValue;
    final feeRatio = effectiveOfferedFee / math.max(1, askingFee);
    final wageRatio = offeredWage / math.max(1, askingWage);
    final averageRatio = (feeRatio * 0.55 + wageRatio * 0.45);

    // Clause bonusları
    double clauseBonus = 0.0;
    if (activeClauses.sellOnPercentage > 0) {
      clauseBonus += (activeClauses.sellOnPercentage / 100.0) * 0.20;
    }
    if (activeClauses.championshipBonus > 0) clauseBonus += 0.05;
    if (activeClauses.goalBonus > 0) clauseBonus += 0.04;
    if (activeClauses.signingBonus > 0) clauseBonus += 0.06;
    if (activeClauses.swapPlayer != null) clauseBonus += 0.05;

    final totalRatio = averageRatio + clauseBonus;

    // Kabul Olasılığı: clamp((teklif/istenen)^2.4, 0.02, 0.97)
    final acceptChance = math.pow(totalRatio, 2.4).toDouble().clamp(0.02, 0.97);

    // Sabır Düşüşü: (1 - teklif/istenen) * 40
    final patienceLoss = math.max(4, ((1.0 - math.min(1.0, totalRatio)) * 40).round());
    final nextPatience = math.max(0, currentPatience - patienceLoss);

    if (totalRatio >= 0.95 || acceptChance > 0.82) {
      return copyWith(
        lastOfferedFee: offeredFee,
        lastOfferedWage: offeredWage,
        roundsPassed: roundsPassed + 1,
        clauses: activeClauses,
        outcome: NegotiationOutcome.accepted,
        statusMessage: '[KUTLAMA] Anlaşma sağlandı! Kulüp ve futbolcu tüm transfer maddelerini onayladı.',
      );
    }

    if (nextPatience <= 0) {
      return copyWith(
        lastOfferedFee: offeredFee,
        lastOfferedWage: offeredWage,
        currentPatience: 0,
        roundsPassed: roundsPassed + 1,
        clauses: activeClauses,
        outcome: NegotiationOutcome.walkedAway,
        statusMessage: ' Karşı taraf masadan kalktı! Teklifleriniz ciddiyetsiz bulundu ve görüşmeler çöktü.',
      );
    }

    // Karşı Teklif Üretimi
    final newAskingFee = math.max(
      offeredFee,
      (askingFee - (askingFee - effectiveOfferedFee) * 0.38).round(),
    );
    final newAskingWage = math.max(
      offeredWage,
      (askingWage - (askingWage - offeredWage) * 0.32).round(),
    );

    return copyWith(
      askingFee: newAskingFee,
      askingWage: newAskingWage,
      lastOfferedFee: offeredFee,
      lastOfferedWage: offeredWage,
      currentPatience: nextPatience,
      roundsPassed: roundsPassed + 1,
      clauses: activeClauses,
      outcome: NegotiationOutcome.counterOffered,
      statusMessage:
          '[MESAJ] Karşı taraf yeni bir teklifle döndü. Sabır: %$nextPatience. İstek: ₣${newAskingFee.toString()} bonservis, ₣${newAskingWage.toString()} maaş.',
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
    TransferOfferClauses? clauses,
    bool? hasPaidAgentKickback,
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
      clauses: clauses ?? this.clauses,
      hasPaidAgentKickback: hasPaidAgentKickback ?? this.hasPaidAgentKickback,
    );
  }
}
