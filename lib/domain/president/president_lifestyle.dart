// domain/president/president_lifestyle.dart
// President Luxury Lifestyle, Personal Assets, Supercars, Jets, and Prestige Perks

class PresidentLuxuryAsset {
  final String id;
  final String name;
  final String category;
  final String icon;
  final int purchaseCost;
  final int prestigeBonus;
  final int fansBonus;
  final String description;
  final bool isOwned;

  const PresidentLuxuryAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.purchaseCost,
    required this.prestigeBonus,
    required this.fansBonus,
    required this.description,
    this.isOwned = false,
  });

  static List<PresidentLuxuryAsset> getDefaultCatalog() {
    return const [
      PresidentLuxuryAsset(
        id: 'luxury_sedan',
        name: 'Zırhlı Başkanlık Makam Aracı (Maybach)',
        category: 'GARAGE',
        icon: '🚘',
        purchaseCost: 75000,
        prestigeBonus: 5,
        fansBonus: 2,
        description: 'Özel çakar lambalı ve koruma konvoylu zırhlı makam aracı. Şehre girişlerde saygınlık sağlar.',
      ),
      PresidentLuxuryAsset(
        id: 'private_jet',
        name: 'Gulfstream G650 Özel Başkanlık Jeti',
        category: 'AVIATION',
        icon: '✈️',
        purchaseCost: 350000,
        prestigeBonus: 25,
        fansBonus: 10,
        description: 'Avrupa deplasmanlarına ve gizli transfer görüşmelerine hızlı erişim sağlar. Menajerler üzerinde büyük etki bırakır.',
      ),
      PresidentLuxuryAsset(
        id: 'bosphorus_yacht',
        name: '50 Metrelik Lüks Süper Yat (Dynasty I)',
        category: 'MARINA',
        icon: '🛥️',
        purchaseCost: 500000,
        prestigeBonus: 35,
        fansBonus: 15,
        description: 'Sponsorluk anlaşmaları ve TFF yetkilileriyle gizli akşam yemekleri için mükemmel bir prestij sembolü.',
      ),
      PresidentLuxuryAsset(
        id: 'historic_mansion',
        name: 'Boğaz Kıyısında Tarihi Başkanlık Yalısı',
        category: 'REAL_ESTATE',
        icon: '🏰',
        purchaseCost: 800000,
        prestigeBonus: 50,
        fansBonus: 20,
        description: 'Şehrin en gözde noktasında tarihi yalı. Basın toplantıları ve şampiyonluk kutlama balolarına ev sahipliği yapar.',
      ),
    ];
  }
}
