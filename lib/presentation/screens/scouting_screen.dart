// presentation/screens/scouting_screen.dart
// Dedicated full-screen Youth Academy & Scouting Expeditions page with Duration Tiers & Error Margins (§10.4).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/player.dart';
import '../../domain/generation/scout_service.dart';
import 'player_detail_screen.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import 'grassroots_tournament_screen.dart';

class ScoutingScreen extends StatefulWidget {
  const ScoutingScreen({super.key});

  @override
  State<ScoutingScreen> createState() => _ScoutingScreenState();
}

class _ScoutingScreenState extends State<ScoutingScreen> {
  final List<Player> _discoveredProspects = [];
  ScoutDurationTier _selectedTier = ScoutDurationTier.standard;
  int _lastAccuracyMargin = 5;

  void _sendScoutExpedition(BuildContext context, WidgetRef ref, String region, int cost) async {
    final state = ref.read(gameStateProvider).value;
    if (state == null) return;
    if (state.userClub.meters.cash < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Kasa bütçesi yetersiz! Scout görevi başlatılamadı.')),
      );
      return;
    }

    final scoutFacilityLevel = state.userClub.facilities[FacilityType.scoutCenter]?.level ?? 1;

    final report = ScoutService.generateScoutReport(
      region: region,
      tier: _selectedTier,
      scoutFacilityLevel: scoutFacilityLevel,
    );

    setState(() {
      _lastAccuracyMargin = report.accuracyMargin;
      _discoveredProspects.insertAll(0, report.players);
    });

    ref.read(gameStateProvider.notifier).claimSponsorReward(-cost);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          report.hasWonderkid
              ? '🌟 MÜTHİŞ KEŞİF! $region bölgesinden bir GİZLİ CEVHER keşfedildi!'
              : '🛰️ Scout $region raporunu masaya getirdi (${report.players.length} genç oyuncu).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, ref, _) {
        final stateAsync = ref.watch(gameStateProvider);

