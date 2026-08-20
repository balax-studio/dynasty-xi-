// domain/progression/player_natural_summary.dart
// Procedural natural language summary generator for players (§21.4)

import '../entities/player.dart';

class PlayerNaturalSummary {
  static String generateSummary(Player player) {
    final sentences = <String>[];

    // Form & Morale
    if (player.form >= 80) {
      sentences.add('Son maçlarda alev almış durumda, formu zirvede.');
    } else if (player.form <= 45) {
      sentences.add('Özgüven kaybı yaşıyor, acil toparlanmaya ihtiyacı var.');
    }

    // Role & Personality
    if (player.personality == PersonalityType.leader) {
      sentences.add('Soyunma odasının doğal lideri ve gençlerin akıl hocası.');
    } else if (player.personality == PersonalityType.ego) {
      sentences.add('Yüksek yetenekli ancak ilgi ve ilk 11 garantisi bekliyor.');
    } else if (player.personality == PersonalityType.rebel) {
      sentences.add('Taktik disiplinsizliğe meyilli; sert uyarılara tepki verebilir.');
    } else if (player.personality == PersonalityType.loyal) {
      sentences.add('Kulübe son derece bağlı, transfer tekliflerini geri çeviriyor.');
    }

    // Fitness & Injury
    if (player.isInjured) {
      sentences.add('Şu an ${player.injuryDetail?.type.title ?? "sakatlık"} sebebiyle tedavi altında.');
    } else if (player.fitness < 60) {
      sentences.add('Fiziksel olarak yorgun; rotasyonda dinlendirilmesi önerilir.');
    } else {
      sentences.add('Fiziksel durumu %100 hazır.');
    }

    if (sentences.isEmpty) {
      sentences.add('Kadroda dengeli ve istikrarlı bir performans sergiliyor.');
    }

    return sentences.join(' ');
  }
}
