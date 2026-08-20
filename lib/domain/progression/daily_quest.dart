// domain/progression/daily_quest.dart
// Daily quest progression system with endowed progress (§17.3, §21.2)

enum QuestTrigger {
  leagueMatch,
  facilityUpgrade,
  cardChoice,
  transfer,
  scouting,
}

class DailyQuest {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int currentCount;
  final int cashReward;
  final int xpReward;
  final bool isClaimed;

  const DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.currentCount,
    required this.cashReward,
    required this.xpReward,
    this.isClaimed = false,
  });

  bool get isCompleted => currentCount >= targetCount;
  bool get canClaim => isCompleted && !isClaimed;
  double get progressRatio => (currentCount / targetCount).clamp(0.0, 1.0);

  DailyQuest copyWith({
    String? id,
    String? title,
    String? description,
    int? targetCount,
    int? currentCount,
    int? cashReward,
    int? xpReward,
    bool? isClaimed,
  }) {
    return DailyQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      cashReward: cashReward ?? this.cashReward,
      xpReward: xpReward ?? this.xpReward,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'cashReward': cashReward,
        'xpReward': xpReward,
        'isClaimed': isClaimed,
      };

  factory DailyQuest.fromJson(Map<String, dynamic> json) => DailyQuest(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        targetCount: json['targetCount'] as int,
        currentCount: json['currentCount'] as int,
        cashReward: json['cashReward'] as int,
        xpReward: json['xpReward'] as int,
        isClaimed: json['isClaimed'] as bool? ?? false,
      );
}

class DailyQuestManager {
  static List<DailyQuest> generateDailyQuests() {
    return const [
      // 1. Görev — Endowed Progress (§7.2, §17.3)
      DailyQuest(
        id: 'q_tactics_check',
        title: 'Taktik ve Kadro Hazırlığı',
        description: 'Kadro ekranını aç ve takım dizilişini kontrol et.',
        targetCount: 1,
        currentCount: 1, // Endowed progress
        cashReward: 2000,
        xpReward: 35,
      ),
      // 2. Görev — Aktif Maç Oynama
      DailyQuest(
        id: 'q_play_league_match',
        title: 'Lig Arenasına Çık',
        description: '1 resmi lig maçını yönet ve tamamla.',
        targetCount: 1,
        currentCount: 0,
        cashReward: 5000,
        xpReward: 75,
      ),
      // 3. Görev — Tesis / Karar / Gelişim
      DailyQuest(
        id: 'q_club_development',
        title: 'Kulüp Yatırımı & Gelişim',
        description: 'Bir tesis inşaatı başlat veya 2 karar kartı yanıtla.',
        targetCount: 2,
        currentCount: 0,
        cashReward: 4000,
        xpReward: 60,
      ),
    ];
  }

  /// Advances quests based on user in-game trigger (§17.3).
  static List<DailyQuest> advanceQuest(
    List<DailyQuest> currentQuests,
    QuestTrigger trigger, {
    int amount = 1,
  }) {
    return currentQuests.map((q) {
      if (trigger == QuestTrigger.leagueMatch && q.id == 'q_play_league_match') {
        return q.copyWith(currentCount: q.currentCount + amount);
      }
      if ((trigger == QuestTrigger.facilityUpgrade || trigger == QuestTrigger.cardChoice) &&
          q.id == 'q_club_development') {
        return q.copyWith(currentCount: q.currentCount + amount);
      }
      return q;
    }).toList();
  }
}
