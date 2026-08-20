// domain/entities/achievement.dart
// Pure Dart. Achievements and Dynasty Scoring based on §13.3, §14.4 and Ek C.5 / Ek E.

import 'facility.dart';
import 'game_state.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int dynastyPoints;
  final int xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.dynastyPoints = 25,
    this.xpReward = 150,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'dynastyPoints': dynastyPoints,
        'xpReward': xpReward,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? '🏆',
      dynastyPoints: json['dynastyPoints'] as int? ?? 25,
      xpReward: json['xpReward'] as int? ?? 150,
    );
  }
}

class AchievementCatalog {
  static const List<Achievement> allAchievements = [
    Achievement(
      id: 'ach_first_win',
      title: 'İlk Zafer',
      description: 'Resmi bir lig maçında ilk galibiyetini al.',
      icon: '⚽',
      dynastyPoints: 10,
      xpReward: 50,
    ),
    Achievement(
      id: 'ach_first_promotion',
      title: 'İlk Terfi',
      description: 'Bulunduğun ligden bir üst lige yüksel.',
      icon: '🚀',
      dynastyPoints: 40,
      xpReward: 300,
    ),
    Achievement(
      id: 'ach_stadium_expanded',
      title: 'Kendi Mabedimiz',
      description: 'Stadyum tesisini 3. seviyeye yükselt.',
      icon: '🏟️',
      dynastyPoints: 20,
      xpReward: 150,
    ),
    Achievement(
      id: 'ach_youth_debut',
      title: 'Akademi Gururu',
      description: 'Altyapıdan yetişen bir oyuncuyu ilk 11\'de sahaya sür.',
      icon: '🌱',
      dynastyPoints: 15,
      xpReward: 100,
    ),
    Achievement(
      id: 'ach_clean_sheet_streak',
      title: 'Çelik Duvar',
      description: 'Üst üste 3 lig maçında kalesinde gol görme.',
      icon: '🛡️',
      dynastyPoints: 30,
      xpReward: 200,
    ),
    Achievement(
      id: 'ach_millionaire_club',
      title: 'Kulüp Zengini',
      description: 'Kulüp kasasında ₣1.000.000 nakit biriktir.',
      icon: '💰',
      dynastyPoints: 50,
      xpReward: 400,
    ),
    Achievement(
      id: 'ach_tactical_mastermind',
      title: 'Taktik Ustası',
      description: 'Menajer seviyesinde 5. seviyeye ulaş.',
      icon: '🧠',
      dynastyPoints: 35,
      xpReward: 250,
    ),
    Achievement(
      id: 'ach_undefeated_champion',
      title: 'Yenilmez Armada',
      description: 'Bir sezon boyunca hiç mağlubiyet almadan şampiyon ol.',
      icon: '👑',
      dynastyPoints: 100,
      xpReward: 1000,
    ),
    Achievement(
      id: 'ach_super_league_top',
      title: 'Zirvedeki Hanedan',
      description: '1. Lig / Süper Lig şampiyonluğuna ulaş.',
      icon: '🏆',
      dynastyPoints: 200,
      xpReward: 2000,
    ),
    Achievement(
      id: 'ach_transfer_master',
      title: 'Pazarlık Dehası',
      description: 'Pazarlıkta istenen fiyatın %30 altına bir transfer tamamla.',
      icon: '💼',
      dynastyPoints: 25,
      xpReward: 150,
    ),
    Achievement(
      id: 'ach_fan_favorite',
      title: 'Halkın Sevgilisi',
      description: 'Taraftar memnuniyet göstergesini 95 ve üzerine çıkar.',
      icon: '📢',
      dynastyPoints: 30,
      xpReward: 200,
    ),
    Achievement(
      id: 'ach_dynasty_legend',
      title: 'Ölümsüz Menajer',
      description: 'Aynı kulüpte 10 sezon boyunca görev yap.',
      icon: '⭐',
      dynastyPoints: 150,
      xpReward: 1500,
    ),
  ];
}

class AchievementEvaluator {
  /// Başarımları Değerlendirir
  static List<Achievement> evaluateAchievements({
    required GameState state,
    required Set<String> previouslyUnlockedIds,
  }) {
    final newUnlocked = <Achievement>[];

    void check(String id, bool condition) {
      if (condition && !previouslyUnlockedIds.contains(id)) {
        final ach = AchievementCatalog.allAchievements.firstWhere((a) => a.id == id);
        newUnlocked.add(ach);
      }
    }

    // 1. Terfi Kontrolü
    check('ach_first_promotion', state.currentLeague.tier < 20);

    // 2. Kasa Zenginliği
    check('ach_millionaire_club', state.userClub.meters.cash >= 1000000);

    // 3. Stadyum
    check('ach_stadium_expanded', state.userClub.getFacilityLevel(FacilityType.stadium) >= 3);

    // 4. Taraftar
    check('ach_fan_favorite', state.userClub.meters.fans >= 95);

    // 5. Menajer Seviyesi
    check('ach_tactical_mastermind', state.manager.level >= 5);

    // 6. Altyapı İlk 11
    check('ach_youth_debut', state.userClub.starting11.any((p) => p.isYouthProduct));

    return newUnlocked;
  }

  /// Hanedan Puanı Formülü (Ek C.5)
  /// HanedanPuanı = ligBonusu + kupa*40 + sezon*8 + efsane*25 + maksDeğer/500000
  static int calculateDynastyScore({
    required int leagueTier,
    required int trophiesWon,
    required int seasonsPlayed,
    required int legendPlayersCount,
    required int maxSquadValue,
  }) {
    final leagueBonus = (21 - leagueTier).clamp(1, 20) * 10;
    final trophyScore = trophiesWon * 40;
    final seasonScore = seasonsPlayed * 8;
    final legendScore = legendPlayersCount * 25;
    final squadScore = (maxSquadValue / 500000).floor();

    return leagueBonus + trophyScore + seasonScore + legendScore + squadScore;
  }
}
