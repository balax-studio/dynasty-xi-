// domain/economy/financial_statement.dart
// Detailed financial statement, 3-slot sponsorship, bank loans, treasury deposit and FFP calculator (§15.2, §15.3, §A.7)

import '../entities/club.dart';
import '../entities/facility.dart';

enum SponsorshipSlot {
  mainShirt('Ana Göğüs Sponsoru', '[GÖĞÜS]'),
  sleeve('Kol & Sırt Sponsoru', '[KOL]'),
  stadiumNaming('Stadyum İsim Hakkı', '[STADYUM]');

  final String label;
  final String icon;

  const SponsorshipSlot(this.label, this.icon);
}

class SponsorshipDeal {
  final String id;
  final SponsorshipSlot slot;
  final String brandName;
  final String brandIcon;
  final int weeklyIncome;
  final int signingBonus;
  final int minLeagueTier;
  final String perkDescription;

  const SponsorshipDeal({
    required this.id,
    required this.slot,
    required this.brandName,
    required this.brandIcon,
    required this.weeklyIncome,
    required this.signingBonus,
    this.minLeagueTier = 20,
    required this.perkDescription,
  });
}

class BankLoanPackage {
  final String id;
  final String name;
  final int principalAmount;
  final double interestRate;
  final int totalWeeks;
  final String icon;
  final String description;

  const BankLoanPackage({
    required this.id,
    required this.name,
    required this.principalAmount,
    required this.interestRate,
    required this.totalWeeks,
    required this.icon,
    required this.description,
  });

  int get totalRepayment => (principalAmount * (1.0 + interestRate)).round();
  int get weeklyPayment => (totalRepayment / totalWeeks).round();
}

enum FfpRiskLevel {
  safe('GÜVENLİ (YEŞİL LİSANS)', 'Maaş bütçesi sağlıklı. Transfer ve harcama kısıtlaması yok.'),
  warning('UYARI (MALİ İZLEME)', 'Maaş/Gelir oranı %70 üzerinde. Yeni harcamalarda dikkatli olun.'),
  critical('KRİTİK (TRANSFER YASAĞI RİSKİ)', 'Maaş giderleri geliri aşıyor! Acil oyuncu satışı veya tasarruf gerekli.');

  final String label;
  final String description;

  const FfpRiskLevel(this.label, this.description);
}

class FfpReport {
  final double wageToIncomeRatio; // 0.0 - 1.5+
  final FfpRiskLevel riskLevel;
  final int maxRecommendedWageBudget;
  final String recommendation;

  const FfpReport({
    required this.wageToIncomeRatio,
    required this.riskLevel,
    required this.maxRecommendedWageBudget,
    required this.recommendation,
  });
}

class BankLoan {
  final int principalAmount;
  final double interestRate;
  final int totalWeeks;
  final int remainingWeeks;

  const BankLoan({
    required this.principalAmount,
    this.interestRate = 0.10,
    this.totalWeeks = 10,
    required this.remainingWeeks,
  });

  int get totalRepayment => (principalAmount * (1.0 + interestRate)).round();
  int get weeklyPayment => (totalRepayment / totalWeeks).round();
  int get remainingDebt => weeklyPayment * remainingWeeks;
  bool get isPaidOff => remainingWeeks <= 0;

  /// Erken kapatma indirimi (%5 faiz tasarrufu)
  int get earlyRepaymentDiscountedAmount => (remainingDebt * 0.95).round();

  BankLoan payWeeklyInstallment() {
    if (isPaidOff) return this;
    return BankLoan(
      principalAmount: principalAmount,
      interestRate: interestRate,
      totalWeeks: totalWeeks,
      remainingWeeks: remainingWeeks - 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'principalAmount': principalAmount,
        'interestRate': interestRate,
        'totalWeeks': totalWeeks,
        'remainingWeeks': remainingWeeks,
      };

  factory BankLoan.fromJson(Map<String, dynamic> json) => BankLoan(
        principalAmount: json['principalAmount'] as int,
        interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.10,
        totalWeeks: json['totalWeeks'] as int? ?? 10,
        remainingWeeks: json['remainingWeeks'] as int,
      );
}

class FinancialStatement {
  final int ticketIncome;
  final int mainSponsorIncome;
  final int sleeveSponsorIncome;
  final int stadiumNamingIncome;
  final int fanShopIncome;
  final int treasuryInterestIncome;
  final int playerWagesExpense;
  final int facilityUpkeepExpense;
  final int loanRepaymentExpense;

