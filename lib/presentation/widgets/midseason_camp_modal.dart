// presentation/widgets/midseason_camp_modal.dart
// Mid-season winter training camp selection modal with Brutalist aesthetics and zero-emoji compliance.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/facilities/training_camp.dart';
import 'retro_pixel_icon.dart';
import 'retro_window.dart';

class MidSeasonCampModal extends ConsumerWidget {
  const MidSeasonCampModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: MidSeasonCampModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e', style: const TextStyle(color: Colors.white))),
      data: (gameState) {
        final currentCash = gameState.userClub.meters.cash;
        final packages = TrainingCampPackage.allPackages;

        return Container(
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: AppColors.primaryDeep,
            border: Border.all(color: AppColors.neonCyan, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık Çubuğu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: AppColors.win95TitleNavy,
                child: Row(
                  children: [
                    const RetroPixelIcon(type: RetroPixelIconType.whistle, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DEVRE ARASI HAZIRLIK KAMPI YÖNETİMİ',
                        style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Açıklama Banner
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: AppColors.neoInnerBg,
                      child: const Row(
                        children: [
                          RetroPixelIcon(type: RetroPixelIconType.tacticsBoard, size: 16, color: AppColors.neonCyan),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ligin ilk yarısı tamamlandı. 2. Yarı maratonu öncesinde oyuncu kondisyonunu ve takım uyumunu tazeleyecek kamp paketini onaylayınız.',
                              style: TextStyle(color: Colors.white70, fontSize: 10.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Kasa Durumu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'KULÜP KASA REZERVİ:',
                          style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₣$currentCash',
                          style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Paket Seçenekleri Listesi
                    ...packages.map((pkg) {
                      final canAfford = currentCash >= pkg.cost;
                      return _buildCampPackageCard(context, ref, pkg, canAfford);
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampPackageCard(BuildContext context, WidgetRef ref, TrainingCampPackage pkg, bool canAfford) {
    final borderColor = pkg.cost == 0
        ? Colors.white30
        : pkg.cost > 30000
            ? AppColors.accentGold
            : AppColors.neonCyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.neoCardBg,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pkg.location.title.toUpperCase(),
                style: TextStyle(color: borderColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                pkg.cost == 0 ? 'ÜCRETSİZ' : '₣${pkg.cost}',
                style: AppTypography.monoNumber(color: canAfford ? AppColors.neonLime : AppColors.signalRed).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            pkg.location.description,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 8),

          // Kazanım Rozetleri
          Row(
            children: [
              _buildStatBadge('Kondisyon', '+${pkg.staminaRegen}'),
              const SizedBox(width: 6),
              _buildStatBadge('Moral', '+${pkg.moraleBoost}'),
              const SizedBox(width: 6),
              _buildStatBadge('Uyum', '+${pkg.tacticalFamiliarityBonus}'),
              const Spacer(),
              RetroButton(
                onPressed: canAfford
                    ? () async {
                        AudioSynthesizer.playClick();
                        final ok = await ref.read(gameStateProvider.notifier).executeTrainingCamp(pkg);
                        if (context.mounted && ok) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.win95TitleNavy,
                              content: Text('[KAMP TAMAMLANDI] ${pkg.location.title} programı başarıyla uygulandı!'),
                            ),
                          );
                        }
                      }
                    : null,
                backgroundColor: canAfford ? borderColor : AppColors.win95DarkGrey,
                textColor: Colors.black,
                child: Text(
                  canAfford ? 'KAMPI BAŞLAT' : 'YETERSİZ BAKİYE',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: AppColors.neonLime, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
