// domain/sim/team_chemistry.dart
// Pure Dart. Calculates Squad Chemistry and Match Multiplier based on §9.4 and Ek C.2.

import '../entities/player.dart';

class TeamChemistry {
  final int score; // 0 - 100
  final double multiplier; // 0.88 - 1.08
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
  /// Kadro Kimyası ve Çarpanını Hesaplar (§9.4, Ek C.2)
  static TeamChemistry calculateSquadChemistry(List<Player> squad) {
    if (squad.isEmpty) {
      return const TeamChemistry(score: 50, multiplier: 1.0);
    }

    int baseScore = 75;
    final notes = <String>[];

    // 1. Liderlik Etkisi
    final leaderCount = squad.where((p) => p.personality == PersonalityType.leader).length;
    final hasLeader = leaderCount > 0;
    if (hasLeader) {
      baseScore += 8;
      notes.add('Takımda lider figür mevcut (+8)');
    } else {
      baseScore -= 5;
      notes.add('Takımda doğal lider eksikliği (-5)');
    }

    // 2. Sadakat ve Uyum
    final loyalCount = squad.where((p) => p.personality == PersonalityType.loyal).length;
    if (loyalCount > 0) {
      final loyalBonus = (loyalCount * 3).clamp(0, 9);
      baseScore += loyalBonus;
      notes.add('Sadık oyuncuların getirdiği huzur (+$loyalBonus)');
    }

    // 3. Çatışma (Asi / Paragöz Oyuncular)
    final rebelCount = squad.where((p) => p.personality == PersonalityType.rebel).length;
    final mercenaryCount = squad.where((p) => p.personality == PersonalityType.mercenary).length;
    final conflictCount = rebelCount + mercenaryCount;
    final hasPersonalityConflict = conflictCount >= 2;

    if (hasPersonalityConflict) {
      final penalty = (conflictCount * 6).clamp(6, 20);
      baseScore -= penalty;
      notes.add('Soyunma odasında ego ve disiplin sürtüşmesi (-$penalty)');
    }

    // 4. Milliyet / Dil Uyumu
    final nationalityCounts = <String, int>{};
    for (final p in squad) {
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

    if (maxNationCount >= 3) {
      baseScore += 5;
      notes.add('Güçlü yerel iletişim bağı ($dominantNation, +5)');
    }

    // 5. Skor Clamp ve Çarpan Formülü: 0.88 - 1.08 arası
    final finalScore = baseScore.clamp(0, 100);
    final multiplier = 0.88 + (finalScore / 100.0) * 0.20;

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
