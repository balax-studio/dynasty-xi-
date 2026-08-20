// test/domain/transfer_and_staff_test.dart
// Unit tests for Sprint 3: Loan Market, Contract Persuasion, and Staff Hierarchy (§10.5, §10.6, §10.7, §8.2)

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/economy/transfer_models.dart';
import 'package:futbol/domain/entities/staff.dart';

void main() {
  group('Sprint 3: Transfer Market & Staff Depth Tests', () {
    test('LoanDeal calculates wage splits and buyout clause correctly', () {
      const player = Player(
        id: 'p_loan',
        firstName: 'Semih',
        lastName: 'Kılıçsoy',
        countryCode: 'TR',
        age: 19,
        position: Position.st,
        pace: 82,
        technique: 80,
        shooting: 84,
        passing: 68,
        defending: 32,
        physical: 80,
        mentality: 78,
        potential: 89,
        weeklyWage: 4000,
      );

      const loan = LoanDeal(
        player: player,
        parentClubName: 'Beşiktaş JK',
        borrowingClubWageShare: 0.50, // %50 maaş katkısı
        buyoutClause: 250000,
        seasons: 1,
      );

      expect(loan.weeklyWageToPay, equals(2000));
      expect(loan.buyoutClause, equals(250000));
      expect(loan.parentClubName, equals('Beşiktaş JK'));
    });

    test('StaffMember models 4 backroom specialists with active perks', () {
      const assistant = StaffMember(
        id: 'staff_asst',
        role: StaffRole.assistantManager,
        name: 'Tayfur Hoca',
        level: 3,
        weeklySalary: 2500,
      );

      const physio = StaffMember(
        id: 'staff_physio',
        role: StaffRole.headPhysio,
        name: 'Dr. Mehmet Öz',
        level: 4,
        weeklySalary: 3200,
      );

      const scout = StaffMember(
        id: 'staff_scout',
        role: StaffRole.chiefScout,
        name: 'Piet de Visser',
        level: 5,
        weeklySalary: 4500,
      );

      const analyst = StaffMember(
        id: 'staff_analyst',
        role: StaffRole.dataAnalyst,
        name: 'Can Bilir',
        level: 2,
        weeklySalary: 1800,
      );

      expect(assistant.role.label, contains('Asistan'));
      expect(physio.injuryRecoverySpeedBonus, greaterThan(0.20));
      expect(scout.potentialAccuracyBonus, equals(5));
      expect(analyst.opponentWeaknessInsightChance, greaterThanOrEqualTo(0.30));
    });
  });
}
