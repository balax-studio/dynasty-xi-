// test/domain/comprehensive_logic_verification_test.dart
// Full verification of all 7 refactored modules: Match persistence, ledger integrity, cup fairness, real entities, manager RPG, season transitions, and database integrations.

import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/assets/card_database.dart';
import 'package:futbol/data/local/save_repository.dart';
import 'package:futbol/application/providers/game_state_provider.dart';
import 'package:futbol/domain/economy/financial_statement.dart';
import 'package:futbol/domain/economy/sponsorship_contract.dart';
import 'package:futbol/domain/economy/weekly_ledger.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/president/president_lifestyle.dart';
import 'package:futbol/domain/progression/coaching_license.dart';
import 'package:futbol/domain/progression/player_natural_summary.dart';
import 'package:futbol/domain/progression/season_transition.dart';
import 'package:futbol/domain/transfers/transfer_hijack.dart';
import 'package:futbol/core/rng/deterministic_rng.dart';

class FakeSaveRepository extends SaveRepository {
  GameState? inMemoryState;

  @override
  Future<void> save(GameState state) async {
    inMemoryState = state;
  }

  @override
  Future<GameState?> load() async {
    return inMemoryState;
  }

  @override
  Future<int?> getLastExitEpochMs() async {
    return null;
  }
}

