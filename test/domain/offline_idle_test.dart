// test/domain/offline_idle_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/economy/offline_calculator.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/facility.dart';
import 'package:futbol/domain/entities/meter.dart';

void main() {
  group('Offline Idle Earnings & Facility Timers (§6.3, §15, Ek C.6)', () {
    const club = Club(
      id: 'test_c',
      name: 'Angora SK',
      city: 'Angora',
      meters: ClubMeters(cash: 100000, fans: 80, lockerRoom: 70, boardTrust: 75),
      facilities: {
        FacilityType.fanShop: Facility(type: FacilityType.fanShop, level: 3),
        FacilityType.stadium: Facility(type: FacilityType.stadium, level: 2),
        FacilityType.trainingGround: Facility(
          type: FacilityType.trainingGround,
          level: 1,
          isUpgrading: true,
          upgradeFinishEpochMs: 1000, // already in the past
        ),
      },
    );

    test('Offline report calculates passive fan shop income and finishes ready upgrades', () {
      // 4 hours (14400 seconds) elapsed
      const elapsedSeconds = 14400;

      final report = OfflineCalculator.calculateOfflineProgress(
        club: club,
        elapsedSeconds: elapsedSeconds,
        currentEpochMs: 2000,
      );

      expect(report.passiveCashEarned, greaterThan(0));
      expect(report.completedFacilityUpgrades.length, equals(1));
      expect(report.completedFacilityTypeNames, contains('Antrenman Sahası'));
      expect(report.updatedClub.meters.cash, greaterThan(club.meters.cash));

      final training = report.updatedClub.facilities[FacilityType.trainingGround]!;
      expect(training.level, equals(2));
      expect(training.isUpgrading, isFalse);
    });

    test('Elapsed time is clamped to 12 hours (43200s) maximum without VIP perk', () {
      // 48 hours (172800s) elapsed
      const elapsedSeconds = 172800;

      final report = OfflineCalculator.calculateOfflineProgress(
        club: club,
        elapsedSeconds: elapsedSeconds,
        currentEpochMs: 2000,
      );

      expect(report.effectiveHoursClamped, equals(12.0));
    });
  });
}
