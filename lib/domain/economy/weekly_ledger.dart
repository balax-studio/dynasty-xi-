// domain/economy/weekly_ledger.dart
// Pure Dart. Single source of truth weekly ledger calculation (§15.3 & §15.4).

import '../entities/facility.dart';
import '../entities/game_state.dart';

class WeeklyLedger {
  // Gelirler
  final int matchdayRevenue;
  final int broadcastRevenue;
  final int sponsorshipRevenue;
  final int merchandiseRevenue;
  final int treasuryInterestRevenue;

  // Giderler
  final int playerWages;
  final int staffSalaries;
  final int facilityUpkeep;
  final int travelExpense;
  final int medicalExpense;
  final int loanInstallment;
  final int winBonusExpense;

  const WeeklyLedger({
    required this.matchdayRevenue,
    required this.broadcastRevenue,
    required this.sponsorshipRevenue,
    required this.merchandiseRevenue,
    required this.treasuryInterestRevenue,
    required this.playerWages,
    required this.staffSalaries,
    required this.facilityUpkeep,
    required this.travelExpense,
    required this.medicalExpense,
    required this.loanInstallment,
    required this.winBonusExpense,
  });

  int get totalIncome =>
      matchdayRevenue +
      broadcastRevenue +
      sponsorshipRevenue +
      merchandiseRevenue +
      treasuryInterestRevenue;

  int get totalExpenses =>
      playerWages +
      staffSalaries +
      facilityUpkeep +
      travelExpense +
      medicalExpense +
      loanInstallment +
      winBonusExpense;

  int get netCashFlow => totalIncome - totalExpenses;

  Map<String, dynamic> toJson() => {
        'matchdayRevenue': matchdayRevenue,
        'broadcastRevenue': broadcastRevenue,
        'sponsorshipRevenue': sponsorshipRevenue,
        'merchandiseRevenue': merchandiseRevenue,
        'treasuryInterestRevenue': treasuryInterestRevenue,
        'playerWages': playerWages,
        'staffSalaries': staffSalaries,
        'facilityUpkeep': facilityUpkeep,
        'travelExpense': travelExpense,
        'medicalExpense': medicalExpense,
        'loanInstallment': loanInstallment,
        'winBonusExpense': winBonusExpense,
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'netCashFlow': netCashFlow,
      };

  factory WeeklyLedger.fromJson(Map<String, dynamic> json) => WeeklyLedger(
        matchdayRevenue: json['matchdayRevenue'] as int? ?? 0,
        broadcastRevenue: json['broadcastRevenue'] as int? ?? 0,
        sponsorshipRevenue: json['sponsorshipRevenue'] as int? ?? 0,
        merchandiseRevenue: json['merchandiseRevenue'] as int? ?? 0,
        treasuryInterestRevenue: json['treasuryInterestRevenue'] as int? ?? 0,
        playerWages: json['playerWages'] as int? ?? 0,
        staffSalaries: json['staffSalaries'] as int? ?? 0,
        facilityUpkeep: json['facilityUpkeep'] as int? ?? 0,
        travelExpense: json['travelExpense'] as int? ?? 0,
        medicalExpense: json['medicalExpense'] as int? ?? 0,
        loanInstallment: json['loanInstallment'] as int? ?? 0,
        winBonusExpense: json['winBonusExpense'] as int? ?? 0,
      );
}

class WeeklyLedgerCalculator {
  /// Calculates the exact weekly balance for the given game state (§15.3).
  static WeeklyLedger calculate({
    required GameState state,
    required bool isHomeMatch,
    bool isWin = false,
  }) {
    final club = state.userClub;
    final tier = state.currentLeague.tier;

    // --- GELİRLER ---
    // 1. Maç Günü / Bilet Hasılatı
    int matchdayRev = 0;
    if (isHomeMatch) {
      final stadiumLvl = club.facilities[FacilityType.stadium]?.level ?? 1;
      final stadiumCapacity = 1500 + (stadiumLvl * 1500);
      final fanRate = (club.meters.fans / 100.0).clamp(0.40, 1.0);
      final attendance = (stadiumCapacity * fanRate).round();
      final ticketPrice = club.ticketPrice > 0 ? club.ticketPrice : 15;
      matchdayRev = attendance * ticketPrice;
    }

    // 2. Yayın Geliri
    final baseBroadcast = 2200 + ((21 - tier) * 650);
    final broadcastRev = (baseBroadcast * (isHomeMatch ? 1.0 : 0.85)).round();

    // 3. Sponsorluk & VIP
    int sponsorRev = state.sleeveSponsorIncome + state.stadiumNamingIncome + club.sponsorWeeklyIncome;
    for (final contract in state.activeSponsorships.values) {
      sponsorRev += contract.weeklyIncome;
    }
    for (final vip in state.vipBoxDeals) {
      if (vip.isSold) {
        sponsorRev += (vip.seasonPrice ~/ 20);
      }
    }

    // 4. Merchandising
    final merchRev = ((club.meters.fans * 25) + (state.manager.reputation * 15)).round();

    // 5. Hazine Faizi
    final interestRev = (state.treasuryDeposit * 0.005).round();

    // --- GİDERLER ---
    // 1. Futbolcu Maaşları
    int wages = 0;
    for (final player in club.squad) {
      wages += player.weeklyWage;
    }
    for (final deal in state.activeLoanDeals) {
      wages += deal.weeklyWageToPay;
    }

    // 2. Personel Maaşları
    int staffSalaries = state.headCoach?.weeklyWage ?? 0;
    for (final member in state.staff) {
      staffSalaries += member.weeklySalary;
    }

    // 3. Tesis Bakımı
    int facilityUpkeep = 0;
    facilityUpkeep += (club.facilities[FacilityType.stadium]?.level ?? 1) * 220;
    facilityUpkeep += (club.facilities[FacilityType.trainingGround]?.level ?? 1) * 160;
    facilityUpkeep += (club.facilities[FacilityType.youthAcademy]?.level ?? 1) * 180;
    facilityUpkeep += (club.facilities[FacilityType.scoutCenter]?.level ?? 1) * 140;
    facilityUpkeep += (club.facilities[FacilityType.medicalCenter]?.level ?? 1) * 150;
    facilityUpkeep += (club.facilities[FacilityType.analyticsDept]?.level ?? 1) * 130;

    // 4. Seyahat Masrafı
    final travelExp = isHomeMatch ? 300 : (1200 + ((21 - tier) * 180));

    // 5. Sağlık ve Tedavi Masrafı
    final injuredCount = club.squad.where((p) => p.isInjured).length;
    final medLvl = club.facilities[FacilityType.medicalCenter]?.level ?? 1;
    final medicalExp = (medLvl * 160) + (injuredCount * 280);

    // 6. Kredi Taksiti
    final loanInstallment = state.activeLoan?.weeklyPayment ?? 0;

    // 7. Prim
    final winBonus = (isWin && state.winBonusPerMatch > 0) ? (state.winBonusPerMatch * 11) : 0;

    return WeeklyLedger(
      matchdayRevenue: matchdayRev,
      broadcastRevenue: broadcastRev,
      sponsorshipRevenue: sponsorRev,
      merchandiseRevenue: merchRev,
      treasuryInterestRevenue: interestRev,
      playerWages: wages,
      staffSalaries: staffSalaries,
      facilityUpkeep: facilityUpkeep,
      travelExpense: travelExp,
      medicalExpense: medicalExp,
      loanInstallment: loanInstallment,
      winBonusExpense: winBonus,
    );
  }
}
