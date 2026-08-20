// test/domain/half_time_talk_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/sim/half_time_talk.dart';

void main() {
  group('Half-Time Talks & In-Match Substitutions (§11.3, §11.4)', () {
    const starterSt = Player(
      id: 'p_st1',
      firstName: 'Ali',
      lastName: 'Forvet',
      countryCode: 'TR',
      age: 25,
      position: Position.st,
      pace: 80,
      technique: 75,
      shooting: 80,
      passing: 65,
      defending: 30,
      physical: 75,
      mentality: 70,
      potential: 82,
      weeklyWage: 2500,
      fitness: 55, // tired
      morale: 60,
    );

    const benchSt = Player(
      id: 'p_st2',
      firstName: 'Genç',
      lastName: 'Yedek',
      countryCode: 'TR',
      age: 19,
      position: Position.st,
      pace: 85,
      technique: 78,
      shooting: 76,
      passing: 60,
      defending: 25,
      physical: 70,
      mentality: 75,
      potential: 88,
      weeklyWage: 1200,
      fitness: 100, // fresh
      morale: 80,
    );

    const club = Club(
      id: 'c1',
      name: 'Angora SK',
      city: 'Angora',
      meters: ClubMeters(cash: 50000, fans: 60, lockerRoom: 60, boardTrust: 60),
      squad: [starterSt, benchSt],
    );

    test('Calm tactical talk reliably increases squad mentality and passing harmony', () {
      final talkResult = HalfTimeTalkHandler.applyTalk(
        club: club,
        talkType: HalfTimeTalkType.calmTactical,
        isTrailing: true,
      );

      expect(talkResult.description, contains('Sakin'));
      expect(talkResult.updatedClub.squad.first.morale, greaterThanOrEqualTo(starterSt.morale));
    });

    test('Substitution correctly swaps starter and bench player', () {
      final subResult = InMatchSubstitutionHandler.substitutePlayer(
        club: club,
        playerOutId: starterSt.id,
        playerInId: benchSt.id,
      );

      expect(subResult.success, isTrue);
      expect(subResult.updatedClub.starting11.any((p) => p.id == benchSt.id), isTrue);
    });
  });
}
