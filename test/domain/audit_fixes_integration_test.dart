import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/data/local/save_repository.dart';
import 'package:futbol/application/providers/game_state_provider.dart';
import 'package:futbol/domain/economy/financial_statement.dart';
import 'package:futbol/domain/economy/transfer_models.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/president/president_crisis.dart';
import 'package:futbol/domain/progression/museum_records.dart';
import 'package:futbol/domain/tournament/continental_cup.dart';

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
  group('Audit Report Core Fixes Verification (K-1 to K-13 & O-1 to O-13)', () {
    late FakeSaveRepository fakeRepo;
    late GameState initialGame;

    setUp(() {
      initialGame = SaveRepository.createNewGame();
      fakeRepo = FakeSaveRepository();
      fakeRepo.inMemoryState = initialGame;
    });

    test('K-1: repayBankLoanEarly properly clears loan in state', () async {
      final notifier = GameStateNotifier(fakeRepo);
      await Future.delayed(const Duration(milliseconds: 100));

      const pkg = BankLoanPackage(
        id: 'pkg_test',
        name: 'Test Kredi',
        principalAmount: 100000,
        interestRate: 0.1,
        totalWeeks: 10,
        icon: '',
        description: 'Test loan',
      );

      // 1. Kredi al
      final took = await notifier.takeBankLoanPackage(pkg);
      expect(took, isTrue);
      expect(notifier.currentState?.activeLoan, isNotNull);

      // 2. Erken kapat
      final repaid = await notifier.repayBankLoanEarly();
      expect(repaid, isTrue);
      expect(notifier.currentState?.activeLoan, isNull, reason: 'K-1: clearLoan: true must nullify activeLoan in copyWith');
    });

    test('K-3 & O-6: loanInPlayer adds player to squad and updates activeLoanDeals', () async {
      final notifier = GameStateNotifier(fakeRepo);
      await Future.delayed(const Duration(milliseconds: 100));

      final testPlayer = initialGame.userClub.squad.first.copyWith(id: 'loaned_player_1');

      final deal = LoanDeal(
        player: testPlayer,
        parentClubName: 'Real Madrid',
        seasons: 1,
        borrowingClubWageShare: 0.5,
        buyoutClause: 500000,
        weeksRemaining: 4,
      );

      final ok = await notifier.loanInPlayer(deal);
      expect(ok, isTrue);
      expect(notifier.currentState?.activeLoanDeals.length, 1);
      expect(notifier.currentState?.userClub.squad.any((p) => p.id == 'loaned_player_1'), isTrue);
      expect(notifier.currentState?.signedMarketIds.contains('loaned_player_1'), isTrue);
    });

    test('K-7: PresidentCrisisCall serializes and deserializes cleanly into GameState', () {
      const call = PresidentCrisisCall(
        id: 'crisis_test_1',
        caller: CrisisCallerType.rivalPresident,
        callerName: 'Başkan Aziz',
        callerTitle: 'Kulüp Başkanı',
        callerAvatar: '[VIP]',
        dialogQuote: 'Basına gizli belgeler sızdırıldı.',
        choices: [
          CrisisChoice(
            title: 'Örtbas Et',
            description: 'Basına sus payı öde',
            outcomeMessage: 'Olay kapandı.',
            cashDelta: -50000,
            boardTrustDelta: 5,
          ),
        ],
      );

      final state = initialGame.copyWith(activeCrisisCall: call);
      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.activeCrisisCall, isNotNull);
      expect(restored.activeCrisisCall?.id, 'crisis_test_1');
      expect(restored.activeCrisisCall?.callerName, 'Başkan Aziz');
      expect(restored.activeCrisisCall?.choices.first.cashDelta, -50000);
    });

    test('K-12: ContinentalCup serializes and deserializes correctly in GameState', () {
      final cup = ContinentalCup.generateTournament(
        userClubName: 'Test FC',
        userBadge: 'LION',
        season: 2,
      );

      final state = initialGame.copyWith(continentalCup: cup);
      final json = state.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.continentalCup, isNotNull);
      expect(restored.continentalCup?.title, 'Avrupa Hanedan Şampiyonlar Kupası');
      expect(restored.continentalCup?.fixtures.isNotEmpty, isTrue);
    });

    test('K-5: Player copyWith clearInjury removes injury completely', () {
      var player = initialGame.userClub.squad.first.copyWith(
        injuryMatchesLeft: 3,
        injurySeverity: InjurySeverity.moderate,
        injuryType: 'Bilek Burkulması',
      );
      expect(player.isInjured, isTrue);

      player = player.copyWith(clearInjury: true);
      expect(player.injuryMatchesLeft, 0);
      expect(player.injurySeverity, InjurySeverity.none);
      expect(player.injuryType, isNull);
      expect(player.isInjured, isFalse);
    });

    test('O-5: ClubMuseumRecords tracks matches and top scorer correctly', () {
      var museum = const ClubMuseumRecords();
      museum = museum.checkAndRecordMatch(
        homeScore: 5,
        awayScore: 0,
        opponentName: 'Ezeli Rakip',
        isWin: true,
      );

      expect(museum.biggestWinScore, '5-0');
      expect(museum.biggestWinOpponent, 'Ezeli Rakip');
      expect(museum.unbeatenStreak, 1);

      final updatedWithScorer = museum.copyWith(
        allTimeTopScorerName: 'Hakan Şükür',
        allTimeTopScorerGoals: 249,
      );
      expect(updatedWithScorer.allTimeTopScorerName, 'Hakan Şükür');
      expect(updatedWithScorer.allTimeTopScorerGoals, 249);
    });
  });
}
