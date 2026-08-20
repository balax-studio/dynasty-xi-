// domain/sim/half_time_talk.dart
// Pure Dart. Half-Time Motivational Talks and In-Match Player Substitutions (§11.3, §11.4).

import '../entities/club.dart';
import '../entities/player.dart';

enum HalfTimeTalkType {
  harshCriticism(
    'Sert Tepki & Şok',
    'Soyunma odasını inlet: "Bu formanın hakkını verin!" (Yüksek Risk / Yüksek Ödül)',
    '⚡',
  ),
  calmTactical(
    'Sakin & Taktiksel',
    'Tahtaya geç ve taktiksel boşlukları sakin kafayla anlat. (Güvenli +Uyum)',
    '📋',
  ),
  allOutPress(
    'Tam Saha Baskı & Yürek',
    '"Rakibe nefes aldırmayacağız, sahayı dar edin!" (+Baskı Gücü, -Kondisyon)',
    '🔥',
  );

  final String title;
  final String description;
  final String icon;

  const HalfTimeTalkType(this.title, this.description, this.icon);
}

class HalfTimeTalkResult {
  final Club updatedClub;
  final String description;
  final int moraleDelta;
  final int fitnessPenalty;

  const HalfTimeTalkResult({
    required this.updatedClub,
    required this.description,
    required this.moraleDelta,
    this.fitnessPenalty = 0,
  });
}

class HalfTimeTalkHandler {
  /// Devre Arası Konuşması Etkisini Uygular (§11.3)
  static HalfTimeTalkResult applyTalk({
    required Club club,
    required HalfTimeTalkType talkType,
    required bool isTrailing,
  }) {
    final updatedSquad = <Player>[];
    int moraleChange = 0;
    int fitnessCost = 0;
    String feedback = '';

    switch (talkType) {
      case HalfTimeTalkType.harshCriticism:
        if (isTrailing) {
          moraleChange = 12;
          feedback = 'Sert konuşman oyuncuların damarına bastı! İkinci yarıya hırslı çıkıyorlar.';
        } else {
          moraleChange = -4;
          feedback = 'Öndeyken yapılan sert çıkış takımı biraz gerdi.';
        }
        break;

      case HalfTimeTalkType.calmTactical:
        moraleChange = 6;
        feedback = 'Sakin ve net taktik direktifler takımın kafasındaki soru işaretlerini giderdi.';
        break;

      case HalfTimeTalkType.allOutPress:
        moraleChange = 8;
        fitnessCost = 6;
        feedback = 'Takım tam saha pres için kenetlendi! Fiziksel tempo artacak.';
        break;
    }

    for (final player in club.squad) {
      final newMorale = (player.morale + moraleChange).clamp(10, 100);
      final newFitness = (player.fitness - fitnessCost).clamp(10, 100);
      updatedSquad.add(player.copyWith(morale: newMorale, fitness: newFitness));
    }

    final updatedClub = club.copyWith(squad: updatedSquad);

    return HalfTimeTalkResult(
      updatedClub: updatedClub,
      description: feedback,
      moraleDelta: moraleChange,
      fitnessPenalty: fitnessCost,
    );
  }
}

class InMatchSubstitutionResult {
  final Club updatedClub;
  final bool success;
  final String message;

  const InMatchSubstitutionResult({
    required this.updatedClub,
    required this.success,
    required this.message,
  });
}

class InMatchSubstitutionHandler {
  /// Maç İçi Canlı Değişiklik Uygular (§11.4)
  static InMatchSubstitutionResult substitutePlayer({
    required Club club,
    required String playerOutId,
    required String playerInId,
  }) {
    final squad = List<Player>.from(club.squad);
    final outIndex = squad.indexWhere((p) => p.id == playerOutId);
    final inIndex = squad.indexWhere((p) => p.id == playerInId);

    if (outIndex == -1 || inIndex == -1) {
      return InMatchSubstitutionResult(
        updatedClub: club,
        success: false,
        message: 'Oyuncu bulunamadı.',
      );
    }

    // İlk 11 sırasını swap et
    final temp = squad[outIndex];
    squad[outIndex] = squad[inIndex];
    squad[inIndex] = temp;

    final updatedClub = club.copyWith(squad: squad);

    return InMatchSubstitutionResult(
      updatedClub: updatedClub,
      success: true,
      message: '${temp.fullName} çıktı, ${squad[outIndex].fullName} oyuna girdi.',
    );
  }
}
