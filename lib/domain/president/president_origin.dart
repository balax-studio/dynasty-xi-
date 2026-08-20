// domain/president/president_origin.dart
// 4 Distinct President Background Classes and Origin Archetypes.

enum PresidentOriginType {
  industrialist,     // Geleneksel Sanayici / Fabrikatör
  legendPlayer,      // Eski Efsane Futbolcu
  techTycoon,        // Genç Teknoloji / Kripto Milyoneri
  politicianBureaucrat, // Siyasetçi / Bürokrat
}

class PresidentOrigin {
  final PresidentOriginType type;
  final String title;
  final String subtitle;
  final String icon;
  final int startingCashBonus;
  final int startingFansBonus;
  final int startingLockerRoomBonus;
  final int startingBoardTrustBonus;
  final double sponsorIncomeMultiplier;
  final double playerWageDiscount;
  final String perkDescription;
  final String flawDescription;

  const PresidentOrigin({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.startingCashBonus,
    required this.startingFansBonus,
    required this.startingLockerRoomBonus,
    required this.startingBoardTrustBonus,
    required this.sponsorIncomeMultiplier,
    required this.playerWageDiscount,
    required this.perkDescription,
    required this.flawDescription,
  });

  static List<PresidentOrigin> getAllOrigins() {
    return const [
      PresidentOrigin(
        type: PresidentOriginType.industrialist,
        title: 'Geleneksel Sanayici',
        subtitle: 'Ağır Sanayi & Fabrika Sahibi',
        icon: '🏭',
        startingCashBonus: 250000,
        startingFansBonus: 0,
        startingLockerRoomBonus: 0,
        startingBoardTrustBonus: 15,
        sponsorIncomeMultiplier: 1.25,
        playerWageDiscount: 0.0,
        perkDescription: '+250.000 € Başlangıç Nakdi, +%25 Sponsor Geliri ve Yüksek Yönetim Güveni.',
        flawDescription: 'Medyada soğuk ve bürokratik algılanır; taraftar coşkusu yavaş yükselir.',
      ),
      PresidentOrigin(
        type: PresidentOriginType.legendPlayer,
        title: 'Eski Efsane Futbolcu',
        subtitle: 'Milli Takım & Kulüp Kaptanı',
        icon: '⚽',
        startingCashBonus: 50000,
        startingFansBonus: 20,
        startingLockerRoomBonus: 25,
        startingBoardTrustBonus: -5,
        sponsorIncomeMultiplier: 1.0,
        playerWageDiscount: 0.15,
        perkDescription: 'Soyunma Odası Güveni tavan (+25), Oyuncular %15 daha düşük maaşa imza atar.',
        flawDescription: 'Mali disiplin zayıftır; banka kredileri daha yüksek faizli olur.',
      ),
      PresidentOrigin(
        type: PresidentOriginType.techTycoon,
        title: 'Genç Teknoloji Milyoneri',
        subtitle: 'Kripto & Yapay Zeka Yatırımcısı',
        icon: '💻',
        startingCashBonus: 180000,
        startingFansBonus: 15,
        startingLockerRoomBonus: -5,
        startingBoardTrustBonus: -10,
        sponsorIncomeMultiplier: 1.15,
        playerWageDiscount: 0.0,
        perkDescription: 'Kripto Fan Token ve Dijital Gelirler 2 katı kazandırır, Sosyal Medya etkileşimi yüksektir.',
        flawDescription: 'Geleneksel yönetim kurulu üyeleri sürekli erken seçim ve güvensizlik çıkarır.',
      ),
      PresidentOrigin(
        type: PresidentOriginType.politicianBureaucrat,
        title: 'Siyasetçi & Bürokrat',
        subtitle: 'Eski Bakan / Milletvekili',
        icon: '🏛️',
        startingCashBonus: 100000,
        startingFansBonus: -5,
        startingLockerRoomBonus: 5,
        startingBoardTrustBonus: 20,
        sponsorIncomeMultiplier: 1.20,
        playerWageDiscount: 0.05,
        perkDescription: 'Belediye İmar İzinleri ve TFF Disiplin cezalarından muafiyet / lobicilik gücü.',
        flawDescription: 'Rakip taraftarlar ve bağımsız medya kulübü sürekli siyasi baskıyla suçlar.',
      ),
    ];
  }
}
