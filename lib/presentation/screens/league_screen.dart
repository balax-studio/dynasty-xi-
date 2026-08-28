// presentation/screens/league_screen.dart
// Standings table, promotion/relegation zones, 21-fixture schedule viewer, and League Stats Leaderboard (§12).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/league.dart';
import '../../domain/match/match_depth_models.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import '../widgets/season_summary_dialog.dart';
import 'clubs_association_summit_screen.dart';

class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key});

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen> with SingleTickerProviderStateMixin {
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
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (GameState gameState) {
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
                Tab(text: '[GRAFIK] PUAN TABLOSU'),
                Tab(text: ' FİKSTÜR'),
                Tab(text: 'STAR GOL & ASİST'),
              ],
            ),
          ),
          body: Column(
            children: [
              MetersBarWidget(meters: gameState.userClub.meters),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    backgroundColor: AppColors.win95TitleNavy,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClubsAssociationSummitScreen()),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('[YÖNETİM]', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text('KULÜPLER BİRLİĞİ VAKFI ZİRVESİ & HAVUZ OYLAMASI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Puan Durumu
                    _buildStandingsTab(sortedStandings, gameState.userClub.id, gameState),

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
  }

  Widget _buildLeaderboardsTab(GameState gameState) {
    final scorers = _computeLeagueScorers(gameState);
    final assists = _computeLeagueAssisters(gameState);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GOL KRALLIĞI
          RetroWindow(
            title: 'LİG GOL KRALLIĞI (ALTIN AYAKKABI)',
            icon: '[GOL]',
            titleBarColor: const Color(0xFF6E5000),
            child: scorers.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const Text('Henüz gol kaydı bulunmuyor.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  )
                : Column(
                    children: scorers.asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final s = entry.value;
                      final isUserClub = s.clubName == gameState.userClub.name;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUserClub ? const Color(0xFF003311) : AppColors.neoInnerBg,
                          border: Border.all(color: isUserClub ? AppColors.neonLime : Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              alignment: Alignment.center,
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rank == 1 ? AppColors.accentGold : Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.playerName,
                                    style: AppTypography.label(
                                      color: isUserClub ? AppColors.neonLime : Colors.white,
                                    ).copyWith(fontSize: 11),
                                  ),
                                  Text(
                                    s.clubName,
                                    style: const TextStyle(color: Colors.white60, fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              color: Colors.black,
                              child: Text(
                                '${s.goals} GOL',
                                style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 12),
                              ),
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
            icon: '',
            titleBarColor: AppColors.win95TitleNavy,
            child: assists.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: const Text('Henüz asist kaydı bulunmuyor.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  )
                : Column(
                    children: assists.asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final a = entry.value;
                      final isUserClub = a.clubName == gameState.userClub.name;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUserClub ? const Color(0xFF003311) : AppColors.neoInnerBg,
                          border: Border.all(color: isUserClub ? AppColors.neonLime : Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              alignment: Alignment.center,
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rank == 1 ? AppColors.neonCyan : Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.playerName,
                                    style: AppTypography.label(
                                      color: isUserClub ? AppColors.neonLime : Colors.white,
                                    ).copyWith(fontSize: 11),
                                  ),
                                  Text(
                                    a.clubName,
                                    style: const TextStyle(color: Colors.white60, fontSize: 9),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              color: Colors.black,
                              child: Text(
                                '${a.assists} ASİST',
                                style: AppTypography.monoNumber(color: AppColors.neonCyan).copyWith(fontSize: 12),
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

  List<ScorerEntry> _computeLeagueScorers(GameState gameState) {
    final List<ScorerEntry> list = [];

    // 1. Kullanıcı Kulübü Oyuncuları
    for (final p in gameState.userClub.squad) {
      if (p.goals > 0) {
        list.add(ScorerEntry(
          playerId: p.id,
          playerName: p.fullName,
          clubName: gameState.userClub.name,
          goals: p.goals,
          assists: p.assists,
        ));
      }
    }

    // 2. Ligdeki Rakip Kulüpler (Standings verilerinden dinamik)
    for (final entry in gameState.currentLeague.standings) {
      if (entry.clubId == gameState.userClub.id) continue;
      final gf = entry.goalsFor;
      if (gf > 0) {
        final strikerGoals = (gf * 0.55).round().clamp(1, gf);
        list.add(ScorerEntry(
          playerId: 'ai_str_${entry.clubId}',
          playerName: _getAiStrikerName(entry.clubId, entry.clubName),
          clubName: entry.clubName,
          goals: strikerGoals,
          assists: (gf * 0.15).round(),
        ));

        if (gf >= 4) {
          final wingGoals = (gf * 0.25).round().clamp(1, gf - strikerGoals);
          if (wingGoals > 0) {
            list.add(ScorerEntry(
              playerId: 'ai_wng_${entry.clubId}',
              playerName: _getAiPlaymakerName(entry.clubId, entry.clubName),
              clubName: entry.clubName,
              goals: wingGoals,
              assists: (gf * 0.40).round().clamp(1, gf),
            ));
          }
        }
      }
    }

    // Başlangıçta 0 gol varsa kadro yıldızlarını göster
    if (list.isEmpty) {
      for (final p in gameState.userClub.squad.take(2)) {
        list.add(ScorerEntry(
          playerId: p.id,
          playerName: p.fullName,
          clubName: gameState.userClub.name,
          goals: 0,
          assists: 0,
        ));
      }
      for (final entry in gameState.currentLeague.standings.where((e) => e.clubId != gameState.userClub.id).take(4)) {
        list.add(ScorerEntry(
          playerId: 'ai_init_${entry.clubId}',
          playerName: _getAiStrikerName(entry.clubId, entry.clubName),
          clubName: entry.clubName,
          goals: 0,
          assists: 0,
        ));
      }
    }

    list.sort((a, b) {
      final gComp = b.goals.compareTo(a.goals);
      if (gComp != 0) return gComp;
      return b.assists.compareTo(a.assists);
    });

    return list.take(8).toList();
  }

  List<ScorerEntry> _computeLeagueAssisters(GameState gameState) {
    final List<ScorerEntry> list = [];

    // 1. Kullanıcı Kulübü Oyuncuları
    for (final p in gameState.userClub.squad) {
      if (p.assists > 0) {
        list.add(ScorerEntry(
          playerId: p.id,
          playerName: p.fullName,
          clubName: gameState.userClub.name,
          goals: p.goals,
          assists: p.assists,
        ));
      }
    }

    // 2. Ligdeki Rakip Kulüpler
    for (final entry in gameState.currentLeague.standings) {
      if (entry.clubId == gameState.userClub.id) continue;
      final gf = entry.goalsFor;
      if (gf > 0) {
        final assistsCount = (gf * 0.45).round().clamp(1, gf);
        list.add(ScorerEntry(
          playerId: 'ai_ast_${entry.clubId}',
          playerName: _getAiPlaymakerName(entry.clubId, entry.clubName),
          clubName: entry.clubName,
          goals: (gf * 0.20).round(),
          assists: assistsCount,
        ));
      }
    }

    if (list.isEmpty) {
      for (final p in gameState.userClub.squad.take(2)) {
        list.add(ScorerEntry(
          playerId: p.id,
          playerName: p.fullName,
          clubName: gameState.userClub.name,
          goals: 0,
          assists: 0,
        ));
      }
      for (final entry in gameState.currentLeague.standings.where((e) => e.clubId != gameState.userClub.id).take(4)) {
        list.add(ScorerEntry(
          playerId: 'ai_init_ast_${entry.clubId}',
          playerName: _getAiPlaymakerName(entry.clubId, entry.clubName),
          clubName: entry.clubName,
          goals: 0,
          assists: 0,
        ));
      }
    }

    list.sort((a, b) {
      final aComp = b.assists.compareTo(a.assists);
      if (aComp != 0) return aComp;
      return b.goals.compareTo(a.goals);
    });

    return list.take(8).toList();
  }

  String _getAiStrikerName(String clubId, String clubName) {
    const strikers = {
      'c_ankara': 'Batuhan Karadeniz',
      'c_marmara': 'Burak Yılmaz',
      'c_bursa': 'Pablo Batalla',
      'c_izmir': 'Göztepe Yıldızı',
      'c_adana': 'Mario Balotelli',
      'c_trabzon': 'Alexander Sörloth',
      'c_rize': 'Vedat Muriqi',
      'c_konya': 'Riad Bajic',
      'c_antalyaspor': 'Samuel Eto\'o',
      'c_kayseri': 'Gökhan Ünal',
      'c_sivas': 'Aatif Chahechouhe',
      'c_kasimpasa': 'Mbaye Diagne',
      'c_alanya': 'Papiss Cisse',
      'c_gaziantep': 'Muhammet Demir',
    };
    return strikers[clubId] ?? '$clubName Santrforu';
  }

  String _getAiPlaymakerName(String clubId, String clubName) {
    const playmakers = {
      'c_ankara': 'Hakan Bayraktar',
      'c_marmara': 'Yıldıray Baştürk',
      'c_bursa': 'Volkan Şen',
      'c_izmir': 'Halil Akbunar',
      'c_adana': 'Younes Belhanda',
      'c_trabzon': 'Jose Sosa',
      'c_rize': 'Fernando Boldrin',
      'c_konya': 'Amir Hadziahmetovic',
      'c_antalyaspor': 'Fredy',
      'c_kayseri': 'Bernard Mensah',
      'c_sivas': 'Fayçal Fajr',
      'c_kasimpasa': 'Haris Hajradinovic',
      'c_alanya': 'Efecan Karaca',
      'c_gaziantep': 'Alexandru Maxim',
    };
    return playmakers[clubId] ?? '$clubName 10 Numarası';
  }

  Widget _buildStandingsTab(List<LeagueTableEntry> standings, String userClubId, GameState gameState) {
    final isSeasonCompleted = gameState.currentLeague.fixtures.isNotEmpty &&
        gameState.currentLeague.fixtures.every((f) => f.isPlayed);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sezon Tamamlandıysa veya 21. Hafta Tören Butonu
          RetroWindow(
            title: 'SEZON SONU PROTOKOLÜ & ÖDÜL TÖRENİ',
            icon: '[KUPA]',
            titleBarColor: const Color(0xFF6E5000),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LİG ŞAMPİYONLUK VE TERFİ PROTOKOLÜ', style: AppTypography.label(color: Colors.black).copyWith(fontSize: 11)),
                      Text('Sezon puan tablosu, kupa ve lig geçişi', style: AppTypography.bodySmall(color: Colors.black87).copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                RetroButton(
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
                  child: Text(isSeasonCompleted ? '[KUPA] TÖRENİ AÇ' : '[KILITLI] 21. HAFTA SONU'),
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
