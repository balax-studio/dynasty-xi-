// domain/facilities/training_camp.dart
// Mid-Season & Pre-Season Training Camp Packages, Fitness Regeneration, and Team Bonding

import '../entities/club.dart';

enum CampLocation {
  localFacility('Kulüp Kendi Tesisleri', 'Maliyetsiz yerel antrenman tesislerinde temel kondisyon yüklemesi.'),
  antalyaResort('Antalya Belek Kampı', 'Sıcak iklim, 5 yıldızlı tesisler, hazırlık maçları ve yüksek takım kaynaşması.'),
  alpsEliteHighAltitude('İsviçre Alpleri Yüksek İrtifa Kampı', 'Oksijen yüklemesi, üst düzey analiz merkezleri ve elit taktiksel disiplin.');

  final String title;
  final String description;
  const CampLocation(this.title, this.description);
}

class TrainingCampPackage {
  final CampLocation location;
  final String title;
  final String description;
  final int cost;
  final int staminaBonus;
  final int lockerRoomMoraleBonus;
  final int boardTrustBonus;
  final int tacticalFamiliarityBonus;
  final String iconCode;

  const TrainingCampPackage({
    required this.location,
    required this.title,
    required this.description,
    required this.cost,
    required this.staminaBonus,
    required this.lockerRoomMoraleBonus,
    required this.boardTrustBonus,
    required this.tacticalFamiliarityBonus,
    required this.iconCode,
  });

  int get staminaRegen => staminaBonus;
  int get moraleBoost => lockerRoomMoraleBonus;

  static List<TrainingCampPackage> get allPackages => availablePackages;

  static List<TrainingCampPackage> get availablePackages => const [
        TrainingCampPackage(
          location: CampLocation.localFacility,
          title: 'KULÜP YEREL TESİS KAMPI',
          description: 'Ek bütçe harcamadan tesislerimizde kondisyon ve taktik çalışma.',
          cost: 0,
          staminaBonus: 5,
          lockerRoomMoraleBonus: 2,
          boardTrustBonus: 0,
          tacticalFamiliarityBonus: 1,
          iconCode: 'stadium',
        ),
        TrainingCampPackage(
          location: CampLocation.antalyaResort,
          title: 'ANTALYA BELEK RESORT KAMPI',
          description: 'Kış ikliminden uzaklaşarak üst düzey moral depolama ve hazırlık maçları.',
          cost: 15000,
          staminaBonus: 15,
          lockerRoomMoraleBonus: 10,
          boardTrustBonus: 5,
          tacticalFamiliarityBonus: 1,
          iconCode: 'sun',
        ),
        TrainingCampPackage(
          location: CampLocation.alpsEliteHighAltitude,
          title: 'İSVİÇRE ALPLERİ ELİT İRTİFA KAMPI',
          description: 'Yüksek irtifada maksimum oksijen yüklemesi, elit taktiksel disiplin ve şampiyonluk odağı.',
          cost: 40000,
          staminaBonus: 25,
          lockerRoomMoraleBonus: 15,
          boardTrustBonus: 10,
          tacticalFamiliarityBonus: 2,
          iconCode: 'crown',
        ),
      ];

  static CampExecutionResult executeCamp({
    required Club club,
    required TrainingCampPackage package,
  }) {
    final nextCash = club.meters.cash - package.cost;
    final nextLockerRoom = (club.meters.lockerRoom + package.lockerRoomMoraleBonus).clamp(0, 100);
    final nextBoardTrust = (club.meters.boardTrust + package.boardTrustBonus).clamp(0, 100);

    final updatedMeters = club.meters.copyWith(
      cash: nextCash,
      lockerRoom: nextLockerRoom,
      boardTrust: nextBoardTrust,
    );

    // Refresh squad fitness/morale
    final updatedSquad = club.squad.map((player) {
      final nextFitness = (player.fitness + package.staminaBonus).clamp(0, 100);
      final nextMorale = (player.morale + package.lockerRoomMoraleBonus).clamp(0, 100);
      return player.copyWith(
        fitness: nextFitness,
        morale: nextMorale,
      );
    }).toList();

    final updatedClub = club.copyWith(
      meters: updatedMeters,
      squad: updatedSquad,
    );

    return CampExecutionResult(
      updatedClub: updatedClub,
      summaryMessage: '${package.title} başarıyla tamamlandı! (Kondisyon: +${package.staminaBonus}, Moral: +${package.lockerRoomMoraleBonus})',
    );
  }
}

class CampExecutionResult {
  final Club updatedClub;
  final String summaryMessage;

  const CampExecutionResult({
    required this.updatedClub,
    required this.summaryMessage,
  });

  bool get isSuccess => true;
  String get message => summaryMessage;
}
