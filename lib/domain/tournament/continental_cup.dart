// domain/tournament/continental_cup.dart
// European Continental Championship Cup for Top League Finishers (§14.5)

import '../entities/club.dart';
import '../../core/rng/deterministic_rng.dart';

class ContinentalMatch {
  final String id;
  final String stage; // 'Grup A', 'Grup B', 'Yarı Final', 'Final'
  final String homeClubName;
  final String homeCountry;
  final String homeBadge;
  final String awayClubName;
  final String awayCountry;
  final String awayBadge;
  final bool isPlayed;
  final int homeScore;
  final int awayScore;
  final String? winnerName;

  const ContinentalMatch({
    required this.id,
    required this.stage,
    required this.homeClubName,
    required this.homeCountry,
    required this.homeBadge,
    required this.awayClubName,
    required this.awayCountry,
    required this.awayBadge,
    this.isPlayed = false,
    this.homeScore = 0,
    this.awayScore = 0,
    this.winnerName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'stage': stage,
    'homeClubName': homeClubName,
    'homeCountry': homeCountry,
    'homeBadge': homeBadge,
    'awayClubName': awayClubName,
    'awayCountry': awayCountry,
    'awayBadge': awayBadge,
    'isPlayed': isPlayed,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'winnerName': winnerName,
  };

  factory ContinentalMatch.fromJson(Map<String, dynamic> json) => ContinentalMatch(
    id: json['id'] as String,
    stage: json['stage'] as String,
    homeClubName: json['homeClubName'] as String,
    homeCountry: json['homeCountry'] as String,
    homeBadge: json['homeBadge'] as String,
    awayClubName: json['awayClubName'] as String,
    awayCountry: json['awayCountry'] as String,
    awayBadge: json['awayBadge'] as String,
    isPlayed: json['isPlayed'] as bool? ?? false,
    homeScore: json['homeScore'] as int? ?? 0,
    awayScore: json['awayScore'] as int? ?? 0,
    winnerName: json['winnerName'] as String?,
  );
}

class ContinentalCup {
  final String title;
  final bool isUnlocked;
  final int seasonNumber;
  final List<ContinentalMatch> fixtures;
  final int prizeMoney;

  const ContinentalCup({
    this.title = 'Avrupa Hanedan Şampiyonlar Kupası',
    this.isUnlocked = false,
    this.seasonNumber = 1,
    this.fixtures = const [],
    this.prizeMoney = 250000,
  });

  factory ContinentalCup.generateTournament({
    required String userClubName,
    required String userBadge,
    int season = 1,
  }) {
    final europeanGiants = [
      {'name': 'Real Madrid FC', 'country': 'İspanya', 'badge': '👑'},
      {'name': 'Bayern München', 'country': 'Almanya', 'badge': '🔴'},
      {'name': 'Manchester Blue', 'country': 'İngiltere', 'badge': '🌊'},
      {'name': 'Paris Saint', 'country': 'Fransa', 'badge': '🗼'},
      {'name': 'Inter Milan', 'country': 'İtalya', 'badge': '🐍'},
      {'name': 'Ajax Amsterdam', 'country': 'Hollanda', 'badge': '⚪'},
      {'name': 'Benfica Lisbon', 'country': 'Portekiz', 'badge': '🦅'},
    ];

    final matches = <ContinentalMatch>[
      ContinentalMatch(
        id: 'cont_1',
        stage: 'Grup 1. Maç',
        homeClubName: userClubName,
        homeCountry: 'Türkiye',
        homeBadge: userBadge,
        awayClubName: europeanGiants[0]['name']!,
        awayCountry: europeanGiants[0]['country']!,
        awayBadge: europeanGiants[0]['badge']!,
      ),
      ContinentalMatch(
        id: 'cont_2',
        stage: 'Grup 2. Maç',
        homeClubName: europeanGiants[1]['name']!,
        homeCountry: europeanGiants[1]['country']!,
        homeBadge: europeanGiants[1]['badge']!,
        awayClubName: userClubName,
        awayCountry: 'Türkiye',
        awayBadge: userBadge,
      ),
      ContinentalMatch(
        id: 'cont_3',
        stage: 'Grup 3. Maç',
        homeClubName: userClubName,
        homeCountry: 'Türkiye',
        homeBadge: userBadge,
        awayClubName: europeanGiants[2]['name']!,
        awayCountry: europeanGiants[2]['country']!,
        awayBadge: europeanGiants[2]['badge']!,
      ),
      ContinentalMatch(
        id: 'cont_semi',
        stage: 'Yarı Final',
        homeClubName: europeanGiants[3]['name']!,
        homeCountry: europeanGiants[3]['country']!,
        homeBadge: europeanGiants[3]['badge']!,
        awayClubName: europeanGiants[4]['name']!,
        awayCountry: europeanGiants[4]['country']!,
        awayBadge: europeanGiants[4]['badge']!,
      ),
      ContinentalMatch(
        id: 'cont_final',
        stage: 'Büyük Final',
        homeClubName: 'Finalist 1',
        homeCountry: 'Avrupa',
        homeBadge: '🏆',
        awayClubName: 'Finalist 2',
        awayCountry: 'Avrupa',
        awayBadge: '⭐',
      ),
    ];

    return ContinentalCup(
      title: 'Avrupa Hanedan Şampiyonlar Kupası',
      isUnlocked: true,
      seasonNumber: season,
      fixtures: matches,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'isUnlocked': isUnlocked,
    'seasonNumber': seasonNumber,
    'fixtures': fixtures.map((f) => f.toJson()).toList(),
    'prizeMoney': prizeMoney,
  };

  factory ContinentalCup.fromJson(Map<String, dynamic> json) => ContinentalCup(
    title: json['title'] as String? ?? 'Avrupa Hanedan Şampiyonlar Kupası',
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    seasonNumber: json['seasonNumber'] as int? ?? 1,
    fixtures: (json['fixtures'] as List<dynamic>?)
            ?.map((e) => ContinentalMatch.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    prizeMoney: json['prizeMoney'] as int? ?? 250000,
  );
}
