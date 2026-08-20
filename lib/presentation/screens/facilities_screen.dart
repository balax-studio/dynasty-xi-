// presentation/screens/facilities_screen.dart
// 12-facility infrastructure management screen with named tiers, visual indicators, and navigation to dedicated sub-pages.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_tiers_data.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_button.dart';
import '../widgets/retro_window.dart';
import 'facility_detail_screen.dart';

class FacilitiesScreen extends ConsumerWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final facilities = club.facilities;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
            title: Text('KULÜP ALTYAPI VE TESİSLER (12 TESİS)', style: AppTypography.h2(color: Colors.white)),
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
                      // Özet Penceresi
                      RetroWindow(
                        title: 'MÜHENDİSLİK VE YATIRIM BİLDİRİMİ',
                        icon: '📐',
                        child: Row(
                          children: [
                            const Text('🏗️', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'KULÜP ALTYAPI VE GELİŞİM MERKEZİ',
                                    style: AppTypography.label(color: AppColors.neonAmber).copyWith(fontSize: 11),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Her tesisin üzerine tıklayarak özel alt sayfasına gidebilir, 5 seviyeli gelişim haritasını ve özel animasyonlarını görebilirsiniz.',
                                    style: AppTypography.bodySmall(color: Colors.black87).copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      RetroWindow(
                        title: '12 KULÜP TESİSİ LİSTESİ',
                        icon: '🏢',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          children: FacilityType.values.map((type) {
                            final fac = facilities[type] ?? Facility(type: type, level: 1);
                            return _buildFacilityCard(context, ref, fac, club.meters.cash);
                          }).toList(),
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

  Widget _buildFacilityCard(
    BuildContext context,
    WidgetRef ref,
    Facility fac,
    int currentCash,
  ) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final isUpgrading = fac.isUpgrading && fac.upgradeFinishEpochMs != null && now < fac.upgradeFinishEpochMs!;
    final remainingSeconds = isUpgrading ? ((fac.upgradeFinishEpochMs! - now) / 1000).ceil() : 0;
    final remainingMinutes = (remainingSeconds / 60).ceil();
    final tierInfo = FacilityTiersData.getTierInfo(fac.type, fac.level);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FacilityDetailScreen(facilityType: fac.type),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: AppColors.comicBoxDecoration(
            backgroundColor: const Color(0xFF141A24),
            borderColor: isUpgrading ? AppColors.neonAmber : Colors.black,
            shadowColor: isUpgrading ? AppColors.neonAmber : AppColors.neonLime,
            borderWidth: 2.0,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: isUpgrading
                            ? AppColors.neonAmber
                            : (fac.level >= 5 ? const Color(0xFFFFD700) : AppColors.neonLime),
                        width: 2.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(fac.type.icon, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tierInfo.name.toUpperCase(),
                                style: AppTypography.label(color: Colors.white).copyWith(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              color: Colors.black,
                              child: Text(
                                'AŞAMA ${fac.level}/5',
                                style: AppTypography.label(
                                  color: fac.level >= 5 ? const Color(0xFFFFD700) : AppColors.neonLime,
                                ).copyWith(fontSize: 9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tierInfo.perkTitle}: ${tierInfo.perkValue}',
                          style: AppTypography.bodySmall(color: AppColors.neonLime).copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // İnşaat Devam Ediyorsa Canlı Bar
              if (isUpgrading) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: AppColors.neonAmber, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('🏗️', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                'İNŞAAT SÜRÜYOR: ${FacilityTiersData.getTierInfo(fac.type, fac.level + 1).name}',
                                style: AppTypography.label(color: AppColors.neonAmber).copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                          Text(
                            '$remainingMinutes DK KALDI',
                            style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: ((fac.upgradeDurationMinutes * 60 - remainingSeconds) / (fac.upgradeDurationMinutes * 60))
                            .clamp(0.05, 1.0),
                        backgroundColor: AppColors.neutral800,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonAmber),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],

              const Divider(color: AppColors.win95DarkGrey, height: 1),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BAKIM: ₣${fac.weeklyMaintenance}/h',
                    style: AppTypography.monoNumber(color: AppColors.signalRed).copyWith(fontSize: 10),
                  ),
                  RetroButton(
                    isNeon: true,
                    backgroundColor: isUpgrading ? AppColors.neonAmber : AppColors.neonLime,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FacilityDetailScreen(facilityType: fac.type),
                        ),
                      );
                    },
                    child: Text(
                      isUpgrading ? '⚡ İNŞAAT DETAYI →' : '🔍 DETAY VE GELİŞTİRME →',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
