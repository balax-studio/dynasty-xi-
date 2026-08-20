// presentation/widgets/president_statue_unveiling_modal.dart
// Club Legends & President Bronze Statue Unveiling Ceremony Modal

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../application/providers/game_state_provider.dart';
import 'retro_window.dart';

class PresidentStatueUnveilingModal extends ConsumerWidget {
  const PresidentStatueUnveilingModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const PresidentStatueUnveilingModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: RetroWindow(
        title: '🗿 STADYUM MEYDANINA HEYKEL DİKME TÖRENİ',
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.black,
                  child: const Row(
                    children: [
                      Text('🗿✨', style: TextStyle(fontSize: 26)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kazanılan tarihi başarıların ardından stadyum meydanına kulüp efsanesinin ya da başkanın bronz heykelini dikebilirsiniz.',
                          style: TextStyle(color: AppColors.accentGold, fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    backgroundColor: AppColors.accentGold,
                    textColor: Colors.black,
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).adjustCash(-100000);
                      ref.read(gameStateProvider.notifier).adjustFans(15);
                      ref.read(gameStateProvider.notifier).adjustBoardTrust(10);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryDeep,
                          content: Text(
                            '🗿 EFSANE BAŞKANIN BRONZ HEYKELİ AÇILDI! Taraftar coşkusu zirve yaptı (+15 Taraftar / +10 Güven)!',
                            style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('EFSANE BAŞKAN HEYKELİ (-₣100K / +15 TARAFTAR / +10 GÜVEN)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).adjustCash(-50000);
                      ref.read(gameStateProvider.notifier).adjustLockerRoom(15);
                      ref.read(gameStateProvider.notifier).adjustFans(10);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryDeep,
                          content: Text(
                            '⚽ KULÜP EFSANESİ KAPTAN HEYKELİ DİKİLDİ! Soyunma odası kenetlendi (+15 Moral)!',
                            style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('EFSANE KAPTAN HEYKELİ (-₣50K / +15 SOYUNMA / +10 TARAFTAR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
