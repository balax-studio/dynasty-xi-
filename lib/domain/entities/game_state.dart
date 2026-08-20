// domain/entities/game_state.dart
// Pure Dart. Root game state combining user club, manager, league pyramid, game clock, cards, quests, economy, cups, prestige, staff and head coach.

import 'dart:math' as math;
import '../../core/time/game_clock.dart';
import '../economy/financial_statement.dart';
import '../economy/sponsorship_contract.dart';
import '../economy/transfer_models.dart';
import '../liveops/season_theme.dart';
import '../president/boardroom_summit.dart';
import '../president/head_coach.dart';
import '../president/president_crisis.dart';
import '../progression/daily_quest.dart';
import '../progression/dynasty_prestige.dart';
import '../progression/museum_records.dart';
import '../tournament/continental_cup.dart';
import '../tournament/cup_tournament.dart';
import 'card.dart';
import 'club.dart';
import 'league.dart';
import 'manager.dart';
import 'player.dart';
import 'staff.dart';

class GameState {
  final Club userClub;
  final Manager manager;
  final GameClock clock;
  final League currentLeague;
  final Map<int, League> leaguePyramid;
  final List<Player> transferMarket;
  final List<DecisionCard> pendingCards;
  final Map<String, int> activeChains;
  final List<String> recentCardIds;
  final bool isFtueActive;
  final int ftueStep; // 0 to 14
  final int targetLeaguePosition;
  final List<String> notificationLog;
  final bool isGameOver;
  final String? gameOverReason;

  // RPG & Ekonomi Katmanları (§15, §17.3, §12.8)
  final List<DailyQuest> dailyQuests;
  final BankLoan? activeLoan;
  final int sleeveSponsorIncome;
  final int stadiumNamingIncome;
  final int accumulatedIdleCash;
  final int sackingCountdownMatches; // 0 ise güvenli, >0 ise kovulma riski uyarısı

  // Offline Genişletilmiş Sistemler (Kupa, Prestij, Bilet, Efsaneler)
  final CupTournament cupTournament;
  final ContinentalCup? continentalCup;
  final List<DynastyLegacyPerk> unlockedLegacyPerks;
  final List<Player> retiredLegends;
  final int ticketPrice;
  final int winBonusPerMatch;
  final List<LoanDeal> activeLoanDeals;
  final HeadCoach? headCoach;
  final List<VipBoxDeal> vipBoxDeals;
  final PresidentCrisisCall? activeCrisisCall;
  final List<String> pinnedShortcutIds;
  final List<StaffMember> staff;
  final Map<SponsorshipSlot, SponsorshipContract> activeSponsorships;
  final Set<String> unlockedAchievementIds;
  final ClubMuseumRecords museumRecords;
  final List<String> signedMarketIds;
  final int crisisCooldownMatches;
  final List<String> resolvedCrisisIds;
  final int clubXp;