        return stateAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
          data: (gameState) {
            final scoutFacility = gameState.userClub.facilities[FacilityType.scoutCenter];
            final scoutLevel = scoutFacility?.level ?? 1;

            return Scaffold(
              backgroundColor: AppColors.primaryDeep,
              appBar: AppBar(
                backgroundColor: AppColors.neoCardBg,
                title: Text('GENÇLİK AKADEMİSİ & SCOUT MERKEZİ', style: AppTypography.h2(color: Colors.white)),
              ),
              body: Column(
                children: [
                  MetersBarWidget(meters: gameState.userClub.meters),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 0. Başkanlık Amatör Scouting Turnuvası Butonu
                          SizedBox(
                            width: double.infinity,
                            child: RetroButton(
                              backgroundColor: AppColors.win95TitleNavy,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const GrassrootsTournamentScreen()),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('⭐', style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 6),
                                  Text('BAŞKANLIK GELECEĞİN YILDIZLARI TURNUVASI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 1. Keşif Süresi ve Doğruluk Modu Seçici (§10.4)
                          RetroWindow(
                            title: 'SCOUT GÖREV DERİNLİĞİ & SÜRESİ',
                            icon: '⏱️',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Scout Ofisi Seviyesi: $scoutLevel', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11)),
                                    Text('Tahmini Hata Payı: ±$_lastAccuracyMargin OVR', style: const TextStyle(color: AppColors.neonAmber, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: ScoutDurationTier.values.map((tier) {
                                    final isSelected = _selectedTier == tier;
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                        child: RetroButton(
                                          onPressed: () {
                                            setState(() => _selectedTier = tier);
                                          },
                                          backgroundColor: isSelected ? AppColors.neonCyan : AppColors.win95DarkGrey,
                                          textColor: isSelected ? Colors.black : Colors.white,
                                          child: Text(
                                            tier.label,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _selectedTier.description,
                                  style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 2. Scout Görev Paneli
                          RetroWindow(
                            title: 'KÜRESEL SCOUT KEŞİF BÖLGELERİ',
                            icon: '🛰️',
                            child: Column(
                              children: [
                                _buildExpeditionTile(
                                  context,
                                  ref,
                                  title: '🇧🇷 GÜNEY AMERİKA AKADEMİ KEŞFİ',
                                  desc: 'Sambacı genç forvet ve kanat yetenekleri (%12 Gizli Cevher şansı).',
                                  cost: 4500,
                                  region: 'Güney Amerika / Brezilya',
                                ),
                                const SizedBox(height: 8),
                                _buildExpeditionTile(
                                  context,
                                  ref,
                                  title: '🇪🇺 AVRUPA LİGİ ALTYAPI TRAMPOLİNİ',
                                  desc: 'Taktik disiplini yüksek genç oyun kurucular ve stoperler.',
                                  cost: 6000,
                                  region: 'Avrupa Akademileri',
                                ),
                                const SizedBox(height: 8),
                                _buildExpeditionTile(
                                  context,
                                  ref,
                                  title: '🇹🇷 YEREL YÜKSEK İRTİFA FİDER LİGİ',
                                  desc: 'Yerel amatör kümeden hırslı genç yetenekler.',
                                  cost: 2000,
                                  region: 'Yerel Amatör Küme',
                                ),
                                const SizedBox(height: 8),
                                _buildExpeditionTile(
                                  context,
                                  ref,
                                  title: '⚽ ANADOLU TOPRAK SAHA TURNUVASI',
                                  desc: 'Toprak sahalardan ve mahalle turnuvalarından saf yetenekler.',
                                  cost: 1000,
                                  region: 'Anadolu Toprak Saha',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 3. Keşfedilen Genç Yetenek Raporları
                          RetroWindow(
                            title: 'KEŞFEDİLEN GENÇ YETENEK RAPORLARI (${_discoveredProspects.length})',
                            icon: '🌟',
                            titleBarColor: const Color(0xFF005500),
                            child: _discoveredProspects.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const Text('📡', style: TextStyle(fontSize: 32)),
                                          const SizedBox(height: 8),
                                          Text(
                                            'HENÜZ RAPOR YOK',
                                            style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 12),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Yukarıdaki keşif bölgelerinden birine scout ekibi göndererek genç yetenek avına başlayın.',
                                            style: AppTypography.bodySmall(color: Colors.white54),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: _discoveredProspects
                                        .map((p) => _buildProspectCard(context, ref, p, gameState))
                                        .toList(),
                                  ),
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
      },
    );
  }

  Widget _buildExpeditionTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String desc,
    required int cost,
    required String region,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neoInnerBg,
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11)),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RetroButton(
            onPressed: () => _sendScoutExpedition(context, ref, region, cost),
            backgroundColor: AppColors.neonCyan,
            textColor: Colors.black,
            child: Text('₣$cost\nGÖNDER', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildProspectCard(BuildContext context, WidgetRef ref, Player p, dynamic gameState) {
    final isWonderkid = p.potential >= 88;
    final minPot = (p.potential - _lastAccuracyMargin).clamp(50, 99);
    final maxPot = (p.potential + _lastAccuracyMargin).clamp(50, 99);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlayerDetailScreen(player: p, isOwned: false),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isWonderkid ? const Color(0xFF2E2405) : AppColors.neoInnerBg,
            border: Border.all(color: isWonderkid ? AppColors.accentGold : Colors.white24, width: isWonderkid ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    color: Colors.black,
                    child: Text(p.position.code, style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isWonderkid) const Text('🌟 ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                p.fullName,
                                style: AppTypography.label(color: isWonderkid ? AppColors.accentGold : Colors.white).copyWith(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${p.age} Yaş • ${p.personality.label} • OVR: ${p.ovr} • Tahmini POT: $minPot-$maxPot',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text('₣${p.weeklyWage}/h', style: const TextStyle(color: AppColors.neonLime, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RetroButton(
                    onPressed: () {
                      setState(() {
                        _discoveredProspects.remove(p);
                      });
                    },
                    backgroundColor: AppColors.win95DarkGrey,
                    textColor: Colors.black,
                    child: const Text('RAPORU SİL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  const SizedBox(width: 8),
                  RetroButton(
                    onPressed: () async {
                      final ok = await ref.read(gameStateProvider.notifier).buyPlayer(p, 0, p.weeklyWage);
                      if (context.mounted) {
                        if (ok) {
                          setState(() => _discoveredProspects.remove(p));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('🎉 ${p.fullName} A Takım kadrosuna eklendi!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('⚠️ Kadro ekleme başarısız oldu.')),
                          );
                        }
                      }
                    },
                    backgroundColor: AppColors.neonLime,
                    textColor: Colors.black,
                    child: const Text('KADROYA KAT (ÜCRETSİZ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
