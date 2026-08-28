// test/presentation/impact_confirm_test.dart
// Widget tests for RetroImpactConfirmModal, PlayerSaleOfferModal, and LoanContractSummaryModal

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/application/providers/game_state_provider.dart';
import 'package:futbol/data/local/save_repository.dart';
import 'package:futbol/domain/economy/transfer_models.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/presentation/widgets/loan_contract_summary_modal.dart';
import 'package:futbol/presentation/widgets/player_sale_offer_modal.dart';
import 'package:futbol/presentation/widgets/retro_impact_confirm_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testPlayer = Player(
    id: 'test_player_confirm',
    firstName: 'Arda',
    lastName: 'Güler',
    countryCode: 'TR',
    age: 19,
    position: Position.am,
    pace: 82,
    technique: 90,
    shooting: 84,
    passing: 88,
    defending: 40,
    physical: 68,
    mentality: 85,
    potential: 94,
    weeklyWage: 12000,
  );

  GameState createTestGameState() {
    return const GameState(
      userClub: Club(
        id: 'club_1',
        name: 'Kadıköy SK',
        city: 'İstanbul',
        badgeIcon: 'BOLT',
        meters: ClubMeters(cash: 300000, fans: 70, lockerRoom: 70, boardTrust: 80),
        squad: [testPlayer],
      ),
      manager: Manager(name: 'Test Menajer'),
      transferMarket: [testPlayer],
    );
  }

  testWidgets('RetroImpactConfirmModal renders details, cash delta, and confirms action', (tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                RetroImpactConfirmModal.show(
                  ctx,
                  title: 'TEST ONAY PENCERESİ',
                  actionTitle: 'KRİTİK EYLEM BAŞLIĞI',
                  description: 'Bu eylem geri alınamaz sonuçlar doğuracaktır.',
                  cashDelta: -25000,
                  weeklyWageDelta: 5000,
                  fanDelta: 2,
                  moraleDelta: -3,
                  boardTrustDelta: 1,
                  targetItemName: 'Ahmet Hoca',
                  targetItemDetails: 'Asistan Menajer • 3. Seviye',
                  confirmButtonText: 'ONAYLA VE DEVAM ET',
                  onConfirmed: () => confirmed = true,
                );
              },
              child: const Text('AÇ'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('AÇ'));
    await tester.pumpAndSettle();

    expect(find.text('TEST ONAY PENCERESİ'), findsOneWidget);
    expect(find.text('KRİTİK EYLEM BAŞLIĞI'), findsOneWidget);
    expect(find.text('Ahmet Hoca'), findsOneWidget);
    expect(find.text('-₣25000'), findsOneWidget);
    expect(find.text('ONAYLA VE DEVAM ET'), findsOneWidget);

    await tester.tap(find.text('ONAYLA VE DEVAM ET'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('PlayerSaleOfferModal renders buyer bid and allows selling', (tester) async {
    final fakeRepo = FakeSaveRepository();
    fakeRepo.inMemoryState = createTestGameState();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          saveRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PlayerSaleOfferModal(player: testPlayer, salePrice: 150000),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('TRANSFER SATIŞ MASASI & RESMİ TEKLİF'), findsOneWidget);
    expect(find.textContaining('Arda Güler'), findsWidgets);
    expect(find.text('₣150000'), findsWidgets);
    expect(find.textContaining('KABUL ET'), findsOneWidget);
    expect(find.text('REDDET'), findsOneWidget);
  });

  testWidgets('LoanContractSummaryModal renders terms and allows borrowing', (tester) async {
    final fakeRepo = FakeSaveRepository();
    fakeRepo.inMemoryState = createTestGameState();

    const loanDeal = LoanDeal(
      player: testPlayer,
      parentClubName: 'Real Madrid',
      borrowingClubWageShare: 0.5,
      buyoutClause: 250000,
      seasons: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          saveRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LoanContractSummaryModal(deal: loanDeal),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('KİRALIK TRANSFER SÖZLEŞME MASASI'), findsOneWidget);
    expect(find.textContaining('Real Madrid'), findsOneWidget);
    expect(find.text('SÖZLEŞMEYİ İMZALA'), findsOneWidget);
    expect(find.text('VAZGEÇ'), findsOneWidget);
  });
}
