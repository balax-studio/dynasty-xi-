// presentation/screens/facility_detail_screen.dart
// Dedicated detail and upgrade sub-page for every facility with 5 named tiers, live visual animations and construction controls.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_tiers_data.dart';
import '../widgets/facility_visual_widget.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_window.dart';

class FacilityDetailScreen extends ConsumerStatefulWidget {
  final FacilityType facilityType;

  const FacilityDetailScreen({
    super.key,
    required this.facilityType,
  });

  @override
  ConsumerState<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends ConsumerState<FacilityDetailScreen> {
  int? _selectedTierPreview;
  bool _showCelebration = false;

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final fac = club.facilities[widget.facilityType] ?? Facility(type: widget.facilityType, level: 1);

        final now = DateTime.now().millisecondsSinceEpoch;
        final isUpgrading = fac.isUpgrading && fac.upgradeFinishEpochMs != null && now < fac.upgradeFinishEpochMs!;
        final remainingSeconds = isUpgrading ? ((fac.upgradeFinishEpochMs! - now) / 1000).ceil() : 0;
        final remainingMinutes = (remainingSeconds / 60).ceil();

        final activeTier = _selectedTierPreview ?? fac.level.clamp(1, 5);
        final currentTierInfo = FacilityTiersData.getTierInfo(fac.type, fac.level);
        final previewTierInfo = FacilityTiersData.getTierInfo(fac.type, activeTier);
        final canAfford = club.meters.cash >= fac.upgradeCost && !fac.isMaxLevel && !fac.isUpgrading;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Text(fac.type.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${fac.type.label.toUpperCase()} MERKEZİ',
                    style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              MetersBarWidget(meters: club.meters),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Central Visual Hero
                      FacilityVisualWidget(
                        type: fac.type,
                        level: fac.level,
                        isUpgrading: isUpgrading,
                        height: 220,
                        isCelebration: _showCelebration,
                      ),
                      const SizedBox(height: 10),

                      // Construction Status Live Bar (if upgrading)
                      if (isUpgrading) ...[
                        RetroWindow(
                          title: 'AKTİF ŞANTİYE VE İNŞAAT DURUMU',
                          icon: '⚠️',
                          titleBarColor: const Color(0xFFB45309),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'YENİ AŞAMA: ${FacilityTiersData.getTierInfo(fac.type, fac.level + 1).name}',
                                    style: AppTypography.label(color: AppColors.neonAmber).copyWith(fontSize: 11),
                                  ),
                                  Text(
                                    '$remainingMinutes DK KALDI',
                                    style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: ((fac.upgradeDurationMinutes * 60 - remainingSeconds) /
                                        (fac.upgradeDurationMinutes * 60))
                                    .clamp(0.05, 1.0),
                                backgroundColor: AppColors.neutral800,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonAmber),
                                minHeight: 10,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: RetroButton(
                                      isNeon: true,
                                      backgroundColor: AppColors.neonAmber,
                                      onPressed: () {
                                        ref
                                            .read(gameStateProvider.notifier)
                                            .claimSponsorReward(0, reduceConstructionMinutes: 30);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('⚡ İnşaat süresi 30 dakika kısaltıldı!'),
                                          ),
                                        );
                                      },
                                      child: const Text('⚡ HIZLANDIR (-30 Dk)'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RetroButton(
                                      isNeon: true,
                                      backgroundColor: AppColors.neonLime,
                                      onPressed: () async {
                                        ref
                                            .read(gameStateProvider.notifier)
                                            .claimSponsorReward(0, reduceConstructionMinutes: 2880);
                                        setState(() {
                                          _showCelebration = true;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('🎉 Tesis yükseltmesi anında tamamlandı!'),
                                          ),
                                        );
                                      },
                                      child: const Text('🏆 ANINDA BİTİR'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Current Tier Overview Window
                      RetroWindow(
                        title: 'TESİS DURUMU VE OPERASYON RAPORU',
                        icon: '📋',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentTierInfo.name.toUpperCase(),
                                        style: AppTypography.h3(color: AppColors.neonLime).copyWith(fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        currentTierInfo.subtitle,
                                        style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  color: Colors.black,
                                  child: Text(
                                    'SEVİYE ${fac.level}/5',
                                    style: AppTypography.monoNumber(
                                      color: fac.level >= 5 ? const Color(0xFFFFD700) : AppColors.neonLime,
                                    ).copyWith(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentTierInfo.description,
                              style: AppTypography.bodySmall(color: AppColors.neutral300).copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 10),
                            const Divider(color: AppColors.win95DarkGrey, height: 1),
                            const SizedBox(height: 8),

                            // Highlights
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: currentTierInfo.highlights.map((h) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.5), width: 1),
                                  ),
                                  child: Text(
                                    '✔ $h',
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Haftalık Bakım Maliyeti:',
                                  style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 11),
                                ),
                                Text(
                                  '₣${fac.weeklyMaintenance} / hafta',
                                  style: AppTypography.monoNumber(color: AppColors.signalRed).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 5-Tier Roadmap & Perks Browser
                      RetroWindow(
                        title: '5 AŞAMALI GELİŞİM VE YÜKSELTME YOL HARİTASI',
                        icon: '🗺️',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aşağıdaki aşamalara tıklayarak detaylı kazanımları inceleyin:',
                              style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                            ),
                            const SizedBox(height: 8),

                            // 5 Tier Buttons
                            Column(
                              children: List.generate(5, (index) {
                                final tierNum = index + 1;
                                final tInfo = FacilityTiersData.getTierInfo(fac.type, tierNum);
                                final isCurrent = tierNum == fac.level;
                                final isUnlocked = tierNum <= fac.level;
                                final isNext = tierNum == fac.level + 1;
                                final isSelected = activeTier == tierNum;

                                Color borderColor = AppColors.win95DarkGrey;
                                Color bgColor = const Color(0xFF141A24);
                                if (isSelected) {
                                  borderColor = AppColors.neonLime;
                                  bgColor = const Color(0xFF1E3A8A);
                                } else if (isCurrent) {
                                  borderColor = const Color(0xFF22C55E);
                                } else if (isNext) {
                                  borderColor = AppColors.neonAmber;
                                }

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedTierPreview = tierNum;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 26,
                                          height: 26,
                                          color: Colors.black,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$tierNum',
                                            style: TextStyle(
                                              color: isUnlocked ? AppColors.neonLime : Colors.white60,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      tInfo.name,
                                                      style: TextStyle(
                                                        color: isUnlocked ? Colors.white : Colors.white70,
                                                        fontSize: 11,
                                                        fontWeight: isSelected || isCurrent
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  _buildTierStatusBadge(tierNum, fac.level),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${tInfo.perkTitle}: ${tInfo.perkValue}',
                                                style: const TextStyle(color: AppColors.neonLime, fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 8),
                            // Selected Tier Detail Inspector Card
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: const Color(0xFF0F172A),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AŞAMA $activeTier ÖZEL ETKİLERİ VE KAZANIMLARI:',
                                    style: AppTypography.label(color: AppColors.neonAmber).copyWith(fontSize: 10),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    previewTierInfo.description,
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: previewTierInfo.highlights.map((h) {
                                      return Text('• $h', style: const TextStyle(color: Colors.white70, fontSize: 10));
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Upgrade Action Panel
                      if (!fac.isMaxLevel && !isUpgrading)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: AppColors.comicBoxDecoration(
                            backgroundColor: const Color(0xFF141A24),
                            borderColor: canAfford ? AppColors.neonLime : AppColors.signalRed,
                            shadowColor: canAfford ? AppColors.neonLime : Colors.black,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'GELİŞTİRME MALİYETİ:',
                                    style: AppTypography.label(color: Colors.white70).copyWith(fontSize: 11),
                                  ),
                                  Text(
                                    '₣${fac.upgradeCost} (${fac.upgradeDurationMinutes} Dk İnşaat)',
                                    style: AppTypography.monoNumber(
                                      color: canAfford ? AppColors.neonLime : AppColors.signalRed,
                                    ).copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: RetroButton(
                                  isNeon: true,
                                  backgroundColor: canAfford ? AppColors.neonLime : AppColors.neutral700,
                                  onPressed: canAfford
                                      ? () async {
                                          final success = await ref
                                              .read(gameStateProvider.notifier)
                                              .upgradeFacility(fac.type);
                                          if (context.mounted && success) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '🏗️ ${fac.type.label} için inşaat başlatıldı! (${fac.upgradeDurationMinutes} dk)',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  child: Text(
                                    canAfford
                                        ? '🏗️ AŞAMA ${fac.level + 1} GELİŞTİRMESİNİ BAŞLAT'
                                        : '❌ YETERSİZ KASA BAKİYESİ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (fac.isMaxLevel)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: const Color(0xFFFFD700), width: 2),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '★ BU TESİS MAKSİMUM HANEDAN SEVİYESİNE ULAŞTI ★',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
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
  }

  Widget _buildTierStatusBadge(int tier, int currentLevel) {
    if (tier == currentLevel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        color: const Color(0xFF22C55E),
        child: const Text('MEVCUT', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
      );
    } else if (tier < currentLevel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        color: Colors.black,
        child: const Text('AÇIK', style: TextStyle(color: AppColors.neonLime, fontSize: 8, fontWeight: FontWeight.bold)),
      );
    } else if (tier == currentLevel + 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        color: AppColors.neonAmber,
        child: const Text('SIRADAKİ', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        color: const Color(0xFF334155),
        child: const Text('KİLİTLİ', style: TextStyle(color: Colors.white70, fontSize: 8)),
      );
    }
  }
}
