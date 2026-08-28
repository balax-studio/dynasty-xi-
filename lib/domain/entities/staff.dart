// domain/entities/staff.dart
// Backroom staff specialists: Assistant Manager, Head Physio, Chief Scout, Data Analyst, Brand Specialist (§8.2, §13)

enum StaffRole {
  assistantManager('Asistan Menajer', '[RAPOR]', 'Antrenman verimini artırır, rotasyon tavsiyesi verir.'),
  headPhysio('Baş Fizyoterapist', '[REVİR]', 'Sakatlık sürelerini kısaltır ve kondisyonu korur.'),
  chiefScout('Şef Scout', '[ARAMA]', 'Oyuncu potansiyel tahmin kesinliğini artırır.'),
  dataAnalyst('Veri Analisti', '[GRAFIK]', 'Rakip zayıflıklarını çözer, maç xG avantajı sağlar.'),
  brandSpecialist('Kulüp Marka & Pazarlama Direktörü', 'DIAMOND', 'Taraftar büyümesini, sponsorluk gelirlerini ve ticari prestiji katlar.');

  final String label;
  final String icon;
  final String description;

  const StaffRole(this.label, this.icon, this.description);
}

class StaffMember {
  final String id;
  final StaffRole role;
  final String name;
  final int level; // 1 to 5
  final int weeklySalary;
  final String specialtyDescription;
  final int signingFee;

  const StaffMember({
    required this.id,
    required this.role,
    required this.name,
    required this.level,
    required this.weeklySalary,
    this.specialtyDescription = '',
    this.signingFee = 0,
  });

  double get trainingGrowthBonus => level * 0.08;
  double get injuryRecoverySpeedBonus => level * 0.08;
  int get potentialAccuracyBonus => level;
  double get opponentWeaknessInsightChance => level * 0.15;
  double get commercialRevenueBonus => role == StaffRole.brandSpecialist ? level * 0.10 : 0.0;
  int get fanGrowthWeeklyBonus => role == StaffRole.brandSpecialist ? level * 2 : 0;

  StaffMember copyWith({
    String? id,
    StaffRole? role,
    String? name,
    int? level,
    int? weeklySalary,
    String? specialtyDescription,
    int? signingFee,
  }) {
    return StaffMember(
      id: id ?? this.id,
      role: role ?? this.role,
      name: name ?? this.name,
      level: level ?? this.level,
      weeklySalary: weeklySalary ?? this.weeklySalary,
      specialtyDescription: specialtyDescription ?? this.specialtyDescription,
      signingFee: signingFee ?? this.signingFee,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'name': name,
        'level': level,
        'weeklySalary': weeklySalary,
        'specialtyDescription': specialtyDescription,
        'signingFee': signingFee,
      };

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
        id: json['id'] as String,
        role: StaffRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => StaffRole.assistantManager,
        ),
        name: json['name'] as String,
        level: json['level'] as int? ?? 1,
        weeklySalary: json['weeklySalary'] as int? ?? 1500,
        specialtyDescription: json['specialtyDescription'] as String? ?? '',
        signingFee: json['signingFee'] as int? ?? 0,
      );
}

class StaffGenerator {
  static List<StaffMember> generateDefaultStaff() {
    return const [
      StaffMember(
        id: 'staff_asst_1',
        role: StaffRole.assistantManager,
        name: 'Murat Şahin',
        level: 2,
        weeklySalary: 1800,
        specialtyDescription: 'Antrenman temposu ve taktiksel rotasyon.',
        signingFee: 4000,
      ),
      StaffMember(
        id: 'staff_physio_1',
        role: StaffRole.headPhysio,
        name: 'Dr. Sarper Çetinkaya',
        level: 2,
        weeklySalary: 2000,
        specialtyDescription: 'Kas sakatlıkları ve hızlı rehabilitasyon.',
        signingFee: 5000,
      ),
      StaffMember(
        id: 'staff_scout_1',
        role: StaffRole.chiefScout,
        name: 'Gökhan Keskin',
        level: 2,
        weeklySalary: 2200,
        specialtyDescription: 'Balkan ve Anadolu yetenek havuzu taraması.',
        signingFee: 5500,
      ),
      StaffMember(
        id: 'staff_analyst_1',
        role: StaffRole.dataAnalyst,
        name: 'Emre Varlık',
        level: 2,
        weeklySalary: 1600,
        specialtyDescription: 'Duran top ve xG analitiği.',
        signingFee: 3500,
      ),
      StaffMember(
        id: 'staff_brand_1',
        role: StaffRole.brandSpecialist,
        name: 'Selin Doğan',
        level: 2,
        weeklySalary: 2400,
        specialtyDescription: 'Dijital medya kampanyaları ve forma lansmanları.',
        signingFee: 6000,
      ),
    ];
  }
}

