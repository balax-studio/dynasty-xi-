// domain/entities/club.dart
// Pure Dart. Club entity with squad, tactics, facilities, meters, and financial parameters.

import 'facility.dart';
import 'meter.dart';
import 'player.dart';

class Club {
  final String id;
  final String name;
  final String city;
  final String badgeIcon;
  final String primaryColorHex;
  final String secondaryColorHex;
  final int leagueTier; // 1 to 20
  final bool isUserClub;

  final ClubMeters meters;
  final Map<FacilityType, Facility> facilities;
  final List<Player> squad;
  final List<String> starting11Ids;
  final List<String> substituteIds;

  final String formation; // '4-3-3', '4-4-2', '3-5-2', '4-2-3-1', '5-3-2'
  final String tacticalStyle; // 'Ofansif', 'Dengeli', 'Defansif', 'Kontra Atak', 'Baskılı'

  final int ticketPrice;
  final int sponsorWeeklyIncome;
  final int totalTrophies;

  const Club({
    required this.id,
    required this.name,
    required this.city,
    this.badgeIcon = '🛡️',
    this.primaryColorHex = '#0B2E20',
    this.secondaryColorHex = '#D9A62E',
    this.leagueTier = 20,
    this.isUserClub = false,
    this.meters = const ClubMeters(),
    this.facilities = const {},
    this.squad = const [],
    this.starting11Ids = const [],
    this.substituteIds = const [],
    this.formation = '4-3-3',
    this.tacticalStyle = 'Dengeli',
    this.ticketPrice = 12,
    this.sponsorWeeklyIncome = 3500,
    this.totalTrophies = 0,
  });

  /// İlk 11 Oyuncuları
  List<Player> get starting11 {
    final map = {for (final p in squad) p.id: p};
    final list = <Player>[];
    for (final pid in starting11Ids) {
      if (map.containsKey(pid)) list.add(map[pid]!);
    }
    // Eğer 11 tamamlanmamışsa kalan sağlıklı oyunculardan tamamla
    if (list.length < 11) {
      for (final p in squad) {
        if (!list.contains(p) && !p.isInjured) {
          list.add(p);
          if (list.length == 11) break;
        }
      }
    }
    return list;
  }

  /// Yedek Oyuncular
  List<Player> get substitutes {
    final s11 = starting11;
    return squad.where((p) => !s11.contains(p)).toList();
  }

  List<Player> get bench => substitutes;

  /// Kadro Ortalama OVR Değeri
  double get averageOvr {
    final s11 = starting11;
    if (s11.isEmpty) return 40.0;
    final total = s11.fold<int>(0, (sum, p) => sum + p.ovr);
    return total / s11.length;
  }

  /// Toplam Haftalık Maaş Yükü
  int get totalWeeklyWages {
    return squad.fold<int>(0, (sum, p) => sum + p.weeklyWage);
  }

  /// Toplam Haftalık Tesis Bakım Masrafı
  int get totalWeeklyMaintenance {
    return facilities.values.fold<int>(0, (sum, f) => sum + f.weeklyMaintenance);
  }

  /// Stadyum Kapasitesi
  int get stadiumCapacity {
    final st = facilities[FacilityType.stadium];
    return st?.stadiumCapacity ?? 2500;
  }

  /// Tesis Seviyesi Getir
  int getFacilityLevel(FacilityType type) {
    return facilities[type]?.level ?? 1;
  }

  Club copyWith({
    String? id,
    String? name,
    String? city,
    String? badgeIcon,
    String? primaryColorHex,
    String? secondaryColorHex,
    int? leagueTier,
    bool? isUserClub,
    ClubMeters? meters,
    Map<FacilityType, Facility>? facilities,
    List<Player>? squad,
    List<String>? starting11Ids,
    List<String>? substituteIds,
    String? formation,
    String? tacticalStyle,
    int? ticketPrice,
    int? sponsorWeeklyIncome,
    int? totalTrophies,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      leagueTier: leagueTier ?? this.leagueTier,
      isUserClub: isUserClub ?? this.isUserClub,
      meters: meters ?? this.meters,
      facilities: facilities ?? this.facilities,
      squad: squad ?? this.squad,
      starting11Ids: starting11Ids ?? this.starting11Ids,
      substituteIds: substituteIds ?? this.substituteIds,
      formation: formation ?? this.formation,
      tacticalStyle: tacticalStyle ?? this.tacticalStyle,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      sponsorWeeklyIncome: sponsorWeeklyIncome ?? this.sponsorWeeklyIncome,
      totalTrophies: totalTrophies ?? this.totalTrophies,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'badgeIcon': badgeIcon,
        'primaryColorHex': primaryColorHex,
        'secondaryColorHex': secondaryColorHex,
        'leagueTier': leagueTier,
        'isUserClub': isUserClub,
        'meters': meters.toJson(),
        'facilities': facilities.map((k, v) => MapEntry(k.name, v.toJson())),
        'squad': squad.map((p) => p.toJson()).toList(),
        'starting11Ids': starting11Ids,
        'substituteIds': substituteIds,
        'formation': formation,
        'tacticalStyle': tacticalStyle,
        'ticketPrice': ticketPrice,
        'sponsorWeeklyIncome': sponsorWeeklyIncome,
        'totalTrophies': totalTrophies,
      };

  factory Club.fromJson(Map<String, dynamic> json) {
    final facMap = <FacilityType, Facility>{};
    if (json['facilities'] != null) {
      final map = json['facilities'] as Map<String, dynamic>;
      for (final entry in map.entries) {
        final type = FacilityType.values.firstWhere(
          (t) => t.name == entry.key,
          orElse: () => FacilityType.stadium,
        );
        facMap[type] = Facility.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String? ?? 'Angora',
      badgeIcon: json['badgeIcon'] as String? ?? '🛡️',
      primaryColorHex: json['primaryColorHex'] as String? ?? '#0B2E20',
      secondaryColorHex: json['secondaryColorHex'] as String? ?? '#D9A62E',
      leagueTier: json['leagueTier'] as int? ?? 20,
      isUserClub: json['isUserClub'] as bool? ?? false,
      meters: json['meters'] != null
          ? ClubMeters.fromJson(json['meters'] as Map<String, dynamic>)
          : const ClubMeters(),
      facilities: facMap,
      squad: (json['squad'] as List<dynamic>?)
              ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
      starting11Ids: (json['starting11Ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      substituteIds: (json['substituteIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      formation: json['formation'] as String? ?? '4-3-3',
      tacticalStyle: json['tacticalStyle'] as String? ?? 'Dengeli',
      ticketPrice: json['ticketPrice'] as int? ?? 12,
      sponsorWeeklyIncome: json['sponsorWeeklyIncome'] as int? ?? 3500,
      totalTrophies: json['totalTrophies'] as int? ?? 0,
    );
  }
}
