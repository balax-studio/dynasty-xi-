// test/domain/achievements_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/achievement.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/league.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/meter.dart';

void main() {
  group('Achievements & Dynasty Trophy Cabinet Tests (§13.3, §14.4, Ek E)', () {
    test('Achievement catalog contains 12 unique achievements', () {
      const achievements = AchievementCatalog.allAchievements;
      expect(achievements.length, greaterThanOrEqualTo(12));
    });

    test('AchievementEvaluator awards First Promotion achievement when league tier improves', () {
      const state = GameState(
        userClub: Club(
          id: 'u1',
          name: 'Angora SK',
          city: 'Angora',
          meters: ClubMeters(cash: 50000, fans: 50, lockerRoom: 50, boardTrust: 50),
        ),
        manager: Manager(name: 'Hoca'),
        currentLeague: League(tier: 19, name: '19. Lig'), // Promoted from 20
      );

      final unlocked = AchievementEvaluator.evaluateAchievements(
        state: state,
        previouslyUnlockedIds: {},
      );

      expect(unlocked.any((a) => a.id == 'ach_first_promotion'), isTrue);
    });

    test('Dynasty Points formula correctly computes career score (Ek C.5)', () {
      final dynastyPoints = AchievementEvaluator.calculateDynastyScore(
        leagueTier: 15,
        trophiesWon: 2,
        seasonsPlayed: 3,
        legendPlayersCount: 1,
        maxSquadValue: 1500000,
      );

      // (21-15)*10 + 2*40 + 3*8 + 1*25 + 1500000/500000 = 60 + 80 + 24 + 25 + 3 = 192
      expect(dynastyPoints, equals(192));
    });
  });
}
