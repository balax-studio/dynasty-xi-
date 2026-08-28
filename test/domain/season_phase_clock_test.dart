// test/domain/season_phase_clock_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/time/game_clock.dart';

void main() {
  group('SeasonPhase & GameClock State Machine Tests', () {
    test('GameClock defaults or initializes with proper phase', () {
      const clock = GameClock(seasonNumber: 1, matchday: 1, phase: SeasonPhase.preSeason);
      expect(clock.phase, SeasonPhase.preSeason);
      expect(clock.isTransferWindowOpen, isTrue);
      expect(clock.phase.isBreakOrCamp, isTrue);
    });

    test('Advancing matches transitions from preSeason to firstHalf', () {
      var clock = const GameClock(seasonNumber: 1, matchday: 1, phase: SeasonPhase.preSeason);
      expect(clock.isTransferWindowOpen, isTrue);

      clock = clock.startFirstHalf();
      expect(clock.phase, SeasonPhase.firstHalf);
      expect(clock.isTransferWindowOpen, isFalse);
    });

    test('Advancing to match 10 triggers midSeasonBreak transition', () {
      var clock = const GameClock(seasonNumber: 1, matchday: 1, phase: SeasonPhase.firstHalf);

      for (int i = 1; i < 10; i++) {
        clock = clock.advanceMatch();
        expect(clock.phase, SeasonPhase.firstHalf);
        expect(clock.isTransferWindowOpen, isFalse);
      }

      expect(clock.matchday, 10);
      // Advancing past match 10 enters mid-season break
      clock = clock.advanceMatch();
      expect(clock.phase, SeasonPhase.midSeasonBreak);
      expect(clock.isTransferWindowOpen, isTrue);
      expect(clock.matchday, 10); // remains on match 10 during the break
    });

    test('Concluding midSeasonBreak starts secondHalf from match 11', () {
      var clock = const GameClock(seasonNumber: 1, matchday: 10, phase: SeasonPhase.midSeasonBreak);
      expect(clock.isTransferWindowOpen, isTrue);

      clock = clock.startSecondHalf();
      expect(clock.phase, SeasonPhase.secondHalf);
      expect(clock.matchday, 11);
      expect(clock.isTransferWindowOpen, isFalse);
    });

    test('Advancing past match 21 enters seasonEvaluation and new season preSeason', () {
      var clock = const GameClock(seasonNumber: 1, matchday: 20, phase: SeasonPhase.secondHalf);
      clock = clock.advanceMatch();
      expect(clock.matchday, 21);
      expect(clock.isSeasonFinale, isTrue);

      clock = clock.advanceMatch();
      expect(clock.phase, SeasonPhase.seasonEvaluation);

      clock = clock.startNextSeason();
      expect(clock.seasonNumber, 2);
      expect(clock.matchday, 1);
      expect(clock.phase, SeasonPhase.preSeason);
      expect(clock.isTransferWindowOpen, isTrue);
    });

    test('Serialization and Deserialization preserve SeasonPhase', () {
      const original = GameClock(
        seasonNumber: 3,
        dayOfSeason: 4,
        matchday: 10,
        phase: SeasonPhase.midSeasonBreak,
        bankedMatches: 2,
      );

      final json = original.toJson();
      final restored = GameClock.fromJson(json);

      expect(restored.seasonNumber, 3);
      expect(restored.dayOfSeason, 4);
      expect(restored.matchday, 10);
      expect(restored.phase, SeasonPhase.midSeasonBreak);
      expect(restored.bankedMatches, 2);
      expect(restored.isTransferWindowOpen, isTrue);
    });
  });
}
