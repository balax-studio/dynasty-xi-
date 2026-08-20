// domain/economy/transfer_models.dart
// Loan market deals, wage sharing, and loan candidate generation (§10.5)

import '../entities/player.dart';

class LoanDeal {
  final Player player;
  final String parentClubName;
  final double borrowingClubWageShare; // e.g. 0.50 = %50
  final int buyoutClause;
  final int seasons;
  final int weeksRemaining;

  const LoanDeal({
    required this.player,
    required this.parentClubName,
    this.borrowingClubWageShare = 0.50,
    required this.buyoutClause,
    this.seasons = 1,
    this.weeksRemaining = 19,
  });

  int get weeklyWageToPay => (player.weeklyWage * borrowingClubWageShare).round();

  LoanDeal copyWith({
    Player? player,
    String? parentClubName,
    double? borrowingClubWageShare,
    int? buyoutClause,
    int? seasons,
    int? weeksRemaining,
  }) {
    return LoanDeal(
      player: player ?? this.player,
      parentClubName: parentClubName ?? this.parentClubName,
      borrowingClubWageShare: borrowingClubWageShare ?? this.borrowingClubWageShare,
      buyoutClause: buyoutClause ?? this.buyoutClause,
      seasons: seasons ?? this.seasons,
      weeksRemaining: weeksRemaining ?? this.weeksRemaining,
    );
  }

  Map<String, dynamic> toJson() => {
        'player': player.toJson(),
        'parentClubName': parentClubName,
        'borrowingClubWageShare': borrowingClubWageShare,
        'buyoutClause': buyoutClause,
        'seasons': seasons,
        'weeksRemaining': weeksRemaining,
      };

  factory LoanDeal.fromJson(Map<String, dynamic> json) => LoanDeal(
        player: Player.fromJson(json['player'] as Map<String, dynamic>),
        parentClubName: json['parentClubName'] as String,
        borrowingClubWageShare: (json['borrowingClubWageShare'] as num?)?.toDouble() ?? 0.50,
        buyoutClause: json['buyoutClause'] as int,
        seasons: json['seasons'] as int? ?? 1,
        weeksRemaining: json['weeksRemaining'] as int? ?? ((json['seasons'] as int? ?? 1) * 19),
      );
}

class LoanMarketGenerator {
  static List<LoanDeal> generateLoanCandidates() {
    return const [
      LoanDeal(
        player: Player(
          id: 'loan_1',
          firstName: 'Emre',
          lastName: 'Gökmen',
          countryCode: 'TR',
          age: 20,
          position: Position.am,
          pace: 78,
          technique: 77,
          shooting: 74,
          passing: 76,
          defending: 42,
          physical: 66,
          mentality: 75,
          potential: 84,
          weeklyWage: 3200,
          personality: PersonalityType.ambitious,
        ),
        parentClubName: 'Galatasaray SK',
        borrowingClubWageShare: 0.40,
        buyoutClause: 120000,
      ),
      LoanDeal(
        player: Player(
          id: 'loan_2',
          firstName: 'Alp',
          lastName: 'Eren',
          countryCode: 'TR',
          age: 21,
          position: Position.cb,
          pace: 72,
          technique: 65,
          shooting: 40,
          passing: 68,
          defending: 76,
          physical: 79,
          mentality: 74,
          potential: 82,
          weeklyWage: 2800,
          personality: PersonalityType.loyal,
        ),
        parentClubName: 'Fenerbahçe SK',
        borrowingClubWageShare: 0.50,
        buyoutClause: 95000,
      ),
      LoanDeal(
        player: Player(
          id: 'loan_3',
          firstName: 'Lucas',
          lastName: 'Mendes',
          countryCode: 'BR',
          age: 19,
          position: Position.rw,
          pace: 84,
          technique: 80,
          shooting: 75,
          passing: 70,
          defending: 35,
          physical: 68,
          mentality: 72,
          potential: 86,
          weeklyWage: 3500,
          personality: PersonalityType.temperamental,
        ),
        parentClubName: 'SL Benfica',
        borrowingClubWageShare: 0.35,
        buyoutClause: 180000,
      ),
    ];
  }
}

class FreeAgentMarketGenerator {
  static List<Player> generateFreeAgents() {
    return const [
      Player(
        id: 'free_agent_1',
        firstName: 'Selim',
        lastName: 'Kurtuluş',
        countryCode: 'TR',
        age: 29,
        position: Position.cm,
        pace: 71,
        technique: 82,
        shooting: 75,
        passing: 84,
        defending: 72,
        physical: 76,
        mentality: 85,
        potential: 82,
        weeklyWage: 4200,
        personality: PersonalityType.leader,
      ),
      Player(
        id: 'free_agent_2',
        firstName: 'Mateo',
        lastName: 'Kovačić',
        countryCode: 'HR',
        age: 31,
        position: Position.dm,
        pace: 68,
        technique: 83,
        shooting: 70,
        passing: 86,
        defending: 78,
        physical: 75,
        mentality: 88,
        potential: 83,
        weeklyWage: 5800,
        personality: PersonalityType.professional,
      ),
      Player(
        id: 'free_agent_3',
        firstName: 'Boubacar',
        lastName: 'Traore',
        countryCode: 'ML',
        age: 23,
        position: Position.st,
        pace: 86,
        technique: 76,
        shooting: 79,
        passing: 64,
        defending: 32,
        physical: 82,
        mentality: 74,
        potential: 85,
        weeklyWage: 3100,
        personality: PersonalityType.ambitious,
      ),
      Player(
        id: 'free_agent_4',
        firstName: 'Volkan',
        lastName: 'Demirok',
        countryCode: 'TR',
        age: 33,
        position: Position.gk,
        pace: 55,
        technique: 62,
        shooting: 25,
        passing: 70,
        defending: 82,
        physical: 80,
        mentality: 87,
        potential: 79,
        weeklyWage: 2600,
        personality: PersonalityType.leader,
      ),
      Player(
        id: 'free_agent_5',
        firstName: 'Gabriel',
        lastName: 'Silva',
        countryCode: 'BR',
        age: 22,
        position: Position.lb,
        pace: 83,
        technique: 78,
        shooting: 65,
        passing: 74,
        defending: 73,
        physical: 75,
        mentality: 76,
        potential: 84,
        weeklyWage: 3400,
        personality: PersonalityType.loyal,
      ),
    ];
  }
}

