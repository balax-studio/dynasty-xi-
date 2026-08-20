// test/domain/facility_tiers_and_subpage_test.dart
// Tests for 12 facilities × 5 named tiers, data consistency, and facility detail components.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:futbol/domain/entities/facility.dart';
import 'package:futbol/domain/entities/facility_tiers_data.dart';
import 'package:futbol/presentation/widgets/facility_visual_widget.dart';
import 'package:futbol/presentation/screens/facility_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  group('Facility Named Tiers & Subpage Tests', () {
    test('All 12 facilities have exactly 5 unique, thematic named tiers', () {
      for (final type in FacilityType.values) {
        final tiers = FacilityTiersData.tiers[type];
        expect(tiers, isNotNull, reason: 'FacilityType ${type.name} must have tier data');
        expect(tiers!.length, equals(5), reason: 'FacilityType ${type.name} must have 5 tiers');

        for (int i = 0; i < 5; i++) {
          final tierInfo = tiers[i];
          expect(tierInfo.tier, equals(i + 1));
          expect(tierInfo.name.isNotEmpty, isTrue);
          expect(tierInfo.subtitle.isNotEmpty, isTrue);
          expect(tierInfo.description.isNotEmpty, isTrue);
          expect(tierInfo.perkTitle.isNotEmpty, isTrue);
          expect(tierInfo.perkValue.isNotEmpty, isTrue);
          expect(tierInfo.highlights.isNotEmpty, isTrue);
        }
      }
    });

    test('FacilityTiersData.getTierInfo gracefully handles clamping', () {
      final stadiumT0 = FacilityTiersData.getTierInfo(FacilityType.stadium, 0);
      expect(stadiumT0.tier, equals(1));
      expect(stadiumT0.name, equals('Toprak Mahalle Sahası'));

      final stadiumT5 = FacilityTiersData.getTierInfo(FacilityType.stadium, 5);
      expect(stadiumT5.tier, equals(5));
      expect(stadiumT5.name, contains('Hanedan Megastadı'));

      final stadiumT99 = FacilityTiersData.getTierInfo(FacilityType.stadium, 99);
      expect(stadiumT99.tier, equals(5));
    });

    testWidgets('FacilityVisualWidget renders correctly without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FacilityVisualWidget(
              type: FacilityType.stadium,
              level: 3,
              isUpgrading: false,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FacilityVisualWidget), findsOneWidget);
      expect(find.textContaining('AŞAMA 3/5'), findsOneWidget);
    });

    testWidgets('FacilityVisualWidget renders active construction overlay', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FacilityVisualWidget(
              type: FacilityType.trainingGround,
              level: 2,
              isUpgrading: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FacilityVisualWidget), findsOneWidget);
      expect(find.text('İNŞAAT DEVAM EDİYOR'), findsOneWidget);
    });

    testWidgets('FacilityDetailScreen renders roadmap and facility information', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FacilityDetailScreen(
              facilityType: FacilityType.youthAcademy,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FacilityDetailScreen), findsOneWidget);
      expect(find.textContaining('5 AŞAMALI GELİŞİM'), findsOneWidget);
    });
  });
}
