// domain/president/head_coach.dart
// Head Coach entity, archetypes, vision dictation, hiring and severance mechanics (§15.4)

enum HeadCoachArchetype {
  tactician(
    'Kurt Taktisyen',
    '[AI]',
    'Yüksek maç aklı. Maç simülasyonunda +%8 güç artışı ve kritik anlarda galibiyet getirir.',
    weeklyWage: 6000,
    signingFee: 15000,
    powerBoost: 8,
    fanBoost: 0,
    youthMultiplier: 1.0,
  ),
  starName(
    'Yıldız İsim',
    'STAR',
    'Global şöhret. Maçlarda +%15 taraftar ilgisi, +%20 forma satışı ve ekstra bilet geliri sağlar.',
    weeklyWage: 9000,
    signingFee: 30000,
    powerBoost: 4,
    fanBoost: 15,
    youthMultiplier: 1.0,
  ),
  youthDeveloper(
    'Altyapıcı Proje Hocası',
    '',
    'Genç oyuncuların potansiyel gelişim hızını 2 katına çıkarır, düşük maliyetle çalışır.',
    weeklyWage: 3200,
    signingFee: 8000,
    powerBoost: 2,
    fanBoost: 0,
    youthMultiplier: 2.0,
  ),
  disciplinarian(
    'Sert Disiplinci',
    '',
    'Soyunma odası huzursuzluğunu sıfırlar, antrenman verimini ve kondisyonu zirvede tutar.',
    weeklyWage: 4800,
    signingFee: 12000,
    powerBoost: 5,
    fanBoost: 0,
    youthMultiplier: 1.2,
  );

  final String label;
  final String icon;
  final String description;
  final int weeklyWage;
  final int signingFee;
  final int powerBoost;
  final int fanBoost;
  final double youthMultiplier;

  const HeadCoachArchetype(
    this.label,
    this.icon,
    this.description, {
    required this.weeklyWage,
    required this.signingFee,
    required this.powerBoost,
    required this.fanBoost,
    required this.youthMultiplier,
  });
}

enum CoachVision {
  attacking('Ofansif & Coşkulu', 'Bol gollü, göze hoş gelen futbol. Taraftar ilgisini artırır.', deltaPower: 3, deltaFans: 3),
  championship('Kazan & Şampiyon Ol', 'Sonuç odaklı pragmatik taktik. Maç kazanma şansını maksimuma çıkarır.', deltaPower: 6, deltaFans: 0),
  youthFocus('Gençlik Devrimi', 'Genç oyunculara ağırlık vererek geleceğin yıldızlarını yetiştirir.', deltaPower: 1, deltaFans: 1);

  final String label;
  final String description;
  final int deltaPower;
  final int deltaFans;

  const CoachVision(this.label, this.description, {required this.deltaPower, required this.deltaFans});
}

class HeadCoach {
  final String id;
  final String fullName;
  final int age;
  final String countryCode;
  final HeadCoachArchetype archetype;
  final int weeklyWage;
  final int signingFee;
  final String tacticalStyle;
  final int reputation; // 1 - 100
  final int boardConfidence; // 0 - 100
  final int matchesManaged;
  final CoachVision activeVision;

  const HeadCoach({
    required this.id,
    required this.fullName,
    required this.age,
    required this.countryCode,
    required this.archetype,
    required this.weeklyWage,
    required this.signingFee,
    this.tacticalStyle = 'Dengeli',
    this.reputation = 75,
    this.boardConfidence = 80,
    this.matchesManaged = 0,
    this.activeVision = CoachVision.championship,
  });

  /// Kovulma Tazminatı (6 haftalık maaş)
  int get severancePay => weeklyWage * 6;

  HeadCoach copyWith({
    String? id,
    String? fullName,
    int? age,
    String? countryCode,
    HeadCoachArchetype? archetype,
    int? weeklyWage,
    int? signingFee,
    String? tacticalStyle,
    int? reputation,
    int? boardConfidence,
    int? matchesManaged,
    CoachVision? activeVision,
  }) {
    return HeadCoach(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      countryCode: countryCode ?? this.countryCode,
      archetype: archetype ?? this.archetype,
      weeklyWage: weeklyWage ?? this.weeklyWage,
      signingFee: signingFee ?? this.signingFee,
      tacticalStyle: tacticalStyle ?? this.tacticalStyle,
      reputation: reputation ?? this.reputation,
      boardConfidence: boardConfidence ?? this.boardConfidence,
      matchesManaged: matchesManaged ?? this.matchesManaged,
      activeVision: activeVision ?? this.activeVision,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'age': age,
        'countryCode': countryCode,
        'archetype': archetype.name,
        'weeklyWage': weeklyWage,
        'signingFee': signingFee,
        'tacticalStyle': tacticalStyle,
        'reputation': reputation,
        'boardConfidence': boardConfidence,
        'matchesManaged': matchesManaged,
        'activeVision': activeVision.name,
      };

  factory HeadCoach.fromJson(Map<String, dynamic> json) => HeadCoach(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        age: json['age'] as int? ?? 50,
        countryCode: json['countryCode'] as String? ?? 'TR',
        archetype: HeadCoachArchetype.values.firstWhere(
          (e) => e.name == json['archetype'],
          orElse: () => HeadCoachArchetype.tactician,
        ),
        weeklyWage: json['weeklyWage'] as int? ?? 5000,
        signingFee: json['signingFee'] as int? ?? 15000,
        tacticalStyle: json['tacticalStyle'] as String? ?? 'Dengeli',
        reputation: json['reputation'] as int? ?? 75,
        boardConfidence: json['boardConfidence'] as int? ?? 80,
        matchesManaged: json['matchesManaged'] as int? ?? 0,
        activeVision: CoachVision.values.firstWhere(
          (e) => e.name == json['activeVision'],
          orElse: () => CoachVision.championship,
        ),
      );
}

class HeadCoachCatalog {
  static List<HeadCoach> getCandidateCoaches() {
    return const [
      HeadCoach(
        id: 'coach_tactician_1',
        fullName: 'Fatih "İmparator" Karahan',
        age: 62,
        countryCode: 'TR',
        archetype: HeadCoachArchetype.tactician,
        weeklyWage: 6500,
        signingFee: 16000,
        tacticalStyle: 'Baskılı Ofansif',
        reputation: 88,
      ),
      HeadCoach(
        id: 'coach_star_1',
        fullName: 'Roberto "Il Maestro" Vieri',
        age: 54,
        countryCode: 'IT',
        archetype: HeadCoachArchetype.starName,
        weeklyWage: 9500,
        signingFee: 32000,
        tacticalStyle: 'Tiki-Taka',
        reputation: 92,
      ),
      HeadCoach(
        id: 'coach_youth_1',
        fullName: 'Klaus "Akademi" Schmidt',
        age: 44,
        countryCode: 'DE',
        archetype: HeadCoachArchetype.youthDeveloper,
        weeklyWage: 3200,
        signingFee: 8500,
        tacticalStyle: 'Gegenpressing',
        reputation: 76,
      ),
      HeadCoach(
        id: 'coach_disc_1',
        fullName: 'Mircea "Çavuş" Popescu',
        age: 58,
        countryCode: 'RO',
        archetype: HeadCoachArchetype.disciplinarian,
        weeklyWage: 4800,
        signingFee: 12500,
        tacticalStyle: 'Katı Savunma',
        reputation: 81,
      ),
    ];
  }
}
