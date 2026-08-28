import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/rng/deterministic_rng.dart';
import '../../data/assets/card_database.dart';
import '../../data/local/save_repository.dart';
import '../../domain/cards/card_effects.dart';
import '../../domain/cards/card_selector.dart';
import '../../domain/economy/financial_statement.dart';
import '../../domain/economy/offline_calculator.dart';
import '../../domain/economy/negotiation_model.dart';
import '../../domain/economy/sponsorship_contract.dart';
import '../../domain/economy/transfer_models.dart';
import '../../domain/entities/card.dart';
import '../../domain/entities/club.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/meter.dart';
import '../../domain/entities/player.dart';
import '../../domain/generation/club_generator.dart';
import '../../domain/progression/daily_quest.dart';
import '../../domain/progression/dynasty_prestige.dart';
import '../../domain/progression/season_transition.dart';
import '../../domain/sim/match_engine.dart';
import '../../domain/sim/match_events.dart';
import '../../domain/tournament/continental_cup.dart';
import '../../domain/rpg/player_dialogue_engine.dart';
import '../../domain/entities/staff.dart';
import '../../domain/generation/player_generator.dart';
import '../../domain/rpg/head_coach_dialogue_engine.dart';
import '../../domain/president/head_coach.dart';
import '../../domain/president/boardroom_summit.dart';
import '../../domain/president/president_crisis.dart';
import '../../domain/president/crisis_trigger_engine.dart';
import '../../domain/sim/match_stats_applier.dart';
import '../../domain/sim/player_condition.dart';
import '../../domain/sim/injury_engine.dart';
import '../../domain/economy/weekly_ledger.dart';
import '../../domain/cards/dynamic_card_factory.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/progression/coaching_license.dart';
import '../../domain/president/president_lifestyle.dart';
import '../../domain/transfers/transfer_hijack.dart';
import '../../domain/president/legal_defense.dart';
import '../../domain/transfers/transfer_window_rules.dart';
import '../../domain/scouting/scouting_mission.dart';
import '../../domain/facilities/training_camp.dart';
import '../../domain/generation/scout_service.dart';
import '../../core/time/game_clock.dart';

final saveRepositoryProvider = Provider<SaveRepository>((ref) => SaveRepository());

final gameStateProvider = StateNotifierProvider<GameStateNotifier, AsyncValue<GameState>>((ref) {
  final saveRepo = ref.watch(saveRepositoryProvider);
  return GameStateNotifier(saveRepo);
});

class GameStateNotifier extends StateNotifier<AsyncValue<GameState>> {
  final SaveRepository _saveRepository;
  final DeterministicRng _rng = DeterministicRng(DateTime.now().millisecondsSinceEpoch);

