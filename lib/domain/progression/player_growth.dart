// domain/progression/player_growth.dart
// Pure Dart. Player seasonal progression, training improvements and age decay models.

import 'dart:math' as math;
import '../entities/player.dart';

import '../entities/position_weights.dart';

class PlayerGrowth {
  /// Sezon Sonu / Antrenman Gelişim Hesabı — §9.3
  static Player applyTrainingGrowth({
    required Player player,
    required int trainingFacilityLevel,
    double randomFactor = 1.0,
  }) {
    if (player.isInjured) {
      return player.copyWith(
        injuryMatchesLeft: math.max(0, player.injuryMatchesLeft - 1),
      );
    }

    final currentOvr = player.ovr;
    final potential = player.potential;

    // Yaş Çarpanı (§9.3)
    double ageFactor;
    if (player.age <= 19) {
      ageFactor = 1.6;
    } else if (player.age <= 23) {
      ageFactor = 1.3;
    } else if (player.age <= 27) {
      ageFactor = 0.6;
    } else if (player.age <= 31) {
      ageFactor = -0.25;
    } else {
      ageFactor = -0.80;
    }

    // Tesis Çarpanı (1.0 - 1.48)
    final facilityFactor = 1.0 + (trainingFacilityLevel - 1) * 0.12;

    // Moral Çarpanı (0.80 - 1.15)
    final moraleFactor = (player.morale / 85.0).clamp(0.80, 1.15);

    // Oynama Süresi Çarpanı (Daha çok maça çıkan daha çok gelişir)
    final appearancesFactor = player.appearances >= 12
        ? 1.30
        : (player.appearances >= 6 ? 1.05 : (player.appearances >= 1 ? 0.85 : 0.60));

    final growthPoints = ((potential - currentOvr) *
            0.18 *
            ageFactor *
            facilityFactor *
            moraleFactor *
            appearancesFactor *
            randomFactor)
        .round();

    if (growthPoints == 0) return player;

    // Pozisyon ağırlıklarına göre niteliklere ağırlıklı dağıtım (§9.3)
    final pw = kPositionWeights[player.position] ?? kPositionWeights[Position.cm]!;

    int calcDelta(double weight) {
      if (growthPoints > 0) {
        return (growthPoints * weight * 1.5).round().clamp(0, 4);
      } else {
        // Yaş gerilemesi fiziksel/hızda daha yüksek
        return (growthPoints * (1.0 - weight * 0.5)).round().clamp(-4, 0);
      }
    }

    final newPace = (player.pace + calcDelta(pw.pace)).clamp(30, 99);
    final newTechnique = (player.technique + calcDelta(pw.technique)).clamp(30, 99);
    final newShooting = (player.shooting + calcDelta(pw.shooting)).clamp(30, 99);
    final newPassing = (player.passing + calcDelta(pw.passing)).clamp(30, 99);
    final newDefending = (player.defending + calcDelta(pw.defending)).clamp(30, 99);
    final newPhysical = (player.physical + calcDelta(pw.physical)).clamp(30, 99);
    final newMentality = (player.mentality + (growthPoints > 0 && player.age > 23 ? 1 : 0)).clamp(30, 99);

    return player.copyWith(
      pace: newPace,
      technique: newTechnique,
      shooting: newShooting,
      passing: newPassing,
      defending: newDefending,
      physical: newPhysical,
      mentality: newMentality,
      fitness: 100,
      sharpness: 90,
    );
  }
}

class ContractOfferEvaluation {
  final bool accepted;
  final int satisfactionScore;
  final String responseMessage;

  const ContractOfferEvaluation({
    required this.accepted,
    required this.satisfactionScore,
    required this.responseMessage,
  });
}

ContractOfferEvaluation evaluateContractOffer({
  required Player player,
  required int offeredWage,
  required int expectedWage,
  required SquadRole promisedRole,
  required int signingBonus,
}) {
  double score = 50.0;
  
  // Wage ratio
  final wageRatio = offeredWage / math.max(1, expectedWage);
  score += (wageRatio - 1.0) * 50;

  // Bonus
  if (signingBonus > 0) {
    score += (signingBonus / 10000).clamp(0, 15);
  }

  // Personality adjustments
  if (player.personality == PersonalityType.mercenary) {
    if (wageRatio < 1.1) score -= 15;
  } else if (player.personality == PersonalityType.loyal) {
    score += 15;
  } else if (player.personality == PersonalityType.ambitious) {
    if (promisedRole != SquadRole.star && promisedRole != SquadRole.first11) {
      score -= 20;
    }
  }

  final finalScore = score.round().clamp(0, 100);
  final isAccepted = finalScore >= 60;

  String message;
  if (finalScore >= 80) {
    message = 'Teklifinizden son derece memnun kaldım. Kulüpte kalmaktan gurur duyuyorum!';
  } else if (finalScore >= 60) {
    message = 'Şartlar makul, sözleşmeyi imzalamaya hazırım.';
  } else if (finalScore >= 40) {
    message = 'Maaş veya rol teklifiniz beklentimin altında. Lütfen şartları iyileştirin.';
  } else {
    message = 'Bu teklif benim futbol kaliteme hakaret! Bu şartlarda anlaşmamız imkansız.';
  }

  return ContractOfferEvaluation(
    accepted: isAccepted,
    satisfactionScore: finalScore,
    responseMessage: message,
  );
}
