// test/domain/training_camp_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/facilities/training_camp.dart';

void main() {
  group('TrainingCampPackage & Mid-Season Camp Tests', () {
    const testClub = Club(
      id: 'club_1',
      name: 'Anadolu Kartalları',
      city: 'Konya',
      meters: ClubMeters(cash: 60000, fans: 50, lockerRoom: 50, boardTrust: 50),
    );

    test('All 3 training camp tiers are configured with realistic costs and bonuses', () {
      final packages = TrainingCampPackage.availablePackages;
      expect(packages.length, 3);

      final local = packages.firstWhere((p) => p.location == CampLocation.localFacility);
      expect(local.cost, 0);
      expect(local.staminaBonus, greaterThan(0));

      final antalya = packages.firstWhere((p) => p.location == CampLocation.antalyaResort);
      expect(antalya.cost, 15000);
      expect(antalya.lockerRoomMoraleBonus, greaterThan(local.lockerRoomMoraleBonus));

      final alps = packages.firstWhere((p) => p.location == CampLocation.alpsEliteHighAltitude);
      expect(alps.cost, 40000);
      expect(alps.tacticalFamiliarityBonus, greaterThanOrEqualTo(2));
    });

    test('executeCamp deducts cost and improves club meters and morale', () {
      final antalya = TrainingCampPackage.availablePackages.firstWhere((p) => p.location == CampLocation.antalyaResort);
      final result = TrainingCampPackage.executeCamp(club: testClub, package: antalya);

      expect(result.updatedClub.meters.cash, testClub.meters.cash - 15000);
      expect(result.updatedClub.meters.lockerRoom, greaterThan(testClub.meters.lockerRoom));
      expect(result.summaryMessage, contains('ANTALYA'));
    });

    test('executeCamp with local facility does not drain club treasury', () {
      final local = TrainingCampPackage.availablePackages.firstWhere((p) => p.location == CampLocation.localFacility);
      final result = TrainingCampPackage.executeCamp(club: testClub, package: local);

      expect(result.updatedClub.meters.cash, testClub.meters.cash);
      expect(result.updatedClub.meters.lockerRoom, greaterThanOrEqualTo(testClub.meters.lockerRoom));
    });
  });
}
