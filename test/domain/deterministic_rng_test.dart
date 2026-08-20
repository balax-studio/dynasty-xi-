// test/domain/deterministic_rng_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/core/rng/deterministic_rng.dart';

void main() {
  group('DeterministicRng Tests', () {
    test('Same seed produces identical sequence', () {
      final rng1 = DeterministicRng(12345);
      final rng2 = DeterministicRng(12345);

      for (var i = 0; i < 100; i++) {
        expect(rng1.next(), equals(rng2.next()));
      }
    });

    test('Different seed produces distinct sequence', () {
      final rng1 = DeterministicRng(111);
      final rng2 = DeterministicRng(222);

      var matches = 0;
      for (var i = 0; i < 50; i++) {
        if (rng1.next() == rng2.next()) matches++;
      }
      expect(matches, lessThan(5));
    });

    test('Weighted pick obeys distribution', () {
      final rng = DeterministicRng(999);
      final items = ['rare', 'common'];
      var rareCount = 0;

      for (var i = 0; i < 1000; i++) {
        final pick = rng.weightedPick<String>(items, (item) => item == 'rare' ? 1.0 : 9.0);
        if (pick == 'rare') rareCount++;
      }

      // Expected ~10% (100)
      expect(rareCount, inInclusiveRange(60, 150));
    });
  });
}
