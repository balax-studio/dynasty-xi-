// domain/transfers/transfer_hijack.dart
// Transfer Hijacking (Transfer Çalımı) and Airport Fan Carnival welcoming mechanics.

class TransferHijackTarget {
  final String playerName;
  final String playerPosition;
  final int overallRating;
  final String rivalClubName;
  final int rivalBidAmount;
  final int requiredHijackBid;
  final int requiredAgentCommission;
  final int fansHypeBonus;

  const TransferHijackTarget({
    required this.playerName,
    required this.playerPosition,
    required this.overallRating,
    required this.rivalClubName,
    required this.rivalBidAmount,
    required this.requiredHijackBid,
    required this.requiredAgentCommission,
    required this.fansHypeBonus,
  });

  static List<TransferHijackTarget> getAvailableHijacks() {
    return const [
      TransferHijackTarget(
        playerName: 'Mateo Kovacic',
        playerPosition: 'Orta Saha (MC)',
        overallRating: 84,
        rivalClubName: 'Ezeli Rakip FK',
        rivalBidAmount: 320000,
        requiredHijackBid: 380000,
        requiredAgentCommission: 45000,
        fansHypeBonus: 25,
      ),
      TransferHijackTarget(
        playerName: 'Gabriel Barbosa (Gabigol)',
        playerPosition: 'Forvet (ST)',
        overallRating: 82,
        rivalClubName: 'Başkent Demirspor',
        rivalBidAmount: 240000,
        requiredHijackBid: 290000,
        requiredAgentCommission: 35000,
        fansHypeBonus: 20,
      ),
    ];
  }
}
