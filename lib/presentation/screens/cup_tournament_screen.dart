// presentation/screens/cup_tournament_screen.dart
// Knockout National Cup Bracket & European Continental Cup Screens (§14.3, §14.5)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/tournament/cup_tournament.dart';
import '../../domain/tournament/continental_cup.dart';
import '../widgets/retro_window.dart';
import '../widgets/victory_bus_parade_dialog.dart';

class CupTournamentScreen extends ConsumerStatefulWidget {
  const CupTournamentScreen({super.key});

  @override
  ConsumerState<CupTournamentScreen> createState() => _CupTournamentScreenState();
}

class _CupTournamentScreenState extends ConsumerState<CupTournamentScreen> {
  late ContinentalCup _continentalCup;

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final cup = gameState.cupTournament;
        final userClub = gameState.userClub;

        final continentalCup = gameState.continentalCup ??
            ContinentalCup.generateTournament(
              userClubName: userClub.name,
              userBadge: userClub.badgeIcon,
              season: gameState.clock.seasonNumber,
            );
        _continentalCup = continentalCup;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.primaryDeep,
            appBar: AppBar(
              backgroundColor: AppColors.win95TitleNavy,
              title: Text('KUPA & TURNUVA MERKEZİ', style: AppTypography.h2(color: Colors.white)),
              bottom: const TabBar(
                indicatorColor: AppColors.neonLime,
                labelColor: AppColors.neonLime,
                unselectedLabelColor: AppColors.win95White,
                tabs: [
                  Tab(text: '🇹🇷 TÜRKİYE KUPASI'),
                  Tab(text: '🌍 AVRUPA KITA KUPASI'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // TAB 1: Türkiye Kupası
                _buildNationalCupTab(context, cup, userClub.id),

                // TAB 2: Avrupa Kıta Kupası (§14.5 #94)
                _buildContinentalCupTab(context, userClub.name),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 1. Türkiye Kupası Sekmesi
  Widget _buildNationalCupTab(BuildContext context, CupTournament cup, String userClubId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament Status Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              border: Border.all(color: AppColors.neonCyan, width: 2),
            ),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cup.tournamentName.toUpperCase(),
                        style: AppTypography.h3(color: Colors.white),
                      ),
                      Text(
                        cup.isCompleted
                            ? 'KUPA TAMAMLANDI • Şampiyon: ${cup.championClubName}'
                            : 'Mevcut Aşama: ${cup.currentRound.title} (Ödül Havuzu: ₣${cup.prizePool})',
                        style: const TextStyle(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Kupa Kutlaması Şehir Turu Butonu
          SizedBox(
            width: double.infinity,
            child: RetroButton(
              backgroundColor: AppColors.neonLime,
              textColor: Colors.black,
              onPressed: () => VictoryBusParadeDialog.show(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🚌', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text('ÜSTÜ AÇIK OTOBÜSLE ŞEHİR TURU & KUTLAMA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Matches by Stage
          _buildStageSection(context, cup, CupRound.quarterFinal, userClubId),
          const SizedBox(height: 10),
          _buildStageSection(context, cup, CupRound.semiFinal, userClubId),
          const SizedBox(height: 10),
          _buildStageSection(context, cup, CupRound.finalMatch, userClubId),
        ],
      ),
    );
  }

  Widget _buildStageSection(
    BuildContext context,
    CupTournament cup,
    CupRound round,
    String userClubId,
  ) {
    final matches = cup.matches.where((m) => m.round == round).toList();

    return RetroWindow(
      title: round.title.toUpperCase(),
      icon: round == CupRound.finalMatch ? '👑' : '⚔️',
      titleBarColor: round == CupRound.finalMatch ? const Color(0xFF581C87) : AppColors.neoCardBg,
      child: matches.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Bu aşamanın eşleşmeleri henüz belirlenmedi.', style: TextStyle(color: Colors.white38, fontSize: 10)),
            )
          : Column(
              children: matches.map((m) {
                final isUserMatch = m.homeClubId == userClubId || m.awayClubId == userClubId;
                final isWinnerHome = m.winnerClubId == m.homeClubId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUserMatch ? const Color(0xFF0D3320) : AppColors.neoInnerBg,
                    border: Border.all(color: isUserMatch ? AppColors.neonLime : Colors.white24, width: isUserMatch ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      // Home Team
                      Expanded(
                        child: Row(
                          children: [
                            Text(m.homeBadge, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                m.homeClubName,
                                style: TextStyle(
                                  color: m.isPlayed && isWinnerHome ? AppColors.neonLime : Colors.white,
                                  fontWeight: isUserMatch ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Score or Action Button
                      if (m.isPlayed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          color: Colors.black,
                          child: Text(
                            '${m.homeScore} - ${m.awayScore}',
                            style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        )
                      else if (isUserMatch)
                        RetroButton(
                          onPressed: () async {
                            await ref.read(gameStateProvider.notifier).playCupMatch(m.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('⚽ Kupa maçı oynandı!')),
                              );
                            }
                          },
                          backgroundColor: AppColors.neonLime,
                          textColor: Colors.black,
                          child: const Text('MAÇI OYNA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      else
                        const Text('vs', style: TextStyle(color: Colors.white38, fontSize: 11)),

                      // Away Team
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                m.awayClubName,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: m.isPlayed && !isWinnerHome ? AppColors.neonLime : Colors.white,
                                  fontWeight: isUserMatch ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(m.awayBadge, style: const TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  /// 2. Avrupa Kıta Kupası Sekmesi (§14.5 #94)
  Widget _buildContinentalCupTab(BuildContext context, String userClubName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B1D5A),
              border: Border.all(color: AppColors.accentGold, width: 2),
            ),
            child: Row(
              children: [
                const Text('🌍', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _continentalCup.title.toUpperCase(),
                        style: AppTypography.h3(color: AppColors.accentGold),
                      ),
                      Text(
                        'Sezon ${_continentalCup.seasonNumber} • Devler Ligi (Büyük Ödül: ₣${_continentalCup.prizeMoney} + 500 DP)',
                        style: const TextStyle(color: Colors.white, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Matches
          RetroWindow(
            title: 'AVRUPA GRUP & ELEME FİKSTÜRÜ',
            icon: '⭐',
            titleBarColor: const Color(0xFF581C87),
            child: Column(
              children: _continentalCup.fixtures.map((m) {
                final isUserMatch = m.homeClubName == userClubName || m.awayClubName == userClubName;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUserMatch ? const Color(0xFF1F1235) : AppColors.neoInnerBg,
                    border: Border.all(color: isUserMatch ? AppColors.accentGold : Colors.white24, width: isUserMatch ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      // Home
                      Expanded(
                        child: Row(
                          children: [
                            Text(m.homeBadge, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                m.homeClubName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isUserMatch ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 10.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status or Action
                      if (m.isPlayed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: Colors.black,
                          child: Text(
                            '${m.homeScore} - ${m.awayScore}',
                            style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        )
                      else if (isUserMatch)
                        RetroButton(
                          onPressed: () {
                            final updatedFixtures = List<ContinentalMatch>.from(_continentalCup.fixtures);
                            final idx = updatedFixtures.indexOf(m);
                            updatedFixtures[idx] = ContinentalMatch(
                              id: m.id,
                              stage: m.stage,
                              homeClubName: m.homeClubName,
                              homeCountry: m.homeCountry,
                              homeBadge: m.homeBadge,
                              awayClubName: m.awayClubName,
                              awayCountry: m.awayCountry,
                              awayBadge: m.awayBadge,
                              isPlayed: true,
                              homeScore: 2,
                              awayScore: 1,
                              winnerName: m.homeClubName,
                            );
                            final updatedCup = _continentalCup.copyWith(fixtures: updatedFixtures);
                            setState(() => _continentalCup = updatedCup);
                            ref.read(gameStateProvider.notifier).updateContinentalCup(updatedCup);
                            ref.read(gameStateProvider.notifier).claimSponsorReward(35000);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.accentGold,
                                content: Text('🎉 Avrupa maçı kazanıldı! (+₣35,000 prim)', style: TextStyle(color: Colors.black)),
                              ),
                            );
                          },
                          backgroundColor: AppColors.accentGold,
                          textColor: Colors.black,
                          child: const Text('AVRUPA MAÇI', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                        )
                      else
                        const Text('vs', style: TextStyle(color: Colors.white38, fontSize: 10)),

                      // Away
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                m.awayClubName,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isUserMatch ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 10.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(m.awayBadge, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
