// domain/economy/offline_calculator.dart
// Pure Dart. Calculates passive earnings and auto-completes facility upgrades during user absence.

import '../entities/club.dart';
import '../entities/facility.dart';

class OfflineReport {
  final int passiveCashEarned;
  final double effectiveHoursClamped;
  final List<FacilityType> completedFacilityUpgrades;
  final Club updatedClub;

  const OfflineReport({
    required this.passiveCashEarned,
    required this.effectiveHoursClamped,
    required this.completedFacilityUpgrades,
    required this.updatedClub,
  });

  List<String> get completedFacilityTypeNames =>
      completedFacilityUpgrades.map((t) => t.label).toList();
}

class OfflineCalculator {
  /// Çevrimdışı İlerleme ve Gelir Hesaplama (§6.3, Ek C.4, Ek C.6)
  static OfflineReport calculateOfflineProgress({
    required Club club,
    required int elapsedSeconds,
    int? currentEpochMs,
  }) {
    final nowMs = currentEpochMs ?? DateTime.now().millisecondsSinceEpoch;

    // 1. Maksimum süre tavanı (VIP Salonu seviye 3+ ise 24 saat, yoksa 12 saat)
    final vipLevel = club.getFacilityLevel(FacilityType.vipLounge);
    final maxHours = vipLevel >= 3 ? 24.0 : 12.0;
    final elapsedHours = elapsedSeconds / 3600.0;
    final effectiveHours = elapsedHours.clamp(0.0, maxHours);

    // 2. Pasif Gelirler (Taraftar Mağazası & Müze & Stadyum Turu)
    final fanShopLvl = club.getFacilityLevel(FacilityType.fanShop);
    final stadiumLvl = club.getFacilityLevel(FacilityType.stadium);
    final museumLvl = club.getFacilityLevel(FacilityType.clubMuseum);

    final fanShopIncome = (club.meters.fans * (fanShopLvl * 150) * (club.meters.fans / 100.0)) * (effectiveHours / 24.0);
    final stadiumPassiveIncome = (stadiumLvl * 200.0) * effectiveHours;
    final museumPassiveIncome = (museumLvl * 120.0) * effectiveHours;

    final totalPassiveEarned = (fanShopIncome + stadiumPassiveIncome + museumPassiveIncome).round();

    // 3. Tesis İnşaatlarını Tamamlama Kontrolü
    final updatedFacilities = Map<FacilityType, Facility>.from(club.facilities);
    final completedUpgrades = <FacilityType>[];

    for (final entry in updatedFacilities.entries) {
      final facility = entry.value;
      if (facility.isUpgrading) {
        // Eğer bitiş zamanı girilmişse veya geçen süre inşaat süresini aştıysa tamamla
        final isFinished = (facility.upgradeFinishEpochMs != null && facility.upgradeFinishEpochMs! <= nowMs) ||
            (facility.upgradeFinishEpochMs == null && elapsedSeconds >= (facility.upgradeDurationMinutes * 60));

        if (isFinished) {
          completedUpgrades.add(facility.type);
          updatedFacilities[facility.type] = Facility(
            type: facility.type,
            level: (facility.level + 1).clamp(1, 5),
            isUpgrading: false,
            upgradeFinishEpochMs: null,
          );
        }
      }
    }

    // 4. Kulüp Kasasını Güncelle
    final updatedMeters = club.meters.applyDeltas(deltaCash: totalPassiveEarned);
    final updatedClub = club.copyWith(
      meters: updatedMeters,
      facilities: updatedFacilities,
    );

    return OfflineReport(
      passiveCashEarned: totalPassiveEarned,
      effectiveHoursClamped: double.parse(effectiveHours.toStringAsFixed(1)),
      completedFacilityUpgrades: completedUpgrades,
      updatedClub: updatedClub,
    );
  }
}
