import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/presentation/screens/player_detail_screen.dart';
import 'package:futbol/presentation/screens/player_dialogue_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Player createSamplePlayer({
    required PersonalityType personality,
    bool isOwned = true,
  }) {
    return Player(
      id: 'p-dialogue-test',
      firstName: 'Barış',
      lastName: 'Alper',
      countryCode: 'TR',
      position: Position.rw,
      age: 24,
      pace: 92,
      technique: 80,
      shooting: 82,
      passing: 75,
      defending: 58,
      physical: 88,
      mentality: 85,
      potential: 89,
      weeklyWage: 14000,
      contractSeasonsLeft: 3,
      releaseClause: 800000,
      personality: personality,
      morale: 70,
      fitness: 80,
      form: 7.5,
      sharpness: 75,
      faceSeed: 'baris-alper-seed',
    );
  }

  testWidgets('PlayerDialogueScreen renders for owned player with topic buttons and responds to option tap', (tester) async {
    final player = createSamplePlayer(personality: PersonalityType.ambitious, isOwned: true);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PlayerDialogueScreen(
            player: player,
            isOwned: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Player identity
    expect(find.textContaining('ÖZEL GÖRÜŞME ODASI'), findsOneWidget);
    expect(find.textContaining('BARIŞ ALPER'), findsWidgets);
    expect(find.textContaining('HIRSLI'), findsWidgets);

    // Verify Option Cards rendered
    expect(find.textContaining('Harika bir tutkuyla oynuyorsun'), findsOneWidget);

    // Tap on praise option
    await tester.tap(find.textContaining('Harika bir tutkuyla oynuyorsun'));
    await tester.pumpAndSettle();

    // Verify Consequence & Outcome Card is displayed
    expect(find.textContaining('GÖRÜŞME SONUCU'), findsOneWidget);
    expect(find.textContaining('Moral'), findsWidgets);
  });

  testWidgets('PlayerDialogueScreen renders for unowned player with transfer persuasion topics', (tester) async {
    final player = createSamplePlayer(personality: PersonalityType.ambitious, isOwned: false);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: PlayerDialogueScreen(
            player: player,
            isOwned: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.textContaining('TRANSFER MÜLAKATI'), findsOneWidget);

    // Tap on trophy vision option
    expect(find.textContaining('Kulübümüz hızla yükselen bir hanedan inşa ediyor'), findsOneWidget);
    await tester.tap(find.textContaining('Kulübümüz hızla yükselen bir hanedan inşa ediyor'));
    await tester.pumpAndSettle();

    // Verify Transfer Discount result
    expect(find.textContaining('GÖRÜŞME SONUCU'), findsOneWidget);
    expect(find.textContaining('Transfer İndirimi'), findsOneWidget);
  });

  testWidgets('PlayerDetailScreen has RPG Dialogue button and navigates to PlayerDialogueScreen', (tester) async {
    final player = createSamplePlayer(personality: PersonalityType.leader, isOwned: true);

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

    // Ensure button is visible in scrollview and tap
    final rpgButtonFinder = find.textContaining('BİREBİR ÖZEL GÖRÜŞME YAP');
    expect(rpgButtonFinder, findsOneWidget);

    await tester.ensureVisible(rpgButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(rpgButtonFinder);
    await tester.pumpAndSettle();

    // Verify Navigation to Dialogue Screen
    expect(find.byType(PlayerDialogueScreen), findsOneWidget);
    expect(find.textContaining('ÖZEL GÖRÜŞME ODASI'), findsOneWidget);
  });
}
