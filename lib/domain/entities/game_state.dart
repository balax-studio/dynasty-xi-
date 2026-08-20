// domain/entities/game_state.dart
// Pure Dart. Root game state combining user club, manager, league pyramid, game clock, cards, quests, economy, cups, and prestige.

import '../../core/time/game_clock.dart';
import '../economy/financial_statement.dart';
import '../economy/transfer_models.dart';
import '../liveops/season_theme.dart';
import '../president/boardroom_summit.dart';
import '../president/head_coach.dart';
import '../progression/daily_quest.dart';
import '../progression/dynasty_prestige.dart';
import '../tournament/cup_tournament.dart';
import 'card.dart';
import 'club.dart';
import 'league.dart';
import 'manager.dart';
import 'player.dart';

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
  final List<DynastyLegacyPerk> unlockedLegacyPerks;
  final List<Player> retiredLegends;
  final int ticketPrice;
  final int winBonusPerMatch;
  final List<LoanDeal> activeLoanDeals;
  final HeadCoach? headCoach;
  final List<VipBoxDeal> vipBoxDeals;

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
    this.unlockedLegacyPerks = const [],
    this.retiredLegends = const [],
    this.ticketPrice = 25,
    this.winBonusPerMatch = 0,
    this.activeLoanDeals = const [],
    this.treasuryDeposit = 0,
    this.headCoach,
    this.vipBoxDeals = const [],
  });

  final int treasuryDeposit;

  bool get isUnderSackingThreat => userClub.meters.boardTrust < 30;
  SeasonThemeType get currentSeasonTheme => SeasonThemeService.getThemeForMatchday(clock.matchday);
  bool get hasSecondBuilder => unlockedLegacyPerks.any((p) => p.id == 'double_builder' && p.isUnlocked);

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
    List<DailyQuest>? dailyQuests,
    BankLoan? activeLoan,
    int? sleeveSponsorIncome,
    int? stadiumNamingIncome,
    int? accumulatedIdleCash,
    int? sackingCountdownMatches,
    CupTournament? cupTournament,
    List<DynastyLegacyPerk>? unlockedLegacyPerks,
    List<Player>? retiredLegends,
    int? ticketPrice,
    int? winBonusPerMatch,
    List<LoanDeal>? activeLoanDeals,
    int? treasuryDeposit,
    HeadCoach? headCoach,
    bool clearHeadCoach = false,
    List<VipBoxDeal>? vipBoxDeals,
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
      gameOverReason: gameOverReason ?? this.gameOverReason,
      dailyQuests: dailyQuests ?? this.dailyQuests,
      activeLoan: activeLoan ?? this.activeLoan,
      sleeveSponsorIncome: sleeveSponsorIncome ?? this.sleeveSponsorIncome,
      stadiumNamingIncome: stadiumNamingIncome ?? this.stadiumNamingIncome,
      accumulatedIdleCash: accumulatedIdleCash ?? this.accumulatedIdleCash,
      sackingCountdownMatches: sackingCountdownMatches ?? this.sackingCountdownMatches,
      cupTournament: cupTournament ?? this.cupTournament,
      unlockedLegacyPerks: unlockedLegacyPerks ?? this.unlockedLegacyPerks,
      retiredLegends: retiredLegends ?? this.retiredLegends,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      winBonusPerMatch: winBonusPerMatch ?? this.winBonusPerMatch,
      activeLoanDeals: activeLoanDeals ?? this.activeLoanDeals,
      treasuryDeposit: treasuryDeposit ?? this.treasuryDeposit,
      headCoach: clearHeadCoach ? null : (headCoach ?? this.headCoach),
      vipBoxDeals: vipBoxDeals ?? this.vipBoxDeals,
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
        'unlockedLegacyPerks': unlockedLegacyPerks.map((p) => p.toJson()).toList(),
        'retiredLegends': retiredLegends.map((p) => p.toJson()).toList(),
        'ticketPrice': ticketPrice,
        'winBonusPerMatch': winBonusPerMatch,
        'activeLoanDeals': activeLoanDeals.map((l) => l.toJson()).toList(),
        'treasuryDeposit': treasuryDeposit,
        'headCoach': headCoach?.toJson(),
        'vipBoxDeals': vipBoxDeals.map((v) => v.toJson()).toList(),
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

    final vipBoxDeals = (json['vipBoxDeals'] as List<dynamic>?)
            ?.map((v) => VipBoxDeal.fromJson(v as Map<String, dynamic>))
            .toList() ??
        BoardroomCatalog.getInitialVipBoxes();

    final cupTournament = json['cupTournament'] != null
        ? CupTournament.fromJson(json['cupTournament'] as Map<String, dynamic>)
        : const CupTournament();

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
      unlockedLegacyPerks: unlockedLegacyPerks,
      retiredLegends: retiredLegends,
      ticketPrice: json['ticketPrice'] as int? ?? 25,
      winBonusPerMatch: json['winBonusPerMatch'] as int? ?? 0,
      activeLoanDeals: activeLoanDeals,
      treasuryDeposit: json['treasuryDeposit'] as int? ?? 0,
      headCoach: headCoach,
      vipBoxDeals: vipBoxDeals,
    );
  }
}
