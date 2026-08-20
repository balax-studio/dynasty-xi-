// presentation/screens/facilities_screen.dart
// 12-facility infrastructure management screen with tier upgrades, costs, and passive benefits.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/facility.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

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
            title: Text('KULÜP ALTYAPI VE TESİS PLANI (12 TESİS)', style: AppTypography.h2(color: Colors.white)),
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
                            const Text('🏗️', style: TextStyle(fontSize: 26)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'KULÜP TESİSLERİ VE GELİŞİM PLANI',
                                    style: AppTypography.label(color: AppColors.neonAmber).copyWith(fontSize: 11),
                                  ),
                                  Text(
                                    'Tesisleri yükselterek pasif gelir, oyuncu gelişimi ve seyirci kapasitesini artırın.',
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
                        title: 'TESİS ENVANTERİ VE GELİŞTİRME MERKEZİ',
                        icon: '🏢',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          children: FacilityType.values.map((type) {
                            final fac = facilities[type] ?? Facility(type: type, level: 0);
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
    final canAfford = currentCash >= fac.upgradeCost && !fac.isMaxLevel && !fac.isUpgrading;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isUpgrading = fac.isUpgrading && fac.upgradeFinishEpochMs != null && now < fac.upgradeFinishEpochMs!;
    final remainingSeconds = isUpgrading ? ((fac.upgradeFinishEpochMs! - now) / 1000).ceil() : 0;
    final remainingMinutes = (remainingSeconds / 60).ceil();

    return Container(
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: isUpgrading
                          ? AppColors.neonAmber
                          : (fac.isOpen ? AppColors.neonLime : AppColors.neutral700),
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
                          Text(fac.type.label.toUpperCase(), style: AppTypography.label(color: Colors.white).copyWith(fontSize: 11)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            color: Colors.black,
                            child: Text(
                              'SV. ${fac.level}/5',
                              style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getBenefitDescription(fac),
                        style: AppTypography.bodySmall(color: AppColors.neutral300).copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // İnşaat Devam Ediyorsa Canlı 16-Bit İnşaat Barı
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
                              'İNŞAAT SÜRÜYOR: ${fac.type.label} Sv.${fac.level + 1}',
                              style: AppTypography.label(color: AppColors.neonAmber).copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        Text(
                          '$remainingMinutes DK KALDI',
                          style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: ((fac.upgradeDurationMinutes * 60 - remainingSeconds) / (fac.upgradeDurationMinutes * 60)).clamp(0.05, 1.0),
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
                if (isUpgrading)
                  RetroButton(
                    isNeon: true,
                    backgroundColor: AppColors.neonAmber,
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).claimSponsorReward(0, reduceConstructionMinutes: 30);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('İnşaat süresi 30 dakika kısaltıldı!')),
                      );
                    },
                    child: const Text('⚡ HIZLANDIR (-30 dk)'),
                  )
                else if (!fac.isMaxLevel)
                  RetroButton(
                    onPressed: canAfford
                        ? () async {
                            final success = await ref
                                .read(gameStateProvider.notifier)
                                .upgradeFacility(fac.type);
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${fac.type.label} için inşaat başlatıldı! (${fac.upgradeDurationMinutes} dk)'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text('⬆ İNŞAT BAŞLAT: ₣${_formatNumber(fac.upgradeCost)} (${fac.upgradeDurationMinutes} dk)'),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    color: Colors.black,
                    child: Text(
                      '★ MAKSİMUM SEVİYE ★',
                      style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getBenefitDescription(Facility fac) {
    switch (fac.type) {
      case FacilityType.stadium:
        return 'Kapasite: ${fac.stadiumCapacity} seyirci • Bilet geliri çarpanı: +%${fac.level * 10}';
      case FacilityType.trainingGround:
        return 'Antrenman verimi: +%${fac.level * 12} haftalık oyuncu gelişimi';
      case FacilityType.youthAcademy:
        return 'Yılda 1 adet ${fac.level >= 3 ? "yüksek potansiyelli" : "genç"} altyapı oyuncusu alımı';
      case FacilityType.medicalCenter:
        return 'Sakatlık riski -%${fac.level * 8} • İyileşme süresi -%${fac.level * 10}';
      case FacilityType.scoutCenter:
        return 'Pazarda +${fac.level * 2} ekstra oyuncu analizi ve potansiyel tahmini';
      case FacilityType.fanShop:
        return 'Haftalık ürün satışı pasif geliri: +₣${fac.level * 1200}';
      default:
        return 'Kulüp itibarını ve genel operasyonel gücünü artırır.';
    }
  }

  String _formatNumber(int n) {
    if (n.abs() >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toString();
  }
}
