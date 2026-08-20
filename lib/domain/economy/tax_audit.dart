// domain/economy/tax_audit.dart
// Tax Audit Inspection and Financial Fair Play (FFP) Compliance Monitoring.

enum TaxAuditRiskLevel {
  clean,    // Temiz / Rutin
  warning,  // Dikkat Çeken Harcamalar
  critical, // Ağır Müfettiş İncelemesi / Ceza Riski
}

class TaxAuditScenario {
  final String title;
  final String description;
  final int auditFineAmount;
  final int bribeCost;
  final int lobbyCost;

  const TaxAuditScenario({
    required this.title,
    required this.description,
    required this.auditFineAmount,
    required this.bribeCost,
    required this.lobbyCost,
  });

  static TaxAuditScenario generateInspection(int clubCash) {
    if (clubCash > 500000) {
      return const TaxAuditScenario(
        title: 'Büyük Mükellefler Özel Müfettiş İncelemesi',
        description: 'Maliye müfettişleri kulübün sponsorluk ve elden prim ödemelerinde usulsüzlük tespit etti. 120.000 € vergi aslı ve ceza talep ediliyor!',
        auditFineAmount: 120000,
        bribeCost: 35000,
        lobbyCost: 50000,
      );
    } else {
      return const TaxAuditScenario(
        title: 'Rutin Stopaj ve SGK Denetimi',
        description: 'Kulüp personelinin ve yerli oyuncuların maç başı stopaj bildirimlerinde eksik beyan bulundu. 30.000 € idari para cezası kesildi.',
        auditFineAmount: 30000,
        bribeCost: 10000,
        lobbyCost: 15000,
      );
    }
  }
}

class FfpStatusReport {
  final int totalAnnualRevenue;
  final int totalAnnualExpenses;
  final int netBalance;
  final int maxAllowedLoss;
  final bool isCompliant;
  final String penaltyRisk;

  const FfpStatusReport({
    required this.totalAnnualRevenue,
    required this.totalAnnualExpenses,
    required this.netBalance,
    required this.maxAllowedLoss,
    required this.isCompliant,
    required this.penaltyRisk,
  });

  static FfpStatusReport calculateFfp({
    required int revenue,
    required int expenses,
  }) {
    final net = revenue - expenses;
    const maxLoss = -100000; // Maksimum 100.000 € sezonluk açık
    final compliant = net >= maxLoss;

    return FfpStatusReport(
      totalAnnualRevenue: revenue,
      totalAnnualExpenses: expenses,
      netBalance: net,
      maxAllowedLoss: maxLoss,
      isCompliant: compliant,
      penaltyRisk: compliant ? 'GÜVENLİ (CEZA RİSKİ YOK)' : 'TRANSFER YASAĞI VE PUAN SİLME RİSKİ!',
    );
  }
}
