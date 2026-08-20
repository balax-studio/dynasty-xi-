// domain/navigation/dynasty_navigation_registry.dart
// Centralized catalog of all Dynasty XI sub-screens with dynamic badge evaluation, category grouping, and customizable pinned shortcuts.

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../entities/game_state.dart';
import '../../presentation/screens/affiliate_clubs_screen.dart';
import '../../presentation/screens/board_faction_screen.dart';
import '../../presentation/screens/board_room_screen.dart';
import '../../presentation/screens/boardroom_summit_screen.dart';
import '../../presentation/screens/clubs_association_summit_screen.dart';
import '../../presentation/screens/cup_tournament_screen.dart';
import '../../presentation/screens/facilities_screen.dart';
import '../../presentation/screens/finance_screen.dart';
import '../../presentation/screens/grassroots_tournament_screen.dart';
import '../../presentation/screens/head_coach_dialogue_screen.dart';
import '../../presentation/screens/head_coach_hiring_screen.dart';
import '../../presentation/screens/president_luxury_lifestyle_screen.dart';
import '../../presentation/screens/press_conference_screen.dart';
import '../../presentation/screens/prestige_screen.dart';
import '../../presentation/screens/scouting_screen.dart';
import '../../presentation/screens/staff_screen.dart';
import '../../presentation/screens/trophy_room_screen.dart';
import '../../presentation/screens/u19_squad_screen.dart';
import '../../presentation/screens/youth_academy_screen.dart';

enum DynastyShortcutCategory {
  management('YÖNETİM & DİREKTÖRLÜK', '👔'),
  competitions('TURNUVALAR & ÖDÜLLER', '🏆'),
  clubAssets('KULÜP TESİSLERİ & KADRO', '🏟️'),
  mediaAndFinance('MEDYA, SCOUT & FİNANS', '📊'),
  specialEvents('ÖZEL ZİRVELER & YAŞAM', '⭐');

  final String title;
  final String icon;
  const DynastyShortcutCategory(this.title, this.icon);
}

class DynastyShortcutDefinition {
  final String id;
  final String label;
  final String icon;
  final Color color;
  final DynastyShortcutCategory category;
  final String? Function(GameState state)? badgeEvaluator;
  final Widget Function(BuildContext context) screenBuilder;

  const DynastyShortcutDefinition({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.category,
    required this.screenBuilder,
    this.badgeEvaluator,
  });
}

class DynastyNavigationRegistry {
  static const List<String> defaultShortcutIds = [
    'head_coach',
    'head_coach_dialogue',
    'boardroom_summit',
    'cup_tournament',
    'prestige',
    'facilities',
    'staff',
    'u19_squad',
    'board_room',
    'press_conference',
    'scouting',
    'trophy_room',
  ];

