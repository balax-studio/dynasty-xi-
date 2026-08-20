// domain/progression/player_growth.dart
// Pure Dart. Player seasonal progression, training improvements and age decay models.

import 'dart:math' as math;
import '../entities/player.dart';

class PlayerGrowth {
  /// Sezon Sonu / Antrenman Gelişim Hesabı — Ek C.1
  static Player applyTrainingGrowth({
    required Player player,
    required int trainingFacilityLevel,
    double randomFactor = 1.0,
  }) {
    if (player.isInjured) {
      // Sakat oyuncunun kondisyonu ve formu toparlanır, OVR artmaz
      return player.copyWith(
        injuryMatchesLeft: math.max(0, player.injuryMatchesLeft - 1),
      );
    }

    final currentOvr = player.ovr;
    final potential = player.potential;

    // Yaş Çarpanı
    double ageFactor;
    if (player.age <= 18) {
      ageFactor = 1.6;
    } else if (player.age <= 22) {
      ageFactor = 1.3;
    } else if (player.age <= 26) {
      ageFactor = 0.6;
    } else if (player.age <= 30) {
      ageFactor = -0.25;
    } else {
      ageFactor = -0.80;
    }

    // Tesis Çarpanı (1.0 - 1.48)
    final facilityFactor = 1.0 + (trainingFacilityLevel - 1) * 0.12;

    // Moral Çarpanı (0.80 - 1.15)
    final moraleFactor = (player.morale / 85.0).clamp(0.80, 1.15);

    // Oynama Süresi Çarpanı (Daha çok maça çıkan daha çok gelişir)
    final appearancesFactor = player.appearances >= 10 ? 1.25 : (player.appearances >= 5 ? 1.0 : 0.75);

    final growthDelta = ((potential - currentOvr) * 0.18 * ageFactor * facilityFactor * moraleFactor * appearancesFactor * randomFactor);
    final deltaInt = growthDelta.round();

    if (deltaInt == 0) return player;

    // Niteliklere dağıt
    final newPace = (player.pace + (deltaInt > 0 ? (deltaInt > 2 ? 1 : 0) : -1)).clamp(30, 99);
    final newTechnique = (player.technique + deltaInt).clamp(30, 99);
    final newShooting = (player.shooting + deltaInt).clamp(30, 99);
    final newPassing = (player.passing + deltaInt).clamp(30, 99);
    final newDefending = (player.defending + deltaInt).clamp(30, 99);
    final newPhysical = (player.physical + (deltaInt > 0 ? 1 : -1)).clamp(30, 99);
    final newMentality = (player.mentality + (player.age > 24 ? 1 : 0)).clamp(30, 99);

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
