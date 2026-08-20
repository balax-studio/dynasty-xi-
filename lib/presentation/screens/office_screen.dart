// presentation/screens/office_screen.dart
// Main Dashboard (Kulüp Ofisi) with Retro Windows 95 & Y2K layout, Daily Quests, and Idle Revenue Collection.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/progression/daily_quest.dart';
import '../widgets/decision_card_widget.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import 'board_room_screen.dart';
import 'match_screen.dart';
import 'press_conference_screen.dart';
import 'scouting_screen.dart';
import 'staff_screen.dart';
import 'trophy_room_screen.dart';

class OfficeScreen extends ConsumerWidget {
  const OfficeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Hata: $err', style: AppTypography.body())),
      ),
      data: (gameState) {
        final club = gameState.userClub;
        final clock = gameState.clock;
        final nextFixture = gameState.currentLeague.fixtures.firstWhere(
          (f) => f.matchday == clock.matchday && !f.isPlayed,
          orElse: () => gameState.currentLeague.fixtures.first,
        );

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            title: Row(
              children: [
                Text(club.badgeIcon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club.name.toUpperCase(),
                        style: AppTypography.label(color: Colors.white).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${gameState.currentLeague.name.toUpperCase()} • SEZON ${clock.seasonNumber}',
                        style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TrophyRoomScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: AppColors.neoBoxDecoration(
                    backgroundColor: AppColors.neonLime,
                    borderColor: Colors.black,
                    shadowColor: Colors.black,
                    shadowOffset: const Offset(2, 2),
                    borderWidth: 1.5,
                  ),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '${gameState.manager.dynastyPoints} DP',
                        style: AppTypography.label(color: Colors.black).copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. 4 Göstergeli Windows 95 LED Üst Bar
              MetersBarWidget(meters: club.meters),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kovulma Tehlikesi Uyarısı (§12.8)
                      if (gameState.isUnderSackingThreat) ...[
                        _buildSackingThreatBanner(context, club.meters.boardTrust),
                        const SizedBox(height: 10),
                      ],

                      // Çevrimdışı / Gece Geliri Toplama Banner'ı (§17.3 D1)
                      if (gameState.accumulatedIdleCash > 0) ...[
                        _buildIdleCashClaimBanner(context, ref, gameState.accumulatedIdleCash),
                        const SizedBox(height: 10),
                      ],

                      // 2. Sıradaki Maç Penceresi (Windows 95 Window Frame)
                      _buildNextMatchWindow(context, ref, gameState, nextFixture),
                      const SizedBox(height: 10),

                      // 3. Günlük Görevler Widget'ı (§17.3, §21.2)
                      RetroWindow(
                        title: 'GÜNLÜK GÖREVLER (DAILY.EXE)',
                        icon: '📅',
                        titleBarColor: const Color(0xFF1E3A8A),
                        child: _buildDailyQuestsContent(context, ref, gameState.dailyQuests),
                      ),
                      const SizedBox(height: 10),

                      // 4. Başkanlık Odası & Departmanlar (Tam Sayfa Navigasyon)
                      RetroWindow(
                        title: 'BAŞKANLIK ODASI & KULÜP DEPARTMANLARI',
                        icon: '🏛️',
                        titleBarColor: AppColors.neoCardBg,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RetroButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const StaffScreen()),
                                      );
                                    },
                                    backgroundColor: AppColors.neonLime,
                                    textColor: Colors.black,
                                    child: const Column(
                                      children: [
                                        Text('👔', style: TextStyle(fontSize: 20)),
                                        SizedBox(height: 4),
                                        Text('TEKNİK EKİP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: RetroButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const BoardRoomScreen()),
                                      );
                                    },
                                    backgroundColor: AppColors.neonCyan,
                                    textColor: Colors.black,
                                    child: const Column(
                                      children: [
                                        Text('🏛️', style: TextStyle(fontSize: 20)),
                                        SizedBox(height: 4),
                                        Text('YÖNETİM KURULU', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: RetroButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const PressConferenceScreen()),
                                      );
                                    },
                                    backgroundColor: AppColors.neonPink,
                                    textColor: Colors.black,
                                    child: const Column(
                                      children: [
                                        Text('🎙️', style: TextStyle(fontSize: 20)),
                                        SizedBox(height: 4),
                                        Text('BASIN SALONU', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: RetroButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ScoutingScreen()),
                                      );
                                    },
                                    backgroundColor: AppColors.comicYellow,
                                    textColor: Colors.black,
                                    child: const Column(
                                      children: [
                                        Text('🛰️', style: TextStyle(fontSize: 20)),
                                        SizedBox(height: 4),
                                        Text('SCOUT & AKADEMİ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 5. Masadaki Karar Kartı (Windows 95 Window Frame)
                      RetroWindow(
                        title: 'MASADAKİ DOSYA — KARAR ANI',
                        icon: '📁',
                        backgroundColor: AppColors.primaryDeep,
                        child: gameState.pendingCards.isNotEmpty
                            ? DecisionCardWidget(
                                card: gameState.pendingCards.first,
                                onOptionSelected: (opt) {
                                  ref
                                      .read(gameStateProvider.notifier)
                                      .chooseCardOption(gameState.pendingCards.first, opt);
                                },
                              )
                            : _buildNoCardsBanner(),
                      ),
                      const SizedBox(height: 10),

                      // 6. Sezon Hedefleri Penceresi
                      RetroWindow(
                        title: 'BAŞKANLIK HEDEF RAPORU',
                        icon: '🎯',
                        child: _buildSeasonGoalsContent(gameState),
                      ),
                      const SizedBox(height: 10),

                      // 7. Kulüp Bildirim Günlüğü
                      RetroWindow(
                        title: 'KULÜP SİSTEM GÜNLÜĞÜ (SYSTEM.LOG)',
                        icon: '📝',
                        child: _buildActivityLogContent(gameState),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSackingThreatBanner(BuildContext context, int trust) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.comicRed.withValues(alpha: 0.2),
        border: Border.all(color: AppColors.comicRed, width: 2),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KOVULMA RİSKİ YÜKSEK!',
                  style: TextStyle(color: AppColors.comicRed, fontWeight: FontWeight.w900, fontSize: 12),
                ),
                Text(
                  'Yönetim Kurulu Güveni (%$trust) kritik seviyeye indi. Galibiyet alamazsanız görevden alınabilirsiniz!',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleCashClaimBanner(BuildContext context, WidgetRef ref, int amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2E20),
        border: Border.all(color: AppColors.neonLime, width: 1.5),
      ),
      child: Row(
        children: [
          const Text('💰', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BİRİKMİŞ ÇEVRİMDIŞI GELİR',
                  style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                Text(
                  'Mağaza & Bilet birikimi: ₣$amount',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
          RetroButton(
            onPressed: () async {
              final claimed = await ref.read(gameStateProvider.notifier).claimIdleCash();
              if (context.mounted && claimed > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('💰 ₣$claimed kasa hesabına aktarıldı!')),
                );
              }
            },
            backgroundColor: AppColors.neonLime,
            textColor: Colors.black,
            child: const Text('KASAYA AL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuestsContent(BuildContext context, WidgetRef ref, List<DailyQuest> quests) {
    if (quests.isEmpty) {
      return const Text('Bugün için yeni görev bulunmuyor.', style: TextStyle(color: Colors.white54, fontSize: 11));
    }

    return Column(
      children: quests.map((q) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF141A24),
            border: Border.all(color: q.isClaimed ? Colors.white12 : (q.isCompleted ? AppColors.neonLime : Colors.white24)),
          ),
          child: Row(
            children: [
              Text(q.isClaimed ? '✅' : (q.isCompleted ? '⭐' : '⏳'), style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          q.title,
                          style: TextStyle(
                            color: q.isClaimed ? Colors.white54 : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            decoration: q.isClaimed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          '+₣${q.cashReward} • +${q.xpReward} XP',
                          style: const TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      q.description,
                      style: TextStyle(color: q.isClaimed ? Colors.white38 : Colors.white70, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: q.progressRatio,
                        backgroundColor: Colors.black,
                        valueColor: AlwaysStoppedAnimation<Color>(q.isCompleted ? AppColors.neonLime : AppColors.neonCyan),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (q.canClaim)
                RetroButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).claimDailyQuest(q.id);
                  },
                  backgroundColor: AppColors.neonLime,
                  textColor: Colors.black,
                  child: const Text('AL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                )
              else if (q.isClaimed)
                const Text('ALINDI', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold))
              else
                Text('${q.currentCount}/${q.targetCount}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNextMatchWindow(
    BuildContext context,
    WidgetRef ref,
    dynamic state,
    dynamic fixture,
  ) {
    final isUserHome = fixture.homeClubId == state.userClub.id;
    final oppId = isUserHome ? fixture.awayClubId : fixture.homeClubId;
    final oppName = state.currentLeague.getClubName(oppId);
    final oppBadge = state.currentLeague.getClubBadge(oppId);

    final homeName = isUserHome ? state.userClub.name : oppName;
    final homeBadge = isUserHome ? state.userClub.badgeIcon : oppBadge;
    final awayName = !isUserHome ? state.userClub.name : oppName;
    final awayBadge = !isUserHome ? state.userClub.badgeIcon : oppBadge;

    return RetroWindow(
      title: 'MAÇ MERKEZİ • HAFTA ${state.clock.matchday}/21',
      icon: '⚽',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RetroBadge(
                text: 'HAFTA ${state.clock.matchday}',
                backgroundColor: AppColors.comicYellow,
                textColor: Colors.black,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black,
                child: Text(
                  state.clock.nextMatchSchedule.toUpperCase(),
                  style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Karşılaşma Skor Paneli (Retro CRT Ekran)
          RetroInsetPanel(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(homeBadge, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 4),
                      Text(
                        homeName.toUpperCase(),
                        style: AppTypography.label(color: Colors.white).copyWith(fontSize: 13),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isUserHome ? '[BİZ • EV]' : '[EV]',
                        style: AppTypography.label(color: isUserHome ? AppColors.neonLime : AppColors.neutral300).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(
                    'VS',
                    style: AppTypography.display(color: AppColors.neonPink).copyWith(fontSize: 28),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(awayBadge, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 4),
                      Text(
                        awayName.toUpperCase(),
                        style: AppTypography.label(color: Colors.white).copyWith(fontSize: 13),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        !isUserHome ? '[BİZ • DEP]' : '[DEP]',
                        style: AppTypography.label(color: !isUserHome ? AppColors.neonLime : AppColors.neutral300).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3D Beveled Butonlar
          Row(
            children: [
              Expanded(
                child: RetroButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MatchScreen(isLiveMode: true),
                      ),
                    );
                  },
                  backgroundColor: AppColors.accentGold,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🎮', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text('CANLI ANLAR (90 sn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RetroButton(
                  onPressed: () async {
                    await ref.read(gameStateProvider.notifier).playMatch(isLiveMode: false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Maç hızlıca simüle edildi!')),
                      );
                    }
                  },
                  backgroundColor: AppColors.win95Grey,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('⚡', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text('HIZLI SİM (8 sn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoCardsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.black,
      child: Column(
        children: [
          const Text('☕', style: TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            'MASA TEMİZ • YENİ DOSYA YOK',
            style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Bu maç penceresindeki kararlar verildi. Yeni kartlar bir sonraki maç saatinde masana gelecek.',
            style: AppTypography.bodySmall(color: AppColors.neutral300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonGoalsContent(dynamic state) {
    return Row(
      children: [
        const Text('🎯', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BAŞKANIN SEZON HEDEFİ',
                style: AppTypography.label(color: AppColors.accentGold).copyWith(fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                'Ligi ilk ${state.targetLeaguePosition} içinde bitir (Ödül: ₣25.000 + 250 XP)',
                style: AppTypography.body(color: Colors.white).copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLogContent(dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.notificationLog.isEmpty)
          Text('Henüz bir sistem kaydı bulunmuyor.', style: AppTypography.bodySmall())
        else
          ...state.notificationLog.take(4).map<Widget>(
                (log) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('>', style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          log,
                          style: AppTypography.bodySmall(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}
