// domain/economy/swap_evaluation_engine.dart
// Intelligent Swap Evaluation Engine for Transfer Negotiations.
// Evaluates AI club position needs, age profile, wage burden, and generates realistic counter-offers or rejections.

import '../entities/player.dart';

enum SwapDecisionStatus {
  accepted('KABUL EDİLDİ', 'Karşı kulüp takas oyuncusunu memnuniyetle kabul etti.'),
  counterOffer('ŞARTLI KARŞI TEKLİF', 'Oyuncu kabul edildi ancak ek nakit bonservis talep ediliyor.'),
  rejected('TAKAS REDDEDİLDİ', 'Kulüp takasa sunduğunuz oyuncuyu kadro planlamasına uygun bulmadı.');

  final String title;
  final String description;
  const SwapDecisionStatus(this.title, this.description);
}

class SwapEvaluationResult {
  final SwapDecisionStatus status;
  final String responseMessage;
  final int effectiveSwapDiscount;
  final int requiredAdditionalCash;

  const SwapEvaluationResult({
    required this.status,
    required this.responseMessage,
    required this.effectiveSwapDiscount,
    this.requiredAdditionalCash = 0,
  });

  bool get isAccepted => status == SwapDecisionStatus.accepted;
  bool get isCounterOffer => status == SwapDecisionStatus.counterOffer;
  bool get isRejected => status == SwapDecisionStatus.rejected;
}

class SwapEvaluationEngine {
  /// Takasa sunulan oyuncuyu karşı kulübün gözünden değerlendirir.
  static SwapEvaluationResult evaluate({
    required Player targetPlayer,
    required Player swapPlayer,
    required int offeredCash,
    required int askingFee,
  }) {
    // 1. Yaşlı ve yüksek maaşlı oyuncu bariyeri (Deadwood filtresi)
    if (swapPlayer.age >= 32 && swapPlayer.weeklyWage >= 5000) {
      return const SwapEvaluationResult(
        status: SwapDecisionStatus.rejected,
        responseMessage: 'Karşı kulüp: "Oyuncunun yüksek maaş yükü ve ilerlemiş yaşı sebebiyle bu takası kabul edemeyiz."',
        effectiveSwapDiscount: 0,
      );
    }

    // 2. Çok düşük OVR veya büyük kalite farkı (Örn: Hedef 84 OVR iken 60 OVR oyuncu sunulması)
    if (targetPlayer.ovr - swapPlayer.ovr > 15 && swapPlayer.potential < 75) {
      return const SwapEvaluationResult(
        status: SwapDecisionStatus.rejected,
        responseMessage: 'Karşı kulüp: "Takas teklif ettiğiniz oyuncunun mevcut seviyesi ilk 11 planlarımızın oldukça gerisinde."',
        effectiveSwapDiscount: 0,
      );
    }

    // 3. Mevki Uyumu ve Takas Değeri Hesabı
    final bool samePositionFamily = (targetPlayer.position.isForward && swapPlayer.position.isForward) ||
        (targetPlayer.position.isMidfielder && swapPlayer.position.isMidfielder) ||
        (targetPlayer.position.isDefender && swapPlayer.position.isDefender) ||
        (targetPlayer.position.isGoalkeeper && swapPlayer.position.isGoalkeeper);

    // Mevki uyumluysa tam değer, farklı mevkideyse %80 değer takdir edilir
    final double positionMultiplier = samePositionFamily ? 1.0 : 0.80;
    final int evaluatedPlayerValue = (swapPlayer.marketValue * positionMultiplier).round();

    final int totalOfferValue = offeredCash + evaluatedPlayerValue;
    final int shortfall = askingFee - totalOfferValue;

    // 4. Genç yetenek / Yüksek potansiyel cazibesi
    if (swapPlayer.age <= 22 && swapPlayer.potential >= 82) {
      if (shortfall <= 0) {
        return SwapEvaluationResult(
          status: SwapDecisionStatus.accepted,
          responseMessage: 'Karşı kulüp: "${swapPlayer.fullName} yüksek potansiyeliyle geleceğimize büyük katkı sağlayacaktır. Takası onaylıyoruz!"',
          effectiveSwapDiscount: evaluatedPlayerValue,
        );
      } else {
        return SwapEvaluationResult(
          status: SwapDecisionStatus.counterOffer,
          responseMessage: 'Karşı kulüp: "${swapPlayer.fullName} ilgimizi çekiyor ancak transferin tamamlanması için ek ₣$shortfall nakit ödeme istiyoruz."',
          effectiveSwapDiscount: evaluatedPlayerValue,
          requiredAdditionalCash: shortfall,
        );
      }
    }

    // 5. Standart Takas Değerlendirmesi
    if (shortfall <= 0) {
      return SwapEvaluationResult(
        status: SwapDecisionStatus.accepted,
        responseMessage: 'Karşı kulüp: "Takas teklifiniz ve sunduğunuz şartlar kabul edilmiştir."',
        effectiveSwapDiscount: evaluatedPlayerValue,
      );
    } else {
      return SwapEvaluationResult(
        status: SwapDecisionStatus.counterOffer,
        responseMessage: 'Karşı kulüp: "Takas oyuncunuz kabul edilebilir düzeyde, ancak bonservis farkı için ek ₣$shortfall daha talep ediyoruz."',
        effectiveSwapDiscount: evaluatedPlayerValue,
        requiredAdditionalCash: shortfall,
      );
    }
  }
}
