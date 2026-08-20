// presentation/widgets/victory_bus_parade_dialog.dart
// Open-Top Champion Bus City Victory Parade Celebration Dialog

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../application/providers/game_state_provider.dart';
import 'retro_window.dart';

class VictoryBusParadeDialog extends ConsumerWidget {
  const VictoryBusParadeDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const VictoryBusParadeDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: RetroWindow(
        title: '🚌 ÜSTÜ AÇIK OTOBÜSLE ŞEHİR TURU KUTLAMASI',
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
                      Text('🚌🎆', style: TextStyle(fontSize: 26)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kazanılan kupa sonrası üstü açık otobüsle Bağdat Caddesi / Kordon turu ve Boğaz\'da havai fişek gösterisi düzenleyebilirsiniz.',
                          style: TextStyle(color: AppColors.neonLime, fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    backgroundColor: AppColors.neonLime,
                    textColor: Colors.black,
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).adjustCash(-40000);
                      ref.read(gameStateProvider.notifier).adjustFans(25);
                      ref.read(gameStateProvider.notifier).adjustLockerRoom(15);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryDeep,
                          content: Text(
                            '🚌 ÜSTÜ AÇIK OTOBÜSLE ŞEHİR KUTLAMASI YAPILDI! Yüzbinler sokağa döküldü (+25 Taraftar)!',
                            style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('ŞEHİR MERKEZİ TURU (-₣40K / +25 TARAFTAR / +15 MORAL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).adjustCash(-15000);
                      ref.read(gameStateProvider.notifier).adjustLockerRoom(10);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryDeep,
                          content: Text(
                            '🍽️ Kulüp tesislerinde şampiyonluk yemeği organize edildi (+10 Moral).',
                            style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('KULÜP İÇİ KUTLAMA YEMEĞİ (-₣15K / +10 MORAL)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
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
