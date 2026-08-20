// domain/entities/staff.dart
// Backroom staff specialists: Assistant Manager, Head Physio, Chief Scout, Data Analyst (§8.2, §13)

enum StaffRole {
  assistantManager('Asistan Menajer', '📋', 'Antrenman verimini artırır, rotasyon tavsiyesi verir.'),
  headPhysio('Baş Fizyoterapist', '🏥', 'Sakatlık sürelerini kısaltır ve kondisyonu korur.'),
  chiefScout('Şef Scout', '🔍', 'Oyuncu potansiyel tahmin kesinliğini artırır.'),
  dataAnalyst('Veri Analisti', '📊', 'Rakip zayıflıklarını çözer, maç xG avantajı sağlar.');

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

  const StaffMember({
    required this.id,
    required this.role,
    required this.name,
    required this.level,
    required this.weeklySalary,
    this.specialtyDescription = '',
  });

  double get trainingGrowthBonus => level * 0.08;
  double get injuryRecoverySpeedBonus => level * 0.08;
  int get potentialAccuracyBonus => level;
  double get opponentWeaknessInsightChance => level * 0.15;

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'name': name,
        'level': level,
        'weeklySalary': weeklySalary,
        'specialtyDescription': specialtyDescription,
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
        specialtyDescription: 'Antrenman temposu dengeleme.',
      ),
      StaffMember(
        id: 'staff_physio_1',
        role: StaffRole.headPhysio,
        name: 'Dr. Sarper Çetinkaya',
        level: 2,
        weeklySalary: 2000,
        specialtyDescription: 'Kas sakatlıkları rehabilitasyonu.',
      ),
      StaffMember(
        id: 'staff_scout_1',
        role: StaffRole.chiefScout,
        name: 'Gökhan Keskin',
        level: 2,
        weeklySalary: 2200,
        specialtyDescription: 'Balkan ve Anadolu yetenek havuzu.',
      ),
      StaffMember(
        id: 'staff_analyst_1',
        role: StaffRole.dataAnalyst,
        name: 'Emre Varlık',
        level: 2,
        weeklySalary: 1600,
        specialtyDescription: 'Duran top ve xG analitiği.',
      ),
    ];
  }
}
