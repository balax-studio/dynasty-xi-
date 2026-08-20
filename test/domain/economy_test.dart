// test/domain/economy_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/rng/deterministic_rng.dart';
import 'package:futbol/domain/economy/economy_calculator.dart';
import 'package:futbol/domain/economy/negotiation_model.dart';
import 'package:futbol/domain/entities/club.dart';
import 'package:futbol/domain/entities/facility.dart';
import 'package:futbol/domain/entities/meter.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/generation/player_generator.dart';

void main() {
  group('Economy & Negotiation Tests', () {
    test('EconomyCalculator produces positive ticket revenue and reasonable attendance', () {
      final facMap = <FacilityType, Facility>{
        FacilityType.stadium: const Facility(type: FacilityType.stadium, level: 2),
        FacilityType.fanShop: const Facility(type: FacilityType.fanShop, level: 1),
      };

      final club = Club(
        id: 'c1',
        name: 'Test FC',
        city: 'Angora',
        leagueTier: 20,
        ticketPrice: 10,
        facilities: facMap,
        meters: const ClubMeters(cash: 25000, fans: 50),
      );

      final revenue = EconomyCalculator.calculateMatchDayRevenue(
        club: club,
        leagueRank: 2,
      );

      expect(revenue.attendance, greaterThan(500));
      expect(revenue.attendance, lessThanOrEqualTo(club.stadiumCapacity));
      expect(revenue.ticketRevenue, equals(revenue.attendance * 10));
      expect(revenue.totalRevenue, greaterThan(revenue.ticketRevenue));
    });

    test('Transfer negotiation model accepts fair offers and rejects extreme lowballs', () {
      final rng = DeterministicRng(123);
      final player = PlayerGenerator.generatePlayer(
        rng: rng,
        position: Position.st,
        targetOvr: 60,
      );

      final negotiation = NegotiationState.start(player: player);

      expect(negotiation.askingFee, greaterThan(0));
      expect(negotiation.currentPatience, equals(100));

      // Low-ball offer
      final lowResult = negotiation.submitOffer(
        offeredFee: (negotiation.askingFee * 0.3).round(),
        offeredWage: (negotiation.askingWage * 0.3).round(),
      );

      expect(lowResult.outcome, equals(NegotiationOutcome.counterOffered));
      expect(lowResult.currentPatience, lessThan(100));

      // Fair offer
      final fairResult = negotiation.submitOffer(
        offeredFee: (negotiation.askingFee * 1.05).round(),
        offeredWage: (negotiation.askingWage * 1.05).round(),
      );

      expect(fairResult.outcome, equals(NegotiationOutcome.accepted));
    });
  });
}
