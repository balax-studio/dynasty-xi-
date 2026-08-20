// domain/sim/match_engine.dart
// Pure Dart. 90-minute deterministic match simulation engine with Live Mode interactive decision branches.

import 'dart:math' as math;
import '../../core/rng/deterministic_rng.dart';
import '../entities/club.dart';
import '../entities/player.dart';
import 'match_events.dart';
import 'team_strength.dart';
import 'xg_model.dart';

class MatchSetup {
  final Club home;
  final Club away;
  final int seed;
  final bool isLiveMode;
  final bool hasTacticianPerk;

  const MatchSetup({
    required this.home,
    required this.away,
    required this.seed,
    this.isLiveMode = false,
    this.hasTacticianPerk = false,
  });
}

class MatchResult {
  final int homeGoals;
  final int awayGoals;
  final List<MatchEvent> events;
  final Map<String, double> playerRatings;
  final int possessionHome;
  final int possessionAway;
  final double xgHome;
  final double xgAway;
  final int seed;
  final int engineVersion;

  const MatchResult({
    required this.homeGoals,
    required this.awayGoals,
    required this.events,
    required this.playerRatings,
    required this.possessionHome,
    required this.possessionAway,
    required this.xgHome,
    required this.xgAway,
    required this.seed,
    this.engineVersion = 1,
  });

  bool get isHomeWin => homeGoals > awayGoals;
  bool get isAwayWin => awayGoals > homeGoals;
  bool get isDraw => homeGoals == awayGoals;

  String get scoreString => '$homeGoals - $awayGoals';
}

class MatchEngine {
  static const int kEngineVersion = 1;
  final DeterministicRng _rng;

  MatchEngine(int seed) : _rng = DeterministicRng(seed);

