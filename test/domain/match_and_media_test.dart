// test/domain/match_and_media_test.dart
// Unit tests for Sprint 4: Match Depth, Press Conferences, Fan Social Buzz & League Leaderboards (§11, §12, §16)

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/match/match_depth_models.dart';
import 'package:futbol/domain/media/press_conference.dart';
import 'package:futbol/domain/media/fan_social_buzz.dart';

void main() {
  group('Sprint 4: Match, Tactics, Media & League Depth Tests', () {
    test('MatchXpDistributor awards bonus XP based on player match ratings', () {
      final xpEarnedHigh = MatchXpDistributor.calculateXpForRating(8.7, isMotm: true);
      final xpEarnedNormal = MatchXpDistributor.calculateXpForRating(6.8, isMotm: false);

      expect(xpEarnedHigh, greaterThan(xpEarnedNormal));
      expect(xpEarnedHigh, greaterThanOrEqualTo(35));
    });

    test('PressConference evaluates Diplomatic, Aggressive, Protective answers', () {
      final conference = PressConferenceGenerator.generatePostMatchConference(
        userGoals: 3,
        oppGoals: 0,
        opponentName: 'Ezeli Rakip SK',
      );

      expect(conference.options.length, equals(3));
      final aggressiveOption = conference.options.firstWhere((o) => o.stance == PressStance.aggressive);
      final diplomaticOption = conference.options.firstWhere((o) => o.stance == PressStance.diplomatic);
      final protectiveOption = conference.options.firstWhere((o) => o.stance == PressStance.protective);

      expect(aggressiveOption.fanImpact, greaterThanOrEqualTo(0));
      expect(diplomaticOption.boardImpact, greaterThanOrEqualTo(0));
      expect(protectiveOption.lockerImpact, greaterThanOrEqualTo(0));
    });

    test('FanSocialBuzz produces realistic fan reactions based on match outcome', () {
      final winTweets = FanSocialBuzzGenerator.generateFanBuzz(
        userClubName: 'Kadıköy FK',
        userGoals: 4,
        oppGoals: 1,
        opponentName: 'Bursa SK',
        motmName: 'Semih Kılıçsoy',
      );

      expect(winTweets.isNotEmpty, isTrue);
      expect(winTweets.any((t) => t.contains('Semih') || t.contains('Harika') || t.contains('Kadıköy')), isTrue);
    });

    test('LeagueStatsLeaderboard tracks top scorers and assists', () {
      final leaderboard = LeagueStatsLeaderboard();
      leaderboard.recordGoal('p1', 'Mauro Icardi', 'Galatasaray SK', 2);
      leaderboard.recordGoal('p2', 'Edin Dzeko', 'Fenerbahçe SK', 1);
      leaderboard.recordGoal('p1', 'Mauro Icardi', 'Galatasaray SK', 1);

      final topScorers = leaderboard.getTopScorers();
      expect(topScorers.first.playerName, equals('Mauro Icardi'));
      expect(topScorers.first.goals, equals(3));
    });
  });
}
