// domain/entities/club.dart
// Pure Dart. Club entity with squad, U19 squad, tactics, facilities, meters, and financial parameters.

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
  final List<Player> u19Squad;
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
    this.u19Squad = const [],
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
    final seniorWages = squad.fold<int>(0, (sum, p) => sum + p.weeklyWage);
    final u19Wages = u19Squad.fold<int>(0, (sum, p) => sum + p.weeklyWage);
    return seniorWages + u19Wages;
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

  /// Otomatik En İyi 11'i Seç (Formasyona ve Mevki OVR'ına Göre)
  List<String> calculateBest11Ids() {
    if (squad.isEmpty) return [];

    int reqGk = 1;
    int reqDef = 4;
    int reqMid = 3;
    int reqFwd = 3;

    switch (formation) {
      case '4-4-2':
        reqDef = 4;
        reqMid = 4;
        reqFwd = 2;
        break;
      case '3-5-2':
        reqDef = 3;
        reqMid = 5;
        reqFwd = 2;
        break;
      case '4-2-3-1':
        reqDef = 4;
        reqMid = 5;
        reqFwd = 1;
        break;
      case '5-3-2':
        reqDef = 5;
        reqMid = 3;
        reqFwd = 2;
        break;
      case '4-3-3':
      default:
        reqDef = 4;
        reqMid = 3;
        reqFwd = 3;
        break;
    }

    final available = List<Player>.from(squad.where((p) => !p.isInjured));
    // OVR azalan sıraya göre sırala
    available.sort((a, b) => b.ovr.compareTo(a.ovr));

    final selected = <Player>[];

    // 1. Kaleci seç
    final gks = available.where((p) => p.position.isGoalkeeper).toList();
    for (var i = 0; i < reqGk && i < gks.length; i++) {
      selected.add(gks[i]);
      available.remove(gks[i]);
    }

    // 2. Defansları seç
    final defs = available.where((p) => p.position.isDefender).toList();
    for (var i = 0; i < reqDef && i < defs.length; i++) {
      selected.add(defs[i]);
      available.remove(defs[i]);
    }

    // 3. Orta Sahaları seç
    final mids = available.where((p) => p.position.isMidfielder).toList();
    for (var i = 0; i < reqMid && i < mids.length; i++) {
      selected.add(mids[i]);
      available.remove(mids[i]);
    }

    // 4. Forvetleri seç
    final fwds = available.where((p) => p.position.isForward).toList();
    for (var i = 0; i < reqFwd && i < fwds.length; i++) {
      selected.add(fwds[i]);
      available.remove(fwds[i]);
    }

    // 5. Eksik kalan olursa en yüksek OVR'lı kalan oyunculardan tamamla
    while (selected.length < 11 && available.isNotEmpty) {
      selected.add(available.removeAt(0));
    }

    return selected.map((p) => p.id).toList();
  }

  /// İlk 11 ile Yedek Oyuncunun Yerini Değiştir
  Club swapStartingAndBench(String startingId, String subId) {
    final currentS11 = List<String>.from(starting11Ids.isEmpty ? starting11.map((p) => p.id) : starting11Ids);
    final currentSubs = List<String>.from(substituteIds.isEmpty ? substitutes.map((p) => p.id) : substituteIds);

    if (currentS11.contains(startingId)) {
      final sIdx = currentS11.indexOf(startingId);
      currentS11[sIdx] = subId;

      if (currentSubs.contains(subId)) {
        final bIdx = currentSubs.indexOf(subId);
        currentSubs[bIdx] = startingId;
      } else {
        currentSubs.remove(subId);
        currentSubs.add(startingId);
      }
    }

    return copyWith(
      starting11Ids: currentS11,
      substituteIds: currentSubs,
    );
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
    List<Player>? u19Squad,
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
      u19Squad: u19Squad ?? this.u19Squad,
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
        'u19Squad': u19Squad.map((p) => p.toJson()).toList(),
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
      u19Squad: (json['u19Squad'] as List<dynamic>?)
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