  GameStateNotifier(this._saveRepository) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final saved = await _saveRepository.load();
      if (saved != null) {
        final lastExit = await _saveRepository.getLastExitEpochMs();
        if (lastExit != null) {
          final elapsedSeconds = ((DateTime.now().millisecondsSinceEpoch - lastExit) / 1000).round();
          if (elapsedSeconds > 60) {
            final offlineReport = OfflineCalculator.calculateOfflineProgress(
              club: saved.userClub,
              elapsedSeconds: elapsedSeconds,
            );
            final updated = saved.copyWith(
              userClub: offlineReport.updatedClub,
              notificationLog: [
                if (offlineReport.passiveCashEarned > 0)
                  'Çevrimdışı Kazanç: +₣${offlineReport.passiveCashEarned} kasa hesabına eklendi (${offlineReport.effectiveHoursClamped} saat).',
                ...saved.notificationLog,
              ],
            );
            state = AsyncValue.data(updated);
            await _saveRepository.save(updated);
            await checkFacilityUpgrades();
            return;
          }
        }
        state = AsyncValue.data(saved);
        await checkFacilityUpgrades();
      } else {
        final newGame = SaveRepository.createNewGame();
        await _saveRepository.save(newGame);
        state = AsyncValue.data(newGame);
      }
    } catch (e) {
      // Bozuk kayıt veya yükleme hatasında güvenli bir şekilde yeni oyun oluştur
      try {
        await _saveRepository.clearSave();
        final newGame = SaveRepository.createNewGame();
        await _saveRepository.save(newGame);
        state = AsyncValue.data(newGame);
      } catch (err, st) {
        state = AsyncValue.error(err, st);
      }
    }
  }

  GameState? get currentState => state.valueOrNull;

  /// Karar Kartı Seçimini Uygula
  Future<void> chooseCardOption(DecisionCard card, CardOption option) async {
    final current = currentState;
    if (current == null) return;

    final updated = CardEffectRunner.applyCardChoice(
      state: current,
      card: card,
      option: option,
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Sıradaki Maçı Simüle Et veya Canlı Maç Sonucunu Kaydet (7 Fazlı Modüler Boru Hattı — Bölüm A & §11)
  Future<MatchResult?> playMatch({bool isLiveMode = false, MatchResult? liveResult}) async {
    final current = currentState;
    if (current == null || current.isGameOver) return null;

    // FAZ 1: ÖN KONTROLLER & FİKSTÜR
    final fixture = current.currentLeague.fixtures.where(
      (f) => f.matchday == current.clock.matchday && !f.isPlayed,
    ).firstOrNull;

    if (fixture == null) {
      return null;
    }

    final isUserHome = fixture.homeClubId == current.userClub.id;
    final oppClubId = isUserHome ? fixture.awayClubId : fixture.homeClubId;
    final oppClub = _getOpponentClub(current, oppClubId);

    // FAZ 2: MAÇ MOTORU SİMÜLASYONU (§11)
    final matchSeed = liveResult?.seed ?? (current.clock.seasonNumber * 10000 + current.clock.matchday * 100 + _rng.nextInt(99));
    final setup = MatchSetup(
      home: isUserHome ? current.userClub : oppClub,
      away: isUserHome ? oppClub : current.userClub,
      seed: matchSeed,
      isLiveMode: isLiveMode,
      hasTacticianPerk: current.manager.hasPerk('tactician_1'),
    );

    final engine = MatchEngine(setup.seed);
    final result = liveResult ?? engine.simulate(setup);

    final userGoals = isUserHome ? result.homeGoals : result.awayGoals;
    final oppGoals = isUserHome ? result.awayGoals : result.homeGoals;
    final isUserWin = userGoals > oppGoals;
    final isUserDraw = userGoals == oppGoals;

    // FAZ 3: OYUNCU DURUMU, İSTATİSTİK & SAKATLIK BORU HATTI (A-2, A-3, A-4, A-5)
    final starterIds = current.userClub.starting11Ids.toSet();

    // Kiralık süresi dolanları filtrele
    final updatedLoanDeals = <LoanDeal>[];
    final expiredLoanPlayerIds = <String>{};
    for (final deal in current.activeLoanDeals) {
      final rem = deal.weeksRemaining - 1;
      if (rem > 0) {
        updatedLoanDeals.add(deal.copyWith(weeksRemaining: rem));
      } else {
        expiredLoanPlayerIds.add(deal.player.id);
      }
    }
    final activeRoster = current.userClub.squad.where((p) => !expiredLoanPlayerIds.contains(p.id)).toList();

    // Gol ve asist olayları
    final userGoalEvents = result.events
        .where((e) => e.type == MatchEventType.goal && e.isHomeTeam == isUserHome)
        .map((e) {
          final scorer = activeRoster.where((p) => p.fullName == e.primaryPlayerName).firstOrNull;
          final assist = activeRoster.where((p) => p.fullName == e.secondaryPlayerName).firstOrNull;
          return MatchGoalEvent(
            minute: e.minute,
            scorerName: e.primaryPlayerName,
            scorerId: scorer?.id,
            assistantName: e.secondaryPlayerName,
            assistantId: assist?.id,
            isHome: isUserHome,
          );
        }).toList();

    // A-2: Maç İstatistikleri & Reytingler
    final matchStats = MatchStatsApplier.apply(
      currentSquad: activeRoster,
      starting11Ids: starterIds,
      userGoals: userGoals,
      opponentGoals: oppGoals,
      opponentOvr: oppClub.averageOvr.round(),
      userGoalEvents: userGoalEvents,
      randomSeed: matchSeed,
    );

    // A-3 & A-5: Kondisyon (Fitness), Form, Keskinlik & Moral Tetikleyicileri
    final conditionSquad = PlayerConditionApplier.applyPostMatchCondition(
      squad: matchStats.updatedPlayers,
      starting11Ids: starterIds,
      userGoals: userGoals,
      opponentGoals: oppGoals,
      performances: matchStats.performances,
      trainingGroundLevel: current.userClub.facilities[FacilityType.trainingGround]?.level ?? 1,
    );

    // A-4: Sakatlık Motoru & İyileşme
    final injuryResult = InjuryEngine.processMatchInjuries(
      currentSquad: conditionSquad,
      matchParticipants: starterIds,
      medicalCenterLevel: current.userClub.facilities[FacilityType.medicalCenter]?.level ?? 1,
      randomSeed: matchSeed,
    );
    final updatedSquad = injuryResult.squad;

    // FAZ 4: EKONOMİ & BİLANÇO BORU HATTI (C-1, C-2, C-3)
    final ledger = WeeklyLedgerCalculator.calculate(
      state: current,
      isHomeMatch: isUserHome,
      isWin: isUserWin,
    );

    // Banka Kredisi Taksit Ödemesi
    BankLoan? updatedLoan = current.activeLoan;
    bool loanPaidOff = false;
    if (updatedLoan != null) {
      updatedLoan = updatedLoan.payWeeklyInstallment();
      if (updatedLoan.isPaidOff) {
        loanPaidOff = true;
        updatedLoan = null;
      }
    }

    // Sponsorluk Süreleri & Bonuslar
    final updatedSponsorships = <SponsorshipSlot, SponsorshipContract>{};
    final sponsorExpiryLogs = <String>[];
    var extraSponsorCash = 0;
    int updatedSleeve = current.sleeveSponsorIncome;
    int updatedStadiumNaming = current.stadiumNamingIncome;
    int updatedMainShirtIncome = current.userClub.sponsorWeeklyIncome;

    for (final entry in current.activeSponsorships.entries) {
      final contract = entry.value;
      if (isUserWin && contract.perk.matchWinBonus > 0) {
        extraSponsorCash += contract.perk.matchWinBonus;
      }
      final remaining = contract.weeksRemaining - 1;
      if (remaining > 0) {
        updatedSponsorships[entry.key] = contract.copyWith(weeksRemaining: remaining);
      } else {
        sponsorExpiryLogs.add('[DUYURU] [${contract.brandName}] ile ${contract.slot.label} sponsorluk sözleşmeniz sona erdi!');
        switch (contract.slot) {
          case SponsorshipSlot.mainShirt:
            updatedMainShirtIncome = 0;
            break;
          case SponsorshipSlot.sleeve:
            updatedSleeve = 0;
            break;
          case SponsorshipSlot.stadiumNaming:
            updatedStadiumNaming = 0;
            break;
        }
      }
    }

    final netCashDelta = ledger.netCashFlow + extraSponsorCash;

    // Metre Güncellemeleri & Kovulma Kontrolü (E-1)
    final deltaFans = isUserWin ? 4 : (isUserDraw ? 0 : -3);
    final deltaLocker = isUserWin ? 6 : (isUserDraw ? 1 : -5);
    final deltaBoard = isUserWin ? 5 : (isUserDraw ? 0 : -4);

    final interimMeters = current.userClub.meters.applyDeltas(
      deltaCash: netCashDelta,
      deltaFans: deltaFans,
      deltaLockerRoom: deltaLocker,
      deltaBoardTrust: deltaBoard,
    );
    final finalMeters = interimMeters.onMatchCompleted();

    // 3 Aşamalı Kovulma Mantığı (E-1)
    int sackingCountdown = current.sackingCountdownMatches;
    if (finalMeters.boardTrust < 15) {
      sackingCountdown = sackingCountdown > 0 ? sackingCountdown - 1 : 3;
    } else {
      sackingCountdown = 0;
    }

    final isGameOver = finalMeters.isSacked || (finalMeters.boardTrust < 15 && sackingCountdown == 0) || current.isGameOver;
    final gameOverReason = isGameOver
        ? (current.gameOverReason ?? 'Yönetim Kurulu Güvenini Kaybettiniz (Kovuldunuz)')
        : null;

    // FAZ 5: İLERLEME, FİKSTÜR & PUAN DURUMU
    final updatedFixtures = current.currentLeague.fixtures.map((f) {
      if (f.id == fixture.id) {
        return f.copyWith(
          homeScore: result.homeGoals,
          awayScore: result.awayGoals,
          isPlayed: true,
        );
      }
      return f;
    }).toList();

    var tempStandings = current.currentLeague.standings.map((entry) {
      if (entry.clubId == current.userClub.id) {
        return entry.recordMatch(goalsScored: userGoals, goalsConceded: oppGoals);
      } else if (entry.clubId == oppClub.id) {
        return entry.recordMatch(goalsScored: oppGoals, goalsConceded: userGoals);
      }
      return entry;
    }).toList();

    // Diğer lig maçlarının simülasyonu
    final otherClubs = tempStandings.where(
      (entry) => entry.clubId != current.userClub.id && entry.clubId != oppClub.id,
    ).toList();

    for (var i = 0; i + 1 < otherClubs.length; i += 2) {
      final clubA = otherClubs[i];
      final clubB = otherClubs[i + 1];
      final goalsA = _rng.nextInt(4);
      final goalsB = _rng.nextInt(4);

      tempStandings = tempStandings.map((entry) {
        if (entry.clubId == clubA.clubId) {
          return entry.recordMatch(goalsScored: goalsA, goalsConceded: goalsB);
        } else if (entry.clubId == clubB.clubId) {
          return entry.recordMatch(goalsScored: goalsB, goalsConceded: goalsA);
        }
        return entry;
      }).toList();
    }

    final updatedLeague = current.currentLeague.copyWith(
      fixtures: updatedFixtures,
      standings: tempStandings,
    );

    // Tesis İnşaatı Kontrolü (A-6)
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedFacMap = Map<FacilityType, Facility>.from(current.userClub.facilities);
    final facilityLogs = <String>[];

    for (final entry in current.userClub.facilities.entries) {
      final fac = entry.value;
      if (fac.isUpgrading && fac.upgradeFinishEpochMs != null && now >= fac.upgradeFinishEpochMs!) {
        updatedFacMap[entry.key] = fac.copyWith(
          level: fac.level + 1,
          isUpgrading: false,
          upgradeFinishEpochMs: null,
        );
        facilityLogs.add('[TESİS] Tesis Tamamlandı: ${fac.type.label} Sv.${fac.level + 1} hizmete girdi!');
      }
    }

    // Günlük Görevler (E-4)
    final updatedDailyQuests = DailyQuestManager.advanceQuest(
      current.dailyQuests,
      QuestTrigger.leagueMatch,
    );

    // Menajer XP & İtibar & KulüpXP (E-3, E-6)
    final xpEarned = 30 + (isUserWin ? 50 : (isUserDraw ? 20 : 0));
    final updatedManager = current.manager.addXp(xpEarned);
    final updatedClubXp = current.clubXp + (isUserWin ? 25 : (isUserDraw ? 10 : 0));

    // Kupa Müzesi Rekorları (E-5)
    final updatedMuseumRecords = current.museumRecords.checkAndRecordMatch(
      homeScore: userGoals,
      awayScore: oppGoals,
      opponentName: oppClub.name,
      isWin: isUserWin,
    );

    // FAZ 6: KART SEÇİMİ, SCOUT KUYRUĞU & KRİZ MOTORU (D-1, D-2, D-3, D-4)
    final nextClock = current.clock.advanceMatch();

    // Asenkron Scout Seferleri İlerlemesi
    final tickedScoutingMissions = <ScoutingMission>[];
    final scoutLogs = <String>[];
    for (final mission in current.activeScoutingMissions) {
      final updatedMission = mission.tickMatch();
      tickedScoutingMissions.add(updatedMission);
      if (updatedMission.isCompleted && !mission.isCompleted) {
        scoutLogs.add('[SCOUT] Gözlemci Raporu Hazır: ${mission.region} bölgesinden ${updatedMission.discoveredProspects.length} oyuncu analizi masanızda!');
      }
    }

    // Sezon Fazı Bildirimleri
    final phaseLogs = <String>[];
    if (nextClock.phase == SeasonPhase.midSeasonBreak && current.clock.phase != SeasonPhase.midSeasonBreak) {
      phaseLogs.add('[DEVRE ARASI] 1. Yarı tamamlandı! Devre arası kampı ve Kış Transfer Penceresi açıldı.');
    } else if (nextClock.phase == SeasonPhase.seasonEvaluation && current.clock.phase != SeasonPhase.seasonEvaluation) {
      phaseLogs.add('[SEZON SONU] Lig maratonu tamamlandı! Sezon değerlendirmesi ve kupa töreni hazır.');
    }

    final newSessionCards = CardSelector.pickSessionCards(
      cardDatabase: CardDatabase.mvpCards,
      state: current,
      rng: _rng,
      count: 2,
    );

    // Sakatlanan oyuncular için dinamik karar kartı ekle
    final dynamicInjuryCards = injuryResult.newInjuries
        .map((inj) => DynamicCardFactory.createInjuryCard(inj.player, inj))
        .toList();

    final allPendingCards = [...dynamicInjuryCards, ...newSessionCards];

    // Kriz Cooldown & Tetikleyici (D-4)
    final nextCrisisCooldown = current.crisisCooldownMatches > 0 ? current.crisisCooldownMatches - 1 : 0;
    PresidentCrisisCall? nextCrisis = current.activeCrisisCall;

    // FAZ 7: STATE COMMIT & PERSISTENCE
    final updatedState = current.copyWith(
      userClub: current.userClub.copyWith(
        meters: finalMeters,
        sponsorWeeklyIncome: updatedMainShirtIncome,
        facilities: updatedFacMap,
        squad: updatedSquad,
      ),
      manager: updatedManager,
      currentLeague: updatedLeague,
      clock: nextClock,
      activeScoutingMissions: tickedScoutingMissions,
      pendingCards: allPendingCards,
      activeSponsorships: updatedSponsorships,
      sleeveSponsorIncome: updatedSleeve,
      stadiumNamingIncome: updatedStadiumNaming,
      activeLoan: loanPaidOff ? null : updatedLoan,
      clearLoan: loanPaidOff,
      activeLoanDeals: updatedLoanDeals,
      museumRecords: updatedMuseumRecords,
      dailyQuests: updatedDailyQuests,
      crisisCooldownMatches: nextCrisisCooldown,
      sackingCountdownMatches: sackingCountdown,
      isGameOver: isGameOver,
      gameOverReason: gameOverReason,
      clubXp: updatedClubXp,
      notificationLog: [
        'Maç Sonucu: ${current.userClub.name} $userGoals - $oppGoals ${oppClub.name}',
        if (extraSponsorCash > 0) '[KASA] Sponsor Galibiyet Primi: +₣$extraSponsorCash hesaba yattı!',
        if (loanPaidOff) '[KUTLAMA] Banka Kredisi Tamamen Ödendi ve Kapatıldı!',
        ...phaseLogs,
        ...scoutLogs,
        ...injuryResult.newInjuries.map((inj) => '[REVİR] Sakatlık: ${inj.player.fullName} (${inj.injuryType}, ${inj.matchesOut} maç yok)'),
        ...injuryResult.recoveredPlayers.map((rec) => '[ETKI] İyileşme: ${rec.fullName} sahalara geri döndü!'),
        ...sponsorExpiryLogs,
        ...facilityLogs,
        ...current.notificationLog,
      ],
    );

    if (nextCrisis == null && nextCrisisCooldown == 0) {
      final evaluated = CrisisTriggerEngine.evaluateCrisis(updatedState);
      if (evaluated != null && !current.resolvedCrisisIds.contains(evaluated.id)) {
        nextCrisis = evaluated;
      }
    }

    var finalState = updatedState.copyWith(
      activeCrisisCall: nextCrisis,
      clearCrisisCall: nextCrisis == null,
    );

    finalState = _checkAndAwardAchievements(finalState);

    state = AsyncValue.data(finalState);
    await _saveRepository.save(finalState);

    return result;
  }

  /// Kırmızı Hat Acil Kriz Çağrısını Çöz
  Future<void> resolveCrisisCall(CrisisChoice choice) async {
    final current = currentState;
    if (current == null) return;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: choice.cashDelta,
      deltaFans: choice.fansDelta,
      deltaLockerRoom: choice.lockerRoomDelta,
      deltaBoardTrust: choice.boardTrustDelta,
    );

    final resolvedId = current.activeCrisisCall?.id;
    final updatedResolvedIds = resolvedId != null
        ? [...current.resolvedCrisisIds, resolvedId]
        : current.resolvedCrisisIds;

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      clearCrisisCall: true,
      crisisCooldownMatches: 3,
      resolvedCrisisIds: updatedResolvedIds,
      notificationLog: [
        '[KIRMIZI] Kırmızı Hat Kriz Çözümü: ${choice.outcomeMessage}',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Kırmızı Hat Çağrısını Ertele / Kapat
  Future<void> dismissCrisisCall() async {
    final current = currentState;
    if (current == null) return;

    final updated = current.copyWith(clearCrisisCall: true);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Dynasty HUD Kısayolunu Sabitle / Çıkar
  Future<void> toggleShortcutPinned(String shortcutId) async {
    final current = currentState;
    if (current == null) return;

    final list = List<String>.from(current.pinnedShortcutIds);
    if (list.contains(shortcutId)) {
      list.remove(shortcutId);
    } else {
      list.add(shortcutId);
    }

    final updated = current.copyWith(pinnedShortcutIds: list);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Dynasty HUD Kısayol Listesini Güncelle
  Future<void> setPinnedShortcuts(List<String> shortcutIds) async {
    final current = currentState;
    if (current == null) return;

    final updated = current.copyWith(pinnedShortcutIds: shortcutIds);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Dynasty HUD Kısayollarını Varsayılana Sıfırla
  Future<void> resetShortcutsToDefault() async {
    final current = currentState;
    if (current == null) return;

    final updated = current.copyWith(
      pinnedShortcutIds: const [
        'head_coach',
        'boardroom_summit',
        'cup_tournament',
        'prestige',
        'facilities',
        'staff',
        'board_room',
        'press_conference',
        'scouting',
        'trophy_room',
      ],
    );
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Teknik Ekip Üyesini Eğitip Geliştir
  Future<bool> upgradeStaffMember(String staffId) async {
    final current = currentState;
    if (current == null) return false;

    final staffList = List<StaffMember>.from(current.staff.isEmpty ? StaffGenerator.generateDefaultStaff() : current.staff);
    final idx = staffList.indexWhere((s) => s.id == staffId);
    if (idx == -1) return false;

    final staff = staffList[idx];
    if (staff.level >= 5) return false;

    final cost = staff.level * 2500;
    if (current.userClub.meters.cash < cost) return false;

    final updatedStaff = staff.copyWith(
      level: staff.level + 1,
      weeklySalary: staff.weeklySalary + 400,
    );
    staffList[idx] = updatedStaff;

    final updatedMeters = current.userClub.meters.applyDeltas(deltaCash: -cost, deltaBoardTrust: 2);
    final updated = current.copyWith(
      staff: staffList,
      userClub: current.userClub.copyWith(meters: updatedMeters),
      notificationLog: [
        ' Teknik Ekip: ${staff.name} kursu tamamlayarak Seviye ${staff.level + 1} oldu! (Maliyet: ₣$cost)',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Pazardan Yeni Teknik Ekip Üyesi Transfer Et
  Future<bool> hireStaffMember(StaffMember newStaff) async {
    final current = currentState;
    if (current == null) return false;

    if (current.userClub.meters.cash < newStaff.signingFee) return false;

    final staffList = List<StaffMember>.from(current.staff.isEmpty ? StaffGenerator.generateDefaultStaff() : current.staff);
    final existingIdx = staffList.indexWhere((s) => s.role == newStaff.role);

    if (existingIdx != -1) {
      staffList[existingIdx] = newStaff;
    } else {
      staffList.add(newStaff);
    }

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -newStaff.signingFee,
      deltaBoardTrust: 3,
      deltaFans: newStaff.role == StaffRole.brandSpecialist ? 5 : 0,
    );

    final updated = current.copyWith(
      staff: staffList,
      userClub: current.userClub.copyWith(meters: updatedMeters),
      notificationLog: [
        '[ANLASMA] Yeni Uzman İmzası: ${newStaff.name} (${newStaff.role.label}) göreve başladı!',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// En İyi 11'i Otomatik Belirle ve Diz
  Future<void> autoSelectBest11() async {
    final current = currentState;
    if (current == null) return;

    final best11Ids = current.userClub.calculateBest11Ids();
    final allIds = current.userClub.squad.map((p) => p.id).toList();
    final subs = allIds.where((id) => !best11Ids.contains(id)).toList();

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        starting11Ids: best11Ids,
        substituteIds: subs,
      ),
      notificationLog: [
        'BOLT Taktik Panosu: En yüksek OVR\'lı ilk 11 otomatik olarak sahaya dizildi.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// İlk 11 ile Yedek Oyuncuyu Takasla
  Future<void> swapStartingAndBench(String startingPlayerId, String benchPlayerId) async {
    final current = currentState;
    if (current == null) return;

    final updatedClub = current.userClub.swapStartingAndBench(startingPlayerId, benchPlayerId);
    final updated = current.copyWith(userClub: updatedClub);

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// U19 Genç Oyuncusunu A Takıma Yükselt
  Future<bool> promoteU19Player(Player player) async {
    final current = currentState;
    if (current == null) return false;

    final updatedU19 = current.userClub.u19Squad.where((p) => p.id != player.id).toList();
    final promoted = player.copyWith(
      morale: 95,
      contractSeasonsLeft: 3,
      weeklyWage: (player.weeklyWage * 1.5).round(),
    );
    final updatedSquad = [...current.userClub.squad, promoted];

    final updatedMeters = current.userClub.meters.applyDeltas(deltaFans: 3, deltaLockerRoom: 2);
    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        u19Squad: updatedU19,
        meters: updatedMeters,
      ),
      notificationLog: [
        'STAR A Takıma Yükseltme: Genç yetenek ${player.fullName} (${player.position.code}) A Takım kadrosuna katıldı!',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Altyapı Akademisinden Yeni Genç Yetenek Keşfet / Scout Et
  Future<bool> scoutNewYouthTalent() async {
    final current = currentState;
    if (current == null) return false;

    const scoutCost = 3000;
    if (current.userClub.meters.cash < scoutCost) return false;

    final academyLevel = current.userClub.getFacilityLevel(FacilityType.youthAcademy);
    final coachMultiplier = current.headCoach?.archetype.youthMultiplier ?? 1.0;

    final youthPlayer = PlayerGenerator.generateYouthPlayer(
      rng: _rng,
      academyLevel: (academyLevel * coachMultiplier).round().clamp(1, 10),
      seasonNumber: current.clock.seasonNumber,
    );

    final updatedU19 = [...current.userClub.u19Squad, youthPlayer];
    final updatedMeters = current.userClub.meters.applyDeltas(deltaCash: -scoutCost, deltaFans: 1);

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        u19Squad: updatedU19,
        meters: updatedMeters,
      ),
      notificationLog: [
        ' Yeni Akademi Yeteneği: ${youthPlayer.fullName} (${youthPlayer.position.code} - POT: ${youthPlayer.potential}) altyapıya katıldı!',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Teknik Direktör RPG Sohbet Seçeneğini Uygula
  Future<void> executeCoachDialogueChoice(CoachDialogueOption option) async {
    final current = currentState;
    if (current == null || current.headCoach == null) return;

    final coach = current.headCoach!;
    final updatedCoach = coach.copyWith(
      reputation: (coach.reputation + option.coachOvrBonus).clamp(40, 99),
      boardConfidence: (coach.boardConfidence + option.deltaBoardTrust).clamp(0, 100),
    );

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: option.deltaCash,
      deltaFans: option.deltaFans,
      deltaLockerRoom: option.deltaLockerRoom,
      deltaBoardTrust: option.deltaBoardTrust,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      headCoach: updatedCoach,
      notificationLog: [
        ' Teknik Direktör Görüşmesi: ${option.resultSummary}',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Başkanlık Özel Primi veya Lüks Hediye Verme
  Future<bool> givePresidentialBonus(String playerId, int bonusAmount, bool isLuxuryGift) async {
    final current = currentState;
    if (current == null) return false;

    final cost = isLuxuryGift ? 7500 : bonusAmount;
    if (current.userClub.meters.cash < cost) return false;

    final squad = current.userClub.squad;
    final index = squad.indexWhere((p) => p.id == playerId);
    if (index == -1) return false;

    final targetPlayer = squad[index];
    final updatedPlayer = targetPlayer.copyWith(
      morale: (targetPlayer.morale + (isLuxuryGift ? 25 : 18)).clamp(0, 100),
      loyalty: (targetPlayer.loyalty + (isLuxuryGift ? 15 : 10)).clamp(0, 100),
      matchBonusOffered: isLuxuryGift ? targetPlayer.matchBonusOffered : bonusAmount,
      hasLuxuryGift: isLuxuryGift ? true : targetPlayer.hasLuxuryGift,
    );

    final updatedSquad = List<Player>.from(squad);
    updatedSquad[index] = updatedPlayer;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -cost,
      deltaLockerRoom: isLuxuryGift ? -2 : 0, // Hafif kıskançlık riski
    );

    final actionLabel = isLuxuryGift
        ? '[ODUL] Başkanlık Hediyesi: ${targetPlayer.fullName}\'e lüks hediye takdim edildi (+25 Moral, +15 Sadakat).'
        : '[KASA] Özel Maç Primi: ${targetPlayer.fullName}\'e ₣$bonusAmount özel galibiyet primi vadedildi.';

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: updatedMeters,
      ),
      notificationLog: [
        actionLabel,
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Oyuncuya Özel Sırt Numarası Atama
  Future<void> assignJerseyNumber(String playerId, int newNumber) async {
    final current = currentState;
    if (current == null) return;

    final squad = current.userClub.squad;
    final index = squad.indexWhere((p) => p.id == playerId);
    if (index == -1) return;

    final targetPlayer = squad[index];
    final isIconicNumber = newNumber == 10 || newNumber == 7 || newNumber == 9;
    final updatedPlayer = targetPlayer.copyWith(
      jerseyNumber: newNumber,
      morale: (targetPlayer.morale + (isIconicNumber ? 6 : 2)).clamp(0, 100),
    );

    final updatedSquad = List<Player>.from(squad);
    updatedSquad[index] = updatedPlayer;

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(squad: updatedSquad),
      notificationLog: [
        ' Sırt Numarası: ${targetPlayer.fullName} artık #$newNumber numaralı formayı giyecek.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Disiplinsizlik Sebebiyle Para Cezası Kesme
  Future<bool> finePlayer(String playerId, int fineAmount) async {
    final current = currentState;
    if (current == null) return false;

    final squad = current.userClub.squad;
    final index = squad.indexWhere((p) => p.id == playerId);
    if (index == -1) return false;

    final targetPlayer = squad[index];
    final updatedPlayer = targetPlayer.copyWith(
      morale: (targetPlayer.morale - 12).clamp(10, 100),
      disciplinaryFinesCount: targetPlayer.disciplinaryFinesCount + 1,
    );

    final updatedSquad = List<Player>.from(squad);
    updatedSquad[index] = updatedPlayer;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: fineAmount,
      deltaBoardTrust: 3, // Yönetim disiplini takdir eder
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: updatedMeters,
      ),
      notificationLog: [
        '[HUKUK] Disiplin Cezası: ${targetPlayer.fullName}\'e ₣$fineAmount para cezası kesildi.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Sözleşme Maddelerini Güncelleme
  Future<void> updateContractClauses(
    String playerId, {
    int? releaseClause,
    int? loyaltyBonus,
    int? goalBonus,
    int? cleanSheetBonus,
  }) async {
    final current = currentState;
    if (current == null) return;

    final squad = current.userClub.squad;
    final index = squad.indexWhere((p) => p.id == playerId);
    if (index == -1) return;

    final targetPlayer = squad[index];
    final updatedPlayer = targetPlayer.copyWith(
      releaseClause: releaseClause ?? targetPlayer.releaseClause,
      loyaltyBonus: loyaltyBonus ?? targetPlayer.loyaltyBonus,
      goalBonus: goalBonus ?? targetPlayer.goalBonus,
      cleanSheetBonus: cleanSheetBonus ?? targetPlayer.cleanSheetBonus,
    );

    final updatedSquad = List<Player>.from(squad);
    updatedSquad[index] = updatedPlayer;

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(squad: updatedSquad),
      notificationLog: [
        ' Sözleşme Maddeleri: ${targetPlayer.fullName} için sözleşme maddeleri güncellendi.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Sözleşme Yenileme
  Future<bool> renewContract(
    String playerId, {
    required int newWeeklyWage,
    required int additionalSeasons,
    int signingBonus = 0,
  }) async {
    final current = currentState;
    if (current == null) return false;

    if (signingBonus > 0 && current.userClub.meters.cash < signingBonus) {
      return false;
    }

    final squad = current.userClub.squad;
    final index = squad.indexWhere((p) => p.id == playerId);
    if (index == -1) return false;

    final targetPlayer = squad[index];
    final updatedPlayer = targetPlayer.copyWith(
      weeklyWage: newWeeklyWage,
      contractSeasonsLeft: targetPlayer.contractSeasonsLeft + additionalSeasons,
      morale: (targetPlayer.morale + 15).clamp(0, 100),
      loyalty: (targetPlayer.loyalty + 10).clamp(0, 100),
    );

    final updatedSquad = List<Player>.from(squad);
    updatedSquad[index] = updatedPlayer;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -signingBonus,
      deltaLockerRoom: 2,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: updatedMeters,
      ),
      notificationLog: [
        ' Sözleşme Yenilendi: ${targetPlayer.fullName} ile +$additionalSeasons sezonluk yeni sözleşme imzalandı.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Transfer İmzalama
  Future<bool> signPlayer(Player player, int fee, int wage) async {
    final current = currentState;
    if (current == null) return false;

    final validation = TransferWindowRules.validatePurchase(
      phase: current.clock.phase,
      clubCash: current.userClub.meters.cash,
      playerFee: fee,
      currentSquadSize: current.userClub.squad.length,
      isU21: player.age <= TransferWindowRules.u21AgeThreshold,
    );

    if (!validation.isValid) {
      return false;
    }

    final signedPlayer = player.copyWith(
      weeklyWage: wage,
      contractSeasonsLeft: 3,
      morale: 85,
    );

    final updatedSquad = [...current.userClub.squad, signedPlayer];
    final updatedMarket = current.transferMarket.where((p) => p.id != player.id).toList();

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -fee,
      deltaFans: 4,
      deltaLockerRoom: 2,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: updatedMeters,
      ),
      transferMarket: updatedMarket,
      notificationLog: [
        'Yeni Transfer: ${player.fullName} ile sözleşme imzalandı.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Transfer Satın Alma (signPlayer alias)
  Future<bool> buyPlayer(Player player, int fee, int wage) => signPlayer(player, fee, wage);

  /// Gelişmiş Transfer İmzası (Bonservis, Maaş, Maddeler, Takas Oyuncusu ve İmza Parası)
  Future<bool> finalizeTransferWithClauses({
    required Player targetPlayer,
    required int fee,
    required int wage,
    required TransferOfferClauses clauses,
  }) async {
    final current = currentState;
    if (current == null) return false;

    final totalCashRequired = fee + clauses.signingBonus;
    final validation = TransferWindowRules.validatePurchase(
      phase: current.clock.phase,
      clubCash: current.userClub.meters.cash,
      playerFee: totalCashRequired,
      currentSquadSize: current.userClub.squad.length,
      isU21: targetPlayer.age <= TransferWindowRules.u21AgeThreshold,
    );

    if (!validation.isValid) {
      return false;
    }

    var updatedSquad = List<Player>.from(current.userClub.squad);

    // Eğer takas oyuncusu verilmişse kadrodan çıkar
    if (clauses.swapPlayer != null) {
      if (updatedSquad.length <= 11) return false;
      updatedSquad.removeWhere((p) => p.id == clauses.swapPlayer!.id);
    }

    final newPlayer = targetPlayer.copyWith(
      weeklyWage: wage,
      contractSeasonsLeft: clauses.contractYears,
      hasLuxuryGift: false,
    );
    updatedSquad.add(newPlayer);

    final updatedMarket = current.transferMarket.where((p) => p.id != targetPlayer.id).toList();

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -totalCashRequired,
      deltaFans: targetPlayer.ovr >= 80 ? 6 : 2,
      deltaBoardTrust: targetPlayer.ovr >= 78 ? 3 : 1,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        substituteIds: [...current.userClub.substituteIds, newPlayer.id],
        meters: updatedMeters,
      ),
      transferMarket: updatedMarket,
      notificationLog: [
        '[KUTLAMA] Anlaşma İmzalandı: ${newPlayer.fullName} (OVR: ${newPlayer.ovr}) kulübümüze katıldı! (Bonservis: ₣$fee, Maaş: ₣$wage/h)',
        if (clauses.swapPlayer != null)
          '[ANLASMA] Takas Ayrılığı: ${clauses.swapPlayer!.fullName} karşı kulübe transfer oldu.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Yeni Asenkron Scout Görevi Başlat
  Future<bool> startScoutingMission({
    required String region,
    required ScoutDurationTier tier,
  }) async {
    final current = currentState;
    if (current == null) return false;

    if (current.userClub.meters.cash < tier.cost) {
      return false;
    }

    final scoutLevel = current.userClub.facilities[FacilityType.scoutCenter]?.level ?? 1;

    final report = ScoutService.generateScoutReport(
      region: region,
      tier: tier,
      scoutFacilityLevel: scoutLevel,
    );

    final mission = ScoutingMission(
      id: 'scout_mission_${DateTime.now().millisecondsSinceEpoch}',
      region: region,
      tier: tier,
      totalMatches: tier.matchDuration,
      matchesRemaining: tier.matchDuration,
      assignedScoutLevel: scoutLevel,
      discoveredProspects: report.players,
      isCompleted: false,
    );

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -tier.cost,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      activeScoutingMissions: [...current.activeScoutingMissions, mission],
      notificationLog: [
        '[SCOUT] Gözlemci Göreve Gönderildi: $region bölgesine ${tier.label} başlatıldı (-₣${tier.cost}).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Tamamlanan Scout Görevini Kapat / Arşivle
  Future<void> dismissCompletedScoutingMission(String missionId) async {
    final current = currentState;
    if (current == null) return;

    final updatedMissions = current.activeScoutingMissions.where((m) => m.id != missionId).toList();
    final updated = current.copyWith(activeScoutingMissions: updatedMissions);

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Devre Arası Kampını Uygula
  Future<bool> executeTrainingCamp(TrainingCampPackage package) async {
    final current = currentState;
    if (current == null) return false;

    final result = TrainingCampPackage.executeCamp(
      club: current.userClub,
      package: package,
    );

    if (!result.isSuccess) {
      return false;
    }

    final nextClock = current.clock.startSecondHalf();

    final updated = current.copyWith(
      userClub: result.updatedClub,
      clock: nextClock,
      notificationLog: [
        result.message,
        '[DEVRE ARASI] Devre arası kampı başarıyla tamamlandı. 2. Yarı fikstürü başladı!',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// 1. Yarıyı Başlat (Sezon Başı -> 1. Yarı)
  Future<void> startFirstHalf() async {
    final current = currentState;
    if (current == null) return;
    final nextClock = current.clock.startFirstHalf();
    final updated = current.copyWith(
      clock: nextClock,
      notificationLog: [
        '[LİG] Yeni sezonun ilk yarısı başladı! İlk maç için kadronuzu belirleyin.',
        ...current.notificationLog,
      ],
    );
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// 2. Yarıyı Başlat (Devre Arası -> 2. Yarı)
  Future<void> startSecondHalf() async {
    final current = currentState;
    if (current == null) return;
    final nextClock = current.clock.startSecondHalf();
    final updated = current.copyWith(
      clock: nextClock,
      notificationLog: [
        '[LİG] Ligin 2. yarısı başladı! Şampiyonluk yarışında kritik haftalar.',
        ...current.notificationLog,
      ],
    );
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Bir Sonraki Sezona Geç (Sezon Değerlendirmesi -> Yeni Sezon Pre-Season)
  Future<void> startNextSeason() async {
    final current = currentState;
    if (current == null) return;
    final nextClock = current.clock.startNextSeason();
    final updated = current.copyWith(
      clock: nextClock,
      notificationLog: [
        '[YENİ SEZON] Sezon ${nextClock.seasonNumber} hazırlık dönemi ve Yaz Transfer Penceresi açıldı!',
        ...current.notificationLog,
      ],
    );
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Yıldız Transferi İmza Töreni ve Basın Lansmanı
  Future<void> holdGrandSigningCeremony({
    required Player player,
    required bool isGrandStadiumShow,
  }) async {
    final current = currentState;
    if (current == null) return;

    if (isGrandStadiumShow) {
      const cost = 8000;
      if (current.userClub.meters.cash < cost) return;

      final jerseyRevenue = (player.ovr * 320).clamp(15000, 45000);
      final netCash = jerseyRevenue - cost;

      final updatedMeters = current.userClub.meters.applyDeltas(
        deltaCash: netCash,
        deltaFans: 15,
        deltaBoardTrust: 4,
      );

      final updated = current.copyWith(
        userClub: current.userClub.copyWith(meters: updatedMeters),
        manager: current.manager.copyWith(
          dynastyPoints: current.manager.dynastyPoints + 25,
        ),
        notificationLog: [
          ' Görkemli İmza Töreni: ${player.fullName} stadyumda binlerce taraftar önünde imza attı! Net Forma Geliri: +₣$netCash, Taraftar: +%15, +25 DP',
          ...current.notificationLog,
        ],
      );

      state = AsyncValue.data(updated);
      await _saveRepository.save(updated);
    }
  }

  /// Oyuncu Satma / Transfer Listesinden Satış
  Future<bool> sellPlayer(Player player, int salePrice) async {
    final current = currentState;
    if (current == null) return false;

    // Minimum kadro büyüklüğü kontrolü (11 kişiden az kalamaz)
    if (current.userClub.squad.length <= 11) {
      return false; // Kadro 11 kişiden az olamaz
    }

    final updatedSquad = current.userClub.squad.where((p) => p.id != player.id).toList();
    final updatedStarting = current.userClub.starting11Ids.where((id) => id != player.id).toList();
    final updatedSubs = current.userClub.substituteIds.where((id) => id != player.id).toList();

    // Yedeklerde başka oyuncu varsa kadrodan boşalan yere kaydır
    if (updatedStarting.length < 11 && updatedSubs.isNotEmpty) {
      final movedPlayerId = updatedSubs.removeAt(0);
      updatedStarting.add(movedPlayerId);
    }

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: salePrice,
      deltaFans: -1,
      deltaLockerRoom: -1,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        starting11Ids: updatedStarting,
        substituteIds: updatedSubs,
        meters: updatedMeters,
      ),
      notificationLog: [
        'Transfer Satışı: ${player.fullName} ₣$salePrice bedelle kulüpten ayrıldı.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Menajer Yeteneği / Perk Açma
  Future<bool> unlockManagerPerk(String perkId) async {
    final current = currentState;
    if (current == null) return false;

    if (current.manager.availableSkillPoints <= 0) return false;
    if (current.manager.hasPerk(perkId)) return false;

    final updatedManager = current.manager.copyWith(
      unlockedPerkIds: [...current.manager.unlockedPerkIds, perkId],
    );

    final updated = current.copyWith(manager: updatedManager);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  Future<bool> spendSkillPoint(String perkId) => unlockManagerPerk(perkId);

  /// Oyuncu Serbest Bırakma / Sözleşme Feshi
  Future<bool> releasePlayer(Player player) async {
    final current = currentState;
    if (current == null) return false;

    if (current.userClub.squad.length <= 11) {
      return false; // Minimum 11 oyuncu şartı
    }

    final severancePay = player.weeklyWage * 2; // 2 haftalık tazminat
    final updatedSquad = current.userClub.squad.where((p) => p.id != player.id).toList();
    final updatedStarting = current.userClub.starting11Ids.where((id) => id != player.id).toList();
    final updatedSubs = current.userClub.substituteIds.where((id) => id != player.id).toList();

    if (updatedStarting.length < 11 && updatedSubs.isNotEmpty) {
      final movedPlayerId = updatedSubs.removeAt(0);
      updatedStarting.add(movedPlayerId);
    }

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -severancePay,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        starting11Ids: updatedStarting,
        substituteIds: updatedSubs,
        meters: updatedMeters,
      ),
      notificationLog: [
        'Sözleşme Feshi: ${player.fullName} serbest bırakıldı. (Tazminat: ₣$severancePay)',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Antrenman Yoğunluğu Ata (§9.6)
  Future<void> setPlayerTraining(String playerId, TrainingIntensity intensity) async {
    final current = currentState;
    if (current == null) return;

    final updatedSquad = current.userClub.squad.map((p) {
      if (p.id == playerId) {
        return p.copyWith(trainingIntensity: intensity);
      }
      return p;
    }).toList();

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(squad: updatedSquad),
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Kaptan Ata (§A.1)
  Future<void> setPlayerCaptain(String playerId) async {
    final current = currentState;
    if (current == null) return;

    String captainName = '';
    final updatedSquad = current.userClub.squad.map((p) {
      if (p.id == playerId) {
        captainName = p.fullName;
        return p.copyWith(isCaptain: true, morale: (p.morale + 10).clamp(0, 100));
      } else if (p.isCaptain) {
        return p.copyWith(isCaptain: false);
      }
      return p;
    }).toList();

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: current.userClub.meters.applyDeltas(deltaLockerRoom: 5),
      ),
      notificationLog: [
        'SHIELD Yeni Takım Kaptanı: $captainName kaptanlık pazubendini taktı.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Rol Vaadi Ata (§10.6)
  Future<void> setPlayerSquadRole(String playerId, SquadRole role) async {
    final current = currentState;
    if (current == null) return;

    final updatedSquad = current.userClub.squad.map((p) {
      if (p.id == playerId) {
        return p.copyWith(squadRole: role);
      }
      return p;
    }).toList();

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(squad: updatedSquad),
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Transfer Listesine Koy / Çıkar
  Future<void> toggleTransferList(String playerId) async {
    final current = currentState;
    if (current == null) return;

    String pName = '';
    bool newListedStatus = false;
    final updatedSquad = current.userClub.squad.map((p) {
      if (p.id == playerId) {
        pName = p.fullName;
        newListedStatus = !p.isTransferListed;
        return p.copyWith(isTransferListed: newListedStatus);
      }
      return p;
    }).toList();

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(squad: updatedSquad),
      notificationLog: [
        newListedStatus
            ? '[ETIKET] $pName transfer listesine konuldu.'
            : '[ETIKET] $pName transfer listesinden çıkarıldı.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// RPG Oyuncu Diyalog & Görüşme Sonucunu Uygula
  Future<void> applyPlayerDialogueResult({
    required String playerId,
    required DialogueResult result,
    required bool isOwned,
    Player? unownedPlayer,
  }) async {
    final current = currentState;
    if (current == null) return;

    if (isOwned) {
      String pName = '';
      final updatedSquad = current.userClub.squad.map((p) {
        if (p.id == playerId) {
          pName = p.fullName;
          int newPace = p.pace;
          int newTech = p.technique;
          int newShoot = p.shooting;
          int newPass = p.passing;
          int newDef = p.defending;
          int newPhy = p.physical;
          int newMen = p.mentality;

          if (result.statBoostAttribute != null && result.statBoostAmount > 0) {
            switch (result.statBoostAttribute) {
              case 'PAC':
                newPace = (p.pace + result.statBoostAmount).clamp(1, 99);
                break;
              case 'TEC':
                newTech = (p.technique + result.statBoostAmount).clamp(1, 99);
                break;
              case 'SHO':
                newShoot = (p.shooting + result.statBoostAmount).clamp(1, 99);
                break;
              case 'PAS':
                newPass = (p.passing + result.statBoostAmount).clamp(1, 99);
                break;
              case 'DEF':
                newDef = (p.defending + result.statBoostAmount).clamp(1, 99);
                break;
              case 'PHY':
                newPhy = (p.physical + result.statBoostAmount).clamp(1, 99);
                break;
              case 'MEN':
                newMen = (p.mentality + result.statBoostAmount).clamp(1, 99);
                break;
            }
          }

          return p.copyWith(
            morale: (p.morale + result.deltaMorale).clamp(0, 100),
            loyalty: (p.loyalty + result.deltaLoyalty).clamp(0, 100),
            form: (p.form + result.deltaForm).clamp(1.0, 10.0),
            sharpness: (p.sharpness + result.deltaSharpness).clamp(0, 100),
            fitness: (p.fitness + result.deltaFitness).clamp(0, 100),
            pace: newPace,
            technique: newTech,
            shooting: newShoot,
            passing: newPass,
            defending: newDef,
            physical: newPhy,
            mentality: newMen,
          );
        }
        return p;
      }).toList();

      final updatedMeters = current.userClub.meters.applyDeltas(
        deltaCash: result.deltaCash,
        deltaLockerRoom: result.deltaLockerRoom,
      );

      final updated = current.copyWith(
        userClub: current.userClub.copyWith(
          squad: updatedSquad,
          meters: updatedMeters,
        ),
        notificationLog: [
          ' $pName ile özel görüşme yapıldı: ${result.summaryDeltas.join(", ")}',
          ...current.notificationLog,
        ],
      );

      state = AsyncValue.data(updated);
      await _saveRepository.save(updated);
    } else {
      final name = unownedPlayer?.fullName ?? 'Hedef Oyuncu';
      final updatedMeters = current.userClub.meters.applyDeltas(
        deltaCash: result.deltaCash,
        deltaLockerRoom: result.deltaLockerRoom,
      );

      final updated = current.copyWith(
        userClub: current.userClub.copyWith(meters: updatedMeters),
        notificationLog: [
          ' $name ile transfer mülakatı: ${result.summaryDeltas.join(", ")}',
          ...current.notificationLog,
        ],
      );

      state = AsyncValue.data(updated);
      await _saveRepository.save(updated);
    }
  }

  /// Günlük Görev Ödülü Topla (§17.3)
  Future<bool> claimDailyQuest(String questId) async {
    final current = currentState;
    if (current == null) return false;

    DailyQuest? claimedQuest;
    final updatedQuests = current.dailyQuests.map((q) {
      if (q.id == questId && q.canClaim) {
        claimedQuest = q;
        return q.copyWith(isClaimed: true);
      }
      return q;
    }).toList();

    if (claimedQuest == null) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: claimedQuest!.cashReward,
      deltaBoardTrust: 2,
    );

    final updatedManager = current.manager.addXp(claimedQuest!.xpReward);

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      manager: updatedManager,
      dailyQuests: updatedQuests,
      notificationLog: [
        '[KUTLAMA] Günlük Görev Tamamlandı: ${claimedQuest!.title} (+₣${claimedQuest!.cashReward}, +${claimedQuest!.xpReward} XP)',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Banka Kredisi Çek (§A.7)
  Future<bool> takeBankLoan(int principalAmount) => takeBankLoanPackage(
        BankLoanPackage(
          id: 'board_loan_$principalAmount',
          name: 'Banka Kredisi',
          principalAmount: principalAmount,
          interestRate: 0.10,
          totalWeeks: 8,
          icon: '',
          description: 'Yönetim Kurulu Kredisi',
        ),
      );

  /// Sponsor Gelirlerini Güncelle (§15.2)
  Future<void> updateSponsors({int? sleeve, int? stadiumNaming}) async {
    final current = currentState;
    if (current == null) return;

    final updated = current.copyWith(
      sleeveSponsorIncome: sleeve ?? current.sleeveSponsorIncome,
      stadiumNamingIncome: stadiumNaming ?? current.stadiumNamingIncome,
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Bilet Fiyatı Ayarla (§15.1)
  Future<void> setTicketPrice(int price) async {
    final current = currentState;
    if (current == null) return;

    final updatedClub = current.userClub.copyWith(ticketPrice: price);
    final updated = current.copyWith(
      userClub: updatedClub,
      ticketPrice: price,
      notificationLog: [
        ' Bilet Fiyatı Güncellendi: Maç başı ₣$price olarak belirlendi.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Sponsorluk Sözleşmesi İmzala (3-Slot, Anti-Spam & Süreli RPG Sistemi)
  Future<bool> signSponsorshipContract(SponsorshipContract contract) async {
    final current = currentState;
    if (current == null) return false;

    // Eğer bu slotta zaten aktif bir sözleşme varsa spam ve çakışmayı engelle
    final active = current.activeSponsorships[contract.slot];
    if (active != null && !active.isExpired) {
      return false; // Zaten aktif sözleşme var!
    }

    final updatedSponsorships = Map<SponsorshipSlot, SponsorshipContract>.from(current.activeSponsorships);
    updatedSponsorships[contract.slot] = contract;

    Club updatedClub = current.userClub;
    int updatedSleeve = current.sleeveSponsorIncome;
    int updatedStadiumNaming = current.stadiumNamingIncome;

    switch (contract.slot) {
      case SponsorshipSlot.mainShirt:
        updatedClub = updatedClub.copyWith(sponsorWeeklyIncome: contract.weeklyIncome);
        break;
      case SponsorshipSlot.sleeve:
        updatedSleeve = contract.weeklyIncome;
        break;
      case SponsorshipSlot.stadiumNaming:
        updatedStadiumNaming = contract.weeklyIncome;
        break;
    }

    // RPG Metre Etkileri: Perk ve Risk deltas
    final totalFanDelta = contract.perk.fanDelta + contract.risk.fanDelta;
    final totalTrustDelta = contract.perk.boardTrustDelta + contract.risk.boardTrustDelta;
    final totalLockerDelta = contract.perk.lockerRoomDelta;

    final updatedMeters = updatedClub.meters.applyDeltas(
      deltaCash: contract.signingBonus,
      deltaFans: totalFanDelta,
      deltaBoardTrust: totalTrustDelta,
      deltaLockerRoom: totalLockerDelta,
    );

    final updated = current.copyWith(
      userClub: updatedClub.copyWith(meters: updatedMeters),
      activeSponsorships: updatedSponsorships,
      sleeveSponsorIncome: updatedSleeve,
      stadiumNamingIncome: updatedStadiumNaming,
      notificationLog: [
        ' Resmi Sponsorluk İmzalandı: ${contract.brandName} (+₣${contract.signingBonus} peşin, +₣${contract.weeklyIncome}/hf, ${contract.durationWeeks} Hafta)',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Mevcut Sponsorluğu Erken Feshet (Tazminatlı)
  Future<bool> terminateSponsorshipContract(SponsorshipSlot slot) async {
    final current = currentState;
    if (current == null) return false;

    final active = current.activeSponsorships[slot];
    if (active == null) return false;

    final penalty = active.risk.earlyTerminationPenalty;
    if (current.userClub.meters.cash < penalty) return false; // Yetersiz bakiye

    final updatedSponsorships = Map<SponsorshipSlot, SponsorshipContract>.from(current.activeSponsorships);
    updatedSponsorships.remove(slot);

    Club updatedClub = current.userClub;
    int updatedSleeve = current.sleeveSponsorIncome;
    int updatedStadiumNaming = current.stadiumNamingIncome;

    switch (slot) {
      case SponsorshipSlot.mainShirt:
        updatedClub = updatedClub.copyWith(sponsorWeeklyIncome: 0);
        break;
      case SponsorshipSlot.sleeve:
        updatedSleeve = 0;
        break;
      case SponsorshipSlot.stadiumNaming:
        updatedStadiumNaming = 0;
        break;
    }

    final updatedMeters = updatedClub.meters.applyDeltas(
      deltaCash: -penalty,
      deltaBoardTrust: -2,
    );

    final updated = current.copyWith(
      userClub: updatedClub.copyWith(meters: updatedMeters),
      activeSponsorships: updatedSponsorships,
      sleeveSponsorIncome: updatedSleeve,
      stadiumNamingIncome: updatedStadiumNaming,
      notificationLog: [
        '[UYARI] Sponsorluk Feshedildi: ${active.brandName} ile sözleşme tek taraflı feshedildi (-₣$penalty tazminat ödendi).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Eski Teklif İmzası (Geriye Dönük Uyumluluk)
  Future<void> signSponsorshipDeal({
    required SponsorshipSlot slot,
    required int weeklyIncome,
    required int signingBonus,
    required String brandName,
  }) async {
    final contract = SponsorshipContract(
      id: 'legacy_${slot.name}_${DateTime.now().millisecondsSinceEpoch}',
      brandName: brandName,
      brandIcon: '',
      sector: 'Kurumsal',
      slot: slot,
      weeklyIncome: weeklyIncome,
      signingBonus: signingBonus,
      durationWeeks: 10,
      weeksRemaining: 10,
      perk: const SponsorshipPerk(description: 'Standart kulüp sponsorluğu'),
      risk: const SponsorshipRisk(description: 'Standart fesih şartları'),
    );
    await signSponsorshipContract(contract);
  }

  /// Banka Kredisi Paketi Çek
  Future<bool> takeBankLoanPackage(BankLoanPackage package) async {
    final current = currentState;
    if (current == null || current.activeLoan != null) return false;

    final newLoan = BankLoan(
      principalAmount: package.principalAmount,
      interestRate: package.interestRate,
      totalWeeks: package.totalWeeks,
      remainingWeeks: package.totalWeeks,
    );

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: package.principalAmount,
      deltaBoardTrust: -2,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      activeLoan: newLoan,
      notificationLog: [
        ' ${package.name} Onaylandı: Kasaya +₣${package.principalAmount} aktarıldı (Haftalık ödeme: ₣${newLoan.weeklyPayment}).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Kiralık Oyuncu Sözleşmesi İmzala (§10.5)
  Future<bool> loanInPlayer(LoanDeal deal) async {
    final current = currentState;
    if (current == null) return false;

    final loanedPlayer = deal.player.copyWith(
      weeklyWage: deal.weeklyWageToPay,
      contractSeasonsLeft: deal.seasons,
      morale: 80,
    );

    final updatedSquad = [...current.userClub.squad, loanedPlayer];
    final updatedLoanDeals = [...current.activeLoanDeals, deal];
    final updatedSignedIds = [...current.signedMarketIds, deal.player.id];

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(squad: updatedSquad),
      activeLoanDeals: updatedLoanDeals,
      signedMarketIds: updatedSignedIds,
      notificationLog: [
        '[ANLASMA] Kiralık Transfer: ${deal.player.fullName} (${deal.parentClubName}) ${deal.seasons} sezonluğuna kiralandı (Haftalık maaş: ₣${deal.weeklyWageToPay}).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Kıta Kupası / Devler Ligi Güncelleme (§14.4)
  Future<void> updateContinentalCup(ContinentalCup cup) async {
    final current = currentState;
    if (current == null) return;

    final updated = current.copyWith(continentalCup: cup);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Banka Kredisini Erken Kapat (İndirimli)
  Future<bool> repayBankLoanEarly() async {
    final current = currentState;
    if (current == null || current.activeLoan == null) return false;

    final loan = current.activeLoan!;
    final cost = loan.earlyRepaymentDiscountedAmount;

    if (current.userClub.meters.cash < cost) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -cost,
      deltaBoardTrust: 4,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      activeLoan: null,
      clearLoan: true,
      notificationLog: [
        '[KUTLAMA] Banka Kredisi Erken Kapatıldı! ₣$cost ödendi ve kulüp tüm faiz yükümlülüğünden kurtuldu.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Hazine Vadeli Mevduat Hesabına Para Yatır
  Future<bool> depositToTreasury(int amount) async {
    final current = currentState;
    if (current == null || amount <= 0) return false;
    if (current.userClub.meters.cash < amount) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(deltaCash: -amount);
    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      treasuryDeposit: current.treasuryDeposit + amount,
      notificationLog: [
        '[ARTIS] Kulüp Hazinesine ₣$amount vadeli mevduat yatırıldı (Haftalık %2.5 bileşik faiz).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Hazine Vadeli Mevduat Hesabından Para Çek
  Future<bool> withdrawFromTreasury(int amount) async {
    final current = currentState;
    if (current == null || amount <= 0) return false;
    if (current.treasuryDeposit < amount) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(deltaCash: amount);
    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      treasuryDeposit: current.treasuryDeposit - amount,
      notificationLog: [
        '[DUSUS] Kulüp Hazinesinden ₣$amount nakit çekilerek kulüp kasasına aktarıldı.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Yeni Teknik Direktör İşe Al (§15.4)
  Future<bool> hireHeadCoach(HeadCoach coach) async {
    final current = currentState;
    if (current == null) return false;
    if (current.userClub.meters.cash < coach.signingFee) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -coach.signingFee,
      deltaBoardTrust: 4,
      deltaFans: coach.archetype.fanBoost,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      headCoach: coach,
      notificationLog: [
        ' Yeni Teknik Direktör Göreve Getirildi: ${coach.fullName} (${coach.archetype.label})',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Teknik Direktörü Görevden Al / Kov (§15.4)
  Future<bool> fireHeadCoach() async {
    final current = currentState;
    if (current == null || current.headCoach == null) return false;

    final coach = current.headCoach!;
    final severance = coach.severancePay;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -severance,
      deltaBoardTrust: -3,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      clearHeadCoach: true,
      notificationLog: [
        '[ACIL] Teknik Direktör ${coach.fullName} Görevden Alındı (₣$severance fesih tazminatı ödendi).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Teknik Direktöre Kulüp Vizyonu Dikte Et
  Future<void> dictateCoachVision(CoachVision vision) async {
    final current = currentState;
    if (current == null || current.headCoach == null) return;

    final updatedCoach = current.headCoach!.copyWith(activeVision: vision);
    final updatedMeters = current.userClub.meters.applyDeltas(deltaFans: vision.deltaFans);

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      headCoach: updatedCoach,
      notificationLog: [
        '[RAPOR] Teknik Direktöre Yeni Kulüp Vizyonu Dikte Edildi: ${vision.label}',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Başkanlık Sermaye Enjeksiyonu / Şahsi Hibe (§15.5)
  Future<bool> injectPresidentCapital(CapitalInjectionOption option) async {
    final current = currentState;
    if (current == null) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: option.cashAmount,
      deltaBoardTrust: option.boardTrustBonus,
      deltaFans: option.fanBonus,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      notificationLog: [
        '[YÖNETİM] Başkanlık Sermaye Enjeksiyonu: Kasaya +₣${option.cashAmount} aktarıldı (${option.title}).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// VIP Loca Kiralama Satışı (§15.5)
  Future<bool> sellVipBox(String boxId) async {
    final current = currentState;
    if (current == null) return false;

    VipBoxDeal? soldBox;
    final updatedBoxes = current.vipBoxDeals.map((b) {
      if (b.id == boxId && !b.isSold) {
        soldBox = b.copyWith(isSold: true);
        return soldBox!;
      }
      return b;
    }).toList();

    if (soldBox == null) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: soldBox!.seasonPrice,
      deltaBoardTrust: 3,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      vipBoxDeals: updatedBoxes,
      notificationLog: [
        ' VIP Protokol Locası Kiralandı: ${soldBox!.companyName} (+₣${soldBox!.seasonPrice} peşin gelir).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Birikmiş Çevrimdışı Geliri Kasaya Aktar (§17.3 D1)
  Future<int> claimIdleCash() async {
    final current = currentState;
    if (current == null || current.accumulatedIdleCash <= 0) return 0;

    final earned = current.accumulatedIdleCash;
    final updatedMeters = current.userClub.meters.applyDeltas(deltaCash: earned);

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      accumulatedIdleCash: 0,
      notificationLog: [
        '[KASA] Çevrimdışı Birikmiş Gelir Kasaya Aktarıldı: +₣$earned',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return earned;
  }

  /// Sezon Hedefi Belirle (§A.3)
  Future<void> setTargetLeaguePosition(int position) async {
    final current = currentState;
    if (current == null) return;

    final updated = current.copyWith(
      targetLeaguePosition: position,
      notificationLog: [
        '[HEDEF] Sezon Hedefi Taahhüt Edildi: Sezon sonu $position. sıra veya üstü.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Tesis Yükseltme (İnşaat Başlatma)
  Future<bool> upgradeFacility(FacilityType type) async {
    final current = currentState;
    if (current == null) return false;

    final facility = current.userClub.facilities[type] ?? Facility(type: type, level: 0);
    if (facility.isMaxLevel || facility.isUpgrading) return false;

    final cost = facility.upgradeCost;
    if (current.userClub.meters.cash < cost) return false;

    final durationMs = facility.upgradeDurationMinutes * 60 * 1000;
    final finishMs = DateTime.now().millisecondsSinceEpoch + durationMs;

    final updatedFacMap = Map<FacilityType, Facility>.from(current.userClub.facilities);
    updatedFacMap[type] = facility.copyWith(
      isUpgrading: true,
      upgradeFinishEpochMs: finishMs,
    );

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -cost,
      deltaBoardTrust: 4,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        facilities: updatedFacMap,
        meters: updatedMeters,
      ),
      notificationLog: [
        'Tesis İnşaatı Başladı: ${type.label} (${facility.upgradeDurationMinutes} dk sürecek).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Tamamlanan Tesis İnşaatlarını Kontrol Et ve Tamamla
  Future<void> checkFacilityUpgrades() async {
    final current = currentState;
    if (current == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    var changed = false;
    final updatedFacMap = Map<FacilityType, Facility>.from(current.userClub.facilities);
    final logs = <String>[];

    for (final entry in current.userClub.facilities.entries) {
      final fac = entry.value;
      if (fac.isUpgrading && fac.upgradeFinishEpochMs != null && now >= fac.upgradeFinishEpochMs!) {
        changed = true;
        updatedFacMap[entry.key] = fac.copyWith(
          level: fac.level + 1,
          isUpgrading: false,
          upgradeFinishEpochMs: null,
        );
        logs.add('Tesis İnşaatı Tamamlandı: ${fac.type.label} Sv.${fac.level + 1} hizmete girdi!');
      }
    }

    if (changed) {
      final updated = current.copyWith(
        userClub: current.userClub.copyWith(facilities: updatedFacMap),
        notificationLog: [...logs, ...current.notificationLog],
      );
      state = AsyncValue.data(updated);
      await _saveRepository.save(updated);
    }
  }

  /// Taktik ve Kadro Dizilişi Değiştirme
  Future<void> updateTactics({
    String? formation,
    String? style,
    List<String>? starting11Ids,
    List<String>? substituteIds,
  }) async {
    final current = currentState;
    if (current == null) return;

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        formation: formation,
        tacticalStyle: style,
        starting11Ids: starting11Ids,
        substituteIds: substituteIds,
      ),
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Kulüp Kimliği ve Menajer İsmini Güncelleme
  Future<void> updateClubProfile({
    String? clubName,
    String? managerName,
    String? badgeIcon,
  }) async {
    final current = currentState;
    if (current == null) return;

    final updatedClub = current.userClub.copyWith(
      name: clubName ?? current.userClub.name,
      badgeIcon: badgeIcon ?? current.userClub.badgeIcon,
    );

    final updatedManager = current.manager.copyWith(
      name: managerName ?? current.manager.name,
    );

    final updated = current.copyWith(
      userClub: updatedClub,
      manager: updatedManager,
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Yönetim Kurulundan Ek Transfer Bütçesi İstemek (Başkan Eylemi)
  Future<bool> requestExtraBudget(int amount) async {
    final current = currentState;
    if (current == null) return false;
    if (current.userClub.meters.boardTrust < 30) return false; // Güven düşükse reddedilir

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: amount,
      deltaBoardTrust: -12,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      notificationLog: [
        'Yönetim Kurulu Kararı: Kasaya ek ₣$amount bütçe aktarıldı. (Yönetim Güveni -12)',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Gençlik Akademisi Oyuncusunu A Takıma Yükseltme
  Future<bool> promoteYouthProspect(Player prospect) async {
    final current = currentState;
    if (current == null) return false;

    final updatedSquad = [...current.userClub.squad, prospect];
    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaFans: 3,
      deltaLockerRoom: 2,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: updatedMeters,
      ),
      notificationLog: [
        'Gençlik Akademisi: ${prospect.fullName} A Takıma yükseltildi!',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Basın Toplantısı Yanıtı Etkilerini Uygulama
  Future<void> applyPressResponse({
    int deltaFans = 0,
    int deltaLockerRoom = 0,
    int deltaBoardTrust = 0,
    String? logText,
  }) async {
    final current = currentState;
    if (current == null) return;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaFans: deltaFans,
      deltaLockerRoom: deltaLockerRoom,
      deltaBoardTrust: deltaBoardTrust,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      notificationLog: [
        if (logText != null) 'Basın Açıklaması: $logText',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Sponsor / Mağaza Ödülü Talep Etme
  Future<void> claimSponsorReward(int cashBonus, {int reduceConstructionMinutes = 0}) async {
    final current = currentState;
    if (current == null) return;

    var updatedClub = current.userClub;
    if (cashBonus > 0) {
      final newMeters = updatedClub.meters.applyDeltas(deltaCash: cashBonus);
      updatedClub = updatedClub.copyWith(meters: newMeters);
    }

    if (reduceConstructionMinutes > 0) {
      final updatedFac = Map<FacilityType, Facility>.from(updatedClub.facilities);
      for (final entry in updatedFac.entries) {
        if (entry.value.isUpgrading && entry.value.upgradeFinishEpochMs != null) {
          final newFinish = entry.value.upgradeFinishEpochMs! - (reduceConstructionMinutes * 60 * 1000);
          updatedFac[entry.key] = entry.value.copyWith(upgradeFinishEpochMs: newFinish);
        }
      }
      updatedClub = updatedClub.copyWith(facilities: updatedFac);
    }

    final updated = current.copyWith(
      userClub: updatedClub,
      notificationLog: [
        if (cashBonus > 0) 'Sponsor Desteği: +₣$cashBonus kasaya aktarıldı.',
        if (reduceConstructionMinutes > 0) 'İnşaat Hızlandırıcı: Süre $reduceConstructionMinutes dk kısaltıldı.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    await checkFacilityUpgrades();
  }

  /// FTUE Adımını İlerletme
  Future<void> advanceFtue() async {
    final current = currentState;
    if (current == null) return;

    final nextStep = current.ftueStep + 1;
    final isDone = nextStep >= 8;

    final updated = current.copyWith(
      ftueStep: nextStep,
      isFtueActive: !isDone,
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Sezon Sonu Geçişini Uygulama
  Future<void> executeSeasonTransition() async {
    final current = currentState;
    if (current == null) return;

    final report = SeasonTransition.processSeasonEnd(current);
    final updated = SeasonTransition.applySeasonTransition(
      state: current,
      report: report,
      rng: _rng,
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Oyunu Baştan Başlatma
  Future<void> resetGame() async {
    await _saveRepository.clearSave();
    final newGame = SaveRepository.createNewGame();
    await _saveRepository.save(newGame);
    state = AsyncValue.data(newGame);
  }

  /// Kupa Maçı Oynama (MatchEngine & Penaltı Destekli Simülasyon)
  Future<void> playCupMatch(String matchId) async {
    final current = currentState;
    if (current == null) return;

    final match = current.cupTournament.matches.firstWhere((m) => m.id == matchId);
    if (match.isPlayed) return;

    final isHome = match.homeClubId == current.userClub.id;
    final oppId = isHome ? match.awayClubId : match.homeClubId;
    final oppClub = _getOpponentClub(current, oppId);

    final setup = MatchSetup(
      home: isHome ? current.userClub : oppClub,
      away: isHome ? oppClub : current.userClub,
      seed: current.clock.seasonNumber * 50000 + match.round.index * 1000 + _rng.nextInt(99),
      hasTacticianPerk: current.manager.hasPerk('tactician_1'),
    );
    final engine = MatchEngine(setup.seed);
    final result = engine.simulate(setup);

    final homeScore = isHome ? result.homeGoals : result.awayGoals;
    final awayScore = isHome ? result.awayGoals : result.homeGoals;
    int? homePens;
    int? awayPens;
    String winnerId;

    if (homeScore > awayScore) {
      winnerId = match.homeClubId;
    } else if (awayScore > homeScore) {
      winnerId = match.awayClubId;
    } else {
      homePens = 3 + _rng.nextInt(3);
      awayPens = 3 + _rng.nextInt(3);
      while (homePens == awayPens) {
        if (_rng.chance(0.5)) {
          homePens = (homePens ?? 0) + 1;
        } else {
          awayPens = (awayPens ?? 0) + 1;
        }
      }
      winnerId = (homePens ?? 0) > (awayPens ?? 0) ? match.homeClubId : match.awayClubId;
    }

    final updatedMatches = current.cupTournament.matches.map((m) {
      if (m.id == matchId) {
        return m.copyWith(
          isPlayed: true,
          homeScore: homeScore,
          awayScore: awayScore,
          homePenalties: homePens,
          awayPenalties: awayPens,
          winnerClubId: winnerId,
        );
      }
      return m;
    }).toList();

    // Diğer AI kupa maçlarını da gerçekçi skorlarla simüle et (adil penaltı motoru)
    final fullySimulated = updatedMatches.map((m) {
      if (m.round == match.round && !m.isPlayed) {
        final hG = _rng.nextInt(3);
        var aG = _rng.nextInt(3);
        int? hP;
        int? aP;
        String wId;
        if (hG > aG) {
          wId = m.homeClubId;
        } else if (aG > hG) {
          wId = m.awayClubId;
        } else {
          hP = 3 + _rng.nextInt(3);
          aP = 3 + _rng.nextInt(3);
          while (hP == aP) {
            if (_rng.chance(0.5)) {
              hP = (hP ?? 0) + 1;
            } else {
              aP = (aP ?? 0) + 1;
            }
          }
          wId = (hP ?? 0) > (aP ?? 0) ? m.homeClubId : m.awayClubId;
        }
        return m.copyWith(
          isPlayed: true,
          homeScore: hG,
          awayScore: aG,
          homePenalties: hP,
          awayPenalties: aP,
          winnerClubId: wId,
        );
      }
      return m;
    }).toList();

    var updatedCup = current.cupTournament.copyWith(matches: fullySimulated);
    updatedCup = updatedCup.progressRound(current.clock.seasonNumber * 100);

    final isUserWinner = winnerId == current.userClub.id;
    final deltaCash = isUserWinner ? 15000 : 3000;
    final deltaFans = isUserWinner ? 6 : -2;

    final penaltyLog = (homePens != null && awayPens != null) ? ' (Penaltılar: $homePens - $awayPens)' : '';
    var updated = current.copyWith(
      cupTournament: updatedCup,
      userClub: current.userClub.copyWith(
        meters: current.userClub.meters.applyDeltas(deltaCash: deltaCash, deltaFans: deltaFans),
      ),
      manager: current.manager.addXp(isUserWinner ? 100 : 30),
      notificationLog: [
        'Kupa Maçı: ${match.homeClubName} $homeScore - $awayScore ${match.awayClubName}$penaltyLog (${isUserWinner ? "TUR ATLANDI!" : "ELENDİK"})',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Hanedan Prestij Yeteneği Kilidi Açma
  Future<void> unlockLegacyPerk(DynastyLegacyPerk perk) async {
    final current = currentState;
    if (current == null) return;
    if (current.manager.dynastyPoints < perk.costDynastyPoints) return;

    final updatedManager = current.manager.copyWith(
      dynastyPoints: current.manager.dynastyPoints - perk.costDynastyPoints,
    );

    final updatedPerks = <DynastyLegacyPerk>[
      ...current.unlockedLegacyPerks.where((p) => p.id != perk.id),
      perk.copyWith(isUnlocked: true),
    ];

    final updated = current.copyWith(
      manager: updatedManager,
      unlockedLegacyPerks: updatedPerks,
      notificationLog: [
        'Hanedan Mirası Açıldı: ${perk.title}',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Galibiyet Primi Ayarlama
  Future<void> setWinBonus(int bonus) async {
    final current = currentState;
    if (current == null) return;

    final updated = current.copyWith(winBonusPerMatch: bonus);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Sözleşme Yenileme
  Future<void> renewPlayerContract(
    String playerId,
    int seasons,
    int newWage, {
    SquadRole role = SquadRole.first11,
    int signingBonus = 0,
  }) async {
    final current = currentState;
    if (current == null) return;

    final updatedSquad = current.userClub.squad.map((p) {
      if (p.id == playerId) {
        return p.copyWith(
          weeklyWage: newWage,
          contractSeasonsLeft: seasons,
          squadRole: role,
          loyalty: (p.loyalty + 15).clamp(0, 100),
          morale: 95,
        );
      }
      return p;
    }).toList();

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -signingBonus,
      deltaLockerRoom: 4,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: updatedMeters,
      ),
      notificationLog: [
        'Sözleşme Uzatıldı: Oyuncu ile yeni anlaşma imzalandı (Maaş: ₣$newWage/h, Prim: ₣$signingBonus).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Kiralık Gönderme / Kiralık Alma
  Future<void> loanPlayer(Player player, String toClub, int wageSplitPercent, int buyoutClause) async {
    final current = currentState;
    if (current == null) return;

    final deal = LoanDeal(
      player: player,
      parentClubName: current.userClub.name,
      borrowingClubWageShare: wageSplitPercent / 100.0,
      buyoutClause: buyoutClause,
      seasons: 1,
    );

    final updated = current.copyWith(
      activeLoanDeals: [...current.activeLoanDeals, deal],
      notificationLog: [
        'Kiralık Anlaşması: ${player.fullName} $toClub kulübüne kiralandı.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Oyuncu Takası Transferi (Swap + Ekstra Nakit)
  Future<bool> swapPlayerTransfer(Player userPlayer, Player targetPlayer, int extraCash) async {
    final current = currentState;
    if (current == null) return false;

    if (current.userClub.meters.cash < extraCash) return false;

    final updatedSquad = current.userClub.squad.where((p) => p.id != userPlayer.id).toList();
    updatedSquad.add(targetPlayer.copyWith(morale: 85, contractSeasonsLeft: 3));

    final updatedMarket = current.transferMarket.where((p) => p.id != targetPlayer.id).toList();

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -extraCash,
      deltaFans: 2,
    );

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: updatedMeters,
      ),
      transferMarket: updatedMarket,
      notificationLog: [
        'Takas Transferi: ${userPlayer.fullName} verildi, ${targetPlayer.fullName} kadroya katıldı (+₣$extraCash).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Kovulma Sonrası Kurtarma (Yeni Kulüp Başlangıcı)
  Future<void> recoverFromSacking() async {
    final current = currentState;
    if (current == null) return;

    final comebackClub = Club(
      id: 'comeback_c',
      name: 'Yıldıztepe SK',
      city: 'Kayseri',
      badgeIcon: 'STAR',
      primaryColorHex: '#1E3A8A',
      secondaryColorHex: '#F59E0B',
      leagueTier: 20,
      isUserClub: true,
      meters: const ClubMeters(
        cash: 15000,
        fans: 35,
        lockerRoom: 45,
        boardTrust: 55,
      ),
      facilities: current.userClub.facilities,
      squad: current.userClub.squad,
      starting11Ids: current.userClub.starting11Ids,
      substituteIds: current.userClub.substituteIds,
    );

    final updated = current.copyWith(
      userClub: comebackClub,
      targetLeaguePosition: 5,
      notificationLog: [
        'Yeni Başlangıç: Yıldıztepe SK teknik direktörlüğü görevine başladınız!',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Win-Back Ödüllerini Alma
  Future<void> claimWinBackRewards(int cash, int xp) async {
    final current = currentState;
    if (current == null) return;

    final updatedMeters = current.userClub.meters.applyDeltas(deltaCash: cash);
    final updatedManager = current.manager.addXp(xp);

    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      manager: updatedManager,
      notificationLog: [
        'Sadakat Ödülü: +₣$cash ve +$xp XP kasaya aktarıldı.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Metre Değerlerini Doğrudan Ayarlama (Başkanlık RPG Eylemleri)
  Future<void> adjustCash(int delta) async {
    final current = currentState;
    if (current == null) return;
    final updatedMeters = current.userClub.meters.applyDeltas(deltaCash: delta);
    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
    );
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  Future<void> adjustFans(int delta) async {
    final current = currentState;
    if (current == null) return;
    final updatedMeters = current.userClub.meters.applyDeltas(deltaFans: delta);
    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
    );
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  Future<void> adjustLockerRoom(int delta) async {
    final current = currentState;
    if (current == null) return;
    final updatedMeters = current.userClub.meters.applyDeltas(deltaLockerRoom: delta);
    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
    );
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  Future<void> adjustBoardTrust(int delta) async {
    final current = currentState;
    if (current == null) return;
    final updatedMeters = current.userClub.meters.applyDeltas(deltaBoardTrust: delta);
    final updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
    );
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Başarımları Değerlendir ve Menajere XP / Hanedan Puanı Teslim Et
  GameState _checkAndAwardAchievements(GameState current) {
    final newlyUnlocked = AchievementEvaluator.evaluateAchievements(
      state: current,
      previouslyUnlockedIds: current.unlockedAchievementIds,
    );
    if (newlyUnlocked.isEmpty) return current;

    var updatedManager = current.manager;
    final updatedIds = Set<String>.from(current.unlockedAchievementIds);
    final logs = <String>[];

    for (final ach in newlyUnlocked) {
      updatedIds.add(ach.id);
      updatedManager = updatedManager.addXp(ach.xpReward).copyWith(
        dynastyPoints: updatedManager.dynastyPoints + ach.dynastyPoints,
      );
      logs.add('[KUPA] Başarım Açıldı: ${ach.title} (+${ach.xpReward} XP, +${ach.dynastyPoints} Hanedan Puanı)');
    }

    return current.copyWith(
      manager: updatedManager,
      unlockedAchievementIds: updatedIds,
      notificationLog: [...logs, ...current.notificationLog],
    );
  }

  /// Teknik Direktör Lisansını Kalıcı Olarak Yükselt
  Future<bool> upgradeCoachingLicense(CoachingLicense newLicense) async {
    final current = currentState;
    if (current == null) return false;
    if (current.userClub.meters.cash < newLicense.courseCost) return false;
    if (current.manager.level < newLicense.requiredManagerLevel) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -newLicense.courseCost,
      deltaBoardTrust: 5,
    );
    final updatedManager = current.manager.copyWith(license: newLicense);

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      manager: updatedManager,
      notificationLog: [
        ' Antrenörlük Lisansı: Tebrikler! ${newLicense.title} başarıyla alındı! (Tüm perkler x${newLicense.allPerkMultiplier} etkili)',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Ezeli Rakipten Transfer Çalımı At (Gerçek Oyuncu Kadroya Eklenir)
  Future<bool> hijackTransfer(TransferHijackTarget target) async {
    final current = currentState;
    if (current == null) return false;
    final totalCost = target.requiredHijackBid + target.requiredAgentCommission;
    if (current.userClub.meters.cash < totalCost) return false;

    Position pos = Position.cm;
    if (target.playerPosition.contains('ST') || target.playerPosition.contains('Forvet')) {
      pos = Position.st;
    } else if (target.playerPosition.contains('CB') || target.playerPosition.contains('Stoper') || target.playerPosition.contains('Defans')) {
      pos = Position.cb;
    } else if (target.playerPosition.contains('GK') || target.playerPosition.contains('Kaleci')) {
      pos = Position.gk;
    }

    final newPlayer = Player(
      id: 'hijack_${target.playerName.hashCode.abs()}',
      firstName: target.playerName.split(' ').first,
      lastName: target.playerName.split(' ').length > 1 ? target.playerName.split(' ').sublist(1).join(' ') : 'Yıldız',
      countryCode: 'TR',
      position: pos,
      age: 26,
      pace: target.overallRating,
      shooting: target.overallRating,
      passing: target.overallRating,
      technique: target.overallRating,
      defending: target.overallRating,
      physical: target.overallRating,
      mentality: target.overallRating,
      potential: (target.overallRating + 2).clamp(1, 99),
      weeklyWage: 12500,
      contractSeasonsLeft: 3,
      morale: 95,
      loyalty: 85,
    );

    final updatedSquad = [...current.userClub.squad, newPlayer];
    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -totalCost,
      deltaFans: target.fansHypeBonus,
      deltaBoardTrust: 8,
      deltaLockerRoom: 5,
    );
    final updatedHijacked = [...current.hijackedPlayerIds, target.playerName];

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: updatedMeters,
      ),
      hijackedPlayerIds: updatedHijacked,
      notificationLog: [
        '[FORM] Dev Transfer Çalımı: ${target.playerName} (${target.overallRating} OVR) kadromuza katıldı! (-₣$totalCost)',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Altyapı Turnuvasından Keşfedilen Genci Akademiye Bedelsiz Ekle
  Future<void> signGrassrootsTalent({
    required String name,
    required String position,
    required int potentialRating,
    required int overallRating,
  }) async {
    final current = currentState;
    if (current == null) return;

    Position pos = Position.am;
    if (position.contains('Forvet') || position.contains('Numara')) {
      pos = Position.st;
    } else if (position.contains('Stoper') || position.contains('Defans')) {
      pos = Position.cb;
    } else if (position.contains('Kaleci')) {
      pos = Position.gk;
    }

    final newProspect = Player(
      id: 'grassroots_${name.hashCode.abs()}_${DateTime.now().millisecondsSinceEpoch}',
      firstName: name.split(' ').first,
      lastName: name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : 'Genç',
      countryCode: 'TR',
      position: pos,
      age: 16,
      pace: overallRating,
      shooting: overallRating,
      passing: overallRating,
      technique: overallRating,
      defending: overallRating,
      physical: overallRating,
      mentality: overallRating,
      potential: potentialRating,
      weeklyWage: 600,
      contractSeasonsLeft: 4,
      isYouthProduct: true,
      morale: 95,
      loyalty: 90,
    );

    final updatedU19 = [...current.userClub.u19Squad, newProspect];
    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaFans: 5,
      deltaBoardTrust: 5,
    );

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(
        u19Squad: updatedU19,
        meters: updatedMeters,
      ),
      notificationLog: [
        'STAR Altyapı İmzası: Geleceğin Yıldızı $name ($potentialRating Potansiyel) U19 Akademimize katıldı!',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Başkanın Lüks Varlık Satın Alımı (Kalıcı Envanter)
  Future<bool> buyLuxuryAsset(PresidentLuxuryAsset asset) async {
    final current = currentState;
    if (current == null) return false;
    if (current.ownedLuxuryAssetIds.contains(asset.id)) return false;
    if (current.userClub.meters.cash < asset.purchaseCost) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -asset.purchaseCost,
      deltaFans: asset.fansBonus,
      deltaBoardTrust: 8,
    );
    final updatedOwned = [...current.ownedLuxuryAssetIds, asset.id];

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      ownedLuxuryAssetIds: updatedOwned,
      notificationLog: [
        'CROWN Başkanlık Envanteri: ${asset.name} satın alındı! (+${asset.fansBonus} Taraftar Hype, +${asset.prestigeBonus} Prestij)',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Pilot Takım Protokolü İmzala (Kalıcı İşbirliği)
  Future<bool> signAffiliateProtocol(String clubName, int cost) async {
    final current = currentState;
    if (current == null) return false;
    if (current.activeAffiliateClubIds.contains(clubName)) return false;
    if (current.userClub.meters.cash < cost) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -cost,
      deltaBoardTrust: 6,
    );
    final updatedAffiliates = [...current.activeAffiliateClubIds, clubName];

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      activeAffiliateClubIds: updatedAffiliates,
      notificationLog: [
        '[ANLASMA] Pilot Kulüp Protokolü: $clubName ile 1 yıllık resmi uydu kulüp anlaşması imzalandı! (-₣$cost)',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Hukuk Bürosu & Tahkim Davası İtirazını Çözümle
  Future<bool> resolveLegalAppeal(LegalCaseItem item) async {
    final current = currentState;
    if (current == null) return false;
    if (current.resolvedLegalCaseIds.contains(item.id)) return false;
    if (current.userClub.meters.cash < item.appealCost) return false;

    final isSuccess = _rng.chance(item.successChancePercent / 100.0);
    int deltaCash = -item.appealCost;
    int deltaBoard = isSuccess ? 6 : -4;
    if (!isSuccess) {
      deltaCash -= item.initialPenalty;
    }

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: deltaCash,
      deltaBoardTrust: deltaBoard,
    );
    final updatedResolved = [...current.resolvedLegalCaseIds, item.id];

    final outcomeMsg = isSuccess
        ? '[HUKUK] Tahkim Zaferi: ${item.victoryOutcome}'
        : '[HUKUK] Tahkim Reddi: İtiraz reddedildi ve ₣${item.initialPenalty} ceza uygulandı.';

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      resolvedLegalCaseIds: updatedResolved,
      notificationLog: [
        outcomeMsg,
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return isSuccess;
  }

  /// Menajer Pazarlığı ile Oyuncu Sözleşmesini ve Maaşını Güncelle
  Future<bool> resolveAgentMeeting({
    required String playerId,
    required int wageDiscountPercent,
    required int extendSeasons,
    required int cost,
    required int loyaltyBonus,
  }) async {
    final current = currentState;
    if (current == null) return false;
    if (cost > 0 && current.userClub.meters.cash < cost) return false;

    final updatedSquad = current.userClub.squad.map((p) {
      if (p.id == playerId) {
        final newWage = wageDiscountPercent > 0
            ? (p.weeklyWage * (1.0 - wageDiscountPercent / 100.0)).round()
            : p.weeklyWage;
        return p.copyWith(
          weeklyWage: newWage,
          contractSeasonsLeft: p.contractSeasonsLeft + extendSeasons,
          loyalty: (p.loyalty + loyaltyBonus).clamp(0, 100),
          morale: 95,
        );
      }
      return p;
    }).toList();

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: -cost,
      deltaLockerRoom: 4,
      deltaBoardTrust: 4,
    );

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(
        squad: updatedSquad,
        meters: updatedMeters,
      ),
      notificationLog: [
        '[ANLASMA] Menajer Zirvesi: Oyuncu sözleşmesi revize edildi ve bağlılık arttırıldı.',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Kulüp Hissesi Satışı (Maksimum %49 Limitli)
  Future<bool> sellClubShares({required int percent, required int cashAmount}) async {
    final current = currentState;
    if (current == null) return false;
    if (current.soldClubSharePercent + percent > 49) return false;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: cashAmount,
      deltaBoardTrust: -10,
    );
    final newSharePercent = current.soldClubSharePercent + percent;

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      soldClubSharePercent: newSharePercent,
      notificationLog: [
        '[MENAJER] Kulüp Yatırım Ortaklığı: %$percent kulüp hissesi satıldı (+₣$cashAmount, Toplam Satılan: %$newSharePercent).',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
  }

  /// Gece Yarısı TV Canlı Yayın Tartışmasına Katılım
  Future<void> participateInDebate(
    String debateId, {
    int cashDelta = 0,
    int fansDelta = 0,
    int boardDelta = 0,
    required String outcomeText,
  }) async {
    final current = currentState;
    if (current == null) return;
    if (current.resolvedDebateIds.contains(debateId)) return;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: cashDelta,
      deltaFans: fansDelta,
      deltaBoardTrust: boardDelta,
    );
    final updatedDebates = [...current.resolvedDebateIds, debateId];

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      resolvedDebateIds: updatedDebates,
      notificationLog: [
        '[TV] Canlı Yayın Düellosu: $outcomeText',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Kulüpler Birliği Zirvesi Gündem Oylaması
  Future<void> voteSummitAgenda(
    String agendaId, {
    int cashDelta = 0,
    int fansDelta = 0,
    int boardDelta = 0,
    required String outcomeText,
  }) async {
    final current = currentState;
    if (current == null) return;
    if (current.votedSummitAgendaIds.contains(agendaId)) return;

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: cashDelta,
      deltaFans: fansDelta,
      deltaBoardTrust: boardDelta,
    );
    final updatedAgendas = [...current.votedSummitAgendaIds, agendaId];

    var updated = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      votedSummitAgendaIds: updatedAgendas,
      notificationLog: [
        '[YÖNETİM] Kulüpler Birliği Oylaması: $outcomeText',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Avrupa Kupası Maçı Simülasyonu & Tur Atlama
  Future<void> playContinentalCupMatch(String matchId) async {
    final current = currentState;
    if (current == null || current.continentalCup == null) return;

    final cup = current.continentalCup!;
    final match = cup.fixtures.firstWhere((m) => m.id == matchId);
    if (match.isPlayed) return;

    final isHome = match.homeClubName == current.userClub.name;
    final oppName = isHome ? match.awayClubName : match.homeClubName;
    final oppBadge = isHome ? match.awayBadge : match.homeBadge;

    final oppClub = Club(
      id: 'cont_opp_${oppName.hashCode.abs()}',
      name: oppName,
      city: match.awayCountry,
      leagueTier: 1,
      badgeIcon: oppBadge,
      squad: current.userClub.squad,
      starting11Ids: current.userClub.starting11Ids,
    );

    final seed = current.clock.seasonNumber * 80000 + match.id.hashCode.abs() + _rng.nextInt(99);
    final setup = MatchSetup(
      home: isHome ? current.userClub : oppClub,
      away: isHome ? oppClub : current.userClub,
      seed: seed,
      hasTacticianPerk: current.manager.hasPerk('tactician_1'),
    );
    final result = MatchEngine(seed).simulate(setup);

    final hScore = isHome ? result.homeGoals : result.awayGoals;
    final aScore = isHome ? result.awayGoals : result.homeGoals;
    final isKnockout = match.stage.contains('Final');
    String winner = hScore > aScore ? match.homeClubName : (aScore > hScore ? match.awayClubName : match.homeClubName);

    if (hScore == aScore && isKnockout) {
      winner = _rng.chance(0.5) ? match.homeClubName : match.awayClubName;
    }

    final updatedFixtures = cup.fixtures.map((m) {
      if (m.id == matchId) {
        return ContinentalMatch(
          id: m.id,
          stage: m.stage,
          homeClubName: m.homeClubName,
          homeCountry: m.homeCountry,
          homeBadge: m.homeBadge,
          awayClubName: m.awayClubName,
          awayCountry: m.awayCountry,
          awayBadge: m.awayBadge,
          isPlayed: true,
          homeScore: hScore,
          awayScore: aScore,
          winnerName: winner,
        );
      }
      return m;
    }).toList();

    // AI maçlarını da simüle et
    final fullySimulated = updatedFixtures.map((m) {
      if (!m.isPlayed && m.stage == match.stage) {
        final hG = _rng.nextInt(3);
        final aG = _rng.nextInt(3);
        final w = hG >= aG ? m.homeClubName : m.awayClubName;
        return ContinentalMatch(
          id: m.id,
          stage: m.stage,
          homeClubName: m.homeClubName,
          homeCountry: m.homeCountry,
          homeBadge: m.homeBadge,
          awayClubName: m.awayClubName,
          awayCountry: m.awayCountry,
          awayBadge: m.awayBadge,
          isPlayed: true,
          homeScore: hG,
          awayScore: aG,
          winnerName: w,
        );
      }
      return m;
    }).toList();

    final isUserWinner = winner == current.userClub.name;
    final prize = match.stage.contains('Büyük Final')
        ? (isUserWinner ? cup.prizeMoney : 50000)
        : (isUserWinner ? 35000 : 10000);

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: prize,
      deltaFans: isUserWinner ? 8 : -2,
      deltaBoardTrust: isUserWinner ? 6 : -2,
    );

    var updatedCup = cup.copyWith(fixtures: fullySimulated);
    var updated = current.copyWith(
      continentalCup: updatedCup,
      userClub: current.userClub.copyWith(meters: updatedMeters),
      manager: current.manager.addXp(isUserWinner ? 150 : 40),
      notificationLog: [
        '[KUPA] Avrupa Kupası (${match.stage}): ${match.homeClubName} $hScore - $aScore ${match.awayClubName} (${isUserWinner ? "GALİBİYET +₣$prize" : "MAĞLUBİYET"})',
        ...current.notificationLog,
      ],
    );

    updated = _checkAndAwardAchievements(updated);
    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  Club _getOpponentClub(GameState current, String oppClubId) {
    final entry = current.currentLeague.getEntry(oppClubId);
    final customName = entry?.clubName ?? 'Demirspor';
    final badge = entry?.badgeIcon ?? 'BOLT';

    final oppSeed = oppClubId.hashCode.abs() + (current.clock.seasonNumber * 1000);
    final oppRng = DeterministicRng(oppSeed);

    return ClubGenerator.generateOpponentClub(
      rng: oppRng,
      leagueTier: current.currentLeague.tier,
      clubId: oppClubId,
      customName: customName,
    ).copyWith(badgeIcon: badge);
  }
}
