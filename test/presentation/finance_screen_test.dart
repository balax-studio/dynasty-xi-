// test/presentation/finance_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/presentation/screens/finance_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FinanceScreen renders all 6 cyber-retro financial modules', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FinanceScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. App Bar
    expect(find.text('KULÜP FİNANS & BORSA MERKEZİ'), findsOneWidget);

    // 2. Module 1: Cashflow Ledger
    expect(find.textContaining('HAFTALIK GELİR-GİDER BİLANÇOSU'), findsOneWidget);
    expect(find.text('KULÜP KASASI'), findsOneWidget);
    expect(find.text('HAFTALIK NET AKIŞ'), findsOneWidget);

    // 3. Module 2: FFP Radar
    expect(find.textContaining('FİNANSAL FAIR PLAY (FFP) RADARI'), findsOneWidget);

    // 4. Module 3: Matchday Ticketing Simulator
    expect(find.textContaining('MAÇ GÜNÜ BİLET VE HASILAT SİMÜLATÖRÜ'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    // 5. Module 4: 3-Slot Sponsorship Desk
    expect(find.textContaining('3-SLOT SPONSORLUK MASASI'), findsOneWidget);
    expect(find.textContaining('ANA'), findsWidgets);

    // 6. Module 5: Bank Loans
    expect(find.textContaining('BANKA KREDİLERİ VE BORÇ YÖNETİMİ'), findsOneWidget);

    // 7. Module 6: Treasury Deposit
    expect(find.textContaining('KULÜP HAZİNESİ & VADELİ MEVDUAT'), findsOneWidget);
    expect(find.text('+₣5,000 YATIR'), findsOneWidget);
    expect(find.text('-₣5,000 ÇEK'), findsOneWidget);
  });
}
