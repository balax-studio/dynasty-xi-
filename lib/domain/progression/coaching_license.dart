// domain/progression/coaching_license.dart
// UEFA Coaching License Tiers: C -> B -> A -> Pro (§13, §14)

enum CoachingLicense {
  uefaC('UEFA C Lisansı (Amatör Antrenör)', '📜', 1, 0, 1.0),
  uefaB('UEFA B Lisansı (Ulusal Antrenör)', '🥉', 5, 25000, 1.05),
  uefaA('UEFA A Lisansı (Kıtasal Taktisyen)', '🥈', 10, 75000, 1.10),
  uefaPro('UEFA Pro Lisansı (Elit Menajer)', '🥇', 20, 200000, 1.20);

  final String title;
  final String badge;
  final int requiredManagerLevel;
  final int courseCost;
  final double allPerkMultiplier;

  const CoachingLicense(
    this.title,
    this.badge,
    this.requiredManagerLevel,
    this.courseCost,
    this.allPerkMultiplier,
  );
}
