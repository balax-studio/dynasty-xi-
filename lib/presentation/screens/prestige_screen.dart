// presentation/screens/prestige_screen.dart
// Dynasty Prestige, Rebirth & Legacy Perks Shop Screen (§14.4)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/progression/dynasty_prestige.dart';
import '../widgets/retro_window.dart';

class PrestigeScreen extends ConsumerWidget {
  const PrestigeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Hata: $err'))),
      data: (gameState) {
        final dynastyPoints = gameState.manager.dynastyPoints;
        final perks = gameState.unlockedLegacyPerks;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            title: Text('HANEDAN PRESTİJ & MİRAS MAĞAZASI', style: AppTypography.h2(color: Colors.white)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Balance Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2405),
                    border: Border.all(color: AppColors.accentGold, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MEVCUT HANEDAN PUANI (DP)', style: TextStyle(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(
                              '$dynastyPoints DP',
                              style: AppTypography.display(color: Colors.white).copyWith(fontSize: 26),
                            ),
                            const Text(
                              'Hanedan Puanları kupa zaferleri, şampiyonluklar ve sezon başarılarıyla kazanılır. Kalıcıdır.',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Legacy Perks List
                Text('KALICI MİRAS YETENEKLERİ (LEGACY PERKS)', style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11)),
                const SizedBox(height: 8),

                ...DynastyPrestigeSystem.getDefaultPerks().map((perk) {
                  final isUnlocked = perks.any((p) => p.id == perk.id && p.isUnlocked);
                  final canAfford = dynastyPoints >= perk.costDynastyPoints;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141A24),
                      border: Border.all(
                        color: isUnlocked ? AppColors.neonLime : (canAfford ? AppColors.accentGold : Colors.white24),
                        width: isUnlocked ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(perk.icon, style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                perk.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                perk.description,
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${perk.costDynastyPoints} DP',
                                style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: AppColors.neonLime,
                            child: const Text('AÇIK ✅', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        else
                          RetroButton(
                            onPressed: canAfford
                                ? () {
                                    ref.read(gameStateProvider.notifier).unlockLegacyPerk(perk);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('⭐ "${perk.title}" kalıcı mirasa eklendi!')),
                                    );
                                  }
                                : null,
                            backgroundColor: canAfford ? AppColors.accentGold : Colors.grey,
                            textColor: Colors.black,
                            child: const Text('SATIN AL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
