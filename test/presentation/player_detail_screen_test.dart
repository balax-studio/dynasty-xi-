import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/presentation/screens/player_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Player createSamplePlayer({bool isCaptain = false, bool isInjured = false}) {
    return Player(
      id: 'p-101',
      firstName: 'Arda',
      lastName: 'Güler',
      countryCode: 'TR',
      position: Position.am,
      age: 19,
      pace: 82,
      shooting: 85,
      passing: 88,
      technique: 89,
      defending: 55,
      physical: 68,
      mentality: 84,
      potential: 94,
      weeklyWage: 12000,
      contractSeasonsLeft: 3,
      releaseClause: 1200000,
      personality: PersonalityType.ambitious,
      morale: 90,
      fitness: 85,
      form: 8.5,
      sharpness: 92,
      isCaptain: isCaptain,
      injuryMatchesLeft: isInjured ? 2 : 0,
      injuryType: isInjured ? 'Ayak Bileği Burkulması' : null,
      injurySeverity: isInjured ? InjurySeverity.minor : InjurySeverity.none,
      squadRole: SquadRole.star,
      trainingIntensity: TrainingIntensity.intensive,
      faceSeed: 'arda-guler-seed-01',
      jerseyNumber: 10,
      faction: LockerRoomFaction.academyYouth,
    );
  }

  testWidgets('PlayerDetailScreen renders owned player details, radar, and 3-tab bento navigation', (tester) async {
    final player = createSamplePlayer();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PlayerDetailScreen(
            player: player,
            isOwned: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Player Identity & Jersey Number
    expect(find.textContaining('ARDA GÜLER'), findsWidgets);
    expect(find.textContaining('OVR'), findsWidgets);
    expect(find.textContaining('94 POT'), findsWidgets);
    expect(find.textContaining('#10'), findsWidgets);

    // Verify 7 Attributes in General Tab
    expect(find.textContaining('HIZ'), findsWidgets);
    expect(find.textContaining('ŞUT'), findsWidgets);
    expect(find.textContaining('PAS'), findsWidgets);
    expect(find.textContaining('TOP TEKNİĞİ'), findsWidgets);
    expect(find.textContaining('SAVUNMA'), findsWidgets);
    expect(find.textContaining('FİZİK'), findsWidgets);
    expect(find.textContaining('MENTALİTE'), findsWidgets);

    // Switch to Contract & Market Tab
    await tester.tap(find.byKey(const Key('tab_contract')));
    await tester.pumpAndSettle();

    expect(find.textContaining('SÖZLEŞME YENİLE'), findsOneWidget);
    expect(find.textContaining('SATILIK LİSTESİNE KOY'), findsOneWidget);
    expect(find.textContaining('MENAJERİ İLE GÖRÜŞ'), findsOneWidget);
    expect(find.textContaining('SERBEST BIRAK'), findsOneWidget);

    // Switch to Presidential & Locker Room Tab
    await tester.tap(find.byKey(const Key('tab_presidential')));
    await tester.pumpAndSettle();

    expect(find.textContaining('AKADEMI GENÇLERI'), findsOneWidget);
    expect(find.textContaining('HOCA UYUM SKORU'), findsOneWidget);
    expect(find.textContaining('ÖZEL PRİM / HEDİYE / NUMARA / CEZA MENÜSÜ'), findsOneWidget);
    expect(find.textContaining('TAKIMLA KIYASLA'), findsOneWidget);
  });

  testWidgets('PlayerDetailScreen renders unowned player with direct transfer option in contract tab', (tester) async {
    final player = createSamplePlayer();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PlayerDetailScreen(
            player: player,
            isOwned: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Player Identity
    expect(find.textContaining('ARDA GÜLER'), findsWidgets);

    // Switch to Contract Tab
    await tester.tap(find.byKey(const Key('tab_contract')));
    await tester.pumpAndSettle();

    // Verify Unowned Transfer Action
    expect(find.textContaining('DOĞRUDAN TRANSFER ET'), findsOneWidget);
  });
}
