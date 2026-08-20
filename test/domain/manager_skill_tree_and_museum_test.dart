// test/domain/manager_skill_tree_and_museum_test.dart
// Unit tests for Sprint 5: 5x12 Manager Skill Tree, Coaching License & Museum Records (§13, §14, Ek E, Ek H)

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/progression/manager_skill_tree.dart';
import 'package:futbol/domain/progression/coaching_license.dart';
import 'package:futbol/domain/progression/museum_records.dart';

void main() {
  group('Sprint 5: Manager Skill Tree, License & Museum Tests', () {
    test('CoachingLicense defines 4 tiers with promotion requirements and bonuses', () {
      expect(CoachingLicense.uefaC.requiredManagerLevel, equals(1));
      expect(CoachingLicense.uefaB.courseCost, equals(25000));
      expect(CoachingLicense.uefaA.requiredManagerLevel, equals(10));
      expect(CoachingLicense.uefaPro.allPerkMultiplier, greaterThan(1.10));
    });

    test('ManagerSkillTree contains 5 distinct branches with unlockable perks', () {
      final skillTree = ManagerSkillTree.createInitialTree();
      expect(skillTree.branches.length, equals(5));

      final tacticalBranch = skillTree.getBranch(SkillBranchType.tactical);
      final financialBranch = skillTree.getBranch(SkillBranchType.financial);

      expect(tacticalBranch.name, contains('Taktik'));
      expect(financialBranch.skills.length, greaterThanOrEqualTo(5));

      // Skill kilit açma
      final updatedTree = skillTree.unlockSkill(
        branchType: SkillBranchType.tactical,
        skillId: 'tac_1',
        availablePoints: 2,
      );

      expect(updatedTree.isSkillUnlocked('tac_1'), isTrue);
    });

    test('ClubMuseumRecords updates records on new milestones', () {
      var records = const ClubMuseumRecords();

      records = records.checkAndRecordMatch(
        homeScore: 6,
        awayScore: 0,
        opponentName: 'Amatör FK',
        isWin: true,
      );

      expect(records.biggestWinScore, equals('6-0'));
      expect(records.biggestWinOpponent, equals('Amatör FK'));
      expect(records.unbeatenStreak, equals(1));

      records = records.checkAndRecordTransfer(
        playerName: 'Semih Kılıçsoy',
        fee: 350000,
        isIncoming: true,
      );

      expect(records.recordSigningFee, equals(350000));
      expect(records.recordSigningName, equals('Semih Kılıçsoy'));
    });
  });
}
