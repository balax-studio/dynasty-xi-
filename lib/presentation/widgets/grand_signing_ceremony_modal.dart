// presentation/widgets/grand_signing_ceremony_modal.dart
// Post-Transfer Celebration & Grand Stadium Signing Ceremony Modal

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/player.dart';
import 'face_avatar_widget.dart';
import 'retro_pixel_icon.dart';
import 'retro_window.dart';

class GrandSigningCeremonyModal extends ConsumerWidget {
  final Player player;
  final int fee;
  final int wage;

  const GrandSigningCeremonyModal({
    super.key,
    required this.player,
    required this.fee,
    required this.wage,
  });

  static void show(BuildContext context, Player player, int fee, int wage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GrandSigningCeremonyModal(player: player, fee: fee, wage: wage),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final currentCash = state?.userClub.meters.cash ?? 0;
    const ceremonyCost = 8000;
    final canAffordStadium = currentCash >= ceremonyCost;
    final estimatedJerseySales = (player.ovr * 320).clamp(15000, 45000);
    final rarityColor = AppColors.getRarityColor(player.stars);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: 'TRANSFER TAMAMLANDI: İMZA TÖRENİ',
        icon: 'trophy',
        titleBarColor: AppColors.win95TitleNavy,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Oyuncu Kimlik Kartı & Başarı Flaşı
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: AppColors.neonLime, width: 2),
              ),
              child: Row(
                children: [
                  FaceAvatarWidget(seed: player.faceSeed, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.fullName.toUpperCase(),
                          style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${player.position.label} • ${player.age} Yaş • ${player.ovr} OVR (${player.potential} POT)',
                          style: TextStyle(color: rarityColor, fontWeight: FontWeight.bold, fontSize: 10.5),
                        ),
                        Text(
                          'Bonservis: ₣$fee • Maaş: ₣$wage/h',
                          style: const TextStyle(color: AppColors.neonLime, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Basın mensupları ve taraftarlar kulüp binasının önünde toplandı! Yeni transferimiz için nasıl bir lansman töreni düzenlemek istersiniz?',
              style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 11),
            ),
            const SizedBox(height: 14),

            // Seçenek 1: Görkemli Stadyum Lansmanı
            RetroButton(
              backgroundColor: canAffordStadium ? AppColors.neonLime : AppColors.win95DarkGrey,
              textColor: Colors.black,
              onPressed: canAffordStadium
                  ? () async {
                      AudioSynthesizer.playSuccess();
                      await ref.read(gameStateProvider.notifier).holdGrandSigningCeremony(
                            player: player,
                            isGrandStadiumShow: true,
                          );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.neonLime,
                            content: Text(
                              '🏟️ ${player.fullName} stadyumda binlerce taraftar önünde imza attı! +₣${estimatedJerseySales - ceremonyCost} Net Gelir, +%15 Taraftar Coşkusu!',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RetroPixelIcon(type: RetroPixelIconType.stadium, size: 16, color: Colors.black),
                        SizedBox(width: 6),
                        Text(
                          'STADYUMDA GÖRKEMLİ İMZA ŞOVU',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Maliyet: ₣$ceremonyCost • Tahmini Forma Satışı: +₣$estimatedJerseySales • Taraftar: +%15 • +25 DP',
                      style: const TextStyle(fontSize: 9, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Seçenek 2: Sade Tesis İmzası
            RetroButton(
              backgroundColor: AppColors.neoInnerBg,
              textColor: Colors.white,
              onPressed: () {
                AudioSynthesizer.playClick();
                Navigator.of(context).pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RetroPixelIcon(type: RetroPixelIconType.pen, size: 14, color: Colors.white70),
                    SizedBox(width: 6),
                    Text(
                      'TESİSLERDE SADE İMZA TÖRENİ (Ücretsiz)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
