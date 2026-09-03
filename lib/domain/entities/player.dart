// domain/entities/player.dart
// Pure Dart. Player entity with position-weighted OVR, dynamic valuation, stats, personality & RPG attributes.

import 'dart:math' as math;
import 'position_weights.dart';

enum Position {
  gk('Kaleci', 'GK', ''),
  cb('Stoper', 'CB', 'SHIELD'),
  lb('Sol Bek', 'LB', 'SHIELD'),
  rb('Sağ Bek', 'RB', 'SHIELD'),
  dm('Ön Libero', 'DM', ''),
  cm('Merkez Orta Saha', 'CM', '[HEDEF]'),
  am('Ofansif Orta Saha', 'AM', ''),
  lw('Sol Kanat', 'LW', 'BOLT'),
  rw('Sağ Kanat', 'RW', 'BOLT'),
  st('Santrfor', 'ST', '[GOL]');

  final String label;
  final String code;
  final String icon;

  const Position(this.label, this.code, this.icon);

  bool get isGoalkeeper => this == Position.gk;
  bool get isDefender => this == Position.cb || this == Position.lb || this == Position.rb;
  bool get isMidfielder => this == Position.dm || this == Position.cm || this == Position.am;
  bool get isForward => this == Position.lw || this == Position.rw || this == Position.st;
}

enum PersonalityType {
  leader('Lider', 'Soyunma odasını toparlar, krizde öne çıkar.'),
  ambitious('Hırslı', 'Gelişimi hızlıdır ama büyük kulüp ve başarı ister.'),
  loyal('Sadık', 'Maaşa az bakar, kulüpten zor ayrılır.'),
  mercenary('Paragöz', 'Yüksek zam ister, ödenmezse moral çöker.'),
  rebel('Asi', 'Yüksek yetenek ama disiplin sorunları yaratabilir.'),
  humble('Mütevazı', 'Yedek kalsa da sorun çıkarmaz, dengeli.'),
  professional('Profesyonel', 'İstikrarlı çalışır, antrenman verimi çok yüksektir.'),
  temperamental('Duygusal', 'Formdayken durdurulamaz, krizde çabuk küser.');

  final String label;
  final String description;

  const PersonalityType(this.label, this.description);

  bool get isLockerRoomLeader => this == PersonalityType.leader || this == PersonalityType.professional;
  bool get isHighMaintenance => this == PersonalityType.rebel || this == PersonalityType.mercenary || this == PersonalityType.temperamental;
  double get moraleSensitivity => this == PersonalityType.temperamental ? 1.5 : (this == PersonalityType.humble ? 0.7 : 1.0);
}

enum TrainingIntensity {
  light('Hafif', 'Dinlendirici tempo. Sakatlık riski düşük, gelişim yavaş.', 0.6, 0.4),
  normal('Normal', 'Dengeli antrenman programı.', 1.0, 1.0),
  intensive('Yoğun', 'Ağır kondisyon ve taktik yükleme. Gelişim yüksek, sakatlık riski fazla.', 1.5, 1.8);

  final String label;
  final String description;
  final double growthMultiplier;
  final double injuryRiskMultiplier;

  const TrainingIntensity(this.label, this.description, this.growthMultiplier, this.injuryRiskMultiplier);
}

enum LockerRoomFaction {
  domesticCore('Yerli Çekirdek', '', 'Takımın yerli ve kıdemli omurgası.'),
  foreignLegion('Yabancı Lejyonu', '', 'Yüksek maaşlı uluslararası yıldızlar.'),
  academyYouth('Akademi Gençleri', '', 'Altyapıdan yetişen aç ve hırslı yetenekler.'),
  loneWolf('Bağımsız Profesyonel', 'WOLF', 'Kliklerden uzak, sadece işine odaklanan.');

  final String label;
  final String icon;
  final String description;

  const LockerRoomFaction(this.label, this.icon, this.description);
}

enum SquadRole {
  star('Yıldız Oyuncu', 'Her maç ilk 11 beklenir.', 0.9, 1.5),
  first11('İlk 11', 'Düzenli olarak sahaya çıkmak ister.', 0.75, 1.2),
  rotation('Rotasyon', 'Sık sık süre bulmayı hedefler.', 0.45, 1.0),
  bench('Yedek / Gelecek', 'Gerektiğinde görev alır, şikayet etmez.', 0.15, 0.8);

