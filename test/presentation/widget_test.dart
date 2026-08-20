import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/main.dart';
import 'package:futbol/presentation/widgets/meters_bar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:futbol/presentation/widgets/retro_pixel_icon.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MetersBarWidget displays Cash, Fans, Locker Room and Board Trust', (tester) async {
    const meters = ClubMeters(
      cash: 25000,
      fans: 65,
      lockerRoom: 70,
      boardTrust: 80,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetersBarWidget(meters: meters),
        ),
      ),
    );

    expect(find.text('KASA'), findsOneWidget);
    expect(find.text('₣25.0K'), findsOneWidget);
    expect(find.text('FAN'), findsOneWidget);
    expect(find.text('%65'), findsOneWidget);
    expect(find.text('MORAL'), findsOneWidget);
    expect(find.text('%70'), findsOneWidget);
    expect(find.text('GÜVEN'), findsOneWidget);
    expect(find.text('%80'), findsOneWidget);
    expect(find.byType(RetroPixelIcon), findsNWidgets(4));
  });

  testWidgets('App renders correctly with ProviderScope and displays FTUE on fresh launch', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DynastyXIApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('DYNASTY XI'), findsOneWidget);
    expect(find.textContaining('KULÜBÜN BAŞINA GEÇ'), findsOneWidget);
  });
}
