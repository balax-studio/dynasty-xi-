// test/domain/finance_depth_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/economy/financial_statement.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/facility.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/player.dart';

void main() {
  group('FinancialStatementCalculator & Deep Economy Tests', () {
    late Club testClub;

    setUp(() {
      final squad = [
        const Player(
          id: 'p1',
          firstName: 'Ahmet',
          lastName: 'Yıldız',
          countryCode: 'TR',
          age: 24,
          position: Position.st,
          pace: 80,
          technique: 75,
          shooting: 82,
          passing: 70,
          defending: 40,
          physical: 75,
          mentality: 78,
          potential: 85,
          weeklyWage: 2500,
        ),
        const Player(
          id: 'p2',
          firstName: 'Mehmet',
          lastName: 'Kaya',
          countryCode: 'TR',
          age: 26,
          position: Position.cm,
          pace: 72,
          technique: 78,
          shooting: 70,
          passing: 80,
          defending: 65,
          physical: 70,
          mentality: 74,
          potential: 80,
          weeklyWage: 1800,
        ),
      ];

      testClub = Club(
        id: 'club_1',
        name: 'Kadıköy Retro FC',
        city: 'İstanbul',
        leagueTier: 20,
        meters: const ClubMeters(cash: 45000, fans: 80),
        facilities: {
          FacilityType.stadium: const Facility(
            type: FacilityType.stadium,
            level: 3,
          ),
        },
        squad: squad,
        sponsorWeeklyIncome: 5000,
        ticketPrice: 20,
      );
    });

    test('calculateWeeklyStatement correctly aggregates all revenue and expense streams', () {
      final statement = FinancialStatementCalculator.calculateWeeklyStatement(
        club: testClub,
        sleeveSponsorIncome: 1800,
        stadiumNamingIncome: 3000,
        activeLoanWeeklyRepayment: 2000,
        treasuryDeposit: 20000,
      );

      // Default capacity at level 3 = 10,000. 10,000 * 0.8 = 8,000. Ticket income: 8,000 * 20 = 160,000.
      expect(statement.ticketIncome, equals(testClub.stadiumCapacity * (80 / 100) * 20));
      expect(statement.mainSponsorIncome, equals(5000));
      expect(statement.sleeveSponsorIncome, equals(1800));
      expect(statement.stadiumNamingIncome, equals(3000));
      expect(statement.treasuryInterestIncome, equals(500)); // 20,000 * 0.025 = 500
      expect(statement.playerWagesExpense, equals(4300)); // 2500 + 1800
      expect(statement.loanRepaymentExpense, equals(2000));
      expect(statement.netProfitOrLoss, greaterThan(0));
    });

    test('evaluateFfp detects safe, warning, and critical risk bands', () {
      final safeFfp = FinancialStatementCalculator.evaluateFfp(
        totalWeeklyWages: 3000,
        totalWeeklyIncome: 10000, // 30% ratio
      );
      expect(safeFfp.riskLevel, equals(FfpRiskLevel.safe));

      final warningFfp = FinancialStatementCalculator.evaluateFfp(
        totalWeeklyWages: 7500,
        totalWeeklyIncome: 10000, // 75% ratio
      );
      expect(warningFfp.riskLevel, equals(FfpRiskLevel.warning));

      final criticalFfp = FinancialStatementCalculator.evaluateFfp(
        totalWeeklyWages: 9500,
        totalWeeklyIncome: 10000, // 95% ratio
      );
      expect(criticalFfp.riskLevel, equals(FfpRiskLevel.critical));
    });

    test('BankLoan early repayment discount is 5%', () {
      const loan = BankLoan(
        principalAmount: 50000,
        interestRate: 0.10,
        totalWeeks: 10,
        remainingWeeks: 5,
      );

      expect(loan.totalRepayment, equals(55000));
      expect(loan.weeklyPayment, equals(5500));
      expect(loan.remainingDebt, equals(27500));
      expect(loan.earlyRepaymentDiscountedAmount, equals((27500 * 0.95).round()));
    });

    test('Sponsorship and loan packages catalogs contain tiered items', () {
      final deals = FinancialStatementCalculator.getAvailableSponsorshipDeals(20);
      expect(deals.isNotEmpty, isTrue);
      expect(deals.any((d) => d.slot == SponsorshipSlot.mainShirt), isTrue);
      expect(deals.any((d) => d.slot == SponsorshipSlot.sleeve), isTrue);
      expect(deals.any((d) => d.slot == SponsorshipSlot.stadiumNaming), isTrue);

      final packages = FinancialStatementCalculator.getAvailableLoanPackages();
      expect(packages.length, equals(3));
      expect(packages.first.principalAmount, equals(15000));
    });
  });
}
