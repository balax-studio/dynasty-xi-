// domain/visuals/face_generator.dart
// Procedural Pixel/Vector Face Generator for Footballers & Managers (§23.1, B.4 faceSeed)

import 'package:flutter/material.dart';
import '../../core/rng/deterministic_rng.dart';

class ProceduralFaceData {
  final int seed;
  final Color skinColor;
  final Color hairColor;
  final Color eyeColor;
  final int hairStyle; // 0..7
  final int beardStyle; // 0..4 (0 = clean shaven)
  final int eyeShape; // 0..3
  final int noseShape; // 0..2
  final int mouthShape; // 0..2
  final int accessory; // 0 = none, 1 = headband, 2 = glasses, 3 = earrings

  const ProceduralFaceData({
    required this.seed,
    required this.skinColor,
    required this.hairColor,
    required this.eyeColor,
    required this.hairStyle,
    required this.beardStyle,
    required this.eyeShape,
    required this.noseShape,
    required this.mouthShape,
    required this.accessory,
  });

  factory ProceduralFaceData.fromSeed(int seed) {
    final rng = DeterministicRng(seed);

    final skinPalette = [
      const Color(0xFFFFDFC4), // Fair
      const Color(0xFFF0D5BE), // Light
      const Color(0xFFEECEB3), // Peach
      const Color(0xFFE1B899), // Olive
      const Color(0xFFCE967C), // Tan
      const Color(0xFF9E6548), // Brown
      const Color(0xFF5C3826), // Dark
    ];

    final hairPalette = [
      const Color(0xFF1C1917), // Black
      const Color(0xFF3E2723), // Dark Brown
      const Color(0xFF5D4037), // Brown
      const Color(0xFFD7CCC8), // Blonde
      const Color(0xFFBCAAA4), // Sandy
      const Color(0xFF8D6E63), // Auburn / Red
      const Color(0xFFECEFF1), // Silver / Grey
    ];

    final eyePalette = [
      const Color(0xFF3E2723), // Brown
      const Color(0xFF1B5E20), // Green
      const Color(0xFF0D47A1), // Blue
      const Color(0xFF263238), // Dark Hazel
    ];

    return ProceduralFaceData(
      seed: seed,
      skinColor: skinPalette[rng.nextInt(skinPalette.length)],
      hairColor: hairPalette[rng.nextInt(hairPalette.length)],
      eyeColor: eyePalette[rng.nextInt(eyePalette.length)],
      hairStyle: rng.nextInt(8),
      beardStyle: rng.nextInt(5),
      eyeShape: rng.nextInt(4),
      noseShape: rng.nextInt(3),
      mouthShape: rng.nextInt(3),
      accessory: rng.nextInt(10) > 7 ? rng.nextInt(4) : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'seed': seed,
    'hairStyle': hairStyle,
    'beardStyle': beardStyle,
    'eyeShape': eyeShape,
    'noseShape': noseShape,
    'mouthShape': mouthShape,
    'accessory': accessory,
  };
}
