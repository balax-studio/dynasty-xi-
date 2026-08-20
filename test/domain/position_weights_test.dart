// test/domain/position_weights_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/entities/position_weights.dart';

void main() {
  group('Position Weights & Valuation Matrix (§9.2, §9.9, §9.10)', () {
    test('Criterion #11: All position weight sums must equal exactly 1.00', () {
      for (final entry in kPositionWeights.entries) {
        final pos = entry.key;
        final weights = entry.value;
        final sum = weights.sum;
        expect(
          (sum * 100).round() / 100.0,
          equals(1.00),
          reason: 'Position ${pos.name} weight sum must be 1.00',
        );
      }
    });

    test('Criterion #10: Player market valuation formula adheres to §9.9', () {
      const player = Player(
        id: 'test_p1',
        firstName: 'Semih',
        lastName: 'Kılıçsoy',
        countryCode: 'TR',
        age: 19,
        position: Position.st,
        pace: 75,
        technique: 70,
        shooting: 78,
        passing: 60,
        defending: 35,
        physical: 72,
        mentality: 65,
        potential: 85,
        weeklyWage: 2500,
        contractSeasonsLeft: 3,
        form: 7.0,
      );

      final valTier20 = player.marketValueIn(20);
      expect(valTier20, greaterThan(10000));
      expect(valTier20, lessThan(250000000));

      final valTier1 = player.marketValueIn(1);
      expect(valTier1, greaterThan(valTier20), reason: 'Higher tier league increases market valuation');
    });

    test('Expected weekly wage and underpaid check follow §9.10', () {
      const player = Player(
        id: 'test_p2',
        firstName: 'Kerem',
        lastName: 'Aktürkoğlu',
        countryCode: 'TR',
        age: 25,
        position: Position.lw,
        pace: 85,
        technique: 80,
        shooting: 75,
        passing: 74,
        defending: 40,
        physical: 70,
        mentality: 75,
        potential: 84,
        weeklyWage: 500, // very low wage
        contractSeasonsLeft: 2,
      );

      final expected = player.expectedWeeklyWage(10);
      expect(expected, greaterThan(1000));
      expect(player.isUnderpaid(10), isTrue);
    });
  });
}
