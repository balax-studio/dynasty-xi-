// domain/economy/financial_statement.dart
// Detailed financial statement, 3-slot sponsorship and bank loan calculator (§15.2, §15.3, §A.7)

import '../entities/club.dart';
import '../entities/facility.dart';

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
  final int playerWagesExpense;
  final int facilityUpkeepExpense;
  final int loanRepaymentExpense;

  const FinancialStatement({
    required this.ticketIncome,
    required this.mainSponsorIncome,
    required this.sleeveSponsorIncome,
    required this.stadiumNamingIncome,
    required this.fanShopIncome,
    required this.playerWagesExpense,
    required this.facilityUpkeepExpense,
    required this.loanRepaymentExpense,
  });

  int get totalIncome => ticketIncome + mainSponsorIncome + sleeveSponsorIncome + stadiumNamingIncome + fanShopIncome;
  int get totalExpenses => playerWagesExpense + facilityUpkeepExpense + loanRepaymentExpense;
  int get netProfitOrLoss => totalIncome - totalExpenses;
}

class FinancialStatementCalculator {
  static FinancialStatement calculateWeeklyStatement({
    required Club club,
    int sleeveSponsorIncome = 0,
    int stadiumNamingIncome = 0,
    int activeLoanWeeklyRepayment = 0,
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

    // 3. Masraflar
    final wages = club.totalWeeklyWages;
    final upkeep = club.totalWeeklyMaintenance;

    return FinancialStatement(
      ticketIncome: ticketIncome,
      mainSponsorIncome: club.sponsorWeeklyIncome,
      sleeveSponsorIncome: sleeveSponsorIncome,
      stadiumNamingIncome: stadiumNamingIncome,
      fanShopIncome: fanShopIncome,
      playerWagesExpense: wages,
      facilityUpkeepExpense: upkeep,
      loanRepaymentExpense: activeLoanWeeklyRepayment,
    );
  }
}
