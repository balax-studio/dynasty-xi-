// domain/progression/dynasty_prestige.dart
// Dynasty Prestige System & Legacy Perk Shop (§14.4)

class DynastyLegacyPerk {
  final String id;
  final String title;
  final String description;
  final int costDynastyPoints;
  final bool isUnlocked;
  final String icon;

  const DynastyLegacyPerk({
    required this.id,
    required this.title,
    required this.description,
    required this.costDynastyPoints,
    this.isUnlocked = false,
    required this.icon,
  });

  DynastyLegacyPerk copyWith({bool? isUnlocked}) {
    return DynastyLegacyPerk(
      id: id,
      title: title,
      description: description,
      costDynastyPoints: costDynastyPoints,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'costDynastyPoints': costDynastyPoints,
    'isUnlocked': isUnlocked,
    'icon': icon,
  };

  factory DynastyLegacyPerk.fromJson(Map<String, dynamic> json) => DynastyLegacyPerk(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    costDynastyPoints: json['costDynastyPoints'] as int,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    icon: json['icon'] as String,
  );
}

class DynastyPrestigeSystem {
  static List<DynastyLegacyPerk> getDefaultPerks() {
    return const [
      DynastyLegacyPerk(
        id: 'legacy_vault',
        title: 'Miras Kasası (Heritage Vault)',
        description: 'Her yeni kulüp başlangıcında kasaya +₣50,000 ek başlangıç bütçesi ekler.',
        costDynastyPoints: 100,
        icon: '💰',
      ),
      DynastyLegacyPerk(
        id: 'legend_scout',
        title: 'Küresel Scout Şebekesi',
        description: 'Scout sürelerini %50 kısaltır ve gizli yetenek (wonderkid) şansını %10 yapar.',
        costDynastyPoints: 150,
        icon: '🛰️',
      ),
      DynastyLegacyPerk(
        id: 'double_builder',
        title: '2. İnşaat Ekibi (Slot)',
        description: 'Tesislerde aynı anda 2 farklı inşaat/yükseltme başlatma hakkı sağlar.',
        costDynastyPoints: 200,
        icon: '🏗️',
      ),
      DynastyLegacyPerk(
        id: 'board_immunity',
        title: 'Başkan Dokunulmazlığı',
        description: 'Yönetim kurulu güveni %0 olsa dahi 1 kereye mahsus kovulmayı iptal eder.',
        costDynastyPoints: 250,
        icon: '🛡️',
      ),
      DynastyLegacyPerk(
        id: 'youth_prodigy',
        title: 'Altın Jenerasyon',
        description: 'Her sezon başlangıcında akademiden en az 1 adet 80+ potansiyelli genç üretilir.',
        costDynastyPoints: 300,
        icon: '⭐',
      ),
    ];
  }
}