  final String label;
  final String description;
  final double minStartExpectation;
  final double salaryMultiplier;

  const SquadRole(this.label, this.description, this.minStartExpectation, this.salaryMultiplier);
}

enum InjurySeverity {
  none('Sağlıklı', 'Maça hazır.'),
  minor('Hafif Zorlanma', '1-2 maç dinlenme önerilir.'),
  moderate('Orta Derece', '3-5 maç tedavi gerektirir.'),
  severe('Ağır Sakatlık', '6-12 maç sahalardan uzak.'),
  critical('Kritik', 'Sezonu kapatabilir.');

  final String label;
  final String riskDescription;

  const InjurySeverity(this.label, this.riskDescription);
}

class ContractOfferResult {
  final bool accepted;
  final int moraleDelta;
  final String reason;
  final int finalWeeklyWage;
  final int finalSeasons;

  const ContractOfferResult({
    required this.accepted,
    required this.moraleDelta,
    required this.reason,
    required this.finalWeeklyWage,
    required this.finalSeasons,
  });
}

class Player {
  final String id;
  final String firstName;
  final String lastName;
  final String countryCode;
  final int age;
  final Position position;
  final List<Position> altPositions;

  // 7 Çekirdek Nitelik (1 - 99)
  final int pace;
  final int technique;
  final int shooting;
  final int passing;
  final int defending;
  final int physical;
  final int mentality;

  // Gelişim & Psikoloji
  final int potential; // 1 - 99
  final int consistency; // 1 - 99
  final int injuryProneness; // 1 - 99
  final PersonalityType personality;
  final TrainingIntensity trainingIntensity;
  final SquadRole squadRole;
  final bool isCaptain;
  final int loyalty; // 0 - 100

  // Dinamik Durum (0 - 100)
  final int morale;
  final int fitness;
  final double form; // 1.0 - 10.0
  final int sharpness; // 0 - 100

  // Sözleşme & Ekonomi
  final int weeklyWage;
  final int contractSeasonsLeft;
  final int releaseClause;
  final bool isYouthProduct;
  final bool isTransferListed;
  final bool isBannedFromSquad;

  // Sakatlık
  final int injuryMatchesLeft;
  final String? injuryType;
  final InjurySeverity injurySeverity;

  // Sezonluk İstatistikler
  final int appearances;
  final int goals;
  final int assists;
  final int cleanSheets;
  final List<double> recentRatings;
  final List<int> seasonRatings;
  final String faceSeed;

  // Başkanlık & Soyunma Odası Özel Alanları
  final int jerseyNumber;
  final LockerRoomFaction faction;
  final int matchBonusOffered;
  final bool hasLuxuryGift;
  final int disciplinaryFinesCount;
  final int loyaltyBonus;
  final int goalBonus;
  final int cleanSheetBonus;

  const Player({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.age,
    required this.position,
    this.altPositions = const [],
    required this.pace,
    required this.technique,
    required this.shooting,
    required this.passing,
    required this.defending,
    required this.physical,
    required this.mentality,
    required this.potential,
    this.consistency = 70,
    this.injuryProneness = 30,
    this.personality = PersonalityType.humble,
    this.trainingIntensity = TrainingIntensity.normal,
    this.squadRole = SquadRole.first11,
    this.isCaptain = false,
    this.loyalty = 75,
    this.morale = 75,
    this.fitness = 100,
    this.form = 6.5,
    this.sharpness = 85,
    required this.weeklyWage,
    this.contractSeasonsLeft = 2,
    this.releaseClause = 0,
    this.isYouthProduct = false,
    this.isTransferListed = false,
    this.isBannedFromSquad = false,
    this.injuryMatchesLeft = 0,
    this.injuryType,
    this.injurySeverity = InjurySeverity.none,
    this.appearances = 0,
    this.goals = 0,
    this.assists = 0,
    this.cleanSheets = 0,
    this.recentRatings = const [],
    this.seasonRatings = const [],
    this.faceSeed = '',
    this.jerseyNumber = 10,
    this.faction = LockerRoomFaction.domesticCore,
    this.matchBonusOffered = 0,
    this.hasLuxuryGift = false,
    this.disciplinaryFinesCount = 0,
    this.loyaltyBonus = 0,
    this.goalBonus = 0,
    this.cleanSheetBonus = 0,
  });

