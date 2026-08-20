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
    );
  }

  testWidgets('PlayerDetailScreen renders owned player details, attributes, and management actions', (tester) async {
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

    // Verify Player Identity
    expect(find.text('Arda Güler'), findsWidgets);
    expect(find.textContaining('OVR'), findsWidgets);
    expect(find.textContaining('94 POT'), findsWidgets);
    expect(find.textContaining('HIRSLI'), findsWidgets);

    // Verify 7 Attributes
    expect(find.text('HIZ / PACE'), findsOneWidget);
    expect(find.text('ŞUT / SHOOTING'), findsOneWidget);
    expect(find.text('PAS / PASSING'), findsOneWidget);
    expect(find.text('TEKNİK & DRIBBLE'), findsOneWidget);
    expect(find.text('SAVUNMA / DEFENSE'), findsOneWidget);
    expect(find.text('FİZİKSEL / PHYSICAL'), findsOneWidget);
    expect(find.text('MENTAL / MENTALITY'), findsOneWidget);

    // Verify Status Meters
    expect(find.text('MORAL'), findsOneWidget);
    expect(find.text('KONDİSYON'), findsOneWidget);
    expect(find.text('KESKİNLİK'), findsOneWidget);

    // Verify Owned Actions
    expect(find.textContaining('SÖZLEŞME YENİLE'), findsOneWidget);
    expect(find.textContaining('KAPTAN YAP'), findsOneWidget);
    expect(find.textContaining('SATILIK LİSTESİNE KOY'), findsOneWidget);
  });

  testWidgets('PlayerDetailScreen renders unowned player with transfer & loan action buttons', (tester) async {
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
    expect(find.text('Arda Güler'), findsWidgets);

    // Verify Unowned Actions
    expect(find.textContaining('TRANSFER ET'), findsOneWidget);
    expect(find.textContaining('SEZONLUK KİRALA'), findsOneWidget);
    expect(find.text('KAPTAN YAP'), findsNothing);
  });

  testWidgets('PlayerDetailScreen renders injury banner when player is injured', (tester) async {
    final player = createSamplePlayer(isInjured: true);

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

    expect(find.textContaining('BURKULMASI'), findsOneWidget);
  });
}
