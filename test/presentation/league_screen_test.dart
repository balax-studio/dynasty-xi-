// test/presentation/league_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/presentation/screens/league_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LeagueScreen renders standings, fixtures, and leaderboards tabs without error', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LeagueScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. App Bar
    expect(find.textContaining('LİG VERİTABANI'), findsOneWidget);

    // 2. Tab 1: Puan Tablosu
    expect(find.text('[GRAFIK] PUAN TABLOSU'), findsOneWidget);
    expect(find.textContaining('SEZON SONU PROTOKOLÜ'), findsOneWidget);
    expect(find.text('KULÜP'), findsOneWidget);

    // 3. Tab 2: Fikstür
    await tester.tap(find.text(' FİKSTÜR'));
    await tester.pumpAndSettle();
    expect(find.textContaining('H.'), findsWidgets);

    // 4. Tab 3: Gol & Asist
    await tester.tap(find.text('STAR GOL & ASİST'));
    await tester.pumpAndSettle();
    expect(find.textContaining('LİG GOL KRALLIĞI'), findsOneWidget);
    expect(find.textContaining('LİG ASİST KRALLIĞI'), findsOneWidget);
  });
}
