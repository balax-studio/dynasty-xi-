// domain/pvp/async_pvp_league.dart
// Asynchronous PvP League Leaderboard (30-Club Divisions, Weekly Promotion/Relegation) (§14.6)

import '../../core/rng/deterministic_rng.dart';

enum PvPTier {
  bronze('Bronz Lig', 1, 10000, 100),
  silver('Gümüş Lig', 2, 25000, 250),
  gold('Altın Lig', 3, 50000, 500),
  master('Elit Hanedan Ligi', 4, 150000, 1500);

  final String title;
  final int tierLevel;
  final int cashReward;
  final int dynastyPointsReward;

  const PvPTier(this.title, this.tierLevel, this.cashReward, this.dynastyPointsReward);
}

class PvPLeaderboardEntry {
  final int rank;
  final String clubName;
  final String managerName;
  final String badge;
  final int ratingOvr;
  final int points;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final bool isUser;

  const PvPLeaderboardEntry({
    required this.rank,
    required this.clubName,
    required this.managerName,
    required this.badge,
    required this.ratingOvr,
    required this.points,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    this.isUser = false,
  });

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'clubName': clubName,
    'managerName': managerName,
    'badge': badge,
    'ratingOvr': ratingOvr,
    'points': points,
    'played': played,
    'won': won,
    'drawn': drawn,
    'lost': lost,
    'isUser': isUser,
  };

  factory PvPLeaderboardEntry.fromJson(Map<String, dynamic> json) => PvPLeaderboardEntry(
    rank: json['rank'] as int,
    clubName: json['clubName'] as String,
    managerName: json['managerName'] as String,
    badge: json['badge'] as String,
    ratingOvr: json['ratingOvr'] as int,
    points: json['points'] as int,
    played: json['played'] as int,
    won: json['won'] as int,
    drawn: json['drawn'] as int,
    lost: json['lost'] as int,
    isUser: json['isUser'] as bool? ?? false,
  );
}

class AsyncPvPDivision {
  final PvPTier tier;
  final int divisionId;
  final int remainingDays;
  final List<PvPLeaderboardEntry> leaderboard;

  const AsyncPvPDivision({
    this.tier = PvPTier.bronze,
    this.divisionId = 104,
    this.remainingDays = 3,
    this.leaderboard = const [],
  });

  factory AsyncPvPDivision.generateDivision({
    required String userClubName,
    required String userManagerName,
    required String userBadge,
    required int userOvr,
    PvPTier tier = PvPTier.bronze,
    int userPoints = 18,
    int seed = 77,
  }) {
    final rng = DeterministicRng(seed);
    final botNames = [
      ('İstanbul United', 'Ahmet Y.', '🦅', 72),
      ('Ankara Gücü 95', 'Mehmet K.', '⚔️', 71),
      ('İzmir Ege FK', 'Caner B.', '⚓', 73),
      ('Bursa Yıldız', 'Emre T.', '🐊', 70),
      ('Trabzon Karadeniz', 'Oğuzhan D.', '🌊', 74),
      ('Antalya Sahil', 'Burak S.', '☀️', 69),
      ('Adana Demir SK', 'Hasan C.', '🚂', 72),
      ('Konya Kartallar', 'Mustafa A.', '🌲', 68),
      ('Eskişehir Kırmızı', 'Alper G.', '⚡', 71),
      ('Göztepe Rüzgar', 'Kaan V.', '🔥', 70),
    ];

    final entries = <PvPLeaderboardEntry>[];

    // Add user entry
    entries.add(PvPLeaderboardEntry(
      rank: 1,
      clubName: userClubName,
      managerName: userManagerName,
      badge: userBadge,
      ratingOvr: userOvr,
      points: userPoints,
      played: 8,
      won: (userPoints / 3).floor(),
      drawn: userPoints % 3,
      lost: 8 - (userPoints / 3).floor() - (userPoints % 3),
      isUser: true,
    ));

    for (int i = 0; i < botNames.length; i++) {
      final b = botNames[i];
      final pts = 6 + rng.nextInt(18);
      final played = 8;
      final won = (pts / 3).floor().clamp(0, played);
      final drawn = (pts - won * 3).clamp(0, played - won);
      final lost = played - won - drawn;

      entries.add(PvPLeaderboardEntry(
        rank: i + 2,
        clubName: b.$1,
        managerName: b.$2,
        badge: b.$3,
        ratingOvr: b.$4,
        points: pts,
        played: played,
        won: won,
        drawn: drawn,
        lost: lost,
        isUser: false,
      ));
    }

    // Sort by points descending
    entries.sort((a, b) => b.points.compareTo(a.points));

    // Reassign ranks
    final ranked = <PvPLeaderboardEntry>[];
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      ranked.add(PvPLeaderboardEntry(
        rank: i + 1,
        clubName: e.clubName,
        managerName: e.managerName,
        badge: e.badge,
        ratingOvr: e.ratingOvr,
        points: e.points,
        played: e.played,
        won: e.won,
        drawn: e.drawn,
        lost: e.lost,
        isUser: e.isUser,
      ));
    }

    return AsyncPvPDivision(
      tier: tier,
      divisionId: 104,
      remainingDays: 3,
      leaderboard: ranked,
    );
  }

  Map<String, dynamic> toJson() => {
    'tier': tier.index,
    'divisionId': divisionId,
    'remainingDays': remainingDays,
    'leaderboard': leaderboard.map((e) => e.toJson()).toList(),
  };

  factory AsyncPvPDivision.fromJson(Map<String, dynamic> json) => AsyncPvPDivision(
    tier: PvPTier.values[json['tier'] as int? ?? 0],
    divisionId: json['divisionId'] as int? ?? 104,
    remainingDays: json['remainingDays'] as int? ?? 3,
    leaderboard: (json['leaderboard'] as List<dynamic>?)
            ?.map((e) => PvPLeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
