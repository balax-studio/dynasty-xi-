// domain/economy/stock_market.dart
// Stock Market (IPO / Halka Arz), Stock Price Fluctuations, and Foreign Takeover Bids.

class StockMarketState {
  final bool isIpoLaunched;
  final double currentSharePrice;   // Hisse Başı Fiyat (€)
  final double weeklyPriceChangePercent;
  final int publicSharesTotal;      // Dolaşımdaki Hisse Adedi
  final double marketCap;           // Toplam Piyasa Değeri (€)

  const StockMarketState({
    required this.isIpoLaunched,
    required this.currentSharePrice,
    required this.weeklyPriceChangePercent,
    required this.publicSharesTotal,
    required this.marketCap,
  });

  static StockMarketState createInitial() {
    return const StockMarketState(
      isIpoLaunched: false,
      currentSharePrice: 12.50,
      weeklyPriceChangePercent: 0.0,
      publicSharesTotal: 100000,
      marketCap: 1250000.0,
    );
  }

  StockMarketState simulatePostMatchValuation({required bool isWin, required bool isDerby}) {
    if (!isIpoLaunched) return this;

    double change = isWin ? (isDerby ? 8.5 : 3.5) : (isDerby ? -9.0 : -4.0);
    double newPrice = (currentSharePrice * (1.0 + change / 100.0)).clamp(2.0, 150.0);

    return StockMarketState(
      isIpoLaunched: true,
      currentSharePrice: double.parse(newPrice.toStringAsFixed(2)),
      weeklyPriceChangePercent: change,
      publicSharesTotal: publicSharesTotal,
      marketCap: newPrice * publicSharesTotal,
    );
  }
}

class ForeignTakeoverOffer {
  final String investorName;
  final String investorCountry;
  final String investorBadge;
  final int stakePercentage; // Satın alınmak istenen hisse % (örn: %25 veya %49)
  final int cashOfferAmount; // Teklif edilen nakit bedeli (€)
  final String investorAgenda; // Şartları (Örn: Yıldız forvet zorunluluğu)

  const ForeignTakeoverOffer({
    required this.investorName,
    required this.investorCountry,
    required this.investorBadge,
    required this.stakePercentage,
    required this.cashOfferAmount,
    required this.investorAgenda,
  });

  static List<ForeignTakeoverOffer> getAvailableOffers() {
    return const [
      ForeignTakeoverOffer(
        investorName: 'Al-Hilal Capital Group',
        investorCountry: 'Birleşik Arap Emirlikleri',
        investorBadge: '',
        stakePercentage: 25,
        cashOfferAmount: 500000,
        investorAgenda: 'Kulübün %25 hissesine karşılık anında 500.000 € nakit enjeksiyonu. Yönetimde 1 koltuk talep ediyorlar.',
      ),
      ForeignTakeoverOffer(
        investorName: 'RedPeak Sports Ventures',
        investorCountry: 'Amerika Birleşik Devletleri',
        investorBadge: '',
        stakePercentage: 40,
        cashOfferAmount: 1000000,
        investorAgenda: 'Kulübün %40 hissesi için 1.000.000 € fon. Gelirlerin %20 temettü olarak dağıtılmasını şart koşuyorlar.',
      ),
    ];
  }
}
