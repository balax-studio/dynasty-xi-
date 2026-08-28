// presentation/screens/trophy_room_screen.dart
// Dynasty Trophy Cabinet, Historical Records, and 12-Achievement Museum Screen (§13.3, §14.4).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/player.dart';
import '../widgets/brutalist_icons.dart';
import '../widgets/president_statue_unveiling_modal.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';
import 'prestige_screen.dart';

class TrophyRoomScreen extends StatelessWidget {
  const TrophyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, ref, _) {
        final stateAsync = ref.watch(gameStateProvider);

        return stateAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
          data: (state) {
            const allAchievements = AchievementCatalog.allAchievements;

            // Dinamik Hanedan Puanı
            final dynastyScore = AchievementEvaluator.calculateDynastyScore(
              leagueTier: state.currentLeague.tier,
              trophiesWon: state.userClub.totalTrophies,
              seasonsPlayed: state.clock.seasonNumber,
              legendPlayersCount: state.userClub.squad.where((p) => p.overall >= 80).length,
              maxSquadValue: state.userClub.squad.fold(0, (sum, p) => sum + p.marketValue),
            );

            // Kilit Açılmış Başarımlar
            final unlockedAchievements = AchievementEvaluator.evaluateAchievements(
              state: state,
              previouslyUnlockedIds: state.unlockedAchievementIds,
            );
            final unlockedIds = unlockedAchievements.map((a) => a.id).toSet();

            final topScorer = state.userClub.squad.isNotEmpty
                ? (List<Player>.from(state.userClub.squad)..sort((a, b) => b.goals.compareTo(a.goals))).first
                : null;
            final topScorerName = (topScorer != null && topScorer.goals > 0)
                ? topScorer.fullName
                : state.museumRecords.allTimeTopScorerName;
            final topScorerGoals = (topScorer != null && topScorer.goals > 0)
                ? topScorer.goals
                : state.museumRecords.allTimeTopScorerGoals;

            final records = state.museumRecords.copyWith(
              allTimeTopScorerName: topScorerName,
              allTimeTopScorerGoals: topScorerGoals,
            );

            return Scaffold(
              backgroundColor: AppColors.primaryDeep,
              appBar: AppBar(
                backgroundColor: AppColors.neoCardBg,
                title: Text('HANEDAN KUPA SALONU & ONUR MÜZESİ', style: AppTypography.h2(color: Colors.white)),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heykel Dikme Butonu
                    SizedBox(
                      width: double.infinity,
                      child: RetroButton(
                        backgroundColor: AppColors.accentGold,
                        textColor: Colors.black,
                        onPressed: () => PresidentStatueUnveilingModal.show(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BrutalistIcon(BrutalistIconType.statue, size: 16, color: Colors.black),
                            SizedBox(width: 8),
                            Text('STADYUM MEYDANINA HEYKEL DİKME TÖRENİ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 1. Hanedan Puanı Penceresi
                    RetroWindow(
                      title: 'HANEDAN BAŞARI VE SKOR TABLOSU',
                      icon: 'capitol',
                      titleBarColor: AppColors.win95TitleNavy,
                      child: Row(
                        children: [
                          const BrutalistIcon(BrutalistIconType.trophy, size: 40, color: AppColors.accentGold),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TOPLAM HANEDAN PUANI',
                                  style: AppTypography.label(color: AppColors.neutral300).copyWith(fontSize: 10),
                                ),
                                Text(
                                  '$dynastyScore PUAN',
                                  style: AppTypography.display(color: AppColors.accentGold).copyWith(fontSize: 28),
                                ),
                                Text(
                                  _getDynastyTitle(dynastyScore),
                                  style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Hanedan Prestij Mağazası Butonu (§13.4, #91, #92)
                    SizedBox(
                      width: double.infinity,
                      child: RetroButton(
                        backgroundColor: AppColors.accentGold,
                        textColor: Colors.black,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PrestigeScreen()),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('STAR', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Text('HANEDAN PRESTİJ MAĞAZASI & YADİGÂR PERKLER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2. Kupa Vitrini Penceresi
                    RetroWindow(
                      title: 'KAZANILAN KUPALAR & MADALYALAR',
                      icon: '[VİTRİN]',
                      titleBarColor: AppColors.neoCardBg,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTrophySlot(
                            icon: '[KUPA]',
                            name: 'LİG ŞAMPİYONLUĞU',
                            count: (state.userClub.totalTrophies > 0 ? state.userClub.totalTrophies : ((20 - state.currentLeague.tier) ~/ 2)).clamp(0, 20),
                          ),
                          _buildTrophySlot(
                            icon: '[MADALYA]',
                            name: 'TERFİ MADALYASI',
                            count: (20 - state.currentLeague.tier).clamp(0, 20),
                          ),
                          _buildTrophySlot(
                            icon: '[ÖDÜL]',
                            name: 'YILIN MENAJERİ',
                            count: state.manager.level >= 3 ? 1 : 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. Kulüp Tarihi Rekorlar Müzesi (§14.4)
                    RetroWindow(
                      title: 'KULÜP TARİHİ REKORLAR MÜZESİ',
                      icon: '[MÜZE]',
                      titleBarColor: AppColors.win95TitleNavy,
                      child: Column(
                        children: [
                          _buildRecordTile('EN FARKLI GALİBİYET', '${records.biggestWinScore} vs ${records.biggestWinOpponent}', '[GOL]'),
                          _buildRecordTile('EN UZUN YENİLMEZLİK SERİSİ', '${records.unbeatenStreak} Maç Üst Üste', 'SHIELD'),
                          _buildRecordTile('REKOR TRANSFER ALIMI', '${records.recordSigningName} (₣${records.recordSigningFee})', 'DIAMOND'),
                          _buildRecordTile('REKOR TRANSFER SATIŞI', '${records.recordSaleName} (₣${records.recordSaleFee})', '[KASA]'),
                          _buildRecordTile('TARİHİN EN GOLCÜ OYUNCUSU', '${records.allTimeTopScorerName} (${records.allTimeTopScorerGoals} Gol)', 'STAR'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 4. 12 Başarım Listesi Penceresi
                    RetroWindow(
                      title: 'KULÜP BAŞARIMLARI (${unlockedIds.length}/${allAchievements.length})',
                      icon: '[MADALYA]',
                      titleBarColor: AppColors.neoCardBg,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allAchievements.length,
                        itemBuilder: (context, index) {
                          final ach = allAchievements[index];
                          final isUnlocked = unlockedIds.contains(ach.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isUnlocked ? AppColors.neoInnerBg : AppColors.neoCardBg,
                              border: Border(
                                top: BorderSide(color: isUnlocked ? AppColors.neonLime : AppColors.win95DarkGrey, width: 1.5),
                                left: BorderSide(color: isUnlocked ? AppColors.neonLime : AppColors.win95DarkGrey, width: 1.5),
                                right: const BorderSide(color: Colors.black, width: 1.5),
                                bottom: const BorderSide(color: Colors.black, width: 1.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(color: isUnlocked ? AppColors.neonLime : AppColors.win95DarkGrey),
                                  ),
                                  alignment: Alignment.center,
                                  child: RetroPixelIcon.fromEmoji(
                                    ach.icon,
                                    size: 20,
                                    color: isUnlocked ? AppColors.neonLime : AppColors.neutral300,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ach.title.toUpperCase(),
                                        style: AppTypography.label(
                                          color: isUnlocked ? AppColors.neonLime : Colors.white60,
                                        ).copyWith(fontSize: 11),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ach.description,
                                        style: AppTypography.bodySmall(
                                          color: isUnlocked ? Colors.white70 : Colors.white38,
                                        ).copyWith(fontSize: 9),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  color: Colors.black,
                                  child: Text(
                                    isUnlocked ? 'KAZANILDI' : 'KİLİTLİ',
                                    style: TextStyle(
                                      color: isUnlocked ? AppColors.neonLime : AppColors.signalRed,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecordTile(String title, String value, String icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.neoInnerBg,
        border: Border.fromBorderSide(BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
                Text(value, style: AppTypography.label(color: AppColors.accentGold).copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophySlot({
    required String icon,
    required String name,
    required int count,
  }) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: count > 0 ? AppColors.accentGold : AppColors.win95DarkGrey, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppTypography.label(color: Colors.white).copyWith(fontSize: 9),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          color: Colors.black,
          child: Text(
            '$count ADET',
            style: AppTypography.monoNumber(color: count > 0 ? AppColors.neonLime : Colors.white38).copyWith(fontSize: 9),
          ),
        ),
      ],
    );
  }

  String _getDynastyTitle(int score) {
    if (score >= 5000) return 'CROWN EFSANEVİ DÜNYA HANEDANI';
    if (score >= 2500) return 'STAR AVRUPA DEVLERİ KATİLLERİ';
    if (score >= 1000) return '[KUPA] ULUSAL FUTBOL KALESİ';
    if (score >= 400) return 'SWORDS PROFESYONEL LİG SAVAŞÇISI';
    return ' AMATÖR KÜME RÜYASI';
  }
}
