// domain/entities/league.dart
// Pure Dart. League pyramid (Tier 1-20), fixtures, standings table and promotion/relegation rules.

class LeagueTableEntry {
  final String clubId;
  final String clubName;
  final String badgeIcon;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  const LeagueTableEntry({
    required this.clubId,
    required this.clubName,
    this.badgeIcon = 'SHIELD',
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
  });

  int get goalDifference => goalsFor - goalsAgainst;

  LeagueTableEntry recordMatch({
    required int goalsScored,
    required int goalsConceded,
  }) {
    final newWon = goalsScored > goalsConceded ? won + 1 : won;
    final newDrawn = goalsScored == goalsConceded ? drawn + 1 : drawn;
    final newLost = goalsScored < goalsConceded ? lost + 1 : lost;
    final newPoints = goalsScored > goalsConceded
        ? points + 3
        : (goalsScored == goalsConceded ? points + 1 : points);

    return LeagueTableEntry(
      clubId: clubId,
      clubName: clubName,
      badgeIcon: badgeIcon,
      played: played + 1,
      won: newWon,
      drawn: newDrawn,
      lost: newLost,
      goalsFor: goalsFor + goalsScored,
      goalsAgainst: goalsAgainst + goalsConceded,
      points: newPoints,
    );
  }

  Map<String, dynamic> toJson() => {
        'clubId': clubId,
        'clubName': clubName,
        'badgeIcon': badgeIcon,
        'played': played,
        'won': won,
        'drawn': drawn,
        'lost': lost,
        'goalsFor': goalsFor,
        'goalsAgainst': goalsAgainst,
        'points': points,
      };

  factory LeagueTableEntry.fromJson(Map<String, dynamic> json) => LeagueTableEntry(
        clubId: json['clubId'] as String,
        clubName: json['clubName'] as String,
        badgeIcon: json['badgeIcon'] as String? ?? 'SHIELD',
        played: json['played'] as int? ?? 0,
        won: json['won'] as int? ?? 0,
        drawn: json['drawn'] as int? ?? 0,
        lost: json['lost'] as int? ?? 0,
        goalsFor: json['goalsFor'] as int? ?? 0,
        goalsAgainst: json['goalsAgainst'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
      );
}

class Fixture {
  final String id;
  final int seasonNumber;
  final int matchday; // 1 to 21
  final String homeClubId;
  final String awayClubId;
  final String homeClubName;
  final String awayClubName;
  final int? homeScore;
  final int? awayScore;
  final bool isPlayed;

  const Fixture({
    required this.id,
    required this.seasonNumber,
    required this.matchday,
    required this.homeClubId,
    required this.awayClubId,
    this.homeClubName = 'Ev Sahibi',
    this.awayClubName = 'Deplasman',
    this.homeScore,
    this.awayScore,
    this.isPlayed = false,
  });

  Fixture copyWith({
    String? homeClubName,
    String? awayClubName,
    int? homeScore,
    int? awayScore,
    bool? isPlayed,
  }) {
    return Fixture(
      id: id,
      seasonNumber: seasonNumber,
      matchday: matchday,
      homeClubId: homeClubId,
      awayClubId: awayClubId,
      homeClubName: homeClubName ?? this.homeClubName,
      awayClubName: awayClubName ?? this.awayClubName,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      isPlayed: isPlayed ?? this.isPlayed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seasonNumber': seasonNumber,
        'matchday': matchday,
        'homeClubId': homeClubId,
        'awayClubId': awayClubId,
        'homeClubName': homeClubName,
        'awayClubName': awayClubName,
        'homeScore': homeScore,
        'awayScore': awayScore,
        'isPlayed': isPlayed,
      };

  factory Fixture.fromJson(Map<String, dynamic> json) => Fixture(
        id: json['id'] as String,
        seasonNumber: json['seasonNumber'] as int,
        matchday: json['matchday'] as int,
        homeClubId: json['homeClubId'] as String,
        awayClubId: json['awayClubId'] as String,
        homeClubName: json['homeClubName'] as String? ?? 'Ev Sahibi',
        awayClubName: json['awayClubName'] as String? ?? 'Deplasman',
        homeScore: json['homeScore'] as int?,
        awayScore: json['awayScore'] as int?,
        isPlayed: json['isPlayed'] as bool? ?? false,
      );
}

class League {
  final int tier; // 1 (Elit Lig) to 20 (Amatör Küme)
  final String name;
  final List<String> clubIds;
  final List<Fixture> fixtures;
  final List<LeagueTableEntry> standings;

  const League({
    required this.tier,
    required this.name,
    this.clubIds = const [],
    this.fixtures = const [],
    this.standings = const [],
  });

  /// Sıralamayı puan, averaj ve atılan gole göre sıralar
  List<LeagueTableEntry> get sortedStandings {
    final list = List<LeagueTableEntry>.from(standings);
    list.sort((a, b) {
      if (b.points != a.points) return b.points.compareTo(a.points);
      if (b.goalDifference != a.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      return b.goalsFor.compareTo(a.goalsFor);
    });
    return list;
  }

  /// Kullanıcı kulübünün sırası (1-indexed)
  int getRankOfClub(String clubId) {
    final list = sortedStandings;
    for (var i = 0; i < list.length; i++) {
      if (list[i].clubId == clubId) return i + 1;
    }
    return list.length;
  }

  /// Belirtilen kulüp ID'sine ait puan tablosu girdisi
  LeagueTableEntry? getEntry(String clubId) {
    for (final s in standings) {
      if (s.clubId == clubId) return s;
    }
    return null;
  }

  /// Belirtilen kulübün adı
  String getClubName(String clubId) {
    return getEntry(clubId)?.clubName ?? 'Rakip Kulüp';
  }

  /// Belirtilen kulübün arma ikonu
  String getClubBadge(String clubId) {
    return getEntry(clubId)?.badgeIcon ?? 'SHIELD';
  }

  League copyWith({
    int? tier,
    String? name,
    List<String>? clubIds,
    List<Fixture>? fixtures,
    List<LeagueTableEntry>? standings,
  }) {
    return League(
      tier: tier ?? this.tier,
      name: name ?? this.name,
      clubIds: clubIds ?? this.clubIds,
      fixtures: fixtures ?? this.fixtures,
      standings: standings ?? this.standings,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier': tier,
        'name': name,
        'clubIds': clubIds,
        'fixtures': fixtures.map((f) => f.toJson()).toList(),
        'standings': standings.map((s) => s.toJson()).toList(),
      };

  factory League.fromJson(Map<String, dynamic> json) => League(
        tier: json['tier'] as int,
        name: json['name'] as String,
        clubIds: (json['clubIds'] as List<dynamic>).map((e) => e as String).toList(),
        fixtures: (json['fixtures'] as List<dynamic>?)
                ?.map((f) => Fixture.fromJson(f as Map<String, dynamic>))
                .toList() ??
            const [],
        standings: (json['standings'] as List<dynamic>?)
                ?.map((s) => LeagueTableEntry.fromJson(s as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
