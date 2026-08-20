// test/domain/match_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/rng/deterministic_rng.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/facility.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/generation/player_generator.dart';
import 'package:futbol/domain/sim/match_engine.dart';
import 'package:futbol/domain/sim/match_events.dart';

void main() {
  group('MatchEngine Simulation Tests', () {
    late Club homeClub;
    late Club awayClub;

    setUp(() {
      final rng = DeterministicRng(77);
      final homeSquad = PlayerGenerator.generateSquad(
        rng: rng,
        leagueTier: 18,
        clubIdPrefix: 'home',
      );
      final awaySquad = PlayerGenerator.generateSquad(
        rng: rng,
        leagueTier: 18,
        clubIdPrefix: 'away',
      );

      final facMap = <FacilityType, Facility>{
        for (final t in FacilityType.values) t: Facility(type: t, level: 1),
      };

      homeClub = Club(
        id: 'home_c',
        name: 'Angora Gücü',
        city: 'Angora',
        leagueTier: 18,
        squad: homeSquad,
        starting11Ids: homeSquad.take(11).map((p) => p.id).toList(),
        substituteIds: homeSquad.skip(11).map((p) => p.id).toList(),
        facilities: facMap,
        meters: const ClubMeters(cash: 20000, fans: 45, lockerRoom: 45, boardTrust: 50),
      );

      awayClub = Club(
        id: 'away_c',
        name: 'Meriç FK',
        city: 'Meriç',
        leagueTier: 18,
        squad: awaySquad,
        starting11Ids: awaySquad.take(11).map((p) => p.id).toList(),
        substituteIds: awaySquad.skip(11).map((p) => p.id).toList(),
        facilities: facMap,
        meters: const ClubMeters(cash: 20000, fans: 45, lockerRoom: 45, boardTrust: 50),
      );
    });

    test('Simulate produces valid match result with events and non-null ratings', () {
      final engine = MatchEngine(12345);
      final setup = MatchSetup(
        home: homeClub,
        away: awayClub,
        seed: 12345,
        isLiveMode: true,
      );

      final result = engine.simulate(setup);

      expect(result.events.isNotEmpty, isTrue);
      expect(result.events.first.type, equals(MatchEventType.whistleStart));
      expect(result.events.last.type, equals(MatchEventType.fullTime));
      expect(result.possessionHome + result.possessionAway, equals(100));
      expect(result.xgHome, greaterThan(0.0));
      expect(result.xgAway, greaterThan(0.0));

      for (final p in homeClub.starting11) {
        expect(result.playerRatings.containsKey(p.id), isTrue);
        expect(result.playerRatings[p.id], inInclusiveRange(4.0, 10.0));
      }
    });

    test('Deterministic simulation is 100% reproducible with same seed', () {
      final engine1 = MatchEngine(999);
      final engine2 = MatchEngine(999);

      final setup = MatchSetup(home: homeClub, away: awayClub, seed: 999);
      final result1 = engine1.simulate(setup);
      final result2 = engine2.simulate(setup);

      expect(result1.homeGoals, equals(result2.homeGoals));
      expect(result1.awayGoals, equals(result2.awayGoals));
      expect(result1.xgHome, equals(result2.xgHome));
      expect(result1.xgAway, equals(result2.xgAway));
      expect(result1.events.length, equals(result2.events.length));
    });
  });
}
