// domain/generation/player_generator.dart
// Pure Dart. Procedural generation of players, squads and youth academy graduates.

import 'dart:math' as math;
import '../../core/rng/deterministic_rng.dart';
import '../entities/player.dart';
import 'name_pools.dart';

class PlayerGenerator {
  /// Lig Kademesine Göre Ortalama OVR Bandı
  static int targetOvrForTier(int leagueTier) {
    // Tier 20 -> ~48 OVR, Tier 1 -> ~87 OVR
    final base = 88 - (leagueTier - 1) * 2.1;
    return base.round().clamp(42, 92);
  }

  /// Tekil Oyuncu Üretimi
  static Player generatePlayer({
    required DeterministicRng rng,
    required Position position,
    required int targetOvr,
    String? id,
    int? age,
  }) {
    final playerId = id ?? 'p_${rng.nextInt(10000000)}';
    final firstName = rng.pick(NamePools.trFirstNames);
    final lastName = rng.pick(NamePools.trLastNames);
    final playerAge = age ?? rng.nextIntInRange(18, 33);

    // OVR etrafında nitelikleri dağıt
    final variance = rng.nextDoubleInRange(-4.0, 4.0);
    final center = (targetOvr + variance).round().clamp(35, 95);

    // Nitelik dağılımı
    final pace = (center + rng.nextIntInRange(-6, 8)).clamp(30, 99);
    final technique = (center + rng.nextIntInRange(-6, 6)).clamp(30, 99);
    final shooting = (position.isForward ? center + 4 : center - 6).clamp(30, 99);
    final passing = (position.isMidfielder ? center + 4 : center - 4).clamp(30, 99);
    final defending = (position.isDefender || position.isGoalkeeper ? center + 5 : center - 8).clamp(30, 99);
    final physical = (center + rng.nextIntInRange(-5, 6)).clamp(30, 99);
    final mentality = (center + rng.nextIntInRange(-4, 6)).clamp(30, 99);

    final potentialBonus = playerAge <= 21
        ? rng.nextIntInRange(8, 22)
        : (playerAge <= 25 ? rng.nextIntInRange(2, 8) : 0);
    final potential = math.min(99, center + potentialBonus);

    final personality = rng.pick(PersonalityType.values);
    final weeklyWage = (math.pow(1.35, (center - 40) / 4.2) * 1000 * 0.0038).round().clamp(100, 150000);

    return Player(
      id: playerId,
      firstName: firstName,
      lastName: lastName,
      countryCode: 'TR',
      age: playerAge,
      position: position,
      pace: pace,
      technique: technique,
      shooting: shooting,
      passing: passing,
      defending: defending,
      physical: physical,
      mentality: mentality,
      potential: potential,
      consistency: rng.nextIntInRange(55, 85),
      injuryProneness: rng.nextIntInRange(15, 45),
      personality: personality,
      weeklyWage: weeklyWage,
      contractSeasonsLeft: rng.nextIntInRange(1, 4),
      releaseClause: (weeklyWage * 85),
      faceSeed: 'face_${rng.nextInt(99999)}',
    );
  }

  /// 18 Kişilik Dengeli Bir Takım Kadrosu Üretimi
  static List<Player> generateSquad({
    required DeterministicRng rng,
    required int leagueTier,
    required String clubIdPrefix,
  }) {
    final targetOvr = targetOvrForTier(leagueTier);
    final squad = <Player>[];

    final positionTemplate = [
      Position.gk, Position.gk,
      Position.cb, Position.cb, Position.cb, Position.lb, Position.rb,
      Position.dm, Position.dm, Position.cm, Position.cm, Position.am, Position.am,
      Position.lw, Position.rw, Position.st, Position.st, Position.st,
    ];

    for (var i = 0; i < positionTemplate.length; i++) {
      final pos = positionTemplate[i];
      final isKeyPlayer = (i == 0 || i == 2 || i == 9 || i == 15);
      final adjustedOvr = isKeyPlayer ? targetOvr + 3 : targetOvr;

      squad.add(generatePlayer(
        rng: rng,
        position: pos,
        targetOvr: adjustedOvr,
        id: '${clubIdPrefix}_p$i',
      ));
    }

    return squad;
  }

  /// Altyapı Akademisi Genç Yetenek Üretimi
  static Player generateYouthPlayer({
    required DeterministicRng rng,
    required int academyLevel,
    required int seasonNumber,
  }) {
    const positions = Position.values;
    final pos = rng.pick(positions);
    final age = rng.nextIntInRange(16, 18);

    // Akademi seviyesine göre temel OVR ve Potansiyel
    final baseOvr = 45 + (academyLevel * 4) + rng.nextIntInRange(-2, 4);
    final potBonus = 18 + (academyLevel * 4) + rng.nextIntInRange(0, 8);
    final potential = (baseOvr + potBonus).clamp(65, 96);

    return generatePlayer(
      rng: rng,
      position: pos,
      targetOvr: baseOvr,
      id: 'youth_s${seasonNumber}_${rng.nextInt(99999)}',
      age: age,
    ).copyWith(
      potential: potential,
      isYouthProduct: true,
      morale: 90,
      contractSeasonsLeft: 3,
      weeklyWage: 200 + (academyLevel * 100),
    );
  }
}
