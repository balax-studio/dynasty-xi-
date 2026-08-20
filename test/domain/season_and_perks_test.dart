// test/domain/season_and_perks_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/rng/deterministic_rng.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/league.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/generation/club_generator.dart';
import 'package:futbol/domain/progression/season_transition.dart';

void main() {
  group('Season Transition & Manager Perk Tests (§13, §14, Ek B, Ek H)', () {
    test('SeasonTransition correctly awards champion prize and promotion', () {
      const userClub = Club(
        id: 'u1',
        name: 'Angora SK',
        city: 'Angora',
        leagueTier: 20,
        meters: ClubMeters(cash: 10000, fans: 50, lockerRoom: 50, boardTrust: 50),
      );

      const league = League(
        tier: 20,
        name: '20. Lig',
        clubIds: ['u1', 'opp1', 'opp2', 'opp3'],
        standings: [
          LeagueTableEntry(clubId: 'u1', clubName: 'Angora SK', played: 21, won: 18, drawn: 2, lost: 1, points: 56),
          LeagueTableEntry(clubId: 'opp1', clubName: 'Demirspor', played: 21, won: 12, drawn: 3, lost: 6, points: 39),
          LeagueTableEntry(clubId: 'opp2', clubName: 'Güneş SK', played: 21, won: 8, drawn: 4, lost: 9, points: 28),
          LeagueTableEntry(clubId: 'opp3', clubName: 'Birlikspor', played: 21, won: 2, drawn: 2, lost: 17, points: 8),
        ],
      );

      const state = GameState(
        userClub: userClub,
        manager: Manager(name: 'Hoca', currentXp: 0, level: 1),
        currentLeague: league,
      );

      final report = SeasonTransition.processSeasonEnd(state);

      expect(report.isChampion, isTrue);
      expect(report.isPromoted, isTrue);
      expect(report.prizeMoney, greaterThanOrEqualTo(100000));
      expect(report.managerXpEarned, greaterThanOrEqualTo(1000));

      final rng = DeterministicRng(42);
      final nextState = SeasonTransition.applySeasonTransition(
        state: state,
        report: report,
        rng: rng,
      );

      expect(nextState.currentLeague.tier, equals(19));
      expect(nextState.clock.seasonNumber, equals(2));
      expect(nextState.userClub.meters.cash, greaterThan(userClub.meters.cash));
    });

    test('Manager entity levels up and allocates skill points', () {
      const manager = Manager(
        name: 'Hoca',
        level: 1,
        currentXp: 0,
        unlockedPerkIds: [],
      );

      // Add 1200 XP
      final updated = manager.addXp(1200);
      expect(updated.level, greaterThan(1));
      expect(updated.availableSkillPoints, greaterThan(0));

      // Unlock a perk
      expect(updated.hasPerk('tactician_1'), isFalse);
      final withPerk = updated.copyWith(
        unlockedPerkIds: [...updated.unlockedPerkIds, 'tactician_1'],
      );
      expect(withPerk.hasPerk('tactician_1'), isTrue);
    });

    test('ClubGenerator produces diverse opponents with unique names and accurate fixture names', () {
      final rng = DeterministicRng(12345);
      const userClub = Club(
        id: 'u_test',
        name: 'Angora Gücü',
        city: 'Angora',
        leagueTier: 20,
        badgeIcon: '🛡️',
      );

      final league = ClubGenerator.generateLeague(
        rng: rng,
        leagueTier: 20,
        userClub: userClub,
        seasonNumber: 1,
      );

      expect(league.clubIds.length, equals(11));
      expect(league.standings.length, equals(11));
      expect(league.fixtures.length, equals(21));

      // Standings names must be unique
      final standingNames = league.standings.map((s) => s.clubName).toSet();
      expect(standingNames.length, equals(11));

      // Fixture names should be populated and not default to placeholder
      for (final fix in league.fixtures) {
        expect(fix.homeClubName, isNot(equals('Ev Sahibi')));
        expect(fix.awayClubName, isNot(equals('Deplasman')));
        expect(fix.homeClubName.isNotEmpty, isTrue);
        expect(fix.awayClubName.isNotEmpty, isTrue);
      }

      // League helper methods work correctly
      expect(league.getClubName('u_test'), equals('Angora Gücü'));
      expect(league.getClubBadge('u_test'), equals('🛡️'));
      final oppId = league.clubIds.firstWhere((id) => id != 'u_test');
      expect(league.getClubName(oppId), isNotEmpty);
      expect(league.getClubBadge(oppId), isNotEmpty);
    });
  });
}
