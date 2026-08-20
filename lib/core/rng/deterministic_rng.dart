// core/rng/deterministic_rng.dart
// Pure Dart. Platform-independent deterministic RNG compatible with Web (JS/WASM) and Native platforms.

import 'dart:math' as math;

class DeterministicRng {
  final int seed;
  final math.Random _random;

  DeterministicRng(this.seed)
      : _random = math.Random(seed == 0 ? 123456789 : (seed.abs() & 0x7FFFFFFF));

  /// Returns a double in the range [0.0, 1.0)
  double next() => _random.nextDouble();

  /// Returns an integer in range [0, max)
  int nextInt(int max) {
    if (max <= 0) return 0;
    return _random.nextInt(max);
  }

  /// Returns a double in range [min, max]
  double nextDoubleInRange(double min, double max) {
    return min + next() * (max - min);
  }

  /// Returns an integer in range [min, max] (inclusive)
  int nextIntInRange(int min, int max) {
    if (min >= max) return min;
    return min + nextInt(max - min + 1);
  }

  /// Returns true with probability [chance] in range [0.0, 1.0]
  bool chance(double probability) {
    return next() < probability;
  }

  /// Picks a random element from list
  T pick<T>(List<T> items) {
    if (items.isEmpty) {
      throw ArgumentError('Cannot pick from an empty list');
    }
    return items[nextInt(items.length)];
  }

  /// Weighted random pick
  T weightedPick<T>(List<T> items, double Function(T) weightOf) {
    if (items.isEmpty) {
      throw ArgumentError('Cannot pick from an empty list');
    }
    final total = items.fold<double>(0.0, (sum, item) => sum + weightOf(item));
    if (total <= 0) return items.first;

    var r = next() * total;
    for (final item in items) {
      r -= weightOf(item);
      if (r <= 0) return item;
    }
    return items.last;
  }
}