  const FinancialStatement({
    required this.ticketIncome,
    required this.mainSponsorIncome,
    required this.sleeveSponsorIncome,
    required this.stadiumNamingIncome,
    required this.fanShopIncome,
    this.treasuryInterestIncome = 0,
    required this.playerWagesExpense,
    required this.facilityUpkeepExpense,
    required this.loanRepaymentExpense,
  });

  int get totalIncome =>
      ticketIncome +
      mainSponsorIncome +
      sleeveSponsorIncome +
      stadiumNamingIncome +
      fanShopIncome +
      treasuryInterestIncome;

  int get totalExpenses => playerWagesExpense + facilityUpkeepExpense + loanRepaymentExpense;
  int get netProfitOrLoss => totalIncome - totalExpenses;
}

class FinancialStatementCalculator {
  static FinancialStatement calculateWeeklyStatement({
    required Club club,
    int sleeveSponsorIncome = 0,
    int stadiumNamingIncome = 0,
    int activeLoanWeeklyRepayment = 0,
    int treasuryDeposit = 0,
  }) {
    // 1. Bilet Geliri (Stadyum Kapasitesi × Bilet Fiyatı × Taraftar Doluluk Oranı)
    final capacity = club.stadiumCapacity;
    final fanRatio = (club.meters.fans / 100.0).clamp(0.2, 1.0);
    final attendance = (capacity * fanRatio).round();
    final ticketIncome = attendance * club.ticketPrice;

    // 2. Taraftar Mağazası (Fan Shop) Geliri
    final fanShopFacility = club.facilities[FacilityType.fanShop];
    final fanShopLevel = fanShopFacility?.level ?? 0;
    final fanShopIncome = fanShopLevel > 0 ? (attendance * (fanShopLevel * 1.5)).round() : 0;

    // 3. Hazine Vadeli Mevduat Faizi (%2.5 haftalık)
    final treasuryInterest = (treasuryDeposit * 0.025).round();

    // 4. Masraflar
    final wages = club.totalWeeklyWages;
    final upkeep = club.totalWeeklyMaintenance;

    return FinancialStatement(
      ticketIncome: ticketIncome,
      mainSponsorIncome: club.sponsorWeeklyIncome,
      sleeveSponsorIncome: sleeveSponsorIncome,
      stadiumNamingIncome: stadiumNamingIncome,
      fanShopIncome: fanShopIncome,
      treasuryInterestIncome: treasuryInterest,
      playerWagesExpense: wages,
      facilityUpkeepExpense: upkeep,
      loanRepaymentExpense: activeLoanWeeklyRepayment,
    );
  }

  /// Finansal Fair Play (FFP) Raporu Hesapla
  static FfpReport evaluateFfp({
    required int totalWeeklyWages,
    required int totalWeeklyIncome,
  }) {
    final effectiveIncome = totalWeeklyIncome <= 0 ? 1 : totalWeeklyIncome;
    final ratio = totalWeeklyWages / effectiveIncome;
    final maxRecommended = (effectiveIncome * 0.70).round();

    if (ratio <= 0.65) {
      return FfpReport(
        wageToIncomeRatio: ratio,
        riskLevel: FfpRiskLevel.safe,
        maxRecommendedWageBudget: maxRecommended,
        recommendation: 'Maaş bütçeniz son derece dengeli. Kulüp yeni transferler için finansal alana sahip.',
      );
    } else if (ratio <= 0.85) {
      return FfpReport(
        wageToIncomeRatio: ratio,
        riskLevel: FfpRiskLevel.warning,
        maxRecommendedWageBudget: maxRecommended,
        recommendation: 'Maaş/Gelir oranı sınırda. Yeni transfer yapmadan önce kadrodaki yüksek maaşlı yedekleri elden çıkarın.',
      );
    } else {
      return FfpReport(
        wageToIncomeRatio: ratio,
        riskLevel: FfpRiskLevel.critical,
        maxRecommendedWageBudget: maxRecommended,
        recommendation: 'Kulüp zarar ediyor ve maaşlar geliri aşıyor! Oyuncu satılmazsa transfer yasağı riski doğabilir.',
      );
    }
  }

