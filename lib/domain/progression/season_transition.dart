// domain/progression/season_transition.dart
// Pure Dart. Handles end-of-season calculations, promotions, relegations, trophies, and reset.

import '../../core/rng/deterministic_rng.dart';
import '../../core/time/game_clock.dart';
import '../entities/facility.dart';
import '../entities/game_state.dart';
import '../generation/club_generator.dart';
import '../generation/player_generator.dart';
import 'player_growth.dart';

class SeasonReport {
  final int seasonNumber;
  final int finalRank;
  final bool isChampion;
  final bool isPromoted;
  final bool isRelegated;
  final int prizeMoney;
  final int managerXpEarned;
  final String summaryText;

  const SeasonReport({
    required this.seasonNumber,
    required this.finalRank,
    required this.isChampion,
    required this.isPromoted,
    required this.isRelegated,
    required this.prizeMoney,
    required this.managerXpEarned,
    required this.summaryText,
  });
}

class SeasonTransition {
  static SeasonReport processSeasonEnd(GameState state) {
    final rank = state.currentLeague.getRankOfClub(state.userClub.id);
    final isChampion = rank == 1;
    final isPromoted = rank <= 2 && state.userClub.leagueTier > 1;
    final isRelegated = rank >= (state.currentLeague.clubIds.length - 1) && state.userClub.leagueTier < 20;

    var prize = 0;
    var xp = 200;

    if (isChampion) {
      prize += 100000;
      xp += 1000;
    } else if (isPromoted) {
      prize += 50000;
      xp += 500;
    }

    if (rank <= state.targetLeaguePosition) {
      prize += 25000;
      xp += 250;
    }

    String summary;
    if (isChampion) {
      summary = 'ŞAMPİYON! Sezonu zirvede tamamlayarak bir üst lige yükseldiniz!';
    } else if (isPromoted) {
      summary = 'TEBRİKLER! Ligi $rank. sırada bitirerek bir üst lige terfi ettiniz!';
    } else if (isRelegated) {
      summary = 'KÜME DÜŞME: Sezon sonu hedeflerinin gerisinde kalarak alt lige gerilediniz.';
    } else {
      summary = 'Sezon tamamlandı. Ligi $rank. sırada bitirdiniz.';
    }

    return SeasonReport(
      seasonNumber: state.clock.seasonNumber,
      finalRank: rank,
      isChampion: isChampion,
      isPromoted: isPromoted,
      isRelegated: isRelegated,
      prizeMoney: prize,
      managerXpEarned: xp,
      summaryText: summary,
    );
  }

  static GameState applySeasonTransition({
    required GameState state,
    required SeasonReport report,
    required DeterministicRng rng,
  }) {
    final trainingLvl = state.userClub.getFacilityLevel(FacilityType.trainingGround);
    final academyLvl = state.userClub.getFacilityLevel(FacilityType.youthAcademy);

    // 1. Oyuncuların Yaşlanması, Sözleşmelerinin Azalması ve Gelişimi
    final updatedSquad = state.userClub.squad.map((p) {
      final grown = PlayerGrowth.applyTrainingGrowth(
        player: p,
        trainingFacilityLevel: trainingLvl,
        randomFactor: rng.nextDoubleInRange(0.85, 1.20),
      );
      return grown.copyWith(
        age: grown.age + 1,
        contractSeasonsLeft: grown.contractSeasonsLeft - 1,
        appearances: 0,
        goals: 0,
        assists: 0,
        cleanSheets: 0,
      );
    }).toList();

    // 2. Altyapı Akademisinden Yeni Genç Oyuncu Katılımı
    final youthCount = academyLvl >= 3 ? 2 : 1;
    for (var i = 0; i < youthCount; i++) {
      final youth = PlayerGenerator.generateYouthPlayer(
        rng: rng,
        academyLevel: academyLvl,
        seasonNumber: state.clock.seasonNumber + 1,
      );
      updatedSquad.add(youth);
    }

    // 3. Lig Kademesi Güncelleme
    var nextTier = state.userClub.leagueTier;
    if (report.isPromoted) {
      nextTier = (nextTier - 1).clamp(1, 20);
    } else if (report.isRelegated) {
      nextTier = (nextTier + 1).clamp(1, 20);
    }

    // 4. Kasa ve Metre Güncellemeleri
    final nextMeters = state.userClub.meters.applyDeltas(
      deltaCash: report.prizeMoney,
      deltaFans: report.isPromoted ? 15 : (report.isRelegated ? -15 : 2),
      deltaLockerRoom: report.isPromoted ? 20 : (report.isRelegated ? -20 : 5),
      deltaBoardTrust: report.isPromoted ? 25 : (report.isRelegated ? -25 : 5),
    );

    final updatedClub = state.userClub.copyWith(
      leagueTier: nextTier,
      meters: nextMeters,
      squad: updatedSquad,
      totalTrophies: report.isChampion ? state.userClub.totalTrophies + 1 : state.userClub.totalTrophies,
    );

    final updatedManager = state.manager
        .addXp(report.managerXpEarned)
        .copyWith(reputation: state.manager.reputation + (report.isPromoted ? 10 : 0));

    // 5. Yeni Sezon Fikstür ve Sıralama Tablosu Üretimi
    final newLeague = ClubGenerator.generateLeague(
      rng: rng,
      leagueTier: nextTier,
      userClub: updatedClub,
      seasonNumber: state.clock.seasonNumber + 1,
    );

    return state.copyWith(
      userClub: updatedClub,
      manager: updatedManager,
      currentLeague: newLeague,
      clock: GameClock(
        seasonNumber: state.clock.seasonNumber + 1,
        dayOfSeason: 1,
        matchday: 1,
        currentWindow: MatchWindow.morning,
      ),
      notificationLog: [
        'Sezon ${state.clock.seasonNumber} tamamlandı: ${report.summaryText}',
        ...state.notificationLog,
      ],
    );
  }
}
