// domain/generation/scout_service.dart
// Scouting generation with duration tiers, accuracy margins, and hidden wonderkid chance (§10.4)

import 'dart:math' as math;
import '../entities/player.dart';

enum ScoutDurationTier {
  instant('Hızlı Tarama', '45 dk • Yüzeysel yetenek tespiti', 0, 8),
  standard('Kapsamlı Rapor', '3 Saat • Dengeli analiz ve potansiyel aralığı', 3, 5),
  deep('Derin Analiz', '6 Saat • Yüksek doğruluk, gizli cevher şansı', 6, 3);

  final String label;
  final String description;
  final int durationHours;
  final int baseAccuracyMargin;

  const ScoutDurationTier(this.label, this.description, this.durationHours, this.baseAccuracyMargin);
}

class ScoutReport {
  final List<Player> players;
  final String region;
  final int accuracyMargin;
  final bool hasWonderkid;
  final int generatedEpochMs;

  const ScoutReport({
    required this.players,
    required this.region,
    required this.accuracyMargin,
    required this.hasWonderkid,
    required this.generatedEpochMs,
  });
}

class ScoutService {
  static final math.Random _random = math.Random();

  static const List<String> _firstNames = [
    'Arda', 'Semih', 'Can', 'Barış', 'Kenan', 'Ferdi', 'Kerem', 'Orkun', 'Salih', 'Yunus',
    'Lucas', 'Mateo', 'Enzo', 'Gabriel', 'Thiago', 'Kylian', 'Jude', 'Pablo', 'Lamine', 'Endrick'
  ];

  static const List<String> _lastNames = [
    'Yılmaz', 'Kılıç', 'Demir', 'Öztürk', 'Güler', 'Kılıçsoy', 'Uzun', 'Yıldız', 'Çelik', 'Koç',
    'Silva', 'Santos', 'Alvarez', 'Fernandez', 'Gomez', 'Moreno', 'Rossi', 'Müller', 'Schmidt', 'Diallo'
  ];

  static ScoutReport generateScoutReport({
    required String region,
    required ScoutDurationTier tier,
    required int scoutFacilityLevel,
  }) {
    // Facility seviyesi artıkça hata payı daralır
    final accuracyMargin = math.max(1, tier.baseAccuracyMargin - (scoutFacilityLevel ~/ 2));
    final isWonderkidChance = _random.nextDouble() < (tier == ScoutDurationTier.deep ? 0.12 : 0.04);

    final players = <Player>[];
    final count = 3 + _random.nextInt(3); // 3-5 oyuncu

    for (int i = 0; i < count; i++) {
      final isWonderkid = (i == 0 && isWonderkidChance);
      final age = isWonderkid ? 16 + _random.nextInt(3) : 17 + _random.nextInt(8);
      final pos = Position.values[_random.nextInt(Position.values.length)];

      final baseAttr = 50 + scoutFacilityLevel * 4 + _random.nextInt(15);
      final pot = isWonderkid ? (84 + _random.nextInt(12)).clamp(84, 96) : (baseAttr + 5 + _random.nextInt(18)).clamp(55, 88);

      final firstName = _firstNames[_random.nextInt(_firstNames.length)];
      final lastName = _lastNames[_random.nextInt(_lastNames.length)];

      players.add(
        Player(
          id: 'scout_${DateTime.now().millisecondsSinceEpoch}_$i',
          firstName: firstName,
          lastName: lastName,
          countryCode: region.contains('Latin') ? 'BR' : (region.contains('Avrupa') ? 'DE' : 'TR'),
          age: age,
          position: pos,
          pace: (baseAttr + _random.nextInt(15) - 7).clamp(40, 95),
          technique: (baseAttr + _random.nextInt(15) - 7).clamp(40, 95),
          shooting: (baseAttr + _random.nextInt(15) - 7).clamp(40, 95),
          passing: (baseAttr + _random.nextInt(15) - 7).clamp(40, 95),
          defending: (baseAttr + _random.nextInt(15) - 7).clamp(40, 95),
          physical: (baseAttr + _random.nextInt(15) - 7).clamp(40, 95),
          mentality: (baseAttr + _random.nextInt(15) - 7).clamp(40, 95),
          potential: pot,
          personality: PersonalityType.values[_random.nextInt(PersonalityType.values.length)],
          weeklyWage: (500 + (baseAttr * 20)).round(),
          isYouthProduct: true,
        ),
      );
    }

    return ScoutReport(
      players: players,
      region: region,
      accuracyMargin: accuracyMargin,
      hasWonderkid: isWonderkidChance,
      generatedEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
