// domain/player/player_agent_deals.dart
// Player Agent Negotiations, Private Detective Scandals, and Secret Incentives.

class PlayerAgentMeetingOption {
  final String title;
  final String description;
  final int cashCost;
  final int loyaltyBonus;
  final int wageDiscountPercent;

  const PlayerAgentMeetingOption({
    required this.title,
    required this.description,
    required this.cashCost,
    required this.loyaltyBonus,
    required this.wageDiscountPercent,
  });

  static List<PlayerAgentMeetingOption> getOptions() {
    return const [
      PlayerAgentMeetingOption(
        title: 'Özel İmza Parası ve Komisyon Ver (-40.000 €)',
        description: 'Menajere elden nakit komisyon öde. Oyuncunun maaş talebini %20 düşür.',
        cashCost: 40000,
        loyaltyBonus: 25,
        wageDiscountPercent: 20,
      ),
      PlayerAgentMeetingOption(
        title: 'Sonraki Satıştan %25 Pay Sözü Ver (-10.000 €)',
        description: 'Nakit vermeden gelecekteki transfer karından pay vaat et.',
        cashCost: 10000,
        loyaltyBonus: 15,
        wageDiscountPercent: 10,
      ),
      PlayerAgentMeetingOption(
        title: 'Menajere Rest Çek ("Oyuncunun aklını çelme")',
        description: 'Komisyon ödemeyi reddet. Menajer basına şikayet edebilir.',
        cashCost: 0,
        loyaltyBonus: -10,
        wageDiscountPercent: 0,
      ),
    ];
  }
}

class DetectiveInvestigationReport {
  final String playerName;
  final String scandalTitle;
  final String scandalDetails;
  final int fineAllowed;

  const DetectiveInvestigationReport({
    required this.playerName,
    required this.scandalTitle,
    required this.scandalDetails,
    required this.fineAllowed,
  });

  static DetectiveInvestigationReport generateReport(String playerName) {
    return DetectiveInvestigationReport(
      playerName: playerName,
      scandalTitle: 'Gece Kulübü & Nargile Kaçamağı',
      scandalDetails: 'Dedektiflerimiz oyuncunun derbi maçtan 2 gün önce sabah 04:30\'a kadar gece kulübünde olduğunu fotoğrafladı.',
      fineAllowed: 25000,
    );
  }
}
