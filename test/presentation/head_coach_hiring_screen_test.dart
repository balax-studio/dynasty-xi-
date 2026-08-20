// test/presentation/head_coach_hiring_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/presentation/screens/head_coach_hiring_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HeadCoachHiringScreen Widget Tests', () {
    testWidgets('renders candidates list and active coach or hiring triggers', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HeadCoachHiringScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TEKNİK DİREKTÖR YÖNETİM MERKEZİ'), findsOneWidget);
      expect(find.text('BOŞTAKİ TEKNİK DİREKTÖR ADAYLARI'), findsOneWidget);
      expect(find.text('GÖREVE GETİR'), findsWidgets);
    });
  });
}
