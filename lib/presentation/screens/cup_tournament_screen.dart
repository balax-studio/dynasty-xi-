// presentation/screens/cup_tournament_screen.dart
// Knockout National Cup Bracket View & Match Simulation Screen (§14.3)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/tournament/cup_tournament.dart';
import '../widgets/retro_window.dart';

class CupTournamentScreen extends ConsumerWidget {
  const CupTournamentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final cup = gameState.cupTournament;
        final userClub = gameState.userClub;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            title: Text('TÜRKİYE HANEDAN KUPASI', style: AppTypography.h2(color: Colors.white)),
          ),
          body: SingleChildScrollView(
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
                const SizedBox(height: 14),

                // Matches by Stage
                _buildStageSection(context, ref, cup, CupRound.quarterFinal, userClub.id),
                const SizedBox(height: 10),
                _buildStageSection(context, ref, cup, CupRound.semiFinal, userClub.id),
                const SizedBox(height: 10),
                _buildStageSection(context, ref, cup, CupRound.finalMatch, userClub.id),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStageSection(
    BuildContext context,
    WidgetRef ref,
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
                    color: isUserMatch ? const Color(0xFF0D3320) : const Color(0xFF141A24),
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
}
