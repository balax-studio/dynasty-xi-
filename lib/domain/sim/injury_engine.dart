// domain/sim/injury_engine.dart
// Pure Dart. Comprehensive Injury Engine with probability roll (§9.6), severity, and recovery ticks.

import 'dart:math' as math;
import '../entities/player.dart';

class InjuryOccurrence {
  final Player player;
  final String injuryType;
  final InjurySeverity severity;
  final int matchesOut;

  const InjuryOccurrence({
    required this.player,
    required this.injuryType,
    required this.severity,
    required this.matchesOut,
  });
}

class InjuryEngineResult {
  final List<Player> squad;
  final List<InjuryOccurrence> newInjuries;
  final List<Player> recoveredPlayers;

  const InjuryEngineResult({
    required this.squad,
    required this.newInjuries,
    required this.recoveredPlayers,
  });
}

class InjuryEngine {
  static const _minorInjuries = [
    'Ayak Bileği Burkulması',
    'Hafif Kas Çekmesi',
    'Aşırı Yorgunluk / Adale Sertleşmesi',
  ];

  static const _moderateInjuries = [
    'Hamstring Yırtığı',
    'Diz Yan Bağ Esnemesi',
    'Kasık Ağrısı (Osteitis Pubis)',
  ];

  static const _severeInjuries = [
    'Menisküs Yırtığı',
    'Köprücük Kemiği Kırığı',
    'İç Yan Bağ Kopması',
  ];

  static const _criticalInjuries = [
    'Ön Çapraz Bağ Kopması (ACL)',
    'Aşil Tendonu Yırtığı',
  ];

  /// Rolls injuries for participants in a match and ticks recovery for non-participants (§9.6).
  static InjuryEngineResult processMatchInjuries({
    required List<Player> currentSquad,
    required Set<String> matchParticipants, // starters and subs
    int medicalCenterLevel = 1,
    double tacticIntensityMultiplier = 1.0,
    int? randomSeed,
  }) {
    final rng = math.Random(randomSeed ?? DateTime.now().millisecondsSinceEpoch);
    final medFactor = (1.0 - (medicalCenterLevel * 0.07)).clamp(0.65, 1.0);

    final newInjuries = <InjuryOccurrence>[];
    final recoveredPlayers = <Player>[];
    final updatedSquad = <Player>[];

    for (final player in currentSquad) {
      // If player is already injured, tick recovery
      if (player.injuryMatchesLeft > 0) {
        final remaining = player.injuryMatchesLeft - 1;
        if (remaining <= 0) {
          final healed = player.copyWith(
            injuryMatchesLeft: 0,
            injuryType: null,
            injurySeverity: InjurySeverity.none,
            clearInjury: true,
            fitness: math.max(player.fitness, 75),
          );
          recoveredPlayers.add(healed);
          updatedSquad.add(healed);
        } else {
          updatedSquad.add(player.copyWith(injuryMatchesLeft: remaining));
        }
        continue;
      }

      // If player did not participate in match, no new match injury roll
      if (!matchParticipants.contains(player.id)) {
        updatedSquad.add(player);
        continue;
      }

      // Calculate probability for participant
      final pronenessFactor = 1.0 + (player.injuryProneness / 100.0);
      final fatigueFactor = (2.0 - (player.fitness / 100.0)).clamp(1.0, 2.0);
      final ageFactor = (player.age >= 30) ? 1.0 + ((player.age - 29) * 0.04) : 1.0;
      final trainingFactor = player.trainingIntensity.injuryRiskMultiplier;

      // Base formula (§9.6)
      final prob = 0.028 *
          pronenessFactor *
          fatigueFactor *
          medFactor *
          tacticIntensityMultiplier *
          ageFactor *
          trainingFactor;

      final roll = rng.nextDouble();
      if (roll < prob) {
        // Player suffered an injury
        final sevRoll = rng.nextDouble();
        InjurySeverity severity;
        String type;
        int matchesOut;

        if (sevRoll < 0.60) {
          severity = InjurySeverity.minor;
          type = _minorInjuries[rng.nextInt(_minorInjuries.length)];
          matchesOut = 1;
        } else if (sevRoll < 0.85) {
          severity = InjurySeverity.moderate;
          type = _moderateInjuries[rng.nextInt(_moderateInjuries.length)];
          matchesOut = 2 + rng.nextInt(2); // 2-3 matches
        } else if (sevRoll < 0.97) {
          severity = InjurySeverity.severe;
          type = _severeInjuries[rng.nextInt(_severeInjuries.length)];
          matchesOut = 4 + rng.nextInt(4); // 4-7 matches
        } else {
          severity = InjurySeverity.critical;
          type = _criticalInjuries[rng.nextInt(_criticalInjuries.length)];
          matchesOut = 8 + rng.nextInt(8); // 8-15 matches
        }

        final injuredPlayer = player.copyWith(
          injuryMatchesLeft: matchesOut,
          injuryType: type,
          injurySeverity: severity,
          fitness: math.max(20, player.fitness - 30),
          morale: math.max(20, player.morale - (severity.index * 5)),
        );

        newInjuries.add(InjuryOccurrence(
          player: injuredPlayer,
          injuryType: type,
          severity: severity,
          matchesOut: matchesOut,
        ));
        updatedSquad.add(injuredPlayer);
      } else {
        updatedSquad.add(player);
      }
    }

    return InjuryEngineResult(
      squad: updatedSquad,
      newInjuries: newInjuries,
      recoveredPlayers: recoveredPlayers,
    );
  }
}
