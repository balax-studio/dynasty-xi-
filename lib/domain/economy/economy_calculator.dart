// domain/economy/economy_calculator.dart
// Pure Dart. Match day ticket revenue, broadcasting rights, merchandise and weekly club expenses.

import 'dart:math' as math;
import '../entities/club.dart';
import '../entities/facility.dart';

class MatchDayRevenue {
  final int ticketRevenue;
  final int attendance;
  final double attendanceRate;
  final int matchDayMerchandise;
  final int totalRevenue;

  const MatchDayRevenue({
    required this.ticketRevenue,
    required this.attendance,
    required this.attendanceRate,
    required this.matchDayMerchandise,
    required this.totalRevenue,
  });
}

class EconomyCalculator {
  /// Bilet ve Maç Günü Geliri Hesabı — Ek C.4
  static MatchDayRevenue calculateMatchDayRevenue({
    required Club club,
    required int leagueRank,
  }) {
    final capacity = club.stadiumCapacity;
    final fanSatisfaction = club.meters.fans;

    // Önerilen Fiyat: 6 + (21 - ligKademesi) * 2.4
    final suggestedPrice = 6.0 + (21 - club.leagueTier) * 2.4;
    final actualPrice = club.ticketPrice;
    final priceElasticity = ((actualPrice - suggestedPrice) / suggestedPrice) * 0.4;

    // Sıra Bonusu (İlk 3'teyse doluluk artar)
    final rankBonus = leagueRank <= 3 ? (4 - leagueRank) * 0.05 : 0.0;

    // Doluluk Oranı: clamp(0.35 + memnuniyet/220 + sıraBonusu - fiyatEsnekliği, 0.15, 1.00)
    final rawRate = 0.35 + (fanSatisfaction / 220.0) + rankBonus - priceElasticity;
    final attendanceRate = rawRate.clamp(0.15, 1.0);
    final attendance = (capacity * attendanceRate).round();

    final ticketRevenue = attendance * actualPrice;

    // Maç Günü Ekstra Ürün Satışı
    final fanShopLvl = club.getFacilityLevel(FacilityType.fanShop);
    final merchandise = (attendance * 0.15 * fanShopLvl * (fanSatisfaction / 100.0)).round();

    return MatchDayRevenue(
      ticketRevenue: ticketRevenue,
      attendance: attendance,
      attendanceRate: attendanceRate,
      matchDayMerchandise: merchandise,
      totalRevenue: ticketRevenue + merchandise,
    );
  }

  /// Haftalık Yayın Geliri — Ek C.4
  /// yayınGeliri = ligTablosu[lig] * (1 + (6 - min(sıra, 6)) * 0.04)
  static int calculateWeeklyBroadcasting({
    required int leagueTier,
    required int leagueRank,
  }) {
    // Lig kademesine göre taban haftalık yayın hakkı
    final baseIncome = (21 - leagueTier) * 1400;
    final rankBonus = (6 - math.min(leagueRank, 6)) * 0.04;
    return (baseIncome * (1.0 + rankBonus)).round();
  }

  /// Haftalık Kulüp Mağazası Satış Geliri
  static int calculateWeeklyFanShop({
    required Club club,
  }) {
    final fanShopLvl = club.getFacilityLevel(FacilityType.fanShop);
    if (fanShopLvl <= 0) return 200;
    final fanSatisfaction = club.meters.fans;
    final baseFans = (21 - club.leagueTier) * 1500;
    return (baseFans * fanShopLvl * 0.25 * (fanSatisfaction / 100.0)).round();
  }

  /// Haftalık Toplam Net Akış (Kasa değişimi)
  static int calculateWeeklyNetCashflow({
    required Club club,
    required int leagueRank,
  }) {
    final broadcast = calculateWeeklyBroadcasting(
      leagueTier: club.leagueTier,
      leagueRank: leagueRank,
    );
    final fanShop = calculateWeeklyFanShop(club: club);
    final sponsor = club.sponsorWeeklyIncome;

    final totalIncome = broadcast + fanShop + sponsor;
    final totalExpense = club.totalWeeklyWages + club.totalWeeklyMaintenance;

    return totalIncome - totalExpense;
  }
}
