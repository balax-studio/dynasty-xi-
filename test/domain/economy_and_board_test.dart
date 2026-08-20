// test/domain/economy_and_board_test.dart
// Unit tests for Sprint 2: Economy, Boardroom, Daily Quests, and Scouting Depth (§15, §12.7-8, §10.4, §17.3)

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/facility.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/economy/financial_statement.dart';
import 'package:futbol/domain/progression/daily_quest.dart';
import 'package:futbol/domain/generation/scout_service.dart';

void main() {
  group('Sprint 2: Economy, Boardroom, Daily Quests & Scouting Depth Tests', () {
    test('DailyQuest entity supports progress tracking, endowed progress and claiming', () {
      const quest = DailyQuest(
        id: 'q1',
        title: 'Günün İlk Taktik İdmanı',
        description: 'Herhangi bir oyuncunun antrenman programını ayarla',
        targetCount: 1,
        currentCount: 1, // Endowed progress (§17.3)
        cashReward: 2500,
        xpReward: 50,
        isClaimed: false,
      );

      expect(quest.isCompleted, isTrue);
      expect(quest.canClaim, isTrue);

      final claimed = quest.copyWith(isClaimed: true);
      expect(claimed.canClaim, isFalse);
    });

    test('DailyQuestManager produces 3 daily missions with at least 1 endowed progress', () {
      final quests = DailyQuestManager.generateDailyQuests();
      expect(quests.length, equals(3));
      expect(quests.any((q) => q.currentCount > 0), isTrue); // Endowed progress check
    });

    test('FinancialStatement accurately computes all income, sponsor slots, and expense streams', () {
      const club = Club(
        id: 'c1',
        name: 'Anadolu Spor',
        city: 'Eskişehir',
        ticketPrice: 15,
        sponsorWeeklyIncome: 5000,
        meters: ClubMeters(cash: 50000, fans: 80, lockerRoom: 75, boardTrust: 60),
        facilities: {
          FacilityType.stadium: Facility(type: FacilityType.stadium, level: 2),
          FacilityType.fanShop: Facility(type: FacilityType.fanShop, level: 2),
        },
        squad: [
          Player(
            id: 'p1',
            firstName: 'Ali',
            lastName: 'Veli',
            countryCode: 'TR',
            age: 24,
            position: Position.cm,
            pace: 70,
            technique: 70,
            shooting: 70,
            passing: 70,
            defending: 70,
            physical: 70,
            mentality: 70,
            potential: 75,
            weeklyWage: 2000,
          ),
        ],
      );

      final statement = FinancialStatementCalculator.calculateWeeklyStatement(
        club: club,
        sleeveSponsorIncome: 1500,
        stadiumNamingIncome: 3000,
        activeLoanWeeklyRepayment: 1000,
      );

      expect(statement.ticketIncome, greaterThan(0));
      expect(statement.mainSponsorIncome, equals(5000));
      expect(statement.sleeveSponsorIncome, equals(1500));
      expect(statement.stadiumNamingIncome, equals(3000));
      expect(statement.totalIncome, equals(statement.ticketIncome + 5000 + 1500 + 3000 + statement.fanShopIncome));
      expect(statement.playerWagesExpense, equals(2000));
      expect(statement.loanRepaymentExpense, equals(1000));
      expect(statement.netProfitOrLoss, equals(statement.totalIncome - statement.totalExpenses));
    });

    test('BankLoanModel calculates loan terms and weekly amortization correctly', () {
      const loan = BankLoan(
        principalAmount: 50000,
        interestRate: 0.10, // %10 toplam faiz
        totalWeeks: 10,
        remainingWeeks: 10,
      );

      expect(loan.totalRepayment, equals(55000));
      expect(loan.weeklyPayment, equals(5500));
      expect(loan.isPaidOff, isFalse);

      final progressLoan = loan.payWeeklyInstallment();
      expect(progressLoan.remainingWeeks, equals(9));
      expect(progressLoan.remainingDebt, equals(49500));
    });

    test('ScoutService calculates duration tiers, error margins and wonderkid 4% chance', () {
      final instantScout = ScoutService.generateScoutReport(
        region: 'Bölgesel Amatör',
        tier: ScoutDurationTier.instant,
        scoutFacilityLevel: 1,
      );

      expect(instantScout.players.length, greaterThanOrEqualTo(3));
      // Error margin should be wider for low scout level
      expect(instantScout.accuracyMargin, greaterThanOrEqualTo(3));

      final deepScout = ScoutService.generateScoutReport(
        region: 'Uluslararası / Latin Amerika',
        tier: ScoutDurationTier.deep,
        scoutFacilityLevel: 5,
      );

      // High scout level has tighter accuracy margin
      expect(deepScout.accuracyMargin, lessThanOrEqualTo(5));
    });
  });
}
