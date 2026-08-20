// presentation/widgets/hostile_takeover_rescue_modal.dart
// Emergency Financial Bailout & Hostile Takeover Defense Modal for Sacked Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../application/providers/game_state_provider.dart';
import 'retro_window.dart';

class HostileTakeoverRescueModal extends ConsumerWidget {
  const HostileTakeoverRescueModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const HostileTakeoverRescueModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: RetroWindow(
        title: '💼 ACİL KULÜP KURTARMA VE SERMAYE ARTIRIMI',
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
                      Text('🏦🚨', style: TextStyle(fontSize: 26)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kulüp iflasın ve kayyum atanmasının eşiğinde! Şahsi servetinizden hibe yaparak ya da yabancı fona hisse satarak kulübü kurtarabilirsiniz.',
                          style: TextStyle(color: AppColors.comicRed, fontSize: 10.5),
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
                      ref.read(gameStateProvider.notifier).adjustCash(250000);
                      ref.read(gameStateProvider.notifier).adjustBoardTrust(25);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryDeep,
                          content: Text(
                            '💰 ŞAHSİ SERVETTEN ₣250.000 HİBE EDİLDİ! Kayyum tehlikesi savuşturuldu, güven tazelendi!',
                            style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('ŞAHSİ SERVETTEN HİBE AKTAR (+₣250K / +25 GÜVEN)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: RetroButton(
                    backgroundColor: AppColors.comicRed,
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).adjustCash(500000);
                      ref.read(gameStateProvider.notifier).adjustFans(-15);
                      ref.read(gameStateProvider.notifier).adjustBoardTrust(30);
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppColors.primaryDeep,
                          content: Text(
                            '🌍 KÖRFEZ YATIRIM FONUNA %25 HİSSE SATILDI (+₣500K Kasaya Girdi)!',
                            style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                    child: const Text('YATIRIM FONUNA AZINLIK HİSSESİ SAT (+₣500K GELİR)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
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
