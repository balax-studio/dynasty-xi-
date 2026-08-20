import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/application/providers/game_state_provider.dart';
import 'package:futbol/data/local/save_repository.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/presentation/screens/transfer_negotiation_screen.dart';
import 'package:futbol/presentation/screens/transfer_screen.dart';
import 'package:futbol/presentation/widgets/grand_signing_ceremony_modal.dart';
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
    id: 'test_transfer_p1',
    firstName: 'Barış',
    lastName: 'Alper',
    countryCode: 'TR',
    age: 24,
    position: Position.rw,
    pace: 90,
    technique: 80,
    shooting: 78,
    passing: 75,
    defending: 55,
    physical: 85,
    mentality: 82,
    potential: 86,
    weeklyWage: 6000,
  );

  GameState createTestGameState() {
    return const GameState(
      userClub: Club(
        id: 'club_1',
        name: 'Kadıköy SK',
        city: 'İstanbul',
        badgeIcon: '⚡',
        meters: ClubMeters(cash: 300000, fans: 70, lockerRoom: 70, boardTrust: 80),
        squad: [
          Player(
            id: 'squad_p1',
            firstName: 'Mert',
            lastName: 'Hakan',
            countryCode: 'TR',
            age: 28,
            position: Position.cm,
            pace: 70,
            technique: 75,
            shooting: 72,
            passing: 74,
            defending: 65,
            physical: 72,
            mentality: 80,
            potential: 76,
            weeklyWage: 3000,
          ),
        ],
      ),
      manager: Manager(name: 'Test Menajer'),
      transferMarket: [testPlayer],
    );
  }

  testWidgets('TransferScreen renders tab bar, advanced filters, and market items', (tester) async {
    final fakeRepo = FakeSaveRepository();
    fakeRepo.inMemoryState = createTestGameState();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          saveRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: TransferScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CYBER TRANSFER & SCOUT BORSASI'), findsOneWidget);
    expect(find.text('TRANSFER PAZARI'), findsOneWidget);
    expect(find.text('SATIŞ LİSTESİ'), findsOneWidget);
    expect(find.text('KİRALIK PAZARI'), findsOneWidget);

    // Filtre butonları
    expect(find.text('TÜMÜ'), findsOneWidget);
    expect(find.text('KALECİ'), findsOneWidget);
    expect(find.text('SAVUNMA'), findsOneWidget);
    expect(find.text('HÜCUM'), findsOneWidget);

    // Pazardaki oyuncu ve Pazarlık butonu
    expect(find.textContaining('Barış Alper'), findsOneWidget);
    expect(find.text('PAZARLIK YAP'), findsWidgets);
  });

  testWidgets('TransferNegotiationScreen renders desk sliders, kickback, and patience bar', (tester) async {
    final fakeRepo = FakeSaveRepository();
    fakeRepo.inMemoryState = createTestGameState();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          saveRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: TransferNegotiationScreen(player: testPlayer),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('TRANSFER PAZARLIK MASASI'), findsOneWidget);
    expect(find.text('BONSERVİS BEDELİ TEKLİFİ'), findsOneWidget);
    expect(find.text('HAFTALIK MAAŞ TEKLİFİ'), findsOneWidget);
    expect(find.text('MENAJERE EL ALTINDAN KOMİSYON'), findsOneWidget);
    expect(find.text('TEKLİFİ SUN'), findsOneWidget);
    expect(find.text('MASADAN KALK'), findsOneWidget);

    // Teklifi sun tıklama
    await tester.tap(find.text('TEKLİFİ SUN'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sabır'), findsWidgets);
  });

  testWidgets('GrandSigningCeremonyModal renders stadium celebration options', (tester) async {
    final fakeRepo = FakeSaveRepository();
    fakeRepo.inMemoryState = createTestGameState();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          saveRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: GrandSigningCeremonyModal(
              player: testPlayer,
              fee: 100000,
              wage: 5000,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('TRANSFER TAMAMLANDI: İMZA TÖRENİ'), findsOneWidget);
    expect(find.text('STADYUMDA GÖRKEMLİ İMZA ŞOVU'), findsOneWidget);
    expect(find.textContaining('TESİSLERDE SADE İMZA TÖRENİ'), findsOneWidget);
  });
}
