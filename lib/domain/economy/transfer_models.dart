// domain/economy/transfer_models.dart
// Loan market deals, wage sharing, and loan candidate generation (§10.5)

import '../entities/player.dart';

class LoanDeal {
  final Player player;
  final String parentClubName;
  final double borrowingClubWageShare; // e.g. 0.50 = %50
  final int buyoutClause;
  final int seasons;

  const LoanDeal({
    required this.player,
    required this.parentClubName,
    this.borrowingClubWageShare = 0.50,
    required this.buyoutClause,
    this.seasons = 1,
  });

  int get weeklyWageToPay => (player.weeklyWage * borrowingClubWageShare).round();

  Map<String, dynamic> toJson() => {
        'player': player.toJson(),
        'parentClubName': parentClubName,
        'borrowingClubWageShare': borrowingClubWageShare,
        'buyoutClause': buyoutClause,
        'seasons': seasons,
      };

  factory LoanDeal.fromJson(Map<String, dynamic> json) => LoanDeal(
        player: Player.fromJson(json['player'] as Map<String, dynamic>),
        parentClubName: json['parentClubName'] as String,
        borrowingClubWageShare: (json['borrowingClubWageShare'] as num?)?.toDouble() ?? 0.50,
        buyoutClause: json['buyoutClause'] as int,
        seasons: json['seasons'] as int? ?? 1,
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
