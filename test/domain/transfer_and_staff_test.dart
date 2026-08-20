// test/domain/transfer_and_staff_test.dart
// Unit tests for Sprint 3: Loan Market, Contract Persuasion, and Staff Hierarchy (§10.5, §10.6, §10.7, §8.2)

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/economy/transfer_models.dart';
import 'package:futbol/domain/economy/negotiation_model.dart';
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

    test('FreeAgentMarketGenerator produces valid free agent pool', () {
      final freeAgents = FreeAgentMarketGenerator.generateFreeAgents();
      expect(freeAgents.length, greaterThanOrEqualTo(4));
      expect(freeAgents.any((p) => p.position == Position.gk), isTrue);
      expect(freeAgents.any((p) => p.position == Position.st), isTrue);
    });

    test('NegotiationState applies agent kickback and clauses correctly', () {
      const player = Player(
        id: 'target_star',
        firstName: 'Kerem',
        lastName: 'Aktürkoğlu',
        countryCode: 'TR',
        age: 25,
        position: Position.lw,
        pace: 88,
        technique: 84,
        shooting: 82,
        passing: 80,
        defending: 40,
        physical: 72,
        mentality: 81,
        potential: 87,
        weeklyWage: 8000,
      );

      const swapPlayer = Player(
        id: 'swap_sub',
        firstName: 'Efe',
        lastName: 'Yılmaz',
        countryCode: 'TR',
        age: 22,
        position: Position.lw,
        pace: 70,
        technique: 68,
        shooting: 65,
        passing: 64,
        defending: 30,
        physical: 68,
        mentality: 70,
        potential: 75,
        weeklyWage: 2000,
      );

      final state = NegotiationState.start(player: player);
      expect(state.currentPatience, equals(100));

      final stateWithKickback = state.applyAgentKickback(5000);
      expect(stateWithKickback.hasPaidAgentKickback, isTrue);
      expect(stateWithKickback.askingWage, lessThan(state.askingWage));

      const clauses = TransferOfferClauses(
        sellOnPercentage: 20,
        championshipBonus: 15000,
        goalBonus: 5000,
        swapPlayer: swapPlayer,
        contractYears: 4,
        signingBonus: 10000,
      );

      expect(clauses.swapPlayerValue, equals(swapPlayer.marketValue));

      final submitted = stateWithKickback.submitOffer(
        offeredFee: stateWithKickback.askingFee,
        offeredWage: stateWithKickback.askingWage,
        clauses: clauses,
      );

      expect(submitted.outcome, equals(NegotiationOutcome.accepted));
    });
  });
}
