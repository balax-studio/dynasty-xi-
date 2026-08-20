// domain/president/legal_defense.dart
// Club Legal Counsel, Arbitration Court Appeals, and Counterfeit Merchandise Raids.

class LegalCaseItem {
  final String id;
  final String title;
  final String summary;
  final int initialPenalty;
  final int appealCost;
  final int successChancePercent;
  final String victoryOutcome;

  const LegalCaseItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.initialPenalty,
    required this.appealCost,
    required this.successChancePercent,
    required this.victoryOutcome,
  });

  static List<LegalCaseItem> getActiveCases() {
    return const [
      LegalCaseItem(
        id: 'tff_stadium_ban',
        title: 'TFF 1 Maç Seyircisiz Oynama Cezası',
        summary: 'Tribün olayları nedeniyle Disiplin Kurulu 1 maç tribün kapatma ve 50.000 € ceza kesti.',
        initialPenalty: 50000,
        appealCost: 12000,
        successChancePercent: 75,
        victoryOutcome: 'Tahkim cezayı kaldırıp para cezasına çevirdi. Seyirci yasağı iptal!',
      ),
      LegalCaseItem(
        id: 'player_breach_contract',
        title: 'Eski Yabancı Oyuncu FIFA Tazminat Davası',
        summary: 'Sözleşmesini tek taraflı fesheden eski forvet 180.000 € haksız fesih tazminatı istiyor.',
        initialPenalty: 180000,
        appealCost: 25000,
        successChancePercent: 65,
        victoryOutcome: 'CAS davası kazanıldı! Kulüp tazminat ödemekten kurtuldu.',
      ),
    ];
  }
}
