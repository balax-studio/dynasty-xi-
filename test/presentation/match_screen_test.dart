import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/application/providers/game_state_provider.dart';
import 'package:futbol/core/time/game_clock.dart';
import 'package:futbol/data/local/save_repository.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/game_state.dart';
import 'package:futbol/domain/entities/league.dart';
import 'package:futbol/domain/entities/manager.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/presentation/screens/match_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Player createPlayer(String id, String lastName, Position pos) {
  return Player(
    id: id,
    firstName: 'Test',
    lastName: lastName,
    countryCode: 'TR',
    age: 24,
    position: pos,
    pace: 75,
    technique: 75,
    shooting: 75,
    passing: 75,
    defending: 75,
    physical: 75,
    mentality: 75,
    potential: 80,
    weeklyWage: 2000,
    fitness: 90,
  );
}

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

  testWidgets('MatchScreen initializes and displays Flame live pitch HUD and scoreboard', (tester) async {
    final starters = [
      createPlayer('p1', 'Demirel', Position.gk),
      createPlayer('p2', 'Gönül', Position.rb),
      createPlayer('p3', 'Lugano', Position.cb),
      createPlayer('p4', 'Edu', Position.cb),
      createPlayer('p5', 'Carlos', Position.lb),
      createPlayer('p6', 'Aurelio', Position.dm),
      createPlayer('p7', 'Appiah', Position.cm),
      createPlayer('p8', 'Alex', Position.am),
      createPlayer('p9', 'Deivid', Position.rw),
      createPlayer('p10', 'Semih', Position.st),
      createPlayer('p11', 'Boral', Position.lw),
    ];

    final userClub = Club(
      id: 'club_user',
      name: 'Kadıköy SK',
      city: 'İstanbul',
      badgeIcon: 'BOLT',
      meters: const ClubMeters(cash: 300000, fans: 70, lockerRoom: 70, boardTrust: 80),
      squad: starters,
      starting11Ids: starters.map((p) => p.id).toList(),
    );

    final fixtures = [
      const Fixture(
        id: 'fix_1',
        seasonNumber: 1,
        matchday: 1,
        homeClubId: 'club_user',
        awayClubId: 'club_opp',
      ),
    ];

    final league = League(
      name: 'Süper Lig',
      tier: 1,
      clubIds: ['club_user', 'club_opp'],
      fixtures: fixtures,
    );

    final testState = GameState(
      userClub: userClub,
      manager: const Manager(name: 'Test Menajer'),
      currentLeague: league,
      clock: const GameClock(matchday: 1, seasonNumber: 1),
    );

    final fakeRepo = FakeSaveRepository()..inMemoryState = testState;
    final container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: MatchScreen(isLiveMode: true),
        ),
      ),
    );

    // Pump to allow async loading from fake repository
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('CANLI MAÇ'), findsOneWidget);
    expect(find.textContaining('FLAME 2D RADAR'), findsOneWidget);
    expect(find.textContaining('KADIKÖY SK'), findsWidgets);
    expect(find.text('[HUKUK] HAKEM ODASI BASKINI'), findsOneWidget);
  });
}
