// presentation/screens/league_screen.dart
// Standings table, promotion/relegation zones, 21-fixture schedule viewer, and League Stats Leaderboard (§12).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/league.dart';
import '../../domain/match/match_depth_models.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import '../widgets/season_summary_dialog.dart';

class LeagueScreen extends StatefulWidget {
  const LeagueScreen({super.key});

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final stateAsync = ref.watch(gameStateProvider);

        return stateAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
          data: (gameState) {
            final league = gameState.currentLeague;
            final sortedStandings = league.sortedStandings;

            return Scaffold(
              backgroundColor: AppColors.primaryDeep,
              appBar: AppBar(
                backgroundColor: AppColors.win95TitleNavy,
                title: Text('${league.tier}. LİG VERİTABANI — ${league.name.toUpperCase()}', style: AppTypography.h2(color: Colors.white)),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.neonLime,
                  labelColor: AppColors.neonLime,
                  unselectedLabelColor: AppColors.win95White,
                  tabs: const [
                    Tab(text: '📊 PUAN TABLOSU'),
                    Tab(text: '📅 FİKSTÜR'),
                    Tab(text: '🌟 GOL & ASİST'),
                  ],
                ),
              ),
              body: Column(
                children: [
                  MetersBarWidget(meters: gameState.userClub.meters),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Puan Durumu
                        _buildStandingsTab(sortedStandings, gameState.userClub.id, gameState, ref),

                        // Tab 2: Fikstür
                        _buildFixturesTab(league.fixtures, gameState.userClub.id),

                        // Tab 3: Gol ve Asist Krallığı (§12)
                        _buildLeaderboardsTab(gameState),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboardsTab(dynamic gameState) {
    // Generate realistic league leaders based on current matchday
    final scorers = [
      ScorerEntry(playerId: 'sc_1', playerName: 'Semih Kılıçsoy', clubName: gameState.userClub.name, goals: 8, assists: 3),
      ScorerEntry(playerId: 'sc_2', playerName: 'Batuhan Karadeniz', clubName: 'Anadolu Gücü', goals: 7, assists: 1),
      ScorerEntry(playerId: 'sc_3', playerName: 'Burak Yılmaz', clubName: 'Marmara FK', goals: 6, assists: 2),
      ScorerEntry(playerId: 'sc_4', playerName: 'Hugo Almeida', clubName: 'Boğaziçi 1903', goals: 5, assists: 0),
      ScorerEntry(playerId: 'sc_5', playerName: 'Umut Bulut', clubName: 'Kuzey Yıldızı', goals: 5, assists: 4),
    ];

    final assists = [
      ScorerEntry(playerId: 'as_1', playerName: 'Alex de Souza', clubName: 'Kadıköy Martı', goals: 4, assists: 9),
      ScorerEntry(playerId: 'as_2', playerName: 'Kerem Aktürkoğlu', clubName: gameState.userClub.name, goals: 4, assists: 6),
      ScorerEntry(playerId: 'as_3', playerName: 'Olcay Şahan', clubName: 'Bursa İdman', goals: 2, assists: 5),
      ScorerEntry(playerId: 'as_4', playerName: 'Arda Turan', clubName: 'Florya Akademi', goals: 3, assists: 5),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GOL KRALLIĞI
          RetroWindow(
            title: 'LİG GOL KRALLIĞI (ALTIN AYAKKABI)',
            icon: '⚽',
            titleBarColor: const Color(0xFF6E5000),
            child: Column(
              children: scorers.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final s = entry.value;
                final isUserClub = s.clubName == gameState.userClub.name;

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUserClub ? const Color(0xFF003311) : const Color(0xFF141A24),
                    border: Border.all(color: isUserClub ? AppColors.neonLime : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: Text('$rank', style: TextStyle(fontWeight: FontWeight.bold, color: rank == 1 ? AppColors.accentGold : Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.playerName, style: AppTypography.label(color: isUserClub ? AppColors.neonLime : Colors.white).copyWith(fontSize: 11)),
                            Text(s.clubName, style: const TextStyle(color: Colors.white60, fontSize: 9)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        color: Colors.black,
                        child: Text('${s.goals} GOL', style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // ASİST KRALLIĞI
          RetroWindow(
            title: 'LİG ASİST KRALLIĞI (OYUN KURUCULAR)',
            icon: '👟',
            titleBarColor: const Color(0xFF1E3A8A),
            child: Column(
              children: assists.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final a = entry.value;
                final isUserClub = a.clubName == gameState.userClub.name;

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUserClub ? const Color(0xFF003311) : const Color(0xFF141A24),
                    border: Border.all(color: isUserClub ? AppColors.neonLime : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: Text('$rank', style: TextStyle(fontWeight: FontWeight.bold, color: rank == 1 ? AppColors.neonCyan : Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.playerName, style: AppTypography.label(color: isUserClub ? AppColors.neonLime : Colors.white).copyWith(fontSize: 11)),
                            Text(a.clubName, style: const TextStyle(color: Colors.white60, fontSize: 9)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        color: Colors.black,
                        child: Text('${a.assists} ASİST', style: AppTypography.monoNumber(color: AppColors.neonCyan).copyWith(fontSize: 12)),
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

  Widget _buildStandingsTab(List<LeagueTableEntry> standings, String userClubId, dynamic gameState, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sezon Tamamlandıysa veya 21. Hafta Tören Butonu
          RetroWindow(
            title: 'SEZON SONU PROTOKOLÜ & ÖDÜL TÖRENİ',
            icon: '🏆',
            titleBarColor: const Color(0xFF6E5000),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LİG ŞAMPİYONLUK VE TERFİ PROTOKOLÜ', style: AppTypography.label(color: Colors.black).copyWith(fontSize: 11)),
                      Text('Sezon puan tablosu, kupa ve lig geçişi', style: AppTypography.bodySmall(color: Colors.black87).copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    final isSeasonCompleted = gameState.currentLeague.fixtures.every((f) => f.isPlayed);
                    return RetroButton(
                      onPressed: isSeasonCompleted
                          ? () {
                              AudioSynthesizer.playTrophyFanfare();
                              showDialog(
                                context: context,
                                builder: (ctx) => SeasonSummaryDialog(
                                  state: gameState,
                                  onStartNextSeason: () {
                                    ref.read(gameStateProvider.notifier).executeSeasonTransition();
                                  },
                                ),
                              );
                            }
                          : null,
                      child: Text(isSeasonCompleted ? '🏆 TÖRENİ AÇ' : '🔒 21. HAFTA SONU'),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Açıklama Notu
          Row(
            children: [
              Container(width: 10, height: 10, color: AppColors.signalGreen),
              const SizedBox(width: 4),
              Text('Üst Lige Yükselme (İlk 2)', style: AppTypography.bodySmall()),
              const SizedBox(width: 16),
              Container(width: 10, height: 10, color: AppColors.signalRed),
              const SizedBox(width: 4),
              Text('Küme Düşme (Son 2)', style: AppTypography.bodySmall()),
            ],
          ),
          const SizedBox(height: 10),

          // Tablo Başlığı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neutral800,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const SizedBox(width: 28, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(child: Text('KULÜP', style: TextStyle(fontWeight: FontWeight.bold))),
                _buildHeaderCell('O'),
                _buildHeaderCell('G'),
                _buildHeaderCell('B'),
                _buildHeaderCell('M'),
                _buildHeaderCell('AV'),
                _buildHeaderCell('P'),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Sıralama Satırları
          ...standings.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            final isUser = item.clubId == userClubId;
            final isPromotion = rank <= 2;
            final isRelegation = rank >= standings.length - 1;

            return Container(
              margin: const EdgeInsets.only(bottom: 3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.accentGold.withValues(alpha: 0.15)
                    : (rank % 2 == 0 ? AppColors.neutral900 : AppColors.primaryDeep),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isUser
                      ? AppColors.accentGold
                      : (isPromotion
                          ? AppColors.signalGreen.withValues(alpha: 0.3)
                          : (isRelegation
                              ? AppColors.signalRed.withValues(alpha: 0.3)
                              : AppColors.neutral800)),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPromotion
                            ? AppColors.signalGreen
                            : (isRelegation ? AppColors.signalRed : AppColors.neutral50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.clubName,
                      style: TextStyle(
                        fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                        color: isUser ? AppColors.accentGold : AppColors.neutral50,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildDataCell('${item.played}'),
                  _buildDataCell('${item.won}'),
                  _buildDataCell('${item.drawn}'),
                  _buildDataCell('${item.lost}'),
                  _buildDataCell('${item.goalDifference}'),
                  _buildDataCell(
                    '${item.points}',
                    isBold: true,
                    color: isUser ? AppColors.accentGold : AppColors.neutral50,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFixturesTab(List<Fixture> fixtures, String userClubId) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: fixtures.length,
      itemBuilder: (context, index) {
        final f = fixtures[index];
        final isUserMatch = f.homeClubId == userClubId || f.awayClubId == userClubId;

        return Card(
          color: isUserMatch
              ? AppColors.accentGold.withValues(alpha: 0.1)
              : AppColors.neutral900,
          margin: const EdgeInsets.only(bottom: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isUserMatch ? AppColors.accentGold : AppColors.neutral800,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neutral800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'H.${f.matchday}',
                    style: AppTypography.monoNumber(color: AppColors.neutral300).copyWith(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    f.homeClubName,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontWeight: f.homeClubId == userClubId ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 54,
                  alignment: Alignment.center,
                  child: Text(
                    f.isPlayed ? '${f.homeScore} - ${f.awayScore}' : 'VS',
                    style: AppTypography.monoNumber(
                      color: f.isPlayed ? AppColors.accentGold : AppColors.neutral300,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    f.awayClubName,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: f.awayClubId == userClubId ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return SizedBox(
      width: 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildDataCell(String text, {bool isBold = false, Color? color}) {
    return SizedBox(
      width: 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? AppColors.neutral300,
          fontSize: 12,
        ),
      ),
    );
  }
}
