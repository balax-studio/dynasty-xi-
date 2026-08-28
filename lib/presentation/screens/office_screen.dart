// presentation/screens/office_screen.dart
// Main Dashboard (Kulüp Ofisi) with Retro Windows 95 & Y2K layout, Daily Quests, and Idle Revenue Collection.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/media/newspaper_story_engine.dart';
import '../../domain/president/president_crisis.dart';
import '../../domain/progression/daily_quest.dart';
import '../../core/time/game_clock.dart';
import '../widgets/club_emblem_widget.dart';
import '../widgets/decision_card_widget.dart';
import '../widgets/match_reward_dialog.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/newspaper_headline_widget.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';
import '../widgets/urgent_phone_call_modal.dart';
import '../widgets/midseason_camp_modal.dart';
import 'match_screen.dart';
import 'sacked_screen.dart';
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
        if (gameState.isGameOver) {
          return SackedScreen(
            clubName: gameState.userClub.name,
            sackingReason: gameState.gameOverReason ?? 'Yönetim Kurulu Güvenini Kaybettiniz',
          );
        }

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
                ClubEmblemWidget(
                  clubName: club.name,
                  clubId: club.id,
                  badgeIcon: club.badgeIcon,
                  size: 26,
                  showShadow: false,
                ),
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
                      const RetroPixelIcon(type: RetroPixelIconType.trophy, size: 14, color: Colors.black),
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

                      // Kırmızı Hat / Acil Telefon Kriz Çağrısı (Yalnızca Kriz Varsa Tetiklenir)
                      if (gameState.hasActiveCrisis && gameState.activeCrisisCall != null) ...[
                        _buildActiveCrisisHotlineBanner(context, gameState.activeCrisisCall!),
                        const SizedBox(height: 10),
                      ],

                      // Haftalık Sezon Teması Banner'ı (§28.2, #100)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: AppColors.accentGold, width: 1),
                        ),
                        child: Row(
                          children: [
                            Text(gameState.currentSeasonTheme.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HAFTALIK TEMA: ${gameState.currentSeasonTheme.title.toUpperCase()}',
                                    style: const TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    gameState.currentSeasonTheme.description,
                                    style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 1. Sıradaki Maç Penceresi (Windows 95 Window Frame)
                      _buildNextMatchWindow(context, ref, gameState, nextFixture),
                      const SizedBox(height: 10),

                      // 2. Basın Manşetleri & Gazete Kupürü (§17.5-1, §66)
                      Builder(
                        builder: (_) {
                          final story = NewspaperStoryEngine.generateStory(gameState);
                          return NewspaperHeadlineWidget(
                            outletName: story.outletName,
                            headline: story.headline,
                            subhead: story.subhead,
                            dateString: story.dateString,
                            reporter: story.reporter,
                            columnQuote: story.columnQuote,
                            isPositive: story.isPositive,
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      // 3. Günlük Görevler Widget'ı (§17.3, §21.2)
                      RetroWindow(
                        title: 'GÜNLÜK GÖREVLER (DAILY.EXE)',
                        icon: '',
                        titleBarColor: const Color(0xFF1E3A8A),
                        child: _buildDailyQuestsContent(context, ref, gameState.dailyQuests),
                      ),
                      const SizedBox(height: 10),

                      // 4. Masadaki Karar Kartı (Windows 95 Window Frame)
                      RetroWindow(
                        title: 'MASADAKİ DOSYA — KARAR ANI',
                        icon: '',
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

                      // 5. Sezon Hedefleri Penceresi
                      RetroWindow(
                        title: 'BAŞKANLIK HEDEF RAPORU',
                        icon: '[HEDEF]',
                        child: _buildSeasonGoalsContent(gameState),
                      ),
                      const SizedBox(height: 10),

                      // 6. Kulüp Bildirim Günlüğü
                      RetroWindow(
                        title: 'KULÜP SİSTEM GÜNLÜĞÜ (SYSTEM.LOG)',
                        icon: '',
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
          const Text('[UYARI]', style: TextStyle(fontSize: 24)),
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
          const Text('[KASA]', style: TextStyle(fontSize: 24)),
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
                  SnackBar(content: Text('[KASA] ₣$claimed kasa hesabına aktarıldı!')),
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
            color: AppColors.neoInnerBg,
            border: Border.all(color: q.isClaimed ? Colors.white12 : (q.isCompleted ? AppColors.neonLime : Colors.white24)),
          ),
          child: Row(
            children: [
              Text(q.isClaimed ? '[ONAY]' : (q.isCompleted ? 'STAR' : '[BEKLEME]'), style: const TextStyle(fontSize: 18)),
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

  Widget _buildActiveCrisisHotlineBanner(BuildContext context, PresidentCrisisCall call) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.win95Grey,
        border: Border.all(color: AppColors.comicRed, width: 2.5),
      ),
      child: InkWell(
        onTap: () {
          UrgentPhoneCallModal.show(context, call);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Text('[KIRMIZI]', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          color: AppColors.comicRed,
                          child: const Text(
                            'ACİL ÇAĞRI GELİYOR',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            call.callerTitle.toUpperCase(),
                            style: AppTypography.label(color: AppColors.comicRed).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      call.dialogQuote,
                      style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.comicRed,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, offset: Offset(2, 2)),
                  ],
                ),
                child: const Text(
                  'YANITLA ',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
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

    // Sezon Öncesi Hazırlık Dönemi
    if (state.clock.phase == SeasonPhase.preSeason) {
      return RetroWindow(
        title: 'SEZON ÖNCESİ HAZIRLIK • YAZ TRANSFER DÖNEMİ',
        icon: '[SEZON]',
        titleBarColor: const Color(0xFF1E3A8A),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const RetroPixelIcon(type: RetroPixelIconType.clock, size: 32, color: AppColors.neonCyan),
              const SizedBox(height: 8),
              const Text(
                'YENİ SEZON HAZIRLIK DÖNEMİ',
                style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                'Yaz Transfer Penceresi açık. Kadro tescilinizi (En fazla 25 A-Takım oyuncusu) tamamlayıp 1. Hafta maçlarına başlayabilirsiniz.',
                style: TextStyle(color: Colors.white70, fontSize: 10.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).startFirstHalf();
                  },
                  backgroundColor: AppColors.neonCyan,
                  textColor: Colors.black,
                  child: const Text('LİGİ BAŞLAT (1. HAFTA FİKSTÜRÜ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Devre Arası Dönemi
    if (state.clock.phase == SeasonPhase.midSeasonBreak) {
      return RetroWindow(
        title: 'DEVRE ARASI DÖNEMİ • KIŞ HAZIRLIK KAMPI',
        icon: '[KAMP]',
        titleBarColor: const Color(0xFF004422),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const RetroPixelIcon(type: RetroPixelIconType.tacticsBoard, size: 32, color: AppColors.neonLime),
              const SizedBox(height: 8),
              const Text(
                'LİGİN İLK YARISI TAMAMLANDI',
                style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kış Transfer Penceresi açıldı. Oyuncularınızın kondisyon ve moralini tazelemek, takım uyumunu artırmak için devre arası kampını organize ediniz.',
                style: TextStyle(color: Colors.white70, fontSize: 10.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  onPressed: () {
                    MidSeasonCampModal.show(context);
                  },
                  backgroundColor: AppColors.neonLime,
                  textColor: Colors.black,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RetroPixelIcon(type: RetroPixelIconType.whistle, size: 14, color: Colors.black),
                      SizedBox(width: 6),
                      Text('DEVRE ARASI KAMPINI DÜZENLE & 2. YARIYA BAŞLA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sezon Sonu Değerlendirmesi
    if (state.clock.phase == SeasonPhase.seasonEvaluation) {
      return RetroWindow(
        title: 'SEZON SONU • LİG DEĞERLENDİRMESİ',
        icon: '[KUPA]',
        titleBarColor: const Color(0xFF4A3800),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const RetroPixelIcon(type: RetroPixelIconType.trophy, size: 32, color: AppColors.accentGold),
              const SizedBox(height: 8),
              const Text(
                'LİG MARATONU TAMAMLANDI',
                style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                '21 haftalık sezon maratonu sona erdi. Kupa müzesi güncellendi ve yeni sezon hazırlıkları için bütçeler belirlendi.',
                style: TextStyle(color: Colors.white70, fontSize: 10.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).startNextSeason();
                  },
                  backgroundColor: AppColors.accentGold,
                  textColor: Colors.black,
                  child: const Text('YENİ SEZONU BAŞLAT (YAZ DÖNEMİ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final homeName = isUserHome ? state.userClub.name : oppName;
    final homeBadge = isUserHome ? state.userClub.badgeIcon : oppBadge;
    final awayName = !isUserHome ? state.userClub.name : oppName;
    final awayBadge = !isUserHome ? state.userClub.badgeIcon : oppBadge;

    return RetroWindow(
      title: 'MAÇ MERKEZİ • HAFTA ${state.clock.matchday}/21',
      icon: '[GOL]',
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
                      ClubEmblemWidget(
                        clubName: homeName,
                        clubId: isUserHome ? state.userClub.id : oppId,
                        badgeIcon: homeBadge,
                        size: 46,
                      ),
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
                      ClubEmblemWidget(
                        clubName: awayName,
                        clubId: !isUserHome ? state.userClub.id : oppId,
                        badgeIcon: awayBadge,
                        size: 46,
                      ),
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
                      Text('[CANLI]', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
                    final res = await ref.read(gameStateProvider.notifier).playMatch(isLiveMode: false);
                    if (res != null && context.mounted) {
                      final userGoals = isUserHome ? res.homeGoals : res.awayGoals;
                      final oppGoals = isUserHome ? res.awayGoals : res.homeGoals;
                      final isWin = userGoals > oppGoals;
                      
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => MatchRewardDialog(
                          userScore: userGoals,
                          oppScore: oppGoals,
                          oppName: oppName.isNotEmpty ? oppName : 'Rakip Kulüp',
                          cashEarned: isWin ? 25000 : 5000,
                          managerXpEarned: isWin ? 80 : 30,
                          fanDelta: isWin ? 4 : -3,
                          motmPlayerName: state.userClub.squad.isNotEmpty ? state.userClub.squad.first.fullName : 'Yıldız Oyuncu',
                          motmPlayerRating: 8,
                          motmSeed: 42,
                          topPerformers: const [],
                          onContinue: () => Navigator.of(ctx).pop(),
                        ),
                      );
                    }
                  },
                  backgroundColor: AppColors.win95Grey,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('[HIZLI]', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
          const Text('[DOSYA]', style: TextStyle(fontSize: 16, color: AppColors.neonLime, fontWeight: FontWeight.bold)),
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
        const Text('[HEDEF]', style: TextStyle(fontSize: 28)),
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
