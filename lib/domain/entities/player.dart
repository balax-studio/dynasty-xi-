// domain/entities/player.dart
// Pure Dart. Player entity with position-weighted OVR, dynamic valuation, stats, personality & RPG attributes.

import 'dart:math' as math;

enum Position {
  gk('Kaleci', 'GK', '🧤'),
  cb('Stoper', 'CB', '🛡️'),
  lb('Sol Bek', 'LB', '🛡️'),
  rb('Sağ Bek', 'RB', '🛡️'),
  dm('Ön Libero', 'DM', '⚙️'),
  cm('Merkez Orta Saha', 'CM', '🎯'),
  am('Ofansif Orta Saha', 'AM', '🪄'),
  lw('Sol Kanat', 'LW', '⚡'),
  rw('Sağ Kanat', 'RW', '⚡'),
  st('Santrfor', 'ST', '⚽');

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

  bool get wantsTransfer {
    if (morale <= 35) return true;
    if (squadRole == SquadRole.star && appearances == 0 && morale < 50) return true;
    if (personality == PersonalityType.mercenary && loyalty < 40) return true;
    return false;
  }

  String get naturalLanguageSummary {
    final buffer = StringBuffer();
    if (isCaptain) buffer.write('🛡️ Takım Kaptanı. ');
    if (wantsTransfer) {
      buffer.write('⚠️ Yeterli süre alamadığı veya mutsuz olduğu için ayrılmak istiyor. ');
    } else if (morale >= 85) {
      buffer.write('🔥 Takımda çok mutlu ve motive. ');
    }
    if (goals > 3) buffer.write('⚽ Bu sezon $goals gol kaydetti. ');
    if (assists > 2) buffer.write('👟 $assists asist yaptı. ');
    if (recentRatings.isNotEmpty) {
      final avg = recentRatings.reduce((a, b) => a + b) / recentRatings.length;
      buffer.write('📊 Son maç ortalaması: ${avg.toStringAsFixed(1)}. ');
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

  /// Ağırlıklı OVR (Genel Güç) Hesabı — Ek C.1
  int get ovr {
    double score;
    switch (position) {
      case Position.gk:
        score = defending * 0.35 + physical * 0.30 + mentality * 0.20 + pace * 0.10 + passing * 0.05;
        break;
      case Position.cb:
        score = defending * 0.40 + physical * 0.25 + mentality * 0.15 + pace * 0.10 + passing * 0.10;
        break;
      case Position.lb:
      case Position.rb:
        score = defending * 0.25 + pace * 0.25 + passing * 0.20 + physical * 0.15 + technique * 0.15;
        break;
      case Position.dm:
        score = defending * 0.30 + passing * 0.25 + physical * 0.20 + mentality * 0.15 + technique * 0.10;
        break;
      case Position.cm:
        score = passing * 0.30 + technique * 0.25 + mentality * 0.15 + physical * 0.15 + shooting * 0.15;
        break;
      case Position.am:
        score = technique * 0.30 + passing * 0.25 + shooting * 0.20 + pace * 0.15 + mentality * 0.10;
        break;
      case Position.lw:
      case Position.rw:
        score = pace * 0.35 + technique * 0.25 + shooting * 0.20 + passing * 0.10 + physical * 0.10;
        break;
      case Position.st:
        score = shooting * 0.35 + physical * 0.20 + pace * 0.20 + technique * 0.15 + mentality * 0.10;
        break;
    }
    return score.round().clamp(35, 99);
  }

  /// Yıldız Derecelendirmesi (1★ - 5★+)
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
    if (s == 1) return 'Amatör (1★)';
    if (s == 2) return 'Profesyonel (2★)';
    if (s == 3) return 'Kaliteli (3★)';
    if (s == 4) return 'Yıldız (4★)';
    return ovr >= 93 ? 'İkon (5★+)' : 'Efsane (5★)';
  }

  /// Piyasa Değeri Formülü — Ek C.1
  int get marketValue {
    final currentOvr = ovr;
    final base = math.pow(1.35, (currentOvr - 40) / 4.2) * 1000.0;
    final ageFactor = (age < 21) ? 1.35 : (age < 27 ? 1.15 : (age < 31 ? 0.90 : 0.65));
    final potFactor = 1.0 + math.max(0, (potential - currentOvr)) * 0.015;
    final contractFactor = contractSeasonsLeft > 1 ? 1.1 : 0.85;
    final formFactor = (form / 6.5).clamp(0.8, 1.25);

    return (base * ageFactor * potFactor * contractFactor * formFactor).round().clamp(1000, 250000000);
  }

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
    int? injuryMatchesLeft,
    String? injuryType,
    InjurySeverity? injurySeverity,
    int? appearances,
    int? goals,
    int? assists,
    int? cleanSheets,
    List<double>? recentRatings,
    List<int>? seasonRatings,
    String? faceSeed,
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
      injuryMatchesLeft: injuryMatchesLeft ?? this.injuryMatchesLeft,
      injuryType: injuryType ?? this.injuryType,
      injurySeverity: injurySeverity ?? this.injurySeverity,
      appearances: appearances ?? this.appearances,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      cleanSheets: cleanSheets ?? this.cleanSheets,
      recentRatings: recentRatings ?? this.recentRatings,
      seasonRatings: seasonRatings ?? this.seasonRatings,
      faceSeed: faceSeed ?? this.faceSeed,
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
      );
}
