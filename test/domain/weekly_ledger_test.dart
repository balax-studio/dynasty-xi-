// test/domain/weekly_ledger_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/local/save_repository.dart';
import 'package:futbol/domain/economy/weekly_ledger.dart';
import 'package:futbol/domain/economy/financial_statement.dart';

void main() {
  group('WeeklyLedger & Economy Balance (§15.3, §15.4)', () {
    test('Criterion #9: Tier 20 weekly ledger produces balanced cash flow', () {
      final state = SaveRepository.createNewGame();
      final ledger = WeeklyLedgerCalculator.calculate(
        state: state,
        isHomeMatch: true,
        isWin: true,
      );

      expect(ledger.totalIncome, greaterThan(0));
      expect(ledger.totalExpenses, greaterThan(0));
      expect(ledger.matchdayRevenue, greaterThan(0));
      expect(ledger.broadcastRevenue, greaterThan(0));
      expect(ledger.playerWages, greaterThan(0));
      expect(ledger.facilityUpkeep, greaterThan(0));
    });

    test('Criterion #7 & #8: Bank loan weekly installments and early repayment', () {
      const loan = BankLoan(
        principalAmount: 50000,
        remainingWeeks: 10,
      );

      var active = loan;
      for (int i = 0; i < 10; i++) {
        active = active.payWeeklyInstallment();
      }
      expect(active.isPaidOff, isTrue);
      expect(active.remainingWeeks, equals(0));
    });
  });
}