  /// Mevcut Sponsorluk Paketleri Kataloğu
  static List<SponsorshipDeal> getAvailableSponsorshipDeals(int leagueTier) {
    return [
      // 1. Ana Göğüs Sponsorları
      const SponsorshipDeal(
        id: 'main_cyber_telecom',
        slot: SponsorshipSlot.mainShirt,
        brandName: 'CyberTel Global',
        brandIcon: '',
        weeklyIncome: 4500,
        signingBonus: 10000,
        minLeagueTier: 20,
        perkDescription: 'Standart telekom ana sponsorluğu. Düzenli haftalık nakit akışı sağlar.',
      ),
      const SponsorshipDeal(
        id: 'main_apex_crypto',
        slot: SponsorshipSlot.mainShirt,
        brandName: 'Apex Vault Finans',
        brandIcon: '',
        weeklyIncome: 7200,
        signingBonus: 25000,
        minLeagueTier: 15,
        perkDescription: 'Yüksek bütçeli kripto borsası sponsoru. Cömert imza parası sunar.',
      ),
      const SponsorshipDeal(
        id: 'main_dynasty_aero',
        slot: SponsorshipSlot.mainShirt,
        brandName: 'Dynasty Havayolları',
        brandIcon: '',
        weeklyIncome: 12500,
        signingBonus: 50000,
        minLeagueTier: 8,
        perkDescription: 'Elit havayolu sponsoru. Üst liglerde devasa sponsorluk bütçesi açar.',
      ),

      // 2. Kol & Sırt Sponsorları
      const SponsorshipDeal(
        id: 'sleeve_retro_energy',
        slot: SponsorshipSlot.sleeve,
        brandName: 'VoltBit Enerji İçeceği',
        brandIcon: 'BOLT',
        weeklyIncome: 1800,
        signingBonus: 4000,
        minLeagueTier: 20,
        perkDescription: 'Kol sponsoru olarak maç başı ekstra motivasyon ve sabit haftalık gelir.',
      ),
      const SponsorshipDeal(
        id: 'sleeve_titan_auto',
        slot: SponsorshipSlot.sleeve,
        brandName: 'Titan Otomotiv',
        brandIcon: '',
        weeklyIncome: 3400,
        signingBonus: 8500,
        minLeagueTier: 14,
        perkDescription: 'Premium otomotiv kol sponsoru.',
      ),

      // 3. Stadyum İsim Hakkı
      const SponsorshipDeal(
        id: 'stadium_arena_plus',
        slot: SponsorshipSlot.stadiumNaming,
        brandName: 'Nexus Cyber Arena',
        brandIcon: '',
        weeklyIncome: 3500,
        signingBonus: 15000,
        minLeagueTier: 20,
        perkDescription: 'Stadyumun adını 1 sezonluğuna kiralayarak anında toplu nakit kazandırır.',
      ),
      const SponsorshipDeal(
        id: 'stadium_glory_dome',
        slot: SponsorshipSlot.stadiumNaming,
        brandName: 'Glory Quantum Park',
        brandIcon: '',
        weeklyIncome: 6500,
        signingBonus: 35000,
        minLeagueTier: 10,
        perkDescription: 'Fütüristik teknoloji devi stadyum isim ortaklığı.',
      ),
    ];
  }

  /// Mevcut Banka Kredisi Paketleri Kataloğu
  static List<BankLoanPackage> getAvailableLoanPackages() {
    return [
      const BankLoanPackage(
        id: 'loan_quick_cash',
        name: 'Hızlı Nakit Avansı',
        principalAmount: 15000,
        interestRate: 0.08,
        totalWeeks: 8,
        icon: '[TL]',
        description: 'Acil transferler ve oyuncu maaşları için düşük faizli hızlı avans.',
      ),
      const BankLoanPackage(
        id: 'loan_facility_growth',
        name: 'Tesis & Altyapı Yatırım Kredisi',
        principalAmount: 50000,
        interestRate: 0.12,
        totalWeeks: 12,
        icon: '[TESİS]',
        description: 'Stadyum ve gençlik akademisi inşaatlarını finanse etmek için orta vadeli kredi.',
      ),
      const BankLoanPackage(
        id: 'loan_dynasty_consolidation',
        name: 'Büyük Kulüp Konsolidasyon Kredisi',
        principalAmount: 120000,
        interestRate: 0.15,
        totalWeeks: 16,
        icon: '[YÖNETİM]',
        description: 'Büyük transfer bütçesi ve şampiyonluk hamlesi için maksimum fonlama.',
      ),
    ];
  }
}
