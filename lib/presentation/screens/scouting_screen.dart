// presentation/screens/scouting_screen.dart
// Asynchronous Scouting Missions Queue, Attribute Fog of War, and Regional Expeditions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/player.dart';
import '../../domain/scouting/scouting_mission.dart';
import 'player_detail_screen.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';
import 'grassroots_tournament_screen.dart';

class ScoutingScreen extends ConsumerStatefulWidget {
  const ScoutingScreen({super.key});

  @override
  ConsumerState<ScoutingScreen> createState() => _ScoutingScreenState();
}

class _ScoutingScreenState extends ConsumerState<ScoutingScreen> {
  ScoutDurationTier _selectedTier = ScoutDurationTier.standard;
  String? _expandedMissionId;

  void _sendScoutExpedition(BuildContext context, String region) async {
    final state = ref.read(gameStateProvider).value;
    if (state == null) return;

    if (state.userClub.meters.cash < _selectedTier.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.signalRed,
          content: Text('[UYARI] Kasa bütçesi yetersiz! Scout görevi başlatılamadı.'),
        ),
      );
      return;
    }

    AudioSynthesizer.playClick();
    final ok = await ref.read(gameStateProvider.notifier).startScoutingMission(
          region: region,
          tier: _selectedTier,
        );

    if (context.mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.win95TitleNavy,
            content: Text('[GÖREV BAŞLATILDI] $region bölgesine ${_selectedTier.label} scout seferi yollandı.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.signalRed,
            content: Text('[HATA] Scout görevi başlatılırken sorun oluştu.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final scoutFacility = gameState.userClub.facilities[FacilityType.scoutCenter];
        final scoutLevel = scoutFacility?.level ?? 1;
        final activeMissions = gameState.activeScoutingMissions;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
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
                          backgroundColor: AppColors.neoCardBg,
                          onPressed: () {
                            AudioSynthesizer.playClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GrassrootsTournamentScreen()),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RetroPixelIcon(type: RetroPixelIconType.trophy, size: 14, color: AppColors.accentGold),
                              SizedBox(width: 8),
                              Text(
                                'BAŞKANLIK GELECEĞİN YILDIZLARI TURNUVASI',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 1. Aktif Scout Görevleri ve Rapor Dosyaları Kuyruğu
                      _buildActiveMissionsWindow(context, activeMissions, scoutLevel, gameState),
                      const SizedBox(height: 10),

                      // 2. Keşif Süresi ve Görev Derinliği Seçici
                      _buildDurationTierSelector(scoutLevel),
                      const SizedBox(height: 10),

                      // 3. Bölgesel Scout Seferleri Listesi
                      _buildRegionalExpeditionsWindow(context, gameState.userClub.meters.cash),
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

  Widget _buildActiveMissionsWindow(
    BuildContext context,
    List<ScoutingMission> missions,
    int scoutLevel,
    dynamic gameState,
  ) {
    final completedCount = missions.where((m) => m.isCompleted).length;
    final inProgressCount = missions.length - completedCount;

    return RetroWindow(
      title: 'AKTİF GÖZLEMCİ GÖREVLERİ ($inProgressCount Sürüyor / $completedCount Hazır)',
      icon: '[KUYRUK]',
      titleBarColor: completedCount > 0 ? const Color(0xFF004422) : AppColors.win95TitleNavy,
      child: missions.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Center(
                child: Column(
                  children: [
                    const RetroPixelIcon(type: RetroPixelIconType.target, size: 28, color: Colors.white30),
                    const SizedBox(height: 8),
                    Text(
                      'AKTİF GÖZLEMCİ SEFERİ YOK',
                      style: AppTypography.label(color: Colors.white70).copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Aşağıdaki coğrafi bölgelerden birini seçip scout seferi başlatarak genç yetenek avına çıkın.',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: missions.map((m) {
                final isExpanded = _expandedMissionId == m.id;
                return _buildMissionTile(context, m, isExpanded, scoutLevel, gameState);
              }).toList(),
            ),
    );
  }

  Widget _buildMissionTile(
    BuildContext context,
    ScoutingMission m,
    bool isExpanded,
    int scoutLevel,
    dynamic gameState,
  ) {
    final isReady = m.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isReady ? const Color(0xFF0A2412) : AppColors.neoInnerBg,
        border: Border.all(
          color: isReady ? AppColors.neonLime : Colors.white24,
          width: isReady ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RetroPixelIcon(
                type: isReady ? RetroPixelIconType.briefcase : RetroPixelIconType.clock,
                size: 14,
                color: isReady ? AppColors.neonLime : AppColors.neonCyan,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  m.region.toUpperCase(),
                  style: TextStyle(
                    color: isReady ? AppColors.neonLime : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                color: Colors.black,
                child: Text(
                  m.tier.label,
                  style: const TextStyle(color: AppColors.neonCyan, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (!isReady) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saha Araştırması Sürüyor • Kalan: ${m.matchesRemaining} Maç',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  '%${(m.progressRatio * 100).round()}',
                  style: AppTypography.monoNumber(color: AppColors.neonCyan).copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: m.progressRatio,
                minHeight: 6,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rapor Masanızda: ${m.discoveredProspects.length} Aday Oyuncu Analiz Edildi',
                  style: const TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    RetroButton(
                      onPressed: () {
                        AudioSynthesizer.playClick();
                        setState(() {
                          _expandedMissionId = isExpanded ? null : m.id;
                        });
                      },
                      backgroundColor: isExpanded ? AppColors.win95DarkGrey : AppColors.neonLime,
                      textColor: Colors.black,
                      child: Text(
                        isExpanded ? 'GİZLE' : 'RAPORU AÇ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    RetroButton(
                      onPressed: () {
                        AudioSynthesizer.playClick();
                        ref.read(gameStateProvider.notifier).dismissCompletedScoutingMission(m.id);
                      },
                      backgroundColor: AppColors.win95DarkGrey,
                      textColor: Colors.white,
                      child: const Text('ARŞİVLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
                    ),
                  ],
                ),
              ],
            ),
            if (isExpanded) ...[
              const Divider(color: Colors.white24, height: 16),
              ...m.discoveredProspects.map(
                (p) => _buildProspectCard(context, p, scoutLevel, m.id),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDurationTierSelector(int scoutLevel) {
    return RetroWindow(
      title: 'SCOUT SEFERİ DERİNLİĞİ & MAÇ SÜRESİ',
      icon: '[SURE]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Scout Tesisi Seviyesi: Sv.$scoutLevel',
                style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11),
              ),
              Text(
                scoutLevel >= 5 ? 'Tam Veri Netliği (0 Hata)' : 'Sis Perdesi: ±${6 - scoutLevel} OVR',
                style: const TextStyle(color: AppColors.neonAmber, fontSize: 10.5),
              ),
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
                      AudioSynthesizer.playClick();
                      setState(() => _selectedTier = tier);
                    },
                    backgroundColor: isSelected ? AppColors.neonCyan : AppColors.win95DarkGrey,
                    textColor: isSelected ? Colors.black : Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tier.label,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₣${tier.cost}',
                          style: TextStyle(
                            color: isSelected ? Colors.black87 : AppColors.neonLime,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedTier == ScoutDurationTier.quick
                ? 'Hızlı Sefer: 1 lig maçında tamamlanır. Temel yetenek tespiti yapar.'
                : _selectedTier == ScoutDurationTier.standard
                    ? 'Standart Sefer: 2 lig maçında tamamlanır. Dengeli potansiyel aralığı sunar.'
                    : 'Kapsamlı Rapor: 3 lig maçında tamamlanır. Yüksek doğruluk ve gizli cevher şansı sunar.',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalExpeditionsWindow(BuildContext context, int clubCash) {
    return RetroWindow(
      title: 'KÜRESEL SCOUT BÖLGELERİ',
      icon: '[DUNYA]',
      child: Column(
        children: [
          _buildExpeditionTile(
            context,
            title: 'GÜNEY AMERİKA / BREZİLYA & ARJANTİN',
            desc: 'Teknik kapasitesi yüksek, çalım yeteneği gelişmiş sambacı kanat ve forvetler.',
            region: 'Güney Amerika',
            clubCash: clubCash,
          ),
          const SizedBox(height: 8),
          _buildExpeditionTile(
            context,
            title: 'BATI AVRUPA AKADEMİLERİ',
            desc: 'Taktik disiplini üst seviye modern orta sahalar ve oyun kurucu stoperler.',
            region: 'Batı Avrupa',
            clubCash: clubCash,
          ),
          const SizedBox(height: 8),
          _buildExpeditionTile(
            context,
            title: 'İSKANDİNAVYA & DOĞU AVRUPA',
            desc: 'Fizik gücü ve dayanıklılığı yüksek, mücadeleci santrfor ve stoperler.',
            region: 'İskandinavya',
            clubCash: clubCash,
          ),
          const SizedBox(height: 8),
          _buildExpeditionTile(
            context,
            title: 'ANADOLU VE YEREL AMATÖR KÜME',
            desc: 'Düşük maliyetli, yüksek aidiyet ve hırsa sahip yerel yetenekler.',
            region: 'Anadolu & Yerel Lig',
            clubCash: clubCash,
          ),
          const SizedBox(height: 8),
          _buildExpeditionTile(
            context,
            title: 'AFRİKA YETENEK MERKEZLERİ',
            desc: 'Üstün patlayıcı güç, hız ve çeviklik vadeden genç prospect adayları.',
            region: 'Afrika Akademileri',
            clubCash: clubCash,
          ),
        ],
      ),
    );
  }

  Widget _buildExpeditionTile(
    BuildContext context, {
    required String title,
    required String desc,
    required String region,
    required int clubCash,
  }) {
    final cost = _selectedTier.cost;
    final canAfford = clubCash >= cost;

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
                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RetroButton(
            onPressed: canAfford ? () => _sendScoutExpedition(context, region) : null,
            backgroundColor: canAfford ? AppColors.neonCyan : AppColors.win95DarkGrey,
            textColor: Colors.black,
            child: Text(
              canAfford ? '₣$cost\nGÖNDER' : 'YETERSİZ\nBAKİYE',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProspectCard(BuildContext context, Player p, int scoutLevel, String missionId) {
    final isWonderkid = p.potential >= 86;
    final ovrDisplay = ScoutFogOfWar.getOvrDisplay(p, scoutLevel);
    final potDisplay = ScoutFogOfWar.getPotentialDisplay(p, scoutLevel);
    final personalityText = ScoutFogOfWar.isTraitRevealed(scoutLevel: scoutLevel)
        ? p.personality.label
        : 'Gizli (Sv.3+ Scout Gerekli)';

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
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isWonderkid ? const Color(0xFF2E2405) : Colors.black,
            border: Border.all(color: isWonderkid ? AppColors.accentGold : Colors.white30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    color: AppColors.win95TitleNavy,
                    child: Text(
                      p.position.code,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isWonderkid)
                              const Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: RetroPixelIcon(type: RetroPixelIconType.star, size: 12, color: AppColors.accentGold),
                              ),
                            Expanded(
                              child: Text(
                                p.fullName,
                                style: AppTypography.label(color: isWonderkid ? AppColors.accentGold : Colors.white).copyWith(fontSize: 11.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${p.age} Yaş • Karakter: $personalityText',
                          style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('OVR: $ovrDisplay', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10.5)),
                      Text('POT: $potDisplay', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 10.5)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RetroButton(
                    onPressed: () async {
                      AudioSynthesizer.playClick();
                      final ok = await ref.read(gameStateProvider.notifier).buyPlayer(p, 0, p.weeklyWage);
                      if (context.mounted) {
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.win95TitleNavy,
                              content: Text('[KUTLAMA] ${p.fullName} A Takım sözleşmesiyle kulübe tescil edildi!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.signalRed,
                              content: Text('[UYARI] Transfer penceresi kapalı veya 25 kişilik A Takım kadro limiti dolu!'),
                            ),
                          );
                        }
                      }
                    },
                    backgroundColor: AppColors.neonLime,
                    textColor: Colors.black,
                    child: const Text('KADROYA TESCİL ET (ÜCRETSİZ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
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
