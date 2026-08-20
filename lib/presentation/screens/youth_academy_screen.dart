// presentation/screens/youth_academy_screen.dart
// Dedicated Youth Academy Infrastructure & Talents Pipeline Screen (§10, §15)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/facility.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import 'facilities_screen.dart';
import 'u19_squad_screen.dart';

class YouthAcademyScreen extends ConsumerWidget {
  const YouthAcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final academyLevel = club.getFacilityLevel(FacilityType.youthAcademy);
        final u19Count = club.u19Squad.length;
        final coach = gameState.headCoach;

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
                const Text('🌱', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ALTYAPI AKADEMİSİ MERKEZİ', style: AppTypography.h3(color: Colors.white)),
                      const Text(
                        'WONDERKID FABRİKASI VE ALTYAPI TESİS GELİŞİMİ',
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
                      // 1. Akademi Tesis Durumu
                      RetroWindow(
                        title: 'AKADEMİ TESİS KAPASİTESİ (SEVİYE $academyLevel/5)',
                        icon: '🏛️',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.black,
                                  alignment: Alignment.center,
                                  child: const Text('🌱', style: TextStyle(fontSize: 28)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ALTYAPI SEVİYESİ: $academyLevel / 5',
                                        style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 13),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Yüksek seviye akademi, sezon başlarında ve scout aramalarında +80 ve +90 POT değerine sahip wonderkid üretir.',
                                        style: TextStyle(color: Colors.white70, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(color: AppColors.win95DarkGrey, height: 1),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'HOCA ÇARPANI: ${coach?.archetype.youthMultiplier ?? 1.0}x',
                                  style: const TextStyle(color: AppColors.accentGold, fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                                RetroButton(
                                  backgroundColor: AppColors.accentGold,
                                  textColor: Colors.black,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const FacilitiesScreen()),
                                    );
                                  },
                                  child: const Text('TESİSLERİ GELİŞTİR ❯', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. U19 Genç Takımı Köprüsü
                      RetroWindow(
                        title: 'U19 GENÇ TAKIMI ($u19Count YETENEK HAZIR)',
                        icon: '⚡',
                        titleBarColor: AppColors.neoCardBg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Akademide yetişen ve gelişmeye devam eden U19 oyuncularını listeleyin, durumlarını inceleyin ve hazır olanları A Takıma yükseltin.',
                              style: AppTypography.bodySmall(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: RetroButton(
                                backgroundColor: AppColors.neonLime,
                                textColor: Colors.black,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const U19SquadScreen()),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🌱', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text(
                                      'U19 KADROSUNU VE YETENEKLERİ AÇ',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
