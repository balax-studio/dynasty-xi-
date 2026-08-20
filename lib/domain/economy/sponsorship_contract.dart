// domain/economy/sponsorship_contract.dart
// Stateful Sponsorship Contract, Catalog, and RPG Trade-offs (+ / -) Engine (§15.2, §15.3, §A.7)

import 'financial_statement.dart';

class SponsorshipPerk {
  final String description;
  final int fanDelta;
  final int boardTrustDelta;
  final int lockerRoomDelta;
  final double facilityDiscount;
  final double domesticTransferDiscount;
  final int matchWinBonus;

  const SponsorshipPerk({
    required this.description,
    this.fanDelta = 0,
    this.boardTrustDelta = 0,
    this.lockerRoomDelta = 0,
    this.facilityDiscount = 0.0,
    this.domesticTransferDiscount = 0.0,
    this.matchWinBonus = 0,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'fanDelta': fanDelta,
        'boardTrustDelta': boardTrustDelta,
        'lockerRoomDelta': lockerRoomDelta,
        'facilityDiscount': facilityDiscount,
        'domesticTransferDiscount': domesticTransferDiscount,
        'matchWinBonus': matchWinBonus,
      };

  factory SponsorshipPerk.fromJson(Map<String, dynamic> json) => SponsorshipPerk(
        description: json['description'] as String? ?? '',
        fanDelta: json['fanDelta'] as int? ?? 0,
        boardTrustDelta: json['boardTrustDelta'] as int? ?? 0,
        lockerRoomDelta: json['lockerRoomDelta'] as int? ?? 0,
        facilityDiscount: (json['facilityDiscount'] as num?)?.toDouble() ?? 0.0,
        domesticTransferDiscount: (json['domesticTransferDiscount'] as num?)?.toDouble() ?? 0.0,
        matchWinBonus: json['matchWinBonus'] as int? ?? 0,
      );
}

class SponsorshipRisk {
  final String description;
  final int fanDelta;
  final int boardTrustDelta;
  final double inspectionCrisisChance;
  final int earlyTerminationPenalty;

  const SponsorshipRisk({
    required this.description,
    this.fanDelta = 0,
    this.boardTrustDelta = 0,
    this.inspectionCrisisChance = 0.0,
    this.earlyTerminationPenalty = 15000,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'fanDelta': fanDelta,
        'boardTrustDelta': boardTrustDelta,
        'inspectionCrisisChance': inspectionCrisisChance,
        'earlyTerminationPenalty': earlyTerminationPenalty,
      };

  factory SponsorshipRisk.fromJson(Map<String, dynamic> json) => SponsorshipRisk(
        description: json['description'] as String? ?? '',
        fanDelta: json['fanDelta'] as int? ?? 0,
        boardTrustDelta: json['boardTrustDelta'] as int? ?? 0,
        inspectionCrisisChance: (json['inspectionCrisisChance'] as num?)?.toDouble() ?? 0.0,
        earlyTerminationPenalty: json['earlyTerminationPenalty'] as int? ?? 15000,
      );
}

class SponsorshipContract {
  final String id;
  final SponsorshipSlot slot;
  final String brandName;
  final String brandIcon;
  final String sector;
  final int durationWeeks;
  final int weeksRemaining;
  final int weeklyIncome;
  final int signingBonus;
  final int minLeagueTier;
  final SponsorshipPerk perk;
  final SponsorshipRisk risk;

  const SponsorshipContract({
    required this.id,
    required this.slot,
    required this.brandName,
    required this.brandIcon,
    required this.sector,
    required this.durationWeeks,
    required this.weeksRemaining,
    required this.weeklyIncome,
    required this.signingBonus,
    this.minLeagueTier = 20,
    required this.perk,
    required this.risk,
  });

  bool get isExpired => weeksRemaining <= 0;

