// test/domain/async_scouting_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/scouting/scouting_mission.dart';

void main() {
  group('Asynchronous Scouting & Fog of War Tests', () {
    const samplePlayer = Player(
      id: 'scout_prospect_1',
      firstName: 'Yasin',
      lastName: 'Yıldırım',
      countryCode: 'TR',
      age: 19,
      position: Position.cm,
      pace: 75,
      technique: 78,
      shooting: 70,
      passing: 80,
      defending: 65,
      physical: 74,
      mentality: 77,
      potential: 88,
      weeklyWage: 200,
    );

    test('ScoutingMission initializes with match duration and ticks down', () {
      const mission = ScoutingMission(
        id: 'mission_1',
        region: 'Balkanlar & Doğu Avrupa',
        tier: ScoutDurationTier.standard,
        totalMatches: 2,
        matchesRemaining: 2,
        assignedScoutLevel: 3,
        discoveredProspects: [samplePlayer],
      );

      expect(mission.isCompleted, isFalse);
      expect(mission.progressRatio, 0.0);

      final ticked1 = mission.tickMatch();
      expect(ticked1.matchesRemaining, 1);
      expect(ticked1.isCompleted, isFalse);
      expect(ticked1.progressRatio, 0.5);

      final ticked2 = ticked1.tickMatch();
      expect(ticked2.matchesRemaining, 0);
      expect(ticked2.isCompleted, isTrue);
      expect(ticked2.progressRatio, 1.0);
    });

    test('Fog of War reveals estimated range for Level 1 scout and exact stats for Level 5', () {
      // Level 1 Scout (Error margin ~ ±5)
      final l1Display = ScoutFogOfWar.getOvrDisplay(samplePlayer, 1);
      expect(l1Display, contains('-')); // e.g. "69 - 79"

      // Level 5 Chief Scout (Exact OVR)
      final l5Display = ScoutFogOfWar.getOvrDisplay(samplePlayer, 5);
      expect(l5Display, '${samplePlayer.overall}');

      // Potential range
      expect(ScoutFogOfWar.getPotentialDisplay(samplePlayer, 1), contains('-'));
      expect(ScoutFogOfWar.getPotentialDisplay(samplePlayer, 5), '88');

      // Hidden traits
      expect(ScoutFogOfWar.isTraitRevealed(scoutLevel: 1), isFalse);
      expect(ScoutFogOfWar.isTraitRevealed(scoutLevel: 4), isTrue);
    });

    test('ScoutingMission serialization and deserialization work cleanly', () {
      const original = ScoutingMission(
        id: 'mission_ser_1',
        region: 'Güney Amerika (Brezilya/Arjantin)',
        tier: ScoutDurationTier.deep,
        totalMatches: 3,
        matchesRemaining: 1,
        assignedScoutLevel: 4,
        discoveredProspects: [samplePlayer],
      );

      final json = original.toJson();
      final restored = ScoutingMission.fromJson(json);

      expect(restored.id, 'mission_ser_1');
      expect(restored.region, 'Güney Amerika (Brezilya/Arjantin)');
      expect(restored.tier, ScoutDurationTier.deep);
      expect(restored.matchesRemaining, 1);
      expect(restored.discoveredProspects.length, 1);
      expect(restored.discoveredProspects.first.fullName, 'Yasin Yıldırım');
    });
  });
}