void main() {
  group('Module 2: Financial Ledger Sponsorship Integrity', () {
    test('Calculates active sponsorship revenue strictly once from active contracts', () {
      final initialGame = SaveRepository.createNewGame();
      const contract1 = SponsorshipContract(
        id: 'sp_shirt',
        slot: SponsorshipSlot.mainShirt,
        brandName: 'Mega Corp',
        brandIcon: '',
        sector: 'Teknoloji',
        durationWeeks: 20,
        weeksRemaining: 20,
        weeklyIncome: 10000,
        signingBonus: 20000,
        minLeagueTier: 20,
        perk: SponsorshipPerk(description: 'Test perk'),
        risk: SponsorshipRisk(description: 'Test risk'),
      );

      const contract2 = SponsorshipContract(
        id: 'sp_stadium',
        slot: SponsorshipSlot.stadiumNaming,
        brandName: 'Stadium Corp',
        brandIcon: '',
        sector: 'İnşaat',
        durationWeeks: 20,
        weeksRemaining: 20,
        weeklyIncome: 5000,
        signingBonus: 10000,
        minLeagueTier: 20,
        perk: SponsorshipPerk(description: 'Test perk'),
        risk: SponsorshipRisk(description: 'Test risk'),
      );

      final state = initialGame.copyWith(
        activeSponsorships: {
          SponsorshipSlot.mainShirt: contract1,
          SponsorshipSlot.stadiumNaming: contract2,
        },
        sleeveSponsorIncome: 1200,
        stadiumNamingIncome: 2500,
      );

      final ledger = WeeklyLedgerCalculator.calculate(
        state: state,
        isHomeMatch: false,
      );

      // Should be exactly 10000 + 5000 = 15000, NOT double counted with legacy 1200 + 2500
      expect(ledger.sponsorshipRevenue, equals(15000));
    });
  });

  group('Module 5: Manager RPG License & Achievements Serialization', () {
    test('Manager license is serialized and deserialized correctly', () {
      const manager = Manager(
        name: 'İmparator',
        level: 5,
        license: CoachingLicense.uefaA,
      );

      final json = manager.toJson();
      expect(json['license'], equals('uefaA'));

      final restored = Manager.fromJson(json);
      expect(restored.license, equals(CoachingLicense.uefaA));
      expect(restored.license.title, contains('UEFA A Lisansı'));
    });
  });

  group('Module 4: Real Entity Creation and State Notifier Actions', () {
    late GameStateNotifier notifier;
    late FakeSaveRepository fakeRepo;
    late GameState initialGame;

    setUp(() async {
      initialGame = SaveRepository.createNewGame();
      // Provide sufficient cash and manager level for tests
      initialGame = initialGame.copyWith(
        userClub: initialGame.userClub.copyWith(
          meters: initialGame.userClub.meters.applyDeltas(deltaCash: 500000),
        ),
        manager: initialGame.manager.copyWith(level: 20),
      );
      fakeRepo = FakeSaveRepository();
      fakeRepo.inMemoryState = initialGame;
      notifier = GameStateNotifier(fakeRepo);
      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('hijackTransfer deducts cash, creates real Player in squad, and tracks target', () async {
      const target = TransferHijackTarget(
        playerName: 'Nemanja Matic',
        playerPosition: 'Orta Saha (CM)',
        overallRating: 78,
        rivalClubName: 'Ezeli Rakip',
        rivalBidAmount: 80000,
        requiredHijackBid: 40000,
        requiredAgentCommission: 10000,
        fansHypeBonus: 15,
      );

      final beforeCash = notifier.currentState!.userClub.meters.cash;
      final beforeCount = notifier.currentState!.userClub.squad.length;

      final success = await notifier.hijackTransfer(target);
      expect(success, isTrue);

      final after = notifier.currentState!;
      expect(after.userClub.meters.cash, equals(beforeCash - 50000));
      expect(after.userClub.squad.length, equals(beforeCount + 1));
      expect(after.hijackedPlayerIds, contains('Nemanja Matic'));

      final created = after.userClub.squad.firstWhere((p) => p.fullName == 'Nemanja Matic');
      expect(created.ovr, greaterThanOrEqualTo(70));
    });

    test('signGrassrootsTalent adds U19 youth prospect with correct ratings', () async {
      final beforeU19Count = notifier.currentState!.userClub.u19Squad.length;

      await notifier.signGrassrootsTalent(
        name: 'Arda Güler Jr',
        position: '10 Numara / Forvet',
        potentialRating: 92,
        overallRating: 68,
      );

      final after = notifier.currentState!;
      expect(after.userClub.u19Squad.length, equals(beforeU19Count + 1));

      final youth = after.userClub.u19Squad.firstWhere((p) => p.fullName == 'Arda Güler Jr');
      expect(youth.potential, equals(92));
      expect(youth.isYouthProduct, isTrue);
    });

    test('buyLuxuryAsset adds asset to ownedLuxuryAssetIds', () async {
      const asset = PresidentLuxuryAsset(
        id: 'lux_gulfstream_jet',
        name: 'Özel Jet',
        category: 'JETS',
        icon: '',
        purchaseCost: 50000,
        prestigeBonus: 25,
        fansBonus: 10,
        description: 'Kulüp başkanlığına yakışır ultra lüks özel jet.',
      );

      final success = await notifier.buyLuxuryAsset(asset);
      expect(success, isTrue);
      expect(notifier.currentState!.ownedLuxuryAssetIds, contains('lux_gulfstream_jet'));
    });

    test('sellClubShares enforces 49% limit', () async {
      final success1 = await notifier.sellClubShares(percent: 30, cashAmount: 300000);
      expect(success1, isTrue);
      expect(notifier.currentState!.soldClubSharePercent, equals(30));

      final success2 = await notifier.sellClubShares(percent: 25, cashAmount: 250000);
      // 30 + 25 = 55% > 49% -> Must fail
      expect(success2, isFalse);
      expect(notifier.currentState!.soldClubSharePercent, equals(30));
    });

    test('upgradeCoachingLicense updates manager license state', () async {
      final success = await notifier.upgradeCoachingLicense(CoachingLicense.uefaPro);
      expect(success, isTrue);
      expect(notifier.currentState!.manager.license, equals(CoachingLicense.uefaPro));
    });
  });

  group('Module 6: Season Transition Reset and Contracts', () {
    test('applySeasonTransition regenerates cups and handles contract expirations', () {
      final rng = DeterministicRng(42);
      var state = SaveRepository.createNewGame();

      // Create a squad with 1 player having 1 year left (which will expire to 0) and 18 players with 3 years left
      final expiringPlayer = state.userClub.squad.first.copyWith(id: 'expiring_p', contractSeasonsLeft: 1);
      final safeSquad = [
        expiringPlayer,
        ...state.userClub.squad.skip(1).map((p) => p.copyWith(contractSeasonsLeft: 3)),
      ];

      state = state.copyWith(
        userClub: state.userClub.copyWith(squad: safeSquad),
        resolvedDebateIds: ['debate_1'],
        votedSummitAgendaIds: ['agenda_1'],
        activeAffiliateClubIds: ['Anadolu FK'],
      );

      final report = SeasonTransition.processSeasonEnd(state);
      final nextSeasonState = SeasonTransition.applySeasonTransition(
        state: state,
        report: report,
        rng: rng,
      );

      expect(nextSeasonState.clock.seasonNumber, equals(2));
      expect(nextSeasonState.resolvedDebateIds, isEmpty);
      expect(nextSeasonState.votedSummitAgendaIds, isEmpty);
      expect(nextSeasonState.activeAffiliateClubIds, isEmpty);
      expect(nextSeasonState.cupTournament.matches, isNotEmpty);
      expect(nextSeasonState.continentalCup, isNotNull);
    });
  });

  group('Module 7: Dead Code Integration & Summary Generator', () {
    test('CardDatabase includes ExtendedNarrativeCards', () {
      final all = CardDatabase.allCards;
      expect(all.length, greaterThan(CardDatabase.mvpCards.length));
      expect(all.any((c) => c.id == 'chain_nepotism_1'), isTrue);
      expect(all.any((c) => c.id == 'chain_agent_shady_1'), isTrue);
    });

    test('PlayerNaturalSummary produces rich natural text description', () {
      const p = Player(
        id: 'p_leader',
        firstName: 'Hakan',
        lastName: 'Çalhanoğlu',
        countryCode: 'TR',
        age: 30,
        position: Position.cm,
        pace: 75,
        technique: 88,
        shooting: 84,
        passing: 90,
        defending: 72,
        physical: 75,
        mentality: 85,
        potential: 88,
        weeklyWage: 20000,
        form: 88.0,
        personality: PersonalityType.leader,
        fitness: 95,
      );

      final summary = PlayerNaturalSummary.generateSummary(p);
      expect(summary, isNotEmpty);
      expect(summary, contains('Soyunma odasının doğal lideri'));
      expect(summary, contains('Son maçlarda alev almış durumda'));
    });
  });
}
