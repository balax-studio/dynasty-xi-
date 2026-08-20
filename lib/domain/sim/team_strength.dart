// domain/sim/team_strength.dart
// Pure Dart. Calculates offensive, defensive and midfield powers with form and home advantage.

import '../entities/club.dart';
import '../entities/facility.dart';
import 'team_chemistry.dart';

class TeamStrength {
  final double attackPower;
  final double defensePower;
  final double midfieldPower;
  final double goalkeeperPower;
  final double averageFitness;
  final double averageMorale;
  final double overallMultiplier;

  const TeamStrength({
    required this.attackPower,
    required this.defensePower,
    required this.midfieldPower,
    required this.goalkeeperPower,
    required this.averageFitness,
    required this.averageMorale,
    required this.overallMultiplier,
  });

  factory TeamStrength.fromClub({
    required Club club,
    required bool isHome,
    bool hasTacticianPerk = false,
  }) {
    final lineup = club.starting11;
    if (lineup.isEmpty) {
      return const TeamStrength(
        attackPower: 40.0,
        defensePower: 40.0,
        midfieldPower: 40.0,
        goalkeeperPower: 40.0,
        averageFitness: 100.0,
        averageMorale: 75.0,
        overallMultiplier: 1.0,
      );
    }

    double totalAtk = 0;
    double totalDef = 0;
    double totalMid = 0;
    double gkPower = 50.0;
    double totalFitness = 0;
    double totalMorale = 0;

    for (final p in lineup) {
      totalFitness += p.fitness;
      totalMorale += p.morale;

      if (p.position.isGoalkeeper) {
        gkPower = (p.defending * 0.5 + p.physical * 0.3 + p.mentality * 0.2);
      } else if (p.position.isDefender) {
        totalDef += p.defending * 0.6 + p.physical * 0.25 + p.pace * 0.15;
        totalMid += p.passing * 0.5 + p.technique * 0.5;
        totalAtk += p.pace * 0.3 + p.shooting * 0.2;
      } else if (p.position.isMidfielder) {
        totalMid += p.passing * 0.4 + p.technique * 0.3 + p.mentality * 0.3;
        totalAtk += p.shooting * 0.4 + p.pace * 0.3 + p.technique * 0.3;
        totalDef += p.defending * 0.5 + p.physical * 0.5;
      } else if (p.position.isForward) {
        totalAtk += p.shooting * 0.5 + p.pace * 0.3 + p.technique * 0.2;
        totalMid += p.technique * 0.5 + p.passing * 0.5;
        totalDef += p.defending * 0.2 + p.physical * 0.3;
      }
    }

    final count = lineup.length;
    final avgFit = totalFitness / count;
    final avgMorale = totalMorale / count;

    // Ev Sahibi Bonusu (Ek C.2: 1.00 + 0.04 + stadyumSv×0.012 + memnuniyet/1000)
    double homeAdvantage = 1.0;
    if (isHome) {
      final stadiumLvl = club.getFacilityLevel(FacilityType.stadium);
      final pitchLvl = club.getFacilityLevel(FacilityType.pitchMaintenance);
      homeAdvantage = 1.02 + (stadiumLvl * 0.008) + (pitchLvl * 0.005) + (club.meters.fans / 2000.0);
    }

    // Takım Kimyası (§9.4, Ek C.2: 0.88 - 1.08)
    final chemistry = TeamChemistryCalculator.calculateSquadChemistry(lineup);
    final chemistryMultiplier = chemistry.multiplier;

    // Takım Uyumu & Taktik Bonusu
    double tacticMultiplier = 1.0;
    if (club.tacticalStyle == 'Ofansif') {
      totalAtk *= 1.12;
      totalDef *= 0.90;
    } else if (club.tacticalStyle == 'Defansif') {
      totalDef *= 1.15;
      totalAtk *= 0.88;
    } else if (club.tacticalStyle == 'Kontra Atak') {
      totalAtk *= 1.08;
      totalMid *= 0.95;
    } else if (club.tacticalStyle == 'Baskılı') {
      totalMid *= 1.10;
      totalAtk *= 1.05;
      totalDef *= 0.92;
    }

    if (hasTacticianPerk) {
      tacticMultiplier *= 1.05;
    }

    final formFactor = (avgMorale / 100.0) * (avgFit / 100.0) * homeAdvantage * tacticMultiplier * chemistryMultiplier;

    return TeamStrength(
      attackPower: (totalAtk / 4.0) * formFactor,
      defensePower: (totalDef / 4.0) * formFactor,
      midfieldPower: (totalMid / 4.0) * formFactor,
      goalkeeperPower: gkPower * chemistryMultiplier,
      averageFitness: avgFit,
      averageMorale: avgMorale,
      overallMultiplier: formFactor,
    );
  }
}