  String get fullName => '$firstName $lastName';
  int get overall => ovr;
  int get pac => pace;
  int get sho => shooting;
  int get pas => passing;
  int get dri => technique;
  int get def => defending;
  int get phy => physical;
  bool get isInjured => injuryMatchesLeft > 0;

  String get injuryDescription {
    if (!isInjured) return 'Sağlıklı';
    final t = injuryType ?? 'Sakatlık';
    return '$t (${injurySeverity.label} - $injuryMatchesLeft maç)';
  }

  int getCoachChemistry(String? tacticalStyle) {
    if (tacticalStyle == null || tacticalStyle.isEmpty) return 75;
    var base = 70;
    final styleLower = tacticalStyle.toLowerCase();

    if (styleLower.contains('ofansif') || styleLower.contains('hücum')) {
      if (position.isForward || position == Position.am) base += 15;
      if (personality == PersonalityType.ambitious || personality == PersonalityType.leader) base += 10;
    } else if (styleLower.contains('defansif') || styleLower.contains('kontra')) {
      if (position.isDefender || position == Position.dm) base += 15;
      if (personality == PersonalityType.professional || personality == PersonalityType.loyal) base += 10;
    } else if (styleLower.contains('baskı') || styleLower.contains('pres')) {
      if (physical >= 75 && mentality >= 75) base += 15;
      if (personality == PersonalityType.temperamental) base -= 10;
    } else {
      base += 5;
    }

    if (morale > 80) base += 5;
    if (morale < 50) base -= 15;
    return base.clamp(20, 99);
  }

  bool get wantsTransfer {
    if (morale <= 35) return true;
    if (squadRole == SquadRole.star && appearances == 0 && morale < 50) return true;
    if (personality == PersonalityType.mercenary && loyalty < 40) return true;
    return false;
  }

  String get naturalLanguageSummary {
    final buffer = StringBuffer();
    if (isCaptain) buffer.write('SHIELD Takım Kaptanı. ');
    if (wantsTransfer) {
      buffer.write('[UYARI] Yeterli süre alamadığı veya mutsuz olduğu için ayrılmak istiyor. ');
    } else if (morale >= 85) {
      buffer.write('[FORM] Takımda çok mutlu ve motive. ');
    }
    if (goals > 3) buffer.write('[GOL] Bu sezon $goals gol kaydetti. ');
    if (assists > 2) buffer.write(' $assists asist yaptı. ');
    if (recentRatings.isNotEmpty) {
      final avg = recentRatings.reduce((a, b) => a + b) / recentRatings.length;
      buffer.write('[GRAFIK] Son maç ortalaması: ${avg.toStringAsFixed(1)}. ');
    }
    buffer.write('Kişilik: ${personality.label}.');
    return buffer.toString().trim();
  }

  /// Sözleşme Teklifini Değerlendir
  ContractOfferResult evaluateContractOffer({
    required int offeredWeeklyWage,
    required int seasons,
    required int signingBonus,
    required SquadRole promisedRole,
  }) {
    final expectedWage = (weeklyWage * (1.15 + (ovr > 75 ? 0.2 : 0.05))).round();
    final wageRatio = offeredWeeklyWage / (expectedWage == 0 ? 1 : expectedWage);

    if (wageRatio >= 0.95) {
      final bonusSatisfaction = signingBonus >= weeklyWage * 2;
      return ContractOfferResult(
        accepted: true,
        moraleDelta: bonusSatisfaction ? 15 : 8,
        reason: 'Teklif şartlarını memnuniyetle kabul etti.',
        finalWeeklyWage: offeredWeeklyWage,
        finalSeasons: seasons,
      );
    } else if (wageRatio >= 0.80 && promisedRole == SquadRole.star && loyalty >= 70) {
      return ContractOfferResult(
        accepted: true,
        moraleDelta: 5,
        reason: 'Kulübe olan sevgisi ve yıldız rolü sebebiyle teklifi kabul etti.',
        finalWeeklyWage: offeredWeeklyWage,
        finalSeasons: seasons,
      );
    } else {
      return ContractOfferResult(
        accepted: false,
        moraleDelta: -10,
        reason: 'Maaş beklentisinin altında kaldığı için teklifi reddetti.',
        finalWeeklyWage: weeklyWage,
        finalSeasons: contractSeasonsLeft,
      );
    }
  }

  /// Ağırlıklı OVR (Genel Güç) Hesabı — §9.2
  int get ovr => calculateOvrFor(position);

