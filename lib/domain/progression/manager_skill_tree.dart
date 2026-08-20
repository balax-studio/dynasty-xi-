// domain/progression/manager_skill_tree.dart
// 5-Branch Manager Skill Tree (Tactical, Motivational, Transfer, Academy, Financial) (§13, Ek H)

enum SkillBranchType {
  tactical('Taktik Dehası', '⚡'),
  motivational('Motivasyon Ustası', '🔥'),
  transfer('Transfer Kurdu', '💼'),
  academy('Altyapı Mimarı', '🌱'),
  financial('Finansal Büyücü', '💰');

  final String title;
  final String icon;

  const SkillBranchType(this.title, this.icon);
}

class ManagerSkill {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int costPoints;
  final bool isUnlocked;
  final int requiredLevel;

  const ManagerSkill({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.costPoints = 1,
    this.isUnlocked = false,
    this.requiredLevel = 1,
  });

  ManagerSkill copyWith({bool? isUnlocked}) => ManagerSkill(
        id: id,
        name: name,
        icon: icon,
        description: description,
        costPoints: costPoints,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        requiredLevel: requiredLevel,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'description': description,
        'costPoints': costPoints,
        'isUnlocked': isUnlocked,
        'requiredLevel': requiredLevel,
      };

  factory ManagerSkill.fromJson(Map<String, dynamic> json) => ManagerSkill(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        description: json['description'] as String,
        costPoints: json['costPoints'] as int? ?? 1,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        requiredLevel: json['requiredLevel'] as int? ?? 1,
      );
}

class SkillBranch {
  final SkillBranchType type;
  final String name;
  final List<ManagerSkill> skills;