  const GameState({
    required this.userClub,
    required this.manager,
    this.clock = const GameClock(),
    this.currentLeague = const League(tier: 20, name: '20. Lig'),
    this.leaguePyramid = const {},
    this.transferMarket = const [],
    this.pendingCards = const [],
    this.activeChains = const {},
    this.recentCardIds = const [],
    this.isFtueActive = true,
    this.ftueStep = 0,
    this.targetLeaguePosition = 5,
    this.notificationLog = const [],
    this.isGameOver = false,
    this.gameOverReason,
    this.dailyQuests = const [],
    this.activeLoan,
    this.sleeveSponsorIncome = 1200,
    this.stadiumNamingIncome = 2500,
    this.accumulatedIdleCash = 0,
    this.sackingCountdownMatches = 0,
    this.cupTournament = const CupTournament(),
    this.continentalCup,
    this.unlockedLegacyPerks = const [],
    this.retiredLegends = const [],
    this.ticketPrice = 25,
    this.winBonusPerMatch = 0,
    this.activeLoanDeals = const [],
    this.treasuryDeposit = 0,
    this.headCoach,
    this.vipBoxDeals = const [],
    this.activeCrisisCall,
    this.staff = const [],
    this.activeSponsorships = const {},
    this.unlockedAchievementIds = const {},
    this.museumRecords = const ClubMuseumRecords(),
    this.signedMarketIds = const [],
    this.crisisCooldownMatches = 0,
    this.resolvedCrisisIds = const [],
    this.clubXp = 0,
    this.pinnedShortcutIds = const [
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
  });

  final int treasuryDeposit;

  bool get isUnderSackingThreat => userClub.meters.boardTrust < 30;
  bool get hasActiveCrisis => activeCrisisCall != null;
  SeasonThemeType get currentSeasonTheme => SeasonThemeService.getThemeForMatchday(clock.matchday);
  bool get hasSecondBuilder => unlockedLegacyPerks.any((p) => p.id == 'double_builder' && p.isUnlocked);
  int get clubLevel => math.min(50, math.max(1, (math.sqrt(clubXp / 180.0)).floor() + 1));
  int get maxSquadSize => math.min(30, 18 + (clubLevel ~/ 5));
  int get minSquadSize => 16;
  bool get isTransferWindowOpen => clock.matchday <= 15;

  GameState copyWith({
    Club? userClub,
    Manager? manager,
    GameClock? clock,
    League? currentLeague,
    Map<int, League>? leaguePyramid,
    List<Player>? transferMarket,
    List<DecisionCard>? pendingCards,
    Map<String, int>? activeChains,
    List<String>? recentCardIds,
    bool? isFtueActive,
    int? ftueStep,
    int? targetLeaguePosition,
    List<String>? notificationLog,
    bool? isGameOver,
    String? gameOverReason,
    bool clearGameOverReason = false,
    List<DailyQuest>? dailyQuests,
    BankLoan? activeLoan,
    bool clearLoan = false,
    int? sleeveSponsorIncome,
    int? stadiumNamingIncome,
    int? accumulatedIdleCash,
    int? sackingCountdownMatches,
    CupTournament? cupTournament,
    ContinentalCup? continentalCup,
    bool clearContinentalCup = false,
    List<DynastyLegacyPerk>? unlockedLegacyPerks,
    List<Player>? retiredLegends,
    int? ticketPrice,
    int? winBonusPerMatch,
    List<LoanDeal>? activeLoanDeals,
    int? treasuryDeposit,
    HeadCoach? headCoach,
    bool clearHeadCoach = false,
    List<VipBoxDeal>? vipBoxDeals,
    PresidentCrisisCall? activeCrisisCall,
    bool clearCrisisCall = false,
    List<String>? pinnedShortcutIds,
    List<StaffMember>? staff,
    Map<SponsorshipSlot, SponsorshipContract>? activeSponsorships,
    Set<String>? unlockedAchievementIds,
    ClubMuseumRecords? museumRecords,
    List<String>? signedMarketIds,
    int? crisisCooldownMatches,
    List<String>? resolvedCrisisIds,
    int? clubXp,
  }) {
    return GameState(
      userClub: userClub ?? this.userClub,
      manager: manager ?? this.manager,
      clock: clock ?? this.clock,
      currentLeague: currentLeague ?? this.currentLeague,
      leaguePyramid: leaguePyramid ?? this.leaguePyramid,
      transferMarket: transferMarket ?? this.transferMarket,
      pendingCards: pendingCards ?? this.pendingCards,
      activeChains: activeChains ?? this.activeChains,
      recentCardIds: recentCardIds ?? this.recentCardIds,
      isFtueActive: isFtueActive ?? this.isFtueActive,
      ftueStep: ftueStep ?? this.ftueStep,
      targetLeaguePosition: targetLeaguePosition ?? this.targetLeaguePosition,
      notificationLog: notificationLog ?? this.notificationLog,
      isGameOver: isGameOver ?? this.isGameOver,
      gameOverReason: clearGameOverReason ? null : (gameOverReason ?? this.gameOverReason),
      dailyQuests: dailyQuests ?? this.dailyQuests,
      activeLoan: clearLoan ? null : (activeLoan ?? this.activeLoan),
      sleeveSponsorIncome: sleeveSponsorIncome ?? this.sleeveSponsorIncome,
      stadiumNamingIncome: stadiumNamingIncome ?? this.stadiumNamingIncome,
      accumulatedIdleCash: accumulatedIdleCash ?? this.accumulatedIdleCash,
      sackingCountdownMatches: sackingCountdownMatches ?? this.sackingCountdownMatches,
      cupTournament: cupTournament ?? this.cupTournament,
      continentalCup: clearContinentalCup ? null : (continentalCup ?? this.continentalCup),
      unlockedLegacyPerks: unlockedLegacyPerks ?? this.unlockedLegacyPerks,
      retiredLegends: retiredLegends ?? this.retiredLegends,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      winBonusPerMatch: winBonusPerMatch ?? this.winBonusPerMatch,
      activeLoanDeals: activeLoanDeals ?? this.activeLoanDeals,
      treasuryDeposit: treasuryDeposit ?? this.treasuryDeposit,
      headCoach: clearHeadCoach ? null : (headCoach ?? this.headCoach),
      vipBoxDeals: vipBoxDeals ?? this.vipBoxDeals,
      activeCrisisCall: clearCrisisCall ? null : (activeCrisisCall ?? this.activeCrisisCall),
      pinnedShortcutIds: pinnedShortcutIds ?? this.pinnedShortcutIds,
      staff: staff ?? this.staff,
      activeSponsorships: activeSponsorships ?? this.activeSponsorships,
      unlockedAchievementIds: unlockedAchievementIds ?? this.unlockedAchievementIds,
      museumRecords: museumRecords ?? this.museumRecords,
      signedMarketIds: signedMarketIds ?? this.signedMarketIds,
      crisisCooldownMatches: crisisCooldownMatches ?? this.crisisCooldownMatches,
      resolvedCrisisIds: resolvedCrisisIds ?? this.resolvedCrisisIds,
      clubXp: clubXp ?? this.clubXp,
    );
  }

  Map<String, dynamic> toJson() => {
        'userClub': userClub.toJson(),
        'manager': manager.toJson(),
        'clock': clock.toJson(),
        'currentLeague': currentLeague.toJson(),
        'leaguePyramid': leaguePyramid.map((k, v) => MapEntry(k.toString(), v.toJson())),
        'transferMarket': transferMarket.map((p) => p.toJson()).toList(),
        'pendingCards': pendingCards.map((c) => c.toJson()).toList(),
        'activeChains': activeChains,
        'recentCardIds': recentCardIds,
        'isFtueActive': isFtueActive,
        'ftueStep': ftueStep,
        'targetLeaguePosition': targetLeaguePosition,
        'notificationLog': notificationLog,
        'isGameOver': isGameOver,
        'gameOverReason': gameOverReason,
        'dailyQuests': dailyQuests.map((q) => q.toJson()).toList(),
        'activeLoan': activeLoan?.toJson(),
        'sleeveSponsorIncome': sleeveSponsorIncome,
        'stadiumNamingIncome': stadiumNamingIncome,
        'accumulatedIdleCash': accumulatedIdleCash,
        'sackingCountdownMatches': sackingCountdownMatches,
        'cupTournament': cupTournament.toJson(),
        'continentalCup': continentalCup?.toJson(),
        'unlockedLegacyPerks': unlockedLegacyPerks.map((p) => p.toJson()).toList(),
        'retiredLegends': retiredLegends.map((p) => p.toJson()).toList(),
        'ticketPrice': ticketPrice,
        'winBonusPerMatch': winBonusPerMatch,
        'activeLoanDeals': activeLoanDeals.map((l) => l.toJson()).toList(),
        'treasuryDeposit': treasuryDeposit,
        'headCoach': headCoach?.toJson(),
        'vipBoxDeals': vipBoxDeals.map((v) => v.toJson()).toList(),
        'activeCrisisCall': activeCrisisCall?.toJson(),
        'pinnedShortcutIds': pinnedShortcutIds,
        'staff': staff.map((s) => s.toJson()).toList(),
        'activeSponsorships': activeSponsorships.map((k, v) => MapEntry(k.name, v.toJson())),
        'unlockedAchievementIds': unlockedAchievementIds.toList(),
        'museumRecords': museumRecords.toJson(),
        'signedMarketIds': signedMarketIds,
        'crisisCooldownMatches': crisisCooldownMatches,
        'resolvedCrisisIds': resolvedCrisisIds,
        'clubXp': clubXp,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    final userClub = Club.fromJson(json['userClub'] as Map<String, dynamic>);
    final manager = Manager.fromJson(json['manager'] as Map<String, dynamic>);
    final clock = json['clock'] != null
        ? GameClock.fromJson(json['clock'] as Map<String, dynamic>)
        : const GameClock();
    final currentLeague = json['currentLeague'] != null
        ? League.fromJson(json['currentLeague'] as Map<String, dynamic>)
        : const League(tier: 20, name: '20. Lig');

    final leaguePyramid = <int, League>{};
    if (json['leaguePyramid'] != null) {
      final map = json['leaguePyramid'] as Map<String, dynamic>;
      for (final entry in map.entries) {
        leaguePyramid[int.parse(entry.key)] = League.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    final transferMarket = (json['transferMarket'] as List<dynamic>?)
            ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    final pendingCards = (json['pendingCards'] as List<dynamic>?)
            ?.map((e) => DecisionCard.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    final activeChains = (json['activeChains'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        const {};

    final recentCardIds = (json['recentCardIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [];
    final notificationLog = (json['notificationLog'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [];

    final dailyQuests = (json['dailyQuests'] as List<dynamic>?)
            ?.map((q) => DailyQuest.fromJson(q as Map<String, dynamic>))
            .toList() ??
        DailyQuestManager.generateDailyQuests();

    final activeLoan = json['activeLoan'] != null
        ? BankLoan.fromJson(json['activeLoan'] as Map<String, dynamic>)
        : null;

    final headCoach = json['headCoach'] != null
        ? HeadCoach.fromJson(json['headCoach'] as Map<String, dynamic>)
        : null;

    final activeCrisisCall = json['activeCrisisCall'] != null
        ? PresidentCrisisCall.fromJson(json['activeCrisisCall'] as Map<String, dynamic>)
        : null;

    final vipBoxDeals = (json['vipBoxDeals'] as List<dynamic>?)
            ?.map((v) => VipBoxDeal.fromJson(v as Map<String, dynamic>))
            .toList() ??
        BoardroomCatalog.getInitialVipBoxes();

    final cupTournament = json['cupTournament'] != null
        ? CupTournament.fromJson(json['cupTournament'] as Map<String, dynamic>)
        : const CupTournament();

    final continentalCup = json['continentalCup'] != null
        ? ContinentalCup.fromJson(json['continentalCup'] as Map<String, dynamic>)
        : null;

    final unlockedLegacyPerks = (json['unlockedLegacyPerks'] as List<dynamic>?)
            ?.map((p) => DynastyLegacyPerk.fromJson(p as Map<String, dynamic>))
            .toList() ??
        const [];

    final retiredLegends = (json['retiredLegends'] as List<dynamic>?)
            ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
            .toList() ??
        const [];

    final activeLoanDeals = (json['activeLoanDeals'] as List<dynamic>?)
            ?.map((l) => LoanDeal.fromJson(l as Map<String, dynamic>))
            .toList() ??
        const [];

    final staff = (json['staff'] as List<dynamic>?)
            ?.map((s) => StaffMember.fromJson(s as Map<String, dynamic>))
            .toList() ??
        StaffGenerator.generateDefaultStaff();

    final pinnedShortcutIds = (json['pinnedShortcutIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        const [
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
        ];

    final activeSponsorships = (json['activeSponsorships'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(
            SponsorshipSlot.values.firstWhere((s) => s.name == k, orElse: () => SponsorshipSlot.mainShirt),
            SponsorshipContract.fromJson(v as Map<String, dynamic>),
          ),
        ) ??
        const {};

    final unlockedAchievementIds = (json['unlockedAchievementIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        const {};

    final museumRecords = json['museumRecords'] != null
        ? ClubMuseumRecords.fromJson(json['museumRecords'] as Map<String, dynamic>)
        : const ClubMuseumRecords();

    final signedMarketIds = (json['signedMarketIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [];
    final crisisCooldownMatches = json['crisisCooldownMatches'] as int? ?? 0;
    final resolvedCrisisIds = (json['resolvedCrisisIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [];

    return GameState(
      userClub: userClub,
      manager: manager,
      clock: clock,
      currentLeague: currentLeague,
      leaguePyramid: leaguePyramid,
      transferMarket: transferMarket,
      pendingCards: pendingCards,
      activeChains: activeChains,
      recentCardIds: recentCardIds,
      isFtueActive: json['isFtueActive'] as bool? ?? true,
      ftueStep: json['ftueStep'] as int? ?? 0,
      targetLeaguePosition: json['targetLeaguePosition'] as int? ?? 5,
      notificationLog: notificationLog,
      isGameOver: json['isGameOver'] as bool? ?? false,
      gameOverReason: json['gameOverReason'] as String?,
      dailyQuests: dailyQuests,
      activeLoan: activeLoan,
      sleeveSponsorIncome: json['sleeveSponsorIncome'] as int? ?? 1200,
      stadiumNamingIncome: json['stadiumNamingIncome'] as int? ?? 2500,
      accumulatedIdleCash: json['accumulatedIdleCash'] as int? ?? 0,
      sackingCountdownMatches: json['sackingCountdownMatches'] as int? ?? 0,
      cupTournament: cupTournament,
      continentalCup: continentalCup,
      unlockedLegacyPerks: unlockedLegacyPerks,
      retiredLegends: retiredLegends,
      ticketPrice: json['ticketPrice'] as int? ?? 25,
      winBonusPerMatch: json['winBonusPerMatch'] as int? ?? 0,
      activeLoanDeals: activeLoanDeals,
      treasuryDeposit: json['treasuryDeposit'] as int? ?? 0,
      headCoach: headCoach,
      vipBoxDeals: vipBoxDeals,
      activeCrisisCall: activeCrisisCall,
      pinnedShortcutIds: pinnedShortcutIds,
      staff: staff,
      activeSponsorships: activeSponsorships,
      unlockedAchievementIds: unlockedAchievementIds,
      museumRecords: museumRecords,
      signedMarketIds: signedMarketIds,
      crisisCooldownMatches: crisisCooldownMatches,
      resolvedCrisisIds: resolvedCrisisIds,
      clubXp: json['clubXp'] as int? ?? 0,
    );
  }
}
