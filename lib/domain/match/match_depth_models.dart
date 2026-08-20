// domain/match/match_depth_models.dart
// Match XP distribution, MOTM calculations, and League Leaderboards (§11.4, §12)

class MatchXpDistributor {
  static int calculateXpForRating(double rating, {bool isMotm = false}) {
    int baseXp = 10;
    if (rating >= 8.5) {
      baseXp = 30;
    } else if (rating >= 7.5) {
      baseXp = 22;
    } else if (rating >= 6.5) {
      baseXp = 15;
    } else if (rating >= 5.5) {
      baseXp = 8;
    } else {
      baseXp = 4;
    }

    if (isMotm) {
      baseXp += 15; // MOTM Bonusu
    }

    return baseXp;
  }
}

class ScorerEntry {
  final String playerId;
  final String playerName;
  final String clubName;
  int goals;
  int assists;

  ScorerEntry({
    required this.playerId,
    required this.playerName,
    required this.clubName,
    this.goals = 0,
    this.assists = 0,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerName': playerName,
        'clubName': clubName,
        'goals': goals,
        'assists': assists,
      };

  factory ScorerEntry.fromJson(Map<String, dynamic> json) => ScorerEntry(
        playerId: json['playerId'] as String,
        playerName: json['playerName'] as String,
        clubName: json['clubName'] as String,
        goals: json['goals'] as int? ?? 0,
        assists: json['assists'] as int? ?? 0,
      );
}

class LeagueStatsLeaderboard {
  final Map<String, ScorerEntry> _scorers = {};

  LeagueStatsLeaderboard();

  void recordGoal(String playerId, String playerName, String clubName, int count) {
    if (!_scorers.containsKey(playerId)) {
      _scorers[playerId] = ScorerEntry(
        playerId: playerId,
        playerName: playerName,
        clubName: clubName,
      );
    }
    _scorers[playerId]!.goals += count;
  }

  void recordAssist(String playerId, String playerName, String clubName, int count) {
    if (!_scorers.containsKey(playerId)) {
      _scorers[playerId] = ScorerEntry(
        playerId: playerId,
        playerName: playerName,
        clubName: clubName,
      );
    }
    _scorers[playerId]!.assists += count;
  }

  List<ScorerEntry> getTopScorers() {
    final list = _scorers.values.toList();
    list.sort((a, b) => b.goals.compareTo(a.goals));
    return list;
  }

  List<ScorerEntry> getTopAssists() {
    final list = _scorers.values.toList();
    list.sort((a, b) => b.assists.compareTo(a.assists));
    return list;
  }
}

class PlayerMatchSummary {
  final String playerId;
  final String playerName;
  final String position;
  final double rating;
  final int goals;
  final int assists;
  final int xpEarned;
  final dynamic faceSeed;

  const PlayerMatchSummary({
    required this.playerId,
    required this.playerName,
    required this.position,
    required this.rating,
    this.goals = 0,
    this.assists = 0,
    this.xpEarned = 10,
    this.faceSeed = 1,
  });
}
