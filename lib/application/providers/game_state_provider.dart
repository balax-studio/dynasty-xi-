import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/rng/deterministic_rng.dart';
import '../../data/assets/card_database.dart';
import '../../data/local/save_repository.dart';
import '../../domain/cards/card_effects.dart';
import '../../domain/cards/card_selector.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/economy/financial_statement.dart';
import '../../domain/economy/offline_calculator.dart';
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
import '../../domain/rpg/player_dialogue_engine.dart';
import '../../domain/president/head_coach.dart';
import '../../domain/president/boardroom_summit.dart';

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

  /// Sıradaki Maçı Simüle Et
  Future<MatchResult?> playMatch({bool isLiveMode = false}) async {
    final current = currentState;
    if (current == null || current.isGameOver) return null;

    final fixture = current.currentLeague.fixtures.firstWhere(
      (f) => f.matchday == current.clock.matchday && !f.isPlayed,
      orElse: () => current.currentLeague.fixtures.first,
    );

    final isUserHome = fixture.homeClubId == current.userClub.id;
    final oppClubId = isUserHome ? fixture.awayClubId : fixture.homeClubId;

    // Rakip Takım
    final oppClub = _getOpponentClub(current, oppClubId);

    final setup = MatchSetup(
      home: isUserHome ? current.userClub : oppClub,
      away: isUserHome ? oppClub : current.userClub,
      seed: current.clock.seasonNumber * 10000 + current.clock.matchday * 100 + _rng.nextInt(99),
      isLiveMode: isLiveMode,
      hasTacticianPerk: current.manager.hasPerk('tactician_1'),
    );

    final engine = MatchEngine(setup.seed);
    final result = engine.simulate(setup);

    final userGoals = isUserHome ? result.homeGoals : result.awayGoals;
    final oppGoals = isUserHome ? result.awayGoals : result.homeGoals;
    final isUserWin = userGoals > oppGoals;
    final isUserDraw = userGoals == oppGoals;

    // 1. Maç Günü Gelirleri (Kullanıcı ev sahibiyse)
    var matchIncome = 0;
    if (isUserHome) {
      final rank = current.currentLeague.getRankOfClub(current.userClub.id);
      final revenue = EconomyCalculator.calculateMatchDayRevenue(
        club: current.userClub,
        leagueRank: rank,
      );
      matchIncome = revenue.totalRevenue;
    }

    // 2. Metre Güncellemeleri
    final deltaFans = isUserWin ? 4 : (isUserDraw ? 0 : -3);
    final deltaLocker = isUserWin ? 6 : (isUserDraw ? 1 : -5);
    final deltaBoard = isUserWin ? 5 : (isUserDraw ? 0 : -4);

    final updatedMeters = current.userClub.meters.applyDeltas(
      deltaCash: matchIncome,
      deltaFans: deltaFans,
      deltaLockerRoom: deltaLocker,
      deltaBoardTrust: deltaBoard,
    );

    // 3. Fikstür ve Sıralama Güncelleme
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

    // Kullanıcı ve aktif rakip puanlarını güncelle
    var tempStandings = current.currentLeague.standings.map((entry) {
      if (entry.clubId == current.userClub.id) {
        return entry.recordMatch(goalsScored: userGoals, goalsConceded: oppGoals);
      } else if (entry.clubId == oppClub.id) {
        return entry.recordMatch(goalsScored: oppGoals, goalsConceded: userGoals);
      }
      return entry;
    }).toList();

    // Aynı haftada diğer AI kulüplerinin maçlarını da simüle et (lig tablosunun dinamik ilerlemesi için)
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

    // 4. Sezon ve Seans İlerlemesi
    final nextClock = current.clock.advanceMatch();

    // 5. Yeni Karar Kartları Seçimi (Yeni Maç Penceresi İçin)
    final newSessionCards = CardSelector.pickSessionCards(
      cardDatabase: CardDatabase.mvpCards,
      state: current,
      rng: _rng,
      count: 2,
    );

    // 6. Menajer XP (+30 XP maç oynama, +50 XP galibiyet)
    final xpEarned = 30 + (isUserWin ? 50 : (isUserDraw ? 20 : 0));
    final updatedManager = current.manager.addXp(xpEarned);

    final updatedState = current.copyWith(
      userClub: current.userClub.copyWith(meters: updatedMeters),
      manager: updatedManager,
      currentLeague: updatedLeague,
      clock: nextClock,
      pendingCards: newSessionCards,
      notificationLog: [
        'Maç Sonucu: ${current.userClub.name} $userGoals - $oppGoals ${oppClub.name}',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updatedState);
    await _saveRepository.save(updatedState);

    return result;
  }

  /// Transfer İmzalama
  Future<bool> signPlayer(Player player, int fee, int wage) async {
    final current = currentState;
    if (current == null) return false;

    if (current.userClub.meters.cash < fee) {
      return false; // Kasa yetersiz
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
        '🛡️ Yeni Takım Kaptanı: $captainName kaptanlık pazubendini taktı.',
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
            ? '🏷️ $pName transfer listesine konuldu.'
            : '🏷️ $pName transfer listesinden çıkarıldı.',
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
          '🗣️ $pName ile özel görüşme yapıldı: ${result.summaryDeltas.join(", ")}',
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
          '🗣️ $name ile transfer mülakatı: ${result.summaryDeltas.join(", ")}',
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
        '🎉 Günlük Görev Tamamlandı: ${claimedQuest!.title} (+₣${claimedQuest!.cashReward}, +${claimedQuest!.xpReward} XP)',
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
          icon: '🏦',
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
        '🎟️ Bilet Fiyatı Güncellendi: Maç başı ₣$price olarak belirlendi.',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
  }

  /// Sponsorluk Sözleşmesi İmzala (3-Slot)
  Future<void> signSponsorshipDeal({
    required SponsorshipSlot slot,
    required int weeklyIncome,
    required int signingBonus,
    required String brandName,
  }) async {
    final current = currentState;
    if (current == null) return;

    Club updatedClub = current.userClub;
    int updatedSleeve = current.sleeveSponsorIncome;
    int updatedStadiumNaming = current.stadiumNamingIncome;

    switch (slot) {
      case SponsorshipSlot.mainShirt:
        updatedClub = updatedClub.copyWith(sponsorWeeklyIncome: weeklyIncome);
        break;
      case SponsorshipSlot.sleeve:
        updatedSleeve = weeklyIncome;
        break;
      case SponsorshipSlot.stadiumNaming:
        updatedStadiumNaming = weeklyIncome;
        break;
    }

    final updatedMeters = updatedClub.meters.applyDeltas(deltaCash: signingBonus, deltaFans: 3);

    final updated = current.copyWith(
      userClub: updatedClub.copyWith(meters: updatedMeters),
      sleeveSponsorIncome: updatedSleeve,
      stadiumNamingIncome: updatedStadiumNaming,
      notificationLog: [
        '✍️ Sponsorluk İmzalandı: $brandName (+₣$signingBonus peşin imza parası, +₣$weeklyIncome/hafta)',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
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
        '🏦 ${package.name} Onaylandı: Kasaya +₣${package.principalAmount} aktarıldı (Haftalık ödeme: ₣${newLoan.weeklyPayment}).',
        ...current.notificationLog,
      ],
    );

    state = AsyncValue.data(updated);
    await _saveRepository.save(updated);
    return true;
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
      notificationLog: [
        '🎉 Banka Kredisi Erken Kapatıldı! ₣$cost ödendi ve kulüp tüm faiz yükümlülüğünden kurtuldu.',
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
        '📈 Kulüp Hazinesine ₣$amount vadeli mevduat yatırıldı (Haftalık %2.5 bileşik faiz).',
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
        '📉 Kulüp Hazinesinden ₣$amount nakit çekilerek kulüp kasasına aktarıldı.',
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
        '👔 Yeni Teknik Direktör Göreve Getirildi: ${coach.fullName} (${coach.archetype.label})',
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
        '🚨 Teknik Direktör ${coach.fullName} Görevden Alındı (₣$severance fesih tazminatı ödendi).',
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
        '📋 Teknik Direktöre Yeni Kulüp Vizyonu Dikte Edildi: ${vision.label}',
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
        '🏛️ Başkanlık Sermaye Enjeksiyonu: Kasaya +₣${option.cashAmount} aktarıldı (${option.title}).',
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
        '🥂 VIP Protokol Locası Kiralandı: ${soldBox!.companyName} (+₣${soldBox!.seasonPrice} peşin gelir).',
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
        '💰 Çevrimdışı Birikmiş Gelir Kasaya Aktarıldı: +₣$earned',
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
        '🎯 Sezon Hedefi Taahhüt Edildi: Sezon sonu $position. sıra veya üstü.',
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

  /// Kupa Maçı Oynama
  Future<void> playCupMatch(String matchId) async {
    final current = currentState;
    if (current == null) return;

    final match = current.cupTournament.matches.firstWhere((m) => m.id == matchId);
    if (match.isPlayed) return;

    final isHome = match.homeClubId == current.userClub.id;

    // Simulate cup match with random determinism
    final userGoals = 1 + _rng.nextInt(3);
    final oppGoals = _rng.nextInt(2);
    final homeScore = isHome ? userGoals : oppGoals;
    final awayScore = isHome ? oppGoals : userGoals;
    final winnerId = homeScore >= awayScore ? match.homeClubId : match.awayClubId;

    final updatedMatches = current.cupTournament.matches.map((m) {
      if (m.id == matchId) {
        return m.copyWith(
          isPlayed: true,
          homeScore: homeScore,
          awayScore: awayScore,
          winnerClubId: winnerId,
        );
      }
      return m;
    }).toList();

    // Auto-simulate other cup matches in the same round
    final fullySimulated = updatedMatches.map((m) {
      if (m.round == match.round && !m.isPlayed) {
        final hG = _rng.nextInt(3);
        var aG = _rng.nextInt(3);
        if (hG == aG) aG += 1;
        final wId = hG > aG ? m.homeClubId : m.awayClubId;
        return m.copyWith(
          isPlayed: true,
          homeScore: hG,
          awayScore: aG,
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

    final updated = current.copyWith(
      cupTournament: updatedCup,
      userClub: current.userClub.copyWith(
        meters: current.userClub.meters.applyDeltas(deltaCash: deltaCash, deltaFans: deltaFans),
      ),
      manager: current.manager.addXp(isUserWinner ? 100 : 30),
      notificationLog: [
        'Kupa Maçı: ${match.homeClubName} $homeScore - $awayScore ${match.awayClubName} (${isUserWinner ? "TUR ATLANDI!" : "ELENDİK"})',
        ...current.notificationLog,
      ],
    );

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
      badgeIcon: '⭐',
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

  Club _getOpponentClub(GameState current, String oppClubId) {
    final entry = current.currentLeague.getEntry(oppClubId);
    final customName = entry?.clubName ?? 'Demirspor';
    final badge = entry?.badgeIcon ?? '⚡';

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
