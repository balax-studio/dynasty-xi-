// presentation/widgets/counterfeit_raid_modal.dart
// Counterfeit Merchandise Police Raid Modal Dialog

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../application/providers/game_state_provider.dart';
import 'retro_window.dart';

class CounterfeitRaidModal extends ConsumerWidget {
  const CounterfeitRaidModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const CounterfeitRaidModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: RetroWindow(
        title: '👮‍♂️ KORSAN ÜRÜNLE MÜCADELE OPERASYONU',
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
                      Text('👕📦', style: TextStyle(fontSize: 26)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Stadyum çevresinde korsan forma ve atkı satan 15 seyyar tezgah tespit edildi. Emniyet ve zabıta baskını emri verebilirsiniz.',
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
                    backgroundColor: AppColors.comicRed,
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).adjustCash(20000);
                      ref.read(gameStateProvider.notifier).adjustFans(-4);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryDeep,
                          content: Text(
                            '🚨 Zabıta operasyonu tamamlandı! Ele geçirilen ürünlerden kulüp kasasına +₣20.000 girdi.',
                            style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('POLİS & ZABITA BASKINI DÜZENLE (+₣20K GELİR)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).adjustFans(6);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryDeep,
                          content: Text(
                            '🤝 Seyyar satıcılara dokunulmadı. Dar gelirli taraftarlar memnun oldu (+6 Taraftar).',
                            style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('GÖRMEZDEN GEL & TARAFTARI KORU (+TARAFTAR COŞKUSU)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
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