  SponsorshipContract copyWith({
    String? id,
    SponsorshipSlot? slot,
    String? brandName,
    String? brandIcon,
    String? sector,
    int? durationWeeks,
    int? weeksRemaining,
    int? weeklyIncome,
    int? signingBonus,
    int? minLeagueTier,
    SponsorshipPerk? perk,
    SponsorshipRisk? risk,
  }) {
    return SponsorshipContract(
      id: id ?? this.id,
      slot: slot ?? this.slot,
      brandName: brandName ?? this.brandName,
      brandIcon: brandIcon ?? this.brandIcon,
      sector: sector ?? this.sector,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      weeksRemaining: weeksRemaining ?? this.weeksRemaining,
      weeklyIncome: weeklyIncome ?? this.weeklyIncome,
      signingBonus: signingBonus ?? this.signingBonus,
      minLeagueTier: minLeagueTier ?? this.minLeagueTier,
      perk: perk ?? this.perk,
      risk: risk ?? this.risk,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slot': slot.name,
        'brandName': brandName,
        'brandIcon': brandIcon,
        'sector': sector,
        'durationWeeks': durationWeeks,
        'weeksRemaining': weeksRemaining,
        'weeklyIncome': weeklyIncome,
        'signingBonus': signingBonus,
        'minLeagueTier': minLeagueTier,
        'perk': perk.toJson(),
        'risk': risk.toJson(),
      };

  factory SponsorshipContract.fromJson(Map<String, dynamic> json) {
    return SponsorshipContract(
      id: json['id'] as String,
      slot: SponsorshipSlot.values.firstWhere(
        (s) => s.name == json['slot'],
        orElse: () => SponsorshipSlot.mainShirt,
      ),
      brandName: json['brandName'] as String,
      brandIcon: json['brandIcon'] as String,
      sector: json['sector'] as String? ?? 'Genel',
      durationWeeks: json['durationWeeks'] as int? ?? 21,
      weeksRemaining: json['weeksRemaining'] as int? ?? 21,
      weeklyIncome: json['weeklyIncome'] as int,
      signingBonus: json['signingBonus'] as int,
      minLeagueTier: json['minLeagueTier'] as int? ?? 20,
      perk: json['perk'] != null
          ? SponsorshipPerk.fromJson(json['perk'] as Map<String, dynamic>)
          : const SponsorshipPerk(description: 'Standart sponsorluk'),
      risk: json['risk'] != null
          ? SponsorshipRisk.fromJson(json['risk'] as Map<String, dynamic>)
          : const SponsorshipRisk(description: 'Standart şartlar'),
    );
  }
}

class SponsorshipCatalog {
  static List<SponsorshipContract> getAvailableContracts(int leagueTier) {
    final tierMultiplier = 1.0 + (20 - leagueTier.clamp(1, 20)) * 0.25;

    final baseContracts = <SponsorshipContract>[
      // ==========================================
      // 1. ANA GÖĞÜS SPONSORLARI (MAIN SHIRT)
      // ==========================================
      const SponsorshipContract(
        id: 'main_cryptobet_cyber',
        slot: SponsorshipSlot.mainShirt,
        brandName: 'CryptoBet Cyber',
        brandIcon: '🪙',
        sector: 'Kripto & Bahis Borsası',
        durationWeeks: 21,
        weeksRemaining: 21,
        weeklyIncome: 35000,
        signingBonus: 100000,
        minLeagueTier: 20,
        perk: SponsorshipPerk(
          description: 'Devasa anlık nakit ve haftalık bütçe desteği.',
          matchWinBonus: 5000,
        ),
        risk: SponsorshipRisk(
          description: 'Etik tartışmalar: Taraftar -6%, Güven -4%. Derbi mağlubiyetinde linç riski.',
          fanDelta: -6,
          boardTrustDelta: -4,
          inspectionCrisisChance: 0.15,
          earlyTerminationPenalty: 45000,
        ),
      ),
      const SponsorshipContract(
        id: 'main_anadolu_celik',
        slot: SponsorshipSlot.mainShirt,
        brandName: 'Anadolu Çelik Holding',
        brandIcon: '🏭',
        sector: 'Yerli Ağır Sanayi',
        durationWeeks: 42,
        weeksRemaining: 42,
        weeklyIncome: 18500,
        signingBonus: 45000,
        minLeagueTier: 20,
        perk: SponsorshipPerk(
          description: 'Yerli taraftar ve yönetim kurulundan tam destek. Yerli transferlerde %10 indirim.',
          fanDelta: 6,
          boardTrustDelta: 8,
          domesticTransferDiscount: 0.10,
        ),
        risk: SponsorshipRisk(
          description: '2 sezonluk uzun bağlayıcılık. Ortalama haftalık gelir.',
          earlyTerminationPenalty: 25000,
        ),
      ),
      const SponsorshipContract(
        id: 'main_ecofuture_energy',
        slot: SponsorshipSlot.mainShirt,
        brandName: 'EcoFuture Yeşil Enerji',
        brandIcon: '🌱',
        sector: 'Ekoloji & Temiz Teknoloji',
        durationWeeks: 21,
        weeksRemaining: 21,
        weeklyIncome: 14000,
        signingBonus: 30000,
        minLeagueTier: 20,
        perk: SponsorshipPerk(
          description: 'Yüksek kurumsal itibar ve taraftar sevgisi. Tesis geliştirme maliyetinde %20 indirim.',
          fanDelta: 12,
          boardTrustDelta: 10,
          facilityDiscount: 0.20,
        ),
        risk: SponsorshipRisk(
          description: 'Düşük nakit akışı. Disiplinsiz oyuncu transferinde itibar kaybı.',
          earlyTerminationPenalty: 18000,
        ),
      ),
      const SponsorshipContract(
        id: 'main_dynasty_aero',
        slot: SponsorshipSlot.mainShirt,
        brandName: 'Dynasty Global Havayolları',
        brandIcon: '✈️',
        sector: 'Uluslararası Havacılık',
        durationWeeks: 42,
        weeksRemaining: 42,
        weeklyIncome: 42000,
        signingBonus: 120000,
        minLeagueTier: 10,
        perk: SponsorshipPerk(
          description: 'Elit kurumsal prestij ve Avrupa deplasmanlarında prim desteği.',
          fanDelta: 8,
          boardTrustDelta: 12,
        ),
        risk: SponsorshipRisk(
          description: 'Ligde ilk 5 dışında kalınırsa yönetim kurulu güven kaybı (-8%).',
          earlyTerminationPenalty: 60000,
        ),
      ),

      // ==========================================
      // 2. STADYUM İSİM HAKKI (STADIUM NAMING)
      // ==========================================
      const SponsorshipContract(
        id: 'stadium_vostok_minerals',
        slot: SponsorshipSlot.stadiumNaming,
        brandName: 'Vostok Mining Arena',
        brandIcon: '⛏️',
        sector: 'Uluslararası Madencilik',
        durationWeeks: 42,
        weeksRemaining: 42,
        weeklyIncome: 50000,
        signingBonus: 150000,
        minLeagueTier: 20,
        perk: SponsorshipPerk(
          description: 'Maksimum stadyum fonu ve anlık yüksek likidite.',
          boardTrustDelta: 5,
        ),
        risk: SponsorshipRisk(
          description: 'Her 5 haftada bir %15 ihtimalle Maliye / Federasyon denetim krizi tetikler.',
          inspectionCrisisChance: 0.15,
          earlyTerminationPenalty: 75000,
        ),
      ),
      const SponsorshipContract(
        id: 'stadium_halk_sigorta',
        slot: SponsorshipSlot.stadiumNaming,
        brandName: 'Halk Sigorta Park',
        brandIcon: '🛡️',
        sector: 'Geleneksel Finans & Sigorta',
        durationWeeks: 21,
        weeksRemaining: 21,
        weeklyIncome: 22000,
        signingBonus: 55000,
        minLeagueTier: 20,
        perk: SponsorshipPerk(
          description: 'Güvenilir ve düzenli gelir. Banka kredi faizlerinde %3 indirim.',
          boardTrustDelta: 7,
        ),
        risk: SponsorshipRisk(
          description: 'Erken fesihte 2 katı tazminat cezası uygulanır.',
          earlyTerminationPenalty: 35000,
        ),
      ),

      // ==========================================
      // 3. KOL & ŞORT SPONSORLARI (SLEEVE)
      // ==========================================
      const SponsorshipContract(
        id: 'sleeve_neospeed_fiber',
        slot: SponsorshipSlot.sleeve,
        brandName: 'NeoSpeed 10G Fiber',
        brandIcon: '📡',
        sector: 'Telekom & Siber Ağ',
        durationWeeks: 21,
        weeksRemaining: 21,
        weeklyIncome: 12000,
        signingBonus: 25000,
        minLeagueTier: 20,
        perk: SponsorshipPerk(
          description: 'Maç günü dijital yayın geliri bonusu (+₣2.500/maç).',
          fanDelta: 4,
        ),
        risk: SponsorshipRisk(
          description: 'Küme düşme hattına inilirse sözleşmeyi tek taraflı feshedebilir.',
          earlyTerminationPenalty: 12000,
        ),
      ),
      const SponsorshipContract(
        id: 'sleeve_voltbit_energy',
        slot: SponsorshipSlot.sleeve,
        brandName: 'VoltBit Bio-Energy',
        brandIcon: '⚡',
        sector: 'Enerji & Performans',
        durationWeeks: 21,
        weeksRemaining: 21,
        weeklyIncome: 8500,
        signingBonus: 18000,
        minLeagueTier: 20,
        perk: SponsorshipPerk(
          description: 'Soyunma odası motivasyonu (+4 Moral) ve maç başı prim.',
          lockerRoomDelta: 4,
        ),
        risk: SponsorshipRisk(
          description: 'Düşük peşinat, standart fesih koşulları.',
          earlyTerminationPenalty: 8000,
        ),
      ),
    ];

    if (tierMultiplier == 1.0) return baseContracts;

    return baseContracts.map((c) {
      return c.copyWith(
        weeklyIncome: (c.weeklyIncome * tierMultiplier).round(),
        signingBonus: (c.signingBonus * tierMultiplier).round(),
      );
    }).toList();
  }
}