  /// Belirli bir pozisyondaki OVR hesabı (§9.2)
  int calculateOvrFor(Position pos) {
    final weights = kPositionWeights[pos] ?? kPositionWeights[position]!;
    return weights.calculateOvr(
      pace: pace,
      technique: technique,
      shooting: shooting,
      passing: passing,
      defending: defending,
      physical: physical,
      mentality: mentality,
    );
  }

  /// Yıldız Derecelendirmesi (1 - 5+)
  int get stars {
    final currentOvr = ovr;
    if (currentOvr < 55) return 1;
    if (currentOvr < 65) return 2;
    if (currentOvr < 75) return 3;
    if (currentOvr < 85) return 4;
    return 5;
  }

  /// Nadirlik Rengi Adı
  String get rarityLabel {
    final s = stars;
    if (s == 1) return 'Amatör (1)';
    if (s == 2) return 'Profesyonel (2)';
    if (s == 3) return 'Kaliteli (3)';
    if (s == 4) return 'Yıldız (4)';
    return ovr >= 93 ? 'İkon (5+)' : 'Efsane (5)';
  }

  /// Lig Kademesine Göre Piyasa Değeri Formülü — §9.9
  int marketValueIn(int leagueTier) {
    final currentOvr = ovr;
    final base = math.pow(1.16, (currentOvr - 50)) * 100000.0;
    final ageFactor = (age <= 19)
        ? 1.55
        : (age <= 23 ? 1.35 : (age <= 27 ? 1.00 : (age <= 30 ? 0.70 : (age <= 33 ? 0.38 : 0.15))));
    final potFactor = 1.0 + math.max(0, (potential - currentOvr)) * 0.028;
    final contractFactor = (contractSeasonsLeft >= 3)
        ? 1.15
        : (contractSeasonsLeft == 2 ? 1.00 : (contractSeasonsLeft == 1 ? 0.72 : 0.40));
    final formFactor = (1.0 + form * 0.035).clamp(0.80, 1.25);
    final leagueFactor = (0.55 + (21 - leagueTier) * 0.048).clamp(0.55, 1.55);

    return (base * ageFactor * potFactor * contractFactor * formFactor * leagueFactor)
        .round()
        .clamp(1000, 250000000);
  }

  /// Piyasa Değeri (Varsayılan Lig 20 Uyumluluğu)
  int get marketValue => marketValueIn(20);

  /// Beklenen Haftalık Maaş Formülü — §9.10
  int expectedWeeklyWage(int leagueTier) {
    final val = marketValueIn(leagueTier);
    double egoMultiplier;
    switch (personality) {
      case PersonalityType.ambitious:
        egoMultiplier = 1.35;
        break;
      case PersonalityType.mercenary:
        egoMultiplier = 1.20;
        break;
      case PersonalityType.rebel:
        egoMultiplier = 1.15;
        break;
      case PersonalityType.professional:
      case PersonalityType.leader:
        egoMultiplier = 1.00;
        break;
      case PersonalityType.loyal:
      case PersonalityType.humble:
        egoMultiplier = 0.85;
        break;
      default:
        egoMultiplier = 1.00;
        break;
    }
    final leagueTierMultiplier = (0.60 + (21 - leagueTier) * 0.045).clamp(0.60, 1.50);
    return (val * 0.0038 * egoMultiplier * leagueTierMultiplier).round().clamp(150, 1000000);
  }

  /// Oyuncunun Maaşından Memnun Olup Olmadığı (§9.10)
  bool isUnderpaid(int leagueTier) => weeklyWage < expectedWeeklyWage(leagueTier) * 0.85;

