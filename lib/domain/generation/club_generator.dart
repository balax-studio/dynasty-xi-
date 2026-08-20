// domain/generation/club_generator.dart
// Pure Dart. Procedural generation of opponent clubs, league pyramids, and season fixtures.

import '../../core/rng/deterministic_rng.dart';
import '../../core/time/game_clock.dart';
import '../entities/club.dart';
import '../entities/facility.dart';
import '../entities/league.dart';
import '../entities/meter.dart';
import 'name_pools.dart';
import 'player_generator.dart';

class ClubGenerator {
  static const List<String> leagueTierNames = [
    'Elit Süper Lig', // Tier 1
    '1. Profesyonel Lig', // Tier 2
    '2. Ulusal Lig', // Tier 3
    '3. Bölgesel Lig', // Tier 4
    '4. Federasyon Ligi', // Tier 5
    '5. Anadolu Ligi', // Tier 6
    '6. Marmara Ligi', // Tier 7
    '7. Ege-Akdeniz Ligi', // Tier 8
    '8. Karadeniz Ligi', // Tier 9
    '9. İç Anadolu Ligi', // Tier 10
    '10. Doğu Ligi', // Tier 11
    '11. Güneydoğu Ligi', // Tier 12
    '12. Şehirler Ligi', // Tier 13
    '13. İlçe Ligi', // Tier 14
    '14. Yükselme Ligi', // Tier 15
    '15. Amatör Süper Lig', // Tier 16
    '16. 1. Amatör Lig', // Tier 17
    '17. 2. Amatör Lig', // Tier 18
    '18. Mahalli Lig', // Tier 19
    '19. Köy & Kasaba Ligi', // Tier 20 (Başlangıç)
  ];

  static String getLeagueName(int tier) {
    final idx = (tier - 1).clamp(0, leagueTierNames.length - 1);
    return leagueTierNames[idx];
  }

  /// Tekil Kulüp Üretimi
  static Club generateOpponentClub({
    required DeterministicRng rng,
    required int leagueTier,
    required String clubId,
    String? customName,
    String? city,
  }) {
    final cityName = city ?? rng.pick(NamePools.fictionalCities);
    final suffix = rng.pick(NamePools.clubSuffixes);
    final clubName = customName ?? '$cityName$suffix';
    final badge = rng.pick(NamePools.badgeIcons);
    final pColor = rng.pick(NamePools.primaryColors);
    final sColor = rng.pick(NamePools.secondaryColors);

    final squad = PlayerGenerator.generateSquad(
      rng: rng,
      leagueTier: leagueTier,
      clubIdPrefix: clubId,
    );

    final starting11 = squad.take(11).map((p) => p.id).toList();
    final subs = squad.skip(11).map((p) => p.id).toList();

    // Tesisler
    final facMap = <FacilityType, Facility>{};
    final facilityTierLevel = ((21 - leagueTier) / 4.0).ceil().clamp(1, 5);
    for (final type in FacilityType.values) {
      facMap[type] = Facility(type: type, level: facilityTierLevel);
    }

    final formations = ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1'];
    final styles = ['Ofansif', 'Dengeli', 'Defansif', 'Kontra Atak', 'Baskılı'];

    return Club(
      id: clubId,
      name: clubName,
      city: cityName ?? 'Anadolu',
      badgeIcon: badge,
      primaryColorHex: pColor,
      secondaryColorHex: sColor,
      leagueTier: leagueTier,
      isUserClub: false,
      meters: const ClubMeters(cash: 50000, fans: 50, lockerRoom: 50, boardTrust: 50),
      facilities: facMap,
      squad: squad,
      starting11Ids: starting11,
      substituteIds: subs,
      formation: rng.pick(formations),
      tacticalStyle: rng.pick(styles),
      ticketPrice: (6 + (21 - leagueTier) * 2.4).round(),
      sponsorWeeklyIncome: (21 - leagueTier) * 1200,
    );
  }

  /// 11 Takımlı Lig ve 21 Maçlık Fikstür Üretimi
  static League generateLeague({
    required DeterministicRng rng,
    required int leagueTier,
    required Club userClub,
    int seasonNumber = 1,
  }) {
    final clubs = <Club>[userClub];
    final clubIds = <String>[userClub.id];

    // 10 Rakip Kulüp Üretimi
    for (var i = 1; i <= 10; i++) {
      final oppId = 'opp_t${leagueTier}_$i';
      final oppClub = generateOpponentClub(
        rng: rng,
        leagueTier: leagueTier,
        clubId: oppId,
      );
      clubs.add(oppClub);
      clubIds.add(oppId);
    }

    // 21 Maçlık Fikstür Üretimi (Kullanıcı + 10 Rakip)
    final fixtures = <Fixture>[];
    var fixtureCounter = 1;
    final otherClubIds = clubIds.where((id) => id != userClub.id).toList();

    for (var m = 1; m <= GameClock.fixturesPerSeason; m++) {
      final oppId = otherClubIds[(m - 1) % otherClubIds.length];
      final oppClub = clubs.firstWhere((c) => c.id == oppId);
      final isHome = (m % 2 == 1);

      fixtures.add(Fixture(
        id: 'fix_${seasonNumber}_$fixtureCounter',
        seasonNumber: seasonNumber,
        matchday: m,
        homeClubId: isHome ? userClub.id : oppId,
        awayClubId: isHome ? oppId : userClub.id,
        homeClubName: isHome ? userClub.name : oppClub.name,
        awayClubName: isHome ? oppClub.name : userClub.name,
      ));
      fixtureCounter++;
    }

    // Başlangıç Puan Durumu
    final standings = clubs.map((c) {
      return LeagueTableEntry(
        clubId: c.id,
        clubName: c.name,
        badgeIcon: c.badgeIcon,
      );
    }).toList();

    return League(
      tier: leagueTier,
      name: getLeagueName(leagueTier),
      clubIds: clubIds,
      fixtures: fixtures,
      standings: standings,
    );
  }
}
