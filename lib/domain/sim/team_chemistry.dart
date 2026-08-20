// domain/sim/team_chemistry.dart
// Pure Dart. Calculates Squad Chemistry and Match Multiplier based on §9.8.

import 'dart:math' as math;
import '../entities/player.dart';

class TeamChemistry {
  final int score; // 0 - 100
  final double multiplier; // 0.85 - 1.10
  final bool hasPersonalityConflict;
  final bool hasLeader;
  final String dominantNationality;
  final List<String> synergyNotes;

  const TeamChemistry({
    required this.score,
    required this.multiplier,
    this.hasPersonalityConflict = false,
    this.hasLeader = false,
    this.dominantNationality = 'TR',
    this.synergyNotes = const [],
  });
}

class TeamChemistryCalculator {
  /// Calculates squad & starting 11 chemistry (§9.8)
  static TeamChemistry calculateSquadChemistry(
    List<Player> starting11, {
    Map<String, Position>? lineupPositions,
    int analysisCenterLevel = 1,
  }) {
    if (starting11.isEmpty) {
      return const TeamChemistry(score: 50, multiplier: 1.0);
    }

    int score = 70;
    final notes = <String>[];

    // 1. Leadership
    final leaderCount = starting11.where((p) => p.personality == PersonalityType.leader).length;
    final hasCaptain = starting11.any((p) => p.isCaptain);
    final hasLeader = leaderCount > 0 || hasCaptain;

    if (hasCaptain) {
      score += 4;
      notes.add('Sahada kaptan var (+4)');
    }
    if (leaderCount > 0) {
      score += 6;
      notes.add('Doğal lider varlığı (+6)');
    }

    final loyalCount = starting11
        .where((p) =>
            p.personality == PersonalityType.loyal ||
            p.personality == PersonalityType.humble ||
            p.personality == PersonalityType.professional)
        .length;
    if (loyalCount > 0) {
      final loyalBonus = math.min(loyalCount * 3, 9);
      score += loyalBonus;
      notes.add('Uyumlu ve profesyonel kadro yapısı (+$loyalBonus)');
    }

    // 2. Loyalty and Veteran Partnerships (§9.8)
    final veteranCount = starting11
        .where((p) => p.appearances >= 10 && p.contractSeasonsLeft >= 1)
        .length;
    final veteranBonus = math.min(veteranCount * 2, 10);
    if (veteranBonus > 0) {
      score += veteranBonus;
      notes.add('Kıdemli oyuncu ortaklığı (+$veteranBonus)');
    }

    // 3. Personality Conflicts
    final conflictCount = starting11
        .where((p) =>
            p.personality == PersonalityType.rebel ||
            p.personality == PersonalityType.mercenary)
        .length;
    final hasPersonalityConflict = conflictCount >= 2;
    if (hasPersonalityConflict) {
      final penalty = math.min(conflictCount * 5, 15);
      score -= penalty;
      notes.add('Ego ve uyumsuzluk sürtüşmesi (-$penalty)');
    }

    // 4. Nationality Synergy (§9.8)
    final nationalityCounts = <String, int>{};
    for (final p in starting11) {
      nationalityCounts[p.countryCode] = (nationalityCounts[p.countryCode] ?? 0) + 1;
    }

    String dominantNation = 'TR';
    int maxNationCount = 0;
    nationalityCounts.forEach((nation, count) {
      if (count > maxNationCount) {
        maxNationCount = count;
        dominantNation = nation;
      }
    });

    if (maxNationCount >= 5) {
      score += 8;
      notes.add('Kuvvetli milliyet ve dil bağı ($dominantNation, +8)');
    } else if (maxNationCount >= 3) {
      score += 4;
      notes.add('Yerel iletişim bağı ($dominantNation, +4)');
    }

    // 5. Out of Position Penalties (§9.8)
    if (lineupPositions != null) {
      int outOfPosCount = 0;
      for (final p in starting11) {
        final assignedPos = lineupPositions[p.id];
        if (assignedPos != null && assignedPos != p.position) {
          if (!p.altPositions.contains(assignedPos)) {
            outOfPosCount++;
          }
        }
      }
      if (outOfPosCount > 0) {
        final outPenalty = outOfPosCount * 6;
        score -= outPenalty;
        notes.add('Mevki dışı oynayan oyuncular (-$outPenalty)');
      }
    }

    // 6. Recent Transfer Adaptation (§9.8)
    final newSigningCount = starting11.where((p) => p.appearances < 3).length;
    if (newSigningCount > 0) {
      final adaptPenalty = math.min(newSigningCount * 3, 9);
      score -= adaptPenalty;
      notes.add('Yeni transferlerin adaptasyon süreci (-$adaptPenalty)');
    }

    // 7. Analysis Center Level Bonus (§9.8)
    if (analysisCenterLevel > 1) {
      final analysisBonus = (analysisCenterLevel - 1) * 2;
      score += analysisBonus;
      notes.add('Analiz Merkezi taktik uyum desteği (+$analysisBonus)');
    }

    // Final Clamping & Multiplier (0.85 - 1.10)
    final finalScore = score.clamp(20, 100);
    final multiplier = 0.85 + (finalScore / 100.0) * 0.25;

    return TeamChemistry(
      score: finalScore,
      multiplier: double.parse(multiplier.toStringAsFixed(3)),
      hasPersonalityConflict: hasPersonalityConflict,
      hasLeader: hasLeader,
      dominantNationality: dominantNation,
      synergyNotes: notes,
    );
  }
}
