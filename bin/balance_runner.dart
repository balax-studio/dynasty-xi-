// ignore_for_file: avoid_print
// bin/balance_runner.dart
// CLI 10,000 match balance simulation runner.

import 'package:futbol/core/rng/deterministic_rng.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/facility.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/generation/player_generator.dart';
import 'package:futbol/domain/sim/match_engine.dart';

void main(List<String> args) {
  final matchCount = args.isNotEmpty ? int.tryParse(args[0]) ?? 10000 : 10000;

  print('====================================================');
  print('DYNASTY XI — 10.000 MAÇLIK DENGE SİMÜLASYON MOTORU');
  print('====================================================');
  print('Simüle edilecek maç sayısı: $matchCount\n');

  final rng = DeterministicRng(42);

  final homeSquad = PlayerGenerator.generateSquad(
    rng: rng,
    leagueTier: 10,
    clubIdPrefix: 'home_c',
  );
  final awaySquad = PlayerGenerator.generateSquad(
    rng: rng,
    leagueTier: 10,
    clubIdPrefix: 'away_c',
  );

  final homeFacilities = <FacilityType, Facility>{
    FacilityType.stadium: const Facility(type: FacilityType.stadium, level: 3),
    FacilityType.pitchMaintenance: const Facility(type: FacilityType.pitchMaintenance, level: 2),
  };

  final homeClub = Club(
    id: 'home_c',
    name: 'Ev Sahibi FC',
    city: 'Angora',
    leagueTier: 10,
    meters: const ClubMeters(cash: 100000, fans: 60, lockerRoom: 50, boardTrust: 50),
    facilities: homeFacilities,
    squad: homeSquad,
    starting11Ids: homeSquad.take(11).map((p) => p.id).toList(),
  );

  final awayClub = Club(
    id: 'away_c',
    name: 'Deplasman SK',
    city: 'Yeşilova',
    leagueTier: 10,
    meters: const ClubMeters(cash: 100000, fans: 50, lockerRoom: 50, boardTrust: 50),
    facilities: const {},
    squad: awaySquad,
    starting11Ids: awaySquad.take(11).map((p) => p.id).toList(),
  );

  var homeWins = 0;
  var draws = 0;
  var awayWins = 0;
  var totalGoals = 0;
  var totalHomeGoals = 0;
  var totalAwayGoals = 0;
  var totalHomeXg = 0.0;
  var totalAwayXg = 0.0;

  final stopwatch = Stopwatch()..start();

  for (var i = 0; i < matchCount; i++) {
    final setup = MatchSetup(
      home: homeClub,
      away: awayClub,
      seed: 1000000 + i,
      isLiveMode: false,
    );

    final engine = MatchEngine(setup.seed);
    final result = engine.simulate(setup);

    totalHomeGoals += result.homeGoals;
    totalAwayGoals += result.awayGoals;
    totalGoals += (result.homeGoals + result.awayGoals);
    totalHomeXg += result.xgHome;
    totalAwayXg += result.xgAway;

    if (result.homeGoals > result.awayGoals) {
      homeWins++;
    } else if (result.homeGoals < result.awayGoals) {
      awayWins++;
    } else {
      draws++;
    }
  }

  stopwatch.stop();

  final homeWinPct = (homeWins / matchCount) * 100;
  final drawPct = (draws / matchCount) * 100;
  final awayWinPct = (awayWins / matchCount) * 100;
  final avgGoals = totalGoals / matchCount;
  final avgHomeGoals = totalHomeGoals / matchCount;
  final avgAwayGoals = totalAwayGoals / matchCount;
  final avgHomeXg = totalHomeXg / matchCount;
  final avgAwayXg = totalAwayXg / matchCount;

  print('--- SİMÜLASYON SONUÇLARI (${stopwatch.elapsedMilliseconds} ms) ---');
  print('Ev Sahibi Galibiyet : %${homeWinPct.toStringAsFixed(2)} (Hedef: %42 - %48)');
  print('Beraberlik          : %${drawPct.toStringAsFixed(2)} (Hedef: %22 - %28)');
  print('Deplasman Galibiyet : %${awayWinPct.toStringAsFixed(2)} (Hedef: %26 - %32)');
  print('Maç Başına Gol      : ${avgGoals.toStringAsFixed(2)} (Hedef: 2.40 - 3.10)');
  print('Ev Sahibi Gol/Maç   : ${avgHomeGoals.toStringAsFixed(2)}');
  print('Deplasman Gol/Maç   : ${avgAwayGoals.toStringAsFixed(2)}');
  print('Ortalama xG (Ev/Dep): ${avgHomeXg.toStringAsFixed(2)} / ${avgAwayXg.toStringAsFixed(2)}');
  print('----------------------------------------------------');

  final isHomeWinValid = homeWinPct >= 40.0 && homeWinPct <= 50.0;
  final isDrawValid = drawPct >= 20.0 && drawPct <= 30.0;
  final isAwayWinValid = awayWinPct >= 24.0 && awayWinPct <= 34.0;
  final isGoalAvgValid = avgGoals >= 2.20 && avgGoals <= 3.30;

  if (isHomeWinValid && isDrawValid && isAwayWinValid && isGoalAvgValid) {
    print('✅ DENGE TESTİ BAŞARILI! Bütün değerler sektör ve doküman toleransları içinde.');
  } else {
    print('❌ DENGE TESTİ UYARISI: Bazı değerler tolerans sınırlarını aştı.');
  }
  print('====================================================\n');
}