  static final List<DynastyShortcutDefinition> allShortcuts = [
    // 1. Yönetim & Direktörlük
    DynastyShortcutDefinition(
      id: 'head_coach',
      label: 'TEKNİK DİREKTÖR MERKEZİ',
      icon: '👔',
      color: AppColors.neonLime,
      category: DynastyShortcutCategory.management,
      badgeEvaluator: (state) => state.headCoach == null ? 'ATAMA YAP' : null,
      screenBuilder: (_) => const HeadCoachHiringScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'head_coach_dialogue',
      label: 'HOCA SOHBET ODASI',
      icon: '💬',
      color: AppColors.neonCyan,
      category: DynastyShortcutCategory.management,
      badgeEvaluator: (state) => state.headCoach != null ? 'GÖRÜŞ' : null,
      screenBuilder: (_) => const HeadCoachDialogueScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'boardroom_summit',
      label: 'BAŞKANLIK ZİRVESİ',
      icon: '🏛️',
      color: AppColors.accentGold,
      category: DynastyShortcutCategory.management,
      badgeEvaluator: (state) => state.userClub.meters.boardTrust < 40 ? 'KRİTİK' : null,
      screenBuilder: (_) => const BoardroomSummitScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'board_room',
      label: 'YÖNETİM KURULU',
      icon: '🤝',
      color: AppColors.neonCyan,
      category: DynastyShortcutCategory.management,
      screenBuilder: (_) => const BoardRoomScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'factions',
      label: 'YÖNETİM FRAKSİYONLARI',
      icon: '⚖️',
      color: const Color(0xFF818CF8),
      category: DynastyShortcutCategory.management,
      screenBuilder: (_) => const BoardFactionScreen(),
    ),

    // 2. Turnuvalar & Ödüller
    DynastyShortcutDefinition(
      id: 'cup_tournament',
      label: 'TÜRKİYE KUPASI',
      icon: '🏆',
      color: AppColors.comicYellow,
      category: DynastyShortcutCategory.competitions,
      badgeEvaluator: (state) => state.cupTournament.isCompleted ? null : 'AKTİF',
      screenBuilder: (_) => const CupTournamentScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'prestige',
      label: 'HANEDAN MAĞAZASI',
      icon: '⭐',
      color: AppColors.neonPink,
      category: DynastyShortcutCategory.competitions,
      screenBuilder: (_) => const PrestigeScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'trophy_room',
      label: 'KUPA ODASI',
      icon: '🥇',
      color: AppColors.accentGold,
      category: DynastyShortcutCategory.competitions,
      screenBuilder: (_) => const TrophyRoomScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'grassroots',
      label: 'MAHALLE TURNUVASI',
      icon: '⚽',
      color: AppColors.neonLime,
      category: DynastyShortcutCategory.competitions,
      screenBuilder: (_) => const GrassrootsTournamentScreen(),
    ),

    // 3. Kulüp Tesisleri & Kadro
    DynastyShortcutDefinition(
      id: 'facilities',
      label: '12 KULÜP TESİSİ',
      icon: '🏟️',
      color: AppColors.neonLime,
      category: DynastyShortcutCategory.clubAssets,
      screenBuilder: (_) => const FacilitiesScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'staff',
      label: 'TEKNİK EKİP',
      icon: '📋',
      color: AppColors.neonLime,
      category: DynastyShortcutCategory.clubAssets,
      screenBuilder: (_) => const StaffScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'u19_squad',
      label: 'U19 GENÇ TAKIMI',
      icon: '🌱',
      color: AppColors.neonLime,
      category: DynastyShortcutCategory.clubAssets,
      badgeEvaluator: (state) => state.userClub.u19Squad.isNotEmpty ? '${state.userClub.u19Squad.length} GENÇ' : null,
      screenBuilder: (_) => const U19SquadScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'youth_academy',
      label: 'ALTYAPI AKADEMİSİ',
      icon: '🏛️',
      color: const Color(0xFF10B981),
      category: DynastyShortcutCategory.clubAssets,
      screenBuilder: (_) => const YouthAcademyScreen(),
    ),

    // 4. Medya, Scout & Finans
    DynastyShortcutDefinition(
      id: 'press_conference',
      label: 'BASIN SALONU',
      icon: '🎙️',
      color: const Color(0xFFF59E0B),
      category: DynastyShortcutCategory.mediaAndFinance,
      screenBuilder: (_) => const PressConferenceScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'scouting',
      label: 'SCOUT & AKADEMİ',
      icon: '🛰️',
      color: AppColors.comicYellow,
      category: DynastyShortcutCategory.mediaAndFinance,
      screenBuilder: (_) => const ScoutingScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'finance',
      label: 'FİNANS & BÜTÇE',
      icon: '💰',
      color: AppColors.neonLime,
      category: DynastyShortcutCategory.mediaAndFinance,
      badgeEvaluator: (state) => state.userClub.meters.cash < 15000 ? '⚠️ NAKİT' : null,
      screenBuilder: (_) => const FinanceScreen(),
    ),

    // 5. Özel Zirveler & Yaşam
    DynastyShortcutDefinition(
      id: 'affiliates',
      label: 'PİLOT KULÜPLER',
      icon: '🌐',
      color: AppColors.neonCyan,
      category: DynastyShortcutCategory.specialEvents,
      screenBuilder: (_) => const AffiliateClubsScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'summit',
      label: 'KULÜPLER BİRLİĞİ',
      icon: '👔',
      color: AppColors.accentGold,
      category: DynastyShortcutCategory.specialEvents,
      screenBuilder: (_) => const ClubsAssociationSummitScreen(),
    ),
    DynastyShortcutDefinition(
      id: 'lifestyle',
      label: 'BAŞKANLIK LÜKS YAŞAM',
      icon: '🏎️',
      color: AppColors.neonPink,
      category: DynastyShortcutCategory.specialEvents,
      screenBuilder: (_) => const PresidentLuxuryLifestyleScreen(),
    ),
  ];

  static DynastyShortcutDefinition? getById(String id) {
    try {
      return allShortcuts.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<DynastyShortcutDefinition> getShortcutsByIds(List<String> ids) {
    final validList = <DynastyShortcutDefinition>[];
    for (final id in ids) {
      final item = getById(id);
      if (item != null) {
        validList.add(item);
      }
    }
    return validList;
  }
}
