// domain/sim/xg_model.dart
// Pure Dart. Mathematical Expected Goals (xG) and conversion model.

import 'dart:math' as math;

enum ShotType {
  openPlay('Açık Oyun', 1.0),
  counterAttack('Hızlı Kontra', 1.28),
  setPieceHeader('Duran Top / Kafa', 0.92),
  directFreeKick('Frikik', 0.82),
  penalty('Penaltı', 0.78);

  final String label;
  final double multiplier;

  const ShotType(this.label, this.multiplier);
}

class XgModel {
  /// xG Hesaplama — Ek C.3
  /// xG = clamp(0.085 * (Atak / Defans)^0.9 * shotTypeÇ * mentalityÇ, 0.02, 0.62)
  static double calculateXg({
    required double attackPower,
    required double defensePower,
    required ShotType shotType,
    double mentalityMultiplier = 1.0,
  }) {
    if (shotType == ShotType.penalty) {
      return 0.76;
    }

    final ratio = (attackPower / math.max(10.0, defensePower));
    final rawXg = 0.165 * math.pow(ratio, 0.95) * shotType.multiplier * mentalityMultiplier;

    return rawXg.clamp(0.04, 0.82);
  }

  /// Kaleci faktörü dahil Gol Olasılığı
  /// golOlasılık = xG * (1 - (kaleci.OVR - 55) * 0.0055)
  static double calculateGoalProbability({
    required double xG,
    required double goalkeeperPower,
  }) {
    final gkFactor = 1.0 - (goalkeeperPower - 55.0) * 0.0055;
    final clampedGk = gkFactor.clamp(0.65, 1.25);
    return (xG * clampedGk).clamp(0.01, 0.92);
  }
}
