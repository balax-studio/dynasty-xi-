// domain/entities/manager.dart
// Pure Dart. Manager RPG progression with 1-30 level curve, 3 talent branches and perks.

import 'dart:math' as math;

enum TalentBranch {
  tactician('Taktisyen', '🧠', 'Maç yönetimi, taktiksel esneklik ve kondisyon.'),
  persuader('İkna Ustası', '🤝', 'Pazarlık, moral kontrolü ve kriz yönetimi.'),
  visionary('Vizyoner', '🏛️', 'Tesis inşası, altyapı yetenekleri ve ekonomi.');

  final String label;
  final String icon;
  final String description;

  const TalentBranch(this.label, this.icon, this.description);
}

class Perk {
  final String id;
  final String title;
  final String description;
  final TalentBranch branch;
  final int tier; // 1, 2, 3
  final String icon;

  const Perk({
    required this.id,
    required this.title,
    required this.description,
    required this.branch,
    required this.tier,
    required this.icon,
  });

  static const List<Perk> allPerks = [
    // Taktisyen
    Perk(
      id: 'tactician_1',
      title: 'Kurt Hoca',
      description: 'Devre arası ve canlı anlardaki taktik kararları %15 daha etkilidir.',
      branch: TalentBranch.tactician,
      tier: 1,
      icon: '🧠',
    ),
    Perk(
      id: 'tactician_2',
      title: 'Çelik Kondisyon',
      description: '60. dakikadan sonraki maç yorgunluğu ve kondisyon kaybı %20 azalır.',
      branch: TalentBranch.tactician,
      tier: 2,
      icon: '⚡',
    ),
    Perk(
      id: 'tactician_3',
      title: 'Duran Top Ustası',
      description: 'Korner ve serbest vuruşlardan gol bulma olasılığı %25 artar.',
      branch: TalentBranch.tactician,
      tier: 3,
      icon: '🎯',
    ),

    // İkna Ustası
    Perk(
      id: 'persuader_1',
      title: 'Sert Pazarlıkçı',
      description: 'Transfer görüşmelerinde kulüplerin bonservis talebi %10 daha düşüktür.',
      branch: TalentBranch.persuader,
      tier: 1,
      icon: '🤝',
    ),
    Perk(
      id: 'persuader_2',
      title: 'Soyunma Odası Büyücüsü',
      description: 'Maç kayıpları sonrası oyuncu morali ve soyunma odası düşüşü yarıya iner.',
      branch: TalentBranch.persuader,
      tier: 2,
      icon: '🗣️',
    ),
    Perk(
      id: 'persuader_3',
      title: 'Menajer Fısıldayan',
      description: 'Transferlerdeki menajer (agent) komisyonu %30 azalır.',
      branch: TalentBranch.persuader,
      tier: 3,
      icon: '💼',
    ),

    // Vizyoner
    Perk(
      id: 'visionary_1',
      title: 'Yatırımcı Dostu',
      description: 'Tüm tesis inşaat ve yükseltme masrafları %12 daha ucuzdur.',
      branch: TalentBranch.visionary,
      tier: 1,
      icon: '🏗️',
    ),
    Perk(
      id: 'visionary_2',
      title: 'Altın Göz',
      description: 'Scout raporları oyuncuların gizli potansiyelini kesin doğrulukla açar.',
      branch: TalentBranch.visionary,
      tier: 2,
      icon: '🔍',
    ),
    Perk(
      id: 'visionary_3',
      title: 'Akademi Fabrikası',
      description: 'Her sezon başı altyapıdan en az 1 adet 4★+ yüksek potansiyelli genç çıkar.',
      branch: TalentBranch.visionary,
      tier: 3,
      icon: '⭐',
    ),
  ];
}

class Manager {
  final String name;
  final int level; // 1 to 30
  final int currentXp;
  final List<String> unlockedPerkIds;
  final int reputation; // İtibar
  final int dynastyPoints; // Hanedan / Prestij Puanı

  const Manager({
    this.name = 'Hoca',
    this.level = 1,
    this.currentXp = 0,
    this.unlockedPerkIds = const [],
    this.reputation = 50,
    this.dynastyPoints = 0,
  });

  /// Seviye atlamak için gereken toplam XP: GerekliXP(n) = 320 * n^1.62 (Ek C.5)
  static int requiredXpForLevel(int targetLevel) {
    if (targetLevel <= 1) return 0;
    return (320 * math.pow(targetLevel, 1.62)).round();
  }

  /// Mevcut seviyenin tamamlanma yüzdesi [0.0, 1.0]
  double get levelProgress {
    if (level >= 30) return 1.0;
    final currentLevelBase = requiredXpForLevel(level);
    final nextLevelTarget = requiredXpForLevel(level + 1);
    final span = nextLevelTarget - currentLevelBase;
    if (span <= 0) return 1.0;
    return ((currentXp - currentLevelBase) / span).clamp(0.0, 1.0);
  }

  int get xpRequiredForNextLevel => requiredXpForLevel(level + 1);

  /// Harcanabilir yetenek puanı sayısı
  int get availableSkillPoints {
    return math.max(0, level - 1 - unlockedPerkIds.length);
  }

  bool hasPerk(String perkId) => unlockedPerkIds.contains(perkId);

  /// XP Ekleme ve seviye atlama kontrolü
  Manager addXp(int xpAmount) {
    var newXp = currentXp + xpAmount;
    var newLevel = level;

    while (newLevel < 30 && newXp >= requiredXpForLevel(newLevel + 1)) {
      newLevel++;
    }

    return copyWith(
      level: newLevel,
      currentXp: newXp,
    );
  }

  Manager copyWith({
    String? name,
    int? level,
    int? currentXp,
    List<String>? unlockedPerkIds,
    int? reputation,
    int? dynastyPoints,
  }) {
    return Manager(
      name: name ?? this.name,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      unlockedPerkIds: unlockedPerkIds ?? this.unlockedPerkIds,
      reputation: reputation ?? this.reputation,
      dynastyPoints: dynastyPoints ?? this.dynastyPoints,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level,
        'currentXp': currentXp,
        'unlockedPerkIds': unlockedPerkIds,
        'reputation': reputation,
        'dynastyPoints': dynastyPoints,
      };

  factory Manager.fromJson(Map<String, dynamic> json) => Manager(
        name: json['name'] as String? ?? 'Hoca',
        level: json['level'] as int? ?? 1,
        currentXp: json['currentXp'] as int? ?? 0,
        unlockedPerkIds: (json['unlockedPerkIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        reputation: json['reputation'] as int? ?? 50,
        dynastyPoints: json['dynastyPoints'] as int? ?? 0,
      );
}
