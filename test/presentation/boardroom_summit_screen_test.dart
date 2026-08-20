// test/presentation/boardroom_summit_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/presentation/screens/boardroom_summit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BoardroomSummitScreen Widget Tests', () {
    testWidgets('renders capital injections, VIP boxes, and boardroom motions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BoardroomSummitScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BAŞKANLIK ZİRVESİ & SERMAYE ARTIRIMI'), findsOneWidget);
      expect(find.text('BAŞKANLIK ŞAHSİ SERMAYE ENJEKSİYONU & HİBE'), findsOneWidget);
      expect(find.text('SEZONLUK VIP PROTOKOL LOCA KİRALAMA BORSASI'), findsOneWidget);
      expect(find.text('DİVAN KURULU VE YÖNETİM OYLAMALARI'), findsOneWidget);
      expect(find.text('SERMAYE AKTAR'), findsWidgets);
      expect(find.text('KİRALA (SAT)'), findsWidgets);
    });
  });
}
