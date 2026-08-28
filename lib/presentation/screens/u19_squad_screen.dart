// presentation/screens/u19_squad_screen.dart
// Dedicated U19 Youth Squad & Wonderkid Development Screen (§10, §15)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_impact_confirm_modal.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';

class U19SquadScreen extends ConsumerWidget {
  const U19SquadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final u19 = club.u19Squad;
        final canScout = club.meters.cash >= 3000;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            leading: IconButton(
              icon: const Text('◀', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const Text('[U19]', style: TextStyle(fontSize: 12, color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('U19 GENÇ TAKIMI (${u19.length} YETENEK)', style: AppTypography.h3(color: Colors.white)),
                      const Text(
                        'GELECEĞİN YILDIZLARI VE WONDERKID GELİŞİM HAVUZU',
                        style: TextStyle(color: AppColors.neonLime, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
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
                      // 1. Yeni Yetenek Keşif Butonu
                      RetroWindow(
                        title: 'AKADEMİ SCOUT RADARI & YETENEK AVI',
                        icon: '[ARAMA]',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Altyapı tesislerinizin kalitesi ve teknik heyetinizin vizyonuna göre yeni yüksek potansiyelli gençler keşfedin.',
                              style: AppTypography.bodySmall(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: RetroButton(
                                backgroundColor: canScout ? AppColors.neonLime : AppColors.neutral700,
                                textColor: canScout ? Colors.black : Colors.white70,
                                onPressed: () async {
                                  AudioSynthesizer.playClick();
                                  final ok = await ref.read(gameStateProvider.notifier).scoutNewYouthTalent();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: ok ? AppColors.neonLime : AppColors.comicRed,
                                        content: Text(
                                          ok
                                              ? ' Yeni genç yetenek keşfedildi ve U19 kadrosuna dahil edildi!'
                                              : '[UYARI] Yetersiz bütçe! (Gereken: ₣3.000)',
                                          style: TextStyle(color: ok ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('[ARAMA]', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 6),
                                    Text(
                                      'YENİ GENÇ YETENEK SCOUT ET (₣3.000)',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. U19 Oyuncu Listesi
                      RetroWindow(
                        title: 'U19 KADROSU LİSTESİ (${u19.length} OYUNCU)',
                        icon: '[RAPOR]',
                        titleBarColor: AppColors.neoCardBg,
                        child: u19.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                color: Colors.black,
                                alignment: Alignment.center,
                                child: const Text(
                                  'Şu an U19 kadrosunda oyuncu bulunmuyor.\nYukarıdaki butondan yeni genç yetenekler scout edin.',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Column(
                                children: u19.map((player) {
                                  final rarityColor = AppColors.getRarityColor(player.stars);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.neoInnerBg,
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Row(
                                      children: [
                                        // Mevki Rozeti
                                        Container(
                                          width: 36,
                                          height: 36,
                                          color: Colors.black,
                                          alignment: Alignment.center,
                                          child: Text(
                                            player.position.code,
                                            style: TextStyle(
                                              color: rarityColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Oyuncu Bilgileri
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    player.fullName,
                                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                    color: AppColors.accentGold,
                                                    child: Text(
                                                      'POT: ${player.potential}',
                                                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 8.5),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Yaş: ${player.age} • ${player.ovr} OVR • Maaş: ₣${player.weeklyWage}/h',
                                                style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // A Takıma Yükselt Butonu
                                        RetroButton(
                                          backgroundColor: AppColors.neonCyan,
                                          textColor: Colors.black,
                                          onPressed: () {
                                            AudioSynthesizer.playClick();
                                            RetroImpactConfirmModal.show(
                                              context,
                                              title: 'GENÇ YETENEK PROFESYONEL İMZA',
                                              actionTitle: 'A TAKIMA YÜKSELTME VE SÖZLEŞME PROTOKOLÜ',
                                              description: '${player.fullName} için 3 yıllık profesyonel sözleşme imzalanacak ve A Takım kadrosuna dahil edilecek.',
                                              iconType: RetroPixelIconType.sprout,
                                              iconColor: AppColors.neonLime,
                                              targetItemName: player.fullName,
                                              targetItemDetails: '${player.age} Yaş • ${player.position.code} • ${player.ovr} OVR • POT: ${player.potential}',
                                              weeklyWageDelta: player.weeklyWage,
                                              fanDelta: 1,
                                              confirmButtonText: 'PROFESYONEL SÖZLEŞME İMZALA',
                                              confirmButtonColor: AppColors.neonLime,
                                              onConfirmed: () async {
                                                final ok = await ref.read(gameStateProvider.notifier).promoteU19Player(player);
                                                if (context.mounted && ok) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor: AppColors.neonLime,
                                                      content: Text(
                                                        'STAR ${player.fullName} başarıyla A Takıma yükseltildi!',
                                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                          child: const Text('A TAKIMA YÜKSELT', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  );
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
}
