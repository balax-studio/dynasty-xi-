// domain/entities/facility.dart
// Pure Dart. 12 facilities × 5 tiers with construction costs, timers, upgrade multipliers and maintenance.

import 'dart:math' as math;

enum FacilityType {
  stadium('Stadyum', '🏟️', 'Kapasiteyi ve bilet gelirini artırır.', 15000, 30),
  trainingGround('Antrenman Sahası', '🏃', 'Oyuncuların antrenmandan kazandığı gelişimi artırır.', 8000, 20),
  youthAcademy('Altyapı Akademisi', '🌱', 'Her sezon başı yüksek potansiyelli genç yetenekler üretir.', 12000, 45),
  medicalCenter('Tıp Merkezi', '🏥', 'Sakatlık riskini düşürür, iyileşme sürelerini hızlandırır.', 9000, 25),
  scoutCenter('Scout Merkezi', '🔍', 'Gözlem hızını ve potansiyel tahmin kesinliğini artırır.', 7500, 20),
  clubMuseum('Kulüp Müzesi', '🏆', 'Taraftar memnuniyetini ve kulüp itibarını yükseltir.', 6000, 15),
  fanShop('Taraftar Mağazası', '👕', 'Haftalık lisanslı ürün ve forma satış gelirini artırır.', 7000, 20),
  analyticsDept('Analiz Departmanı', '📊', 'Rakip analiz bonusu ve taktik uyum çarpanı sağlar.', 8500, 25),
  pitchMaintenance('Çim & Bakım', '🌱', 'Ev sahibi saha avantajını artırır, zemin kaynaklı sakatlıkları önler.', 5000, 15),
  pressRoom('Basın Odası', '🎙️', 'Kriz anlarında yönetim ve basın baskısını dengeler.', 4500, 15),
  nutritionCenter('Beslenme & Kondisyon', '🥗', 'Maç içi yorgunluğu azaltır, maçlar arası dinlenmeyi hızlandırır.', 6500, 20),
  vipLounge('VIP Salonu', '🥂', 'Kurumsal sponsorluk ve kombine gelirlerini çarpar.', 11000, 35);

  final String label;
  final String icon;
  final String description;
  final int baseCost;
  final int baseDurationMinutes;

  const FacilityType(
    this.label,
    this.icon,
    this.description,
    this.baseCost,
    this.baseDurationMinutes,
  );
}

class Facility {
  final FacilityType type;
  final int level; // 1 to 5 (0 = not constructed)
  final bool isUpgrading;
  final int? upgradeFinishEpochMs;

  const Facility({
    required this.type,
    this.level = 1,
    this.isUpgrading = false,
    this.upgradeFinishEpochMs,
  });

  bool get isMaxLevel => level >= 5;
  bool get isOpen => level > 0;

  /// Bir sonraki seviyeye yükseltme maliyeti (Ek C.4: tabanMaliyet × 3.9^(sv-1))
  int get upgradeCost {
    if (isMaxLevel) return 0;
    final nextLevel = level + 1;
    final cost = type.baseCost * math.pow(3.9, nextLevel - 2);
    return cost.round();
  }

  /// İnşaat Süresi (dakika) (Ek C.4: tabanSüre × 2.7^(sv-1))
  int get upgradeDurationMinutes {
    if (isMaxLevel) return 0;
    final nextLevel = level + 1;
    final duration = type.baseDurationMinutes * math.pow(2.7, nextLevel - 2);
    return duration.round().clamp(5, 2880); // maks 48 saat
  }

  /// Haftalık Bakım Gideri (Ek C.4: maliyet × 0.0085)
  int get weeklyMaintenance {
    if (level <= 0) return 0;
    final totalCost = type.baseCost * math.pow(3.9, level - 1);
    return (totalCost * 0.0085).round();
  }

  /// Stadyum kapasitesi hesabı (Sadece Stadyum için)
  int get stadiumCapacity {
    if (type != FacilityType.stadium) return 0;
    switch (level) {
      case 1:
        return 2500;
      case 2:
        return 7500;
      case 3:
        return 18000;
      case 4:
        return 36000;
      case 5:
        return 62000;
      default:
        return 1000;
    }
  }

  Facility copyWith({
    FacilityType? type,
    int? level,
    bool? isUpgrading,
    int? upgradeFinishEpochMs,
  }) {
    return Facility(
      type: type ?? this.type,
      level: level ?? this.level,
      isUpgrading: isUpgrading ?? this.isUpgrading,
      upgradeFinishEpochMs: upgradeFinishEpochMs ?? this.upgradeFinishEpochMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'level': level,
        'isUpgrading': isUpgrading,
        'upgradeFinishEpochMs': upgradeFinishEpochMs,
      };

  factory Facility.fromJson(Map<String, dynamic> json) => Facility(
        type: FacilityType.values.firstWhere(
          (f) => f.name == json['type'],
          orElse: () => FacilityType.stadium,
        ),
        level: json['level'] as int? ?? 1,
        isUpgrading: json['isUpgrading'] as bool? ?? false,
        upgradeFinishEpochMs: json['upgradeFinishEpochMs'] as int?,
      );
}
