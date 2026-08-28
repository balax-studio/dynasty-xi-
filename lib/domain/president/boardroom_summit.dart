// domain/president/boardroom_summit.dart
// Boardroom Summit, VIP Box sales, Capital Injection, and Divan Council mechanics (§15.5)

class VipBoxDeal {
  final String id;
  final String companyName;
  final String companyIcon;
  final int seasonPrice;
  final int seatsCount;
  final bool isSold;
  final String perkDescription;

  const VipBoxDeal({
    required this.id,
    required this.companyName,
    required this.companyIcon,
    required this.seasonPrice,
    required this.seatsCount,
    this.isSold = false,
    required this.perkDescription,
  });

  VipBoxDeal copyWith({bool? isSold}) {
    return VipBoxDeal(
      id: id,
      companyName: companyName,
      companyIcon: companyIcon,
      seasonPrice: seasonPrice,
      seatsCount: seatsCount,
      isSold: isSold ?? this.isSold,
      perkDescription: perkDescription,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyName': companyName,
        'companyIcon': companyIcon,
        'seasonPrice': seasonPrice,
        'seatsCount': seatsCount,
        'isSold': isSold,
        'perkDescription': perkDescription,
      };

  factory VipBoxDeal.fromJson(Map<String, dynamic> json) => VipBoxDeal(
        id: json['id'] as String,
        companyName: json['companyName'] as String,
        companyIcon: json['companyIcon'] as String? ?? '[KULÜP]',
        seasonPrice: json['seasonPrice'] as int,
        seatsCount: json['seatsCount'] as int? ?? 12,
        isSold: json['isSold'] as bool? ?? false,
        perkDescription: json['perkDescription'] as String? ?? '',
      );
}

class CapitalInjectionOption {
  final String id;
  final String title;
  final int cashAmount;
  final int boardTrustBonus;
  final int fanBonus;
  final String icon;
  final String description;

  const CapitalInjectionOption({
    required this.id,
    required this.title,
    required this.cashAmount,
    required this.boardTrustBonus,
    required this.fanBonus,
    required this.icon,
    required this.description,
  });
}

class BoardroomMotion {
  final String id;
  final String title;
  final String description;
  final int yesVotes;
  final int noVotes;
  final int requiredCost;
  final String rewardDescription;
  final bool isVoted;
  final bool isApproved;

  const BoardroomMotion({
    required this.id,
    required this.title,
    required this.description,
    required this.yesVotes,
    required this.noVotes,
    required this.requiredCost,
    required this.rewardDescription,
    this.isVoted = false,
    this.isApproved = false,
  });

  BoardroomMotion copyWith({bool? isVoted, bool? isApproved}) {
    return BoardroomMotion(
      id: id,
      title: title,
      description: description,
      yesVotes: yesVotes,
      noVotes: noVotes,
      requiredCost: requiredCost,
      rewardDescription: rewardDescription,
      isVoted: isVoted ?? this.isVoted,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}

class BoardroomCatalog {
  static List<VipBoxDeal> getInitialVipBoxes() {
    return const [
      VipBoxDeal(
        id: 'vip_kocak_holding',
        companyName: 'Koçak Holding VIP Lounge',
        companyIcon: '[YÖNETİM]',
        seasonPrice: 35000,
        seatsCount: 16,
        perkDescription: 'Holding yöneticilerine 1 sezonluk protokol locası. Peşin milyonluk nakit sağlar.',
      ),
      VipBoxDeal(
        id: 'vip_neotech_lounge',
        companyName: 'NeoTech Global Suite',
        companyIcon: '',
        seasonPrice: 28000,
        seatsCount: 12,
        perkDescription: 'Teknoloji devi sponsorluk locası. Sezon başı büyük nakit girişi.',
      ),
      VipBoxDeal(
        id: 'vip_apex_petrol',
        companyName: 'Apex Energy Skybox',
        companyIcon: '',
        seasonPrice: 42000,
        seatsCount: 20,
        perkDescription: 'Stadyumun en prestijli merkez locası. Yüksek gelirli iş insanlarını ağırlar.',
      ),
      VipBoxDeal(
        id: 'vip_atlas_logistics',
        companyName: 'Atlas Lojistik Club',
        companyIcon: '',
        seasonPrice: 22000,
        seatsCount: 10,
        perkDescription: 'Uluslararası taşımacılık devi için ayrılmış özel tribün locası.',
      ),
    ];
  }

  static List<CapitalInjectionOption> getCapitalInjections() {
    return const [
      CapitalInjectionOption(
        id: 'inject_small_grant',
        title: 'Başkanlık Acil Hibe Fonu',
        cashAmount: 50000,
        boardTrustBonus: 8,
        fanBonus: 5,
        icon: '[TL]',
        description: 'Başkan şahsi servetinden kulüp kasasına ₣50,000 karşılıksız hibe aktarır.',
      ),
      CapitalInjectionOption(
        id: 'inject_mega_capital',
        title: 'Genel Kurul Sermaye Artırımı',
        cashAmount: 150000,
        boardTrustBonus: 15,
        fanBonus: 10,
        icon: 'DIAMOND',
        description: 'Büyük transfer bütçesi için kulübün sermayesini artırarak kasaya ₣150,000 aktarır.',
      ),
      CapitalInjectionOption(
        id: 'inject_stadium_bond',
        title: 'Başkanlık Tahvili & Gayrimenkul Fonu',
        cashAmount: 300000,
        boardTrustBonus: 25,
        fanBonus: 18,
        icon: '[YÖNETİM]',
        description: 'Kulüp mülklerini teminat gösterip şahsi garantiyle devasa ₣300,000 bütçe yaratır.',
      ),
    ];
  }

  static List<BoardroomMotion> getMotions() {
    return const [
      BoardroomMotion(
        id: 'motion_stadium_expansion',
        title: 'Tribün Kapasite Artışı Oylaması',
        description: 'Kale arkası tribünlerine 2,500 ekstra koltuk ekleme tasarısı.',
        yesVotes: 14,
        noVotes: 4,
        requiredCost: 40000,
        rewardDescription: 'Stadyum kapasitesi +2,500 artar, her maç bilet hasılatı katlanır.',
      ),
      BoardroomMotion(
        id: 'motion_youth_scholarship',
        title: 'Balkan & Afrika Altyapı Bursu',
        description: 'Yurtdışından 3 genç yeteneği kulüp akademisine kazandırma fonu.',
        yesVotes: 16,
        noVotes: 2,
        requiredCost: 25000,
        rewardDescription: 'Akademiye 4 potansiyelli wonderkid eklenir.',
      ),
      BoardroomMotion(
        id: 'motion_club_channel',
        title: 'Retro TV & Dijital Yayın Ağı',
        description: 'Kulübün kendi dijital TV kanalını ve yayın stüdyosunu kurma tasarısı.',
        yesVotes: 11,
        noVotes: 7,
        requiredCost: 30000,
        rewardDescription: 'Haftalık düzenli +₣2,500 medya ve fan shop geliri açılır.',
      ),
    ];
  }
}