class StaffMarketCatalog {
  static List<StaffMember> getAvailableMarketCandidates() {
    return const [
      // Asistan Menajerler
      StaffMember(
        id: 'market_asst_elite',
        role: StaffRole.assistantManager,
        name: 'Tayfun Korkut (Pro Lisans)',
        level: 4,
        weeklySalary: 3800,
        specialtyDescription: 'Bundesliga tempolu pres antrenmanları.',
        signingFee: 12000,
      ),
      StaffMember(
        id: 'market_asst_youth',
        role: StaffRole.assistantManager,
        name: 'Nedim Yiğit (Genç Gelişim)',
        level: 3,
        weeklySalary: 2600,
        specialtyDescription: 'U19 A Takım geçiş köprüsü uzmanı.',
        signingFee: 7500,
      ),
      // Fizyoterapistler
      StaffMember(
        id: 'market_physio_master',
        role: StaffRole.headPhysio,
        name: 'Prof. Dr. Bülent Zeren',
        level: 5,
        weeklySalary: 4500,
        specialtyDescription: 'Efsanevi bağ tedavisi, sakatlık süresini yarıya indirir.',
        signingFee: 18000,
      ),
      StaffMember(
        id: 'market_physio_tech',
        role: StaffRole.headPhysio,
        name: 'Dr. Ceyhun Aydoğan',
        level: 3,
        weeklySalary: 2800,
        specialtyDescription: 'Kriyoterapi ve rejenerasyon protokolleri.',
        signingFee: 8000,
      ),
      // Şef Scoutlar
      StaffMember(
        id: 'market_scout_global',
        role: StaffRole.chiefScout,
        name: 'Piet de Visser (Global)',
        level: 5,
        weeklySalary: 5000,
        specialtyDescription: 'Güney Amerika ve Afrika wonderkid radarı.',
        signingFee: 22000,
      ),
      StaffMember(
        id: 'market_scout_domestic',
        role: StaffRole.chiefScout,
        name: 'Kemalettin Şentürk',
        level: 3,
        weeklySalary: 2500,
        specialtyDescription: 'Alt ligler ve amatör cevher keşfi.',
        signingFee: 7000,
      ),
      // Veri Analistleri
      StaffMember(
        id: 'market_analyst_ai',
        role: StaffRole.dataAnalyst,
        name: 'Kerem Yılmaz (Big Data)',
        level: 4,
        weeklySalary: 3500,
        specialtyDescription: 'Yapay zeka tabanlı rakip pres kırıcı simülasyonları.',
        signingFee: 11000,
      ),
      // Marka & Pazarlama Direktörleri
      StaffMember(
        id: 'market_brand_luxury',
        role: StaffRole.brandSpecialist,
        name: 'Cem Mirap (Global Pazarlama)',
        level: 5,
        weeklySalary: 5500,
        specialtyDescription: 'Uluslararası sponsorluk anlaşmaları ve VIP kulüp prestiji.',
        signingFee: 25000,
      ),
      StaffMember(
        id: 'market_brand_creator',
        role: StaffRole.brandSpecialist,
        name: 'Ece Güner (Sosyal Medya Gurusu)',
        level: 3,
        weeklySalary: 3000,
        specialtyDescription: 'Viral TikTok/Reels içerikleri ve Z kuşağı taraftar büyümesi.',
        signingFee: 8500,
      ),
    ];
  }
}