  const SkillBranch({
    required this.type,
    required this.name,
    required this.skills,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'name': name,
        'skills': skills.map((s) => s.toJson()).toList(),
      };

  factory SkillBranch.fromJson(Map<String, dynamic> json) => SkillBranch(
        type: SkillBranchType.values.firstWhere((t) => t.name == json['type']),
        name: json['name'] as String,
        skills: (json['skills'] as List<dynamic>)
            .map((s) => ManagerSkill.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class ManagerSkillTree {
  final List<SkillBranch> branches;

  const ManagerSkillTree({required this.branches});

  SkillBranch getBranch(SkillBranchType type) {
    return branches.firstWhere((b) => b.type == type);
  }

  bool isSkillUnlocked(String skillId) {
    for (final branch in branches) {
      for (final s in branch.skills) {
        if (s.id == skillId && s.isUnlocked) return true;
      }
    }
    return false;
  }

  ManagerSkillTree unlockSkill({
    required SkillBranchType branchType,
    required String skillId,
    required int availablePoints,
  }) {
    final updatedBranches = branches.map((branch) {
      if (branch.type != branchType) return branch;

      final updatedSkills = branch.skills.map((s) {
        if (s.id == skillId && availablePoints >= s.costPoints) {
          return s.copyWith(isUnlocked: true);
        }
        return s;
      }).toList();

      return SkillBranch(type: branch.type, name: branch.name, skills: updatedSkills);
    }).toList();

    return ManagerSkillTree(branches: updatedBranches);
  }

  static ManagerSkillTree createInitialTree() {
    return const ManagerSkillTree(
      branches: [
        SkillBranch(
          type: SkillBranchType.tactical,
          name: 'Taktik Dehası (Saha)',
          skills: [
            ManagerSkill(id: 'tac_1', name: 'Gegenpress Ustası', icon: '⚡', description: 'Rakip yarı sahada top kapma şansı +%12.'),
            ManagerSkill(id: 'tac_2', name: 'Duran Top Üstadı', icon: '🎯', description: 'Korner ve frikiklerden xG üretimi +%20.'),
            ManagerSkill(id: 'tac_3', name: 'Çelik Savunma', icon: '🛡️', description: 'Kalesini kapatma olasılığı +%15.'),
            ManagerSkill(id: 'tac_4', name: 'Hızlı Kontra', icon: '👟', description: 'Top kapıldıktan sonra şut şansı +%25.'),
            ManagerSkill(id: 'tac_5', name: 'Total Futbol', icon: '🌟', description: 'Tüm saha oyuncularına +2 OVR geçici maç buffı.'),
          ],
        ),
        SkillBranch(
          type: SkillBranchType.motivational,
          name: 'Motivasyon Ustası (Soyunma Odası)',
          skills: [
            ManagerSkill(id: 'mot_1', name: 'Devre Arası Ateşi', icon: '🔥', description: 'Devre arası konuşmalarında moral artışı 2 katı.'),
            ManagerSkill(id: 'mot_2', name: 'Kriz Çözücü', icon: '🧘', description: 'Kırmızı kart veya mağlubiyet serilerinde moral düşüşünü %50 azaltır.'),
            ManagerSkill(id: 'mot_3', name: 'Kaptanlık Bağı', icon: '👑', description: 'Kaptanın takıma sağladığı kimya bonusu +%25.'),
            ManagerSkill(id: 'mot_4', name: 'Geri Dönüş Ruhu', icon: '⚡', description: 'Mağlup durumdayken son 15 dakikada gol şansı +%30.'),
            ManagerSkill(id: 'mot_5', name: 'Sarsılmaz Birlik', icon: '🤝', description: 'Takım kimyası asla 60 altına düşmez.'),
          ],
        ),
        SkillBranch(
          type: SkillBranchType.transfer,
          name: 'Transfer Kurdu (Pazar)',
          skills: [
            ManagerSkill(id: 'tra_1', name: 'Sert Pazarlıkçı', icon: '💼', description: 'Bonservis pazarlıklarında başlangıç indirim payı +%15.'),
            ManagerSkill(id: 'tra_2', name: 'Menajer Ağı', icon: '🤝', description: 'Menajer komisyonu ücretini %8 yerine %4 yapar.'),
            ManagerSkill(id: 'tra_3', name: 'Gözlem Radarı', icon: '📡', description: 'Scout keşif süresini %30 kısaltır.'),
            ManagerSkill(id: 'tra_4', name: 'Cevher Avcısı', icon: '🌟', description: 'Gizli cevher (Wonderkid) keşif şansını 2 katına çıkarır.'),
            ManagerSkill(id: 'tra_5', name: 'Yıldız İkna Sanatı', icon: '💎', description: 'Yüksek maaş talep eden yıldızlar maaşlarını %20 düşürür.'),
          ],
        ),
        SkillBranch(
          type: SkillBranchType.academy,
          name: 'Altyapı Mimarı (Gelişim)',
          skills: [
            ManagerSkill(id: 'aca_1', name: 'Hızlı Parlama', icon: '🌱', description: '21 yaş altı oyuncuların antrenmandan kazandığı XP +%25.'),
            ManagerSkill(id: 'aca_2', name: 'Doğal Yetenek', icon: '🪄', description: 'Altyapıdan çıkan gençlerin potansiyel tabanı +3 artar.'),
            ManagerSkill(id: 'aca_3', name: 'Özel Mentorluk', icon: '👴', description: 'Kıdemli oyuncular genç oyunculara +5 OVR gelişim hızı kazandırır.'),
            ManagerSkill(id: 'aca_4', name: 'Bedelsiz A Takım', icon: '📝', description: 'Altyapı oyuncularını A Takıma taşırken imza parası ödenmez.'),
            ManagerSkill(id: 'aca_5', name: 'Akademi Fabrikası', icon: '🏭', description: 'Her sezon başı 2 ekstra elit altyapı adayı üretilir.'),
          ],
        ),
        SkillBranch(
          type: SkillBranchType.financial,
          name: 'Finansal Büyücü (Ekonomi)',
          skills: [
            ManagerSkill(id: 'fin_1', name: 'Sponsor Mıknatısı', icon: '💰', description: 'Tüm sponsorluk gelirlerini +%20 artırır.'),
            ManagerSkill(id: 'fin_2', name: 'Kombine Patlaması', icon: '🎟️', description: 'Bilet ve stadyum hasılatına +%15 ek gelir.'),
            ManagerSkill(id: 'fin_3', name: 'Düşük Faiz', icon: '🏦', description: 'Banka kredi faiz oranını %10 yerine %5 yapar.'),
            ManagerSkill(id: 'fin_4', name: 'Pasif Fonlar', icon: '📈', description: 'Offline bekleme gelirlerini saatlik 2 katına çıkarır.'),
            ManagerSkill(id: 'fin_5', name: 'Kulüp Hanedanı', icon: '👑', description: 'Her hafta kasaya sabit ₣5.000 kulüp fonu aktarılır.'),
          ],
        ),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
        'branches': branches.map((b) => b.toJson()).toList(),
      };

  factory ManagerSkillTree.fromJson(Map<String, dynamic> json) => ManagerSkillTree(
        branches: (json['branches'] as List<dynamic>)
            .map((b) => SkillBranch.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
}