  MatchResult simulate(MatchSetup setup) {
    final homeStrength = TeamStrength.fromClub(
      club: setup.home,
      isHome: true,
      hasTacticianPerk: setup.hasTacticianPerk,
    );
    final awayStrength = TeamStrength.fromClub(
      club: setup.away,
      isHome: false,
    );

    // Topa Sahip Olma Hesabı — Ek C.3: possA = midA^1.35 / (midA^1.35 + midB^1.35), clamp(0.22, 0.78)
    final midAExp = math.pow(math.max(10.0, homeStrength.midfieldPower), 1.35);
    final midBExp = math.pow(math.max(10.0, awayStrength.midfieldPower), 1.35);
    final rawPossA = midAExp / (midAExp + midBExp);
    final possHome = rawPossA.clamp(0.22, 0.78);
    final possHomePercent = (possHome * 100).round();
    final possAwayPercent = 100 - possHomePercent;

    final events = <MatchEvent>[];
    var homeGoals = 0;
    var awayGoals = 0;
    var totalXgHome = 0.0;
    var totalXgAway = 0.0;

    final homeStarters = setup.home.starting11;
    final awayStarters = setup.away.starting11;

    events.add(const MatchEvent(
      minute: 0,
      type: MatchEventType.whistleStart,
      description: 'Hakem ilk düdüğü çaldı, maç başladı!',
      isHomeTeam: true,
      scoreHome: 0,
      scoreAway: 0,
    ));

    // Canlı Mod için Anahtar An (Key Moment) Dakikaları
    final keyMomentMinutes = setup.isLiveMode ? [22, 48, 73, 86] : <int>[];

    for (var minute = 1; minute <= 90; minute++) {
      if (minute == 45) {
        events.add(MatchEvent(
          minute: 45,
          type: MatchEventType.halfTime,
          description: 'İlk yarı sona erdi: $homeGoals - $awayGoals',
          scoreHome: homeGoals,
          scoreAway: awayGoals,
        ));
      }

      // Canlı An (Key Moment) Tetikleyici
      if (keyMomentMinutes.contains(minute)) {
        events.add(MatchEvent(
          minute: minute,
          type: MatchEventType.keyMoment,
          description: minute < 45
              ? 'Taktik Fırsatı: Rakip defans arkasında boşluk var!'
              : (minute < 75
                  ? 'Kritik Karar: Takım yoruluyor, hücum baskısını artıralım mı?'
                  : 'Son Dakika Hamlesi: Galibiyet için tüm hatlarla yüklenelim mi?'),
          scoreHome: homeGoals,
          scoreAway: awayGoals,
          liveOptions: [
            const LiveDecisionOption(
              id: 'all_out_attack',
              label: 'Tam Saha Baskı (+xG, Yüksek Risk)',
              description: 'Tüm takımı ileri sür. Gol şansı artar ancak kontra atak riski doğar.',
              boostXg: 0.15,
              riskCounterXg: 0.08,
            ),
            const LiveDecisionOption(
              id: 'keep_calm',
              label: 'Kontrollü Pas Oyunu (Dengeli)',
              description: 'Topa sahip ol, tempoyu düşür ve garanti boşluk kolla.',
              boostXg: 0.04,
              riskCounterXg: 0.0,
            ),
            const LiveDecisionOption(
              id: 'park_the_bus',
              label: 'Savunmaya Çekil (Defansif)',
              description: 'Skoru koru, hatları geriye yasla.',
              boostXg: -0.05,
              riskCounterXg: -0.10,
            ),
          ],
        ));
      }

      // Yorgunluk Çarpanı — Ek C.3: yorgunlukÇ(m) = 1 - max(0, m-60) * 0.004 * (1 - fitOrt/150)
      final fatigueFactor = 1.0 - math.max(0, minute - 60) * 0.004 * (1.0 - homeStrength.averageFitness / 150.0);

      // Atak Olasılığı: poss * tempoÇ * yorgunlukÇ
      final isHomeAttacking = _rng.next() < possHome;
      final attackChance = 0.235 * fatigueFactor.clamp(0.70, 1.0);

      if (_rng.next() < attackChance) {
        final attackingTeamIsHome = isHomeAttacking;
        final atkPower = attackingTeamIsHome ? homeStrength.attackPower : awayStrength.attackPower;
        final defPower = attackingTeamIsHome ? awayStrength.defensePower : homeStrength.defensePower;
        final gkPower = attackingTeamIsHome ? awayStrength.goalkeeperPower : homeStrength.goalkeeperPower;

        final attackers = attackingTeamIsHome ? homeStarters : awayStarters;
        final shooter = _pickShooter(attackers);
        final assister = _pickAssister(attackers, shooter);

        // Şut Tipi Belirleme
        final shotTypeVal = _rng.next();
        final shotType = shotTypeVal < 0.65
            ? ShotType.openPlay
            : (shotTypeVal < 0.85
                ? ShotType.counterAttack
                : (shotTypeVal < 0.95 ? ShotType.setPieceHeader : ShotType.directFreeKick));

        final shotXg = XgModel.calculateXg(
          attackPower: atkPower,
          defensePower: defPower,
          shotType: shotType,
        );

        if (attackingTeamIsHome) {
          totalXgHome += shotXg;
        } else {
          totalXgAway += shotXg;
        }

        final goalChance = XgModel.calculateGoalProbability(
          xG: shotXg,
          goalkeeperPower: gkPower,
        );

        if (_rng.next() < goalChance) {
          // GOL!
          if (attackingTeamIsHome) {
            homeGoals++;
          } else {
            awayGoals++;
          }

          events.add(MatchEvent(
            minute: minute,
            type: MatchEventType.goal,
            description: assister != null
                ? 'GOOOL! ${shooter.fullName}, ${assister.fullName}\'in pasıyla topu ağlara gönderdi!'
                : 'GOOOL! ${shooter.fullName} harika bir vuruşla golü buldu!',
            primaryPlayerName: shooter.fullName,
            secondaryPlayerName: assister?.fullName,
            isHomeTeam: attackingTeamIsHome,
            scoreHome: homeGoals,
            scoreAway: awayGoals,
          ));
        } else {
          // Kaçan şut veya Kaleci kurtarışı
          final isSaved = _rng.next() < 0.55;
          events.add(MatchEvent(
            minute: minute,
            type: isSaved ? MatchEventType.shotSaved : MatchEventType.shotOffTarget,
            description: isSaved
                ? '${shooter.fullName} kaleyi yokladı, kaleci son anda kornere çeldi!'
                : '${shooter.fullName} sert vurdu ama top az farkla auta gitti.',
            primaryPlayerName: shooter.fullName,
            isHomeTeam: attackingTeamIsHome,
            scoreHome: homeGoals,
            scoreAway: awayGoals,
          ));
        }
      }

      // Kart ve Faul Olayları
      if (_rng.next() < 0.022) {
        final isHomeFoul = _rng.next() < 0.5;
        final foulers = isHomeFoul ? homeStarters : awayStarters;
        if (foulers.isNotEmpty) {
          final fouler = _rng.pick(foulers);
          final isYellow = _rng.next() < 0.35;
          if (isYellow) {
            events.add(MatchEvent(
              minute: minute,
              type: MatchEventType.yellowCard,
              description: 'Sarı Kart: ${fouler.fullName} rakibine yaptığı sert müdahale nedeniyle uyarıldı.',
              primaryPlayerName: fouler.fullName,
              isHomeTeam: isHomeFoul,
              scoreHome: homeGoals,
              scoreAway: awayGoals,
            ));
          }
        }
      }
    }

    events.add(MatchEvent(
      minute: 90,
      type: MatchEventType.fullTime,
      description: 'Maç sona erdi! Maç Sonucu: $homeGoals - $awayGoals',
      scoreHome: homeGoals,
      scoreAway: awayGoals,
    ));

    // Oyuncu Puanları Hesabı (6.0 taban puanı)
    final ratings = _computeRatings(homeStarters, awayStarters, homeGoals, awayGoals, events);

    return MatchResult(
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      events: events,
      playerRatings: ratings,
      possessionHome: possHomePercent,
      possessionAway: possAwayPercent,
      xgHome: double.parse(totalXgHome.toStringAsFixed(2)),
      xgAway: double.parse(totalXgAway.toStringAsFixed(2)),
      seed: _rng.seed,
      engineVersion: kEngineVersion,
    );
  }