  Player copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? countryCode,
    int? age,
    Position? position,
    List<Position>? altPositions,
    int? pace,
    int? technique,
    int? shooting,
    int? passing,
    int? defending,
    int? physical,
    int? mentality,
    int? potential,
    int? consistency,
    int? injuryProneness,
    PersonalityType? personality,
    TrainingIntensity? trainingIntensity,
    SquadRole? squadRole,
    bool? isCaptain,
    int? loyalty,
    int? morale,
    int? fitness,
    double? form,
    int? sharpness,
    int? weeklyWage,
    int? contractSeasonsLeft,
    int? releaseClause,
    bool? isYouthProduct,
    bool? isTransferListed,
    bool? isBannedFromSquad,
    int? injuryMatchesLeft,
    String? injuryType,
    InjurySeverity? injurySeverity,
    bool clearInjury = false,
    int? appearances,
    int? goals,
    int? assists,
    int? cleanSheets,
    List<double>? recentRatings,
    List<int>? seasonRatings,
    String? faceSeed,
    int? jerseyNumber,
    LockerRoomFaction? faction,
    int? matchBonusOffered,
    bool? hasLuxuryGift,
    int? disciplinaryFinesCount,
    int? loyaltyBonus,
    int? goalBonus,
    int? cleanSheetBonus,
  }) {
    return Player(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      countryCode: countryCode ?? this.countryCode,
      age: age ?? this.age,
      position: position ?? this.position,
      altPositions: altPositions ?? this.altPositions,
      pace: pace ?? this.pace,
      technique: technique ?? this.technique,
      shooting: shooting ?? this.shooting,
      passing: passing ?? this.passing,
      defending: defending ?? this.defending,
      physical: physical ?? this.physical,
      mentality: mentality ?? this.mentality,
      potential: potential ?? this.potential,
      consistency: consistency ?? this.consistency,
      injuryProneness: injuryProneness ?? this.injuryProneness,
      personality: personality ?? this.personality,
      trainingIntensity: trainingIntensity ?? this.trainingIntensity,
      squadRole: squadRole ?? this.squadRole,
      isCaptain: isCaptain ?? this.isCaptain,
      loyalty: loyalty ?? this.loyalty,
      morale: morale ?? this.morale,
      fitness: fitness ?? this.fitness,
      form: form ?? this.form,
      sharpness: sharpness ?? this.sharpness,
      weeklyWage: weeklyWage ?? this.weeklyWage,
      contractSeasonsLeft: contractSeasonsLeft ?? this.contractSeasonsLeft,
      releaseClause: releaseClause ?? this.releaseClause,
      isYouthProduct: isYouthProduct ?? this.isYouthProduct,
      isTransferListed: isTransferListed ?? this.isTransferListed,
      isBannedFromSquad: isBannedFromSquad ?? this.isBannedFromSquad,
      injuryMatchesLeft: clearInjury ? 0 : (injuryMatchesLeft ?? this.injuryMatchesLeft),
      injuryType: clearInjury ? null : (injuryType ?? this.injuryType),
      injurySeverity: clearInjury ? InjurySeverity.none : (injurySeverity ?? this.injurySeverity),
      appearances: appearances ?? this.appearances,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      cleanSheets: cleanSheets ?? this.cleanSheets,
      recentRatings: recentRatings ?? this.recentRatings,
      seasonRatings: seasonRatings ?? this.seasonRatings,
      faceSeed: faceSeed ?? this.faceSeed,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      faction: faction ?? this.faction,
      matchBonusOffered: matchBonusOffered ?? this.matchBonusOffered,
      hasLuxuryGift: hasLuxuryGift ?? this.hasLuxuryGift,
      disciplinaryFinesCount: disciplinaryFinesCount ?? this.disciplinaryFinesCount,
      loyaltyBonus: loyaltyBonus ?? this.loyaltyBonus,
      goalBonus: goalBonus ?? this.goalBonus,
      cleanSheetBonus: cleanSheetBonus ?? this.cleanSheetBonus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'countryCode': countryCode,
        'age': age,
        'position': position.name,
        'altPositions': altPositions.map((p) => p.name).toList(),
        'pace': pace,
        'technique': technique,
        'shooting': shooting,
        'passing': passing,
        'defending': defending,
        'physical': physical,
        'mentality': mentality,
        'potential': potential,
        'consistency': consistency,
        'injuryProneness': injuryProneness,
        'personality': personality.name,
        'trainingIntensity': trainingIntensity.name,
        'squadRole': squadRole.name,
        'isCaptain': isCaptain,
        'loyalty': loyalty,
        'morale': morale,
        'fitness': fitness,
        'form': form,
        'sharpness': sharpness,
        'weeklyWage': weeklyWage,
        'contractSeasonsLeft': contractSeasonsLeft,
        'releaseClause': releaseClause,
        'isYouthProduct': isYouthProduct,
        'isTransferListed': isTransferListed,
        'isBannedFromSquad': isBannedFromSquad,
        'injuryMatchesLeft': injuryMatchesLeft,
        'injuryType': injuryType,
        'injurySeverity': injurySeverity.name,
        'appearances': appearances,
        'goals': goals,
        'assists': assists,
        'cleanSheets': cleanSheets,
        'recentRatings': recentRatings,
        'seasonRatings': seasonRatings,
        'faceSeed': faceSeed,
        'jerseyNumber': jerseyNumber,
        'faction': faction.name,
        'matchBonusOffered': matchBonusOffered,
        'hasLuxuryGift': hasLuxuryGift,
        'disciplinaryFinesCount': disciplinaryFinesCount,
        'loyaltyBonus': loyaltyBonus,
        'goalBonus': goalBonus,
        'cleanSheetBonus': cleanSheetBonus,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        countryCode: json['countryCode'] as String? ?? 'TR',
        age: json['age'] as int,
        position: Position.values.firstWhere(
          (p) => p.name == json['position'],
          orElse: () => Position.cm,
        ),
        altPositions: (json['altPositions'] as List<dynamic>?)
                ?.map((e) => Position.values.firstWhere((p) => p.name == e, orElse: () => Position.cm))
                .toList() ??
            const [],
        pace: json['pace'] as int,
        technique: json['technique'] as int,
        shooting: json['shooting'] as int,
        passing: json['passing'] as int,
        defending: json['defending'] as int,
        physical: json['physical'] as int,
        mentality: json['mentality'] as int,
        potential: json['potential'] as int,
        consistency: json['consistency'] as int? ?? 70,
        injuryProneness: json['injuryProneness'] as int? ?? 30,
        personality: PersonalityType.values.firstWhere(
          (p) => p.name == json['personality'],
          orElse: () => PersonalityType.humble,
        ),
        trainingIntensity: TrainingIntensity.values.firstWhere(
          (t) => t.name == json['trainingIntensity'],
          orElse: () => TrainingIntensity.normal,
        ),
        squadRole: SquadRole.values.firstWhere(
          (r) => r.name == json['squadRole'],
          orElse: () => SquadRole.first11,
        ),
        isCaptain: json['isCaptain'] as bool? ?? false,
        loyalty: json['loyalty'] as int? ?? 75,
        morale: json['morale'] as int? ?? 75,
        fitness: json['fitness'] as int? ?? 100,
        form: (json['form'] as num?)?.toDouble() ?? 6.5,
        sharpness: json['sharpness'] as int? ?? 85,
        weeklyWage: json['weeklyWage'] as int,
        contractSeasonsLeft: json['contractSeasonsLeft'] as int? ?? 2,
        releaseClause: json['releaseClause'] as int? ?? 0,
        isYouthProduct: json['isYouthProduct'] as bool? ?? false,
        isTransferListed: json['isTransferListed'] as bool? ?? false,
        isBannedFromSquad: json['isBannedFromSquad'] as bool? ?? false,
        injuryMatchesLeft: json['injuryMatchesLeft'] as int? ?? 0,
        injuryType: json['injuryType'] as String?,
        injurySeverity: InjurySeverity.values.firstWhere(
          (s) => s.name == json['injurySeverity'],
          orElse: () => InjurySeverity.none,
        ),
        appearances: json['appearances'] as int? ?? 0,
        goals: json['goals'] as int? ?? 0,
        assists: json['assists'] as int? ?? 0,
        cleanSheets: json['cleanSheets'] as int? ?? 0,
        recentRatings: (json['recentRatings'] as List<dynamic>?)
                ?.map((e) => (e as num).toDouble())
                .toList() ??
            const [],
        seasonRatings: (json['seasonRatings'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            const [],
        faceSeed: json['faceSeed'] as String? ?? '',
        jerseyNumber: json['jerseyNumber'] as int? ?? 10,
        faction: LockerRoomFaction.values.firstWhere(
          (f) => f.name == json['faction'],
          orElse: () => LockerRoomFaction.domesticCore,
        ),
        matchBonusOffered: json['matchBonusOffered'] as int? ?? 0,
        hasLuxuryGift: json['hasLuxuryGift'] as bool? ?? false,
        disciplinaryFinesCount: json['disciplinaryFinesCount'] as int? ?? 0,
        loyaltyBonus: json['loyaltyBonus'] as int? ?? 0,
        goalBonus: json['goalBonus'] as int? ?? 0,
        cleanSheetBonus: json['cleanSheetBonus'] as int? ?? 0,
      );
}