  Player _pickShooter(List<Player> lineup) {
    if (lineup.isEmpty) {
      return const Player(
        id: 'generic',
        firstName: 'Forvet',
        lastName: 'Oyuncu',
        countryCode: 'TR',
        age: 24,
        position: Position.st,
        pace: 70,
        technique: 70,
        shooting: 75,
        passing: 65,
        defending: 40,
        physical: 70,
        mentality: 70,
        potential: 75,
        weeklyWage: 1000,
      );
    }
    return _rng.weightedPick(lineup, (p) {
      if (p.position.isForward) return p.shooting * 1.8 + p.technique;
      if (p.position.isMidfielder) return p.shooting * 0.8 + p.passing;
      return 5.0;
    });
  }

  Player? _pickAssister(List<Player> lineup, Player shooter) {
    final candidates = lineup.where((p) => p.id != shooter.id).toList();
    if (candidates.isEmpty) return null;
    if (_rng.next() < 0.25) return null; // Bireysel gol

    return _rng.weightedPick<Player>(candidates, (Player p) {
      if (p.position.isMidfielder) return p.passing * 2.0 + p.technique;
      if (p.position.isForward) return p.passing * 1.2;
      return p.passing * 0.5;
    });
  }

  Map<String, double> _computeRatings(
    List<Player> homeLineup,
    List<Player> awayLineup,
    int homeGoals,
    int awayGoals,
    List<MatchEvent> events,
  ) {
    final ratings = <String, double>{};
    final allPlayers = [...homeLineup, ...awayLineup];

    for (final p in allPlayers) {
      var rating = 6.0 + (_rng.nextDoubleInRange(-0.4, 0.4));
      // Gol katkısı
      final goalsScored = events
          .where((e) => e.type == MatchEventType.goal && e.primaryPlayerName == p.fullName)
          .length;
      final assists = events
          .where((e) => e.type == MatchEventType.goal && e.secondaryPlayerName == p.fullName)
          .length;
      final yellowCards = events
          .where((e) => e.type == MatchEventType.yellowCard && e.primaryPlayerName == p.fullName)
          .length;

      rating += goalsScored * 1.2;
      rating += assists * 0.7;
      rating -= yellowCards * 0.4;

      final isHome = homeLineup.contains(p);
      if (isHome) {
        if (homeGoals > awayGoals) rating += 0.4;
        if (awayGoals == 0 && (p.position.isDefender || p.position.isGoalkeeper)) rating += 0.6;
        if (homeGoals < awayGoals) rating -= 0.3;
      } else {
        if (awayGoals > homeGoals) rating += 0.4;
        if (homeGoals == 0 && (p.position.isDefender || p.position.isGoalkeeper)) rating += 0.6;
        if (awayGoals < homeGoals) rating -= 0.3;
      }

      ratings[p.id] = double.parse(rating.clamp(4.0, 10.0).toStringAsFixed(1));
    }

    return ratings;
  }
}
