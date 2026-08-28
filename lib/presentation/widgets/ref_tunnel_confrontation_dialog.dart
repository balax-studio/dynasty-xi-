// presentation/widgets/ref_tunnel_confrontation_dialog.dart
// Halftime Referee Tunnel Confrontation / Hakem Odası & Koridor Baskını

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/president/president_crisis.dart';
import 'retro_window.dart';

class RefTunnelConfrontationDialog extends ConsumerWidget {
  final Function(RefTunnelOutcome outcome) onConfrontationComplete;

  const RefTunnelConfrontationDialog({
    super.key,
    required this.onConfrontationComplete,
  });

  static Future<void> show(
    BuildContext context,
    Function(RefTunnelOutcome outcome) onComplete,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RefTunnelConfrontationDialog(onConfrontationComplete: onComplete),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: RetroWindow(
        title: 'BOLT DEVRE ARASI KORİDOR BASKINI',
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: AppColors.comicRed, width: 2),
                  ),
                  child: const Row(
                    children: [
                      Text('[HUKUK]', style: TextStyle(fontSize: 32)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Hakem odasına ve koridora indiniz! Temsilciler ve korumalar etrafınızı sardı. Hakeme nasıl müdahale edeceksiniz?',
                          style: TextStyle(color: Colors.white, fontSize: 11, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _buildApproachButton(
                  context: context,
                  ref: ref,
                  index: 0,
                  title: '[FORM] Sert Gözdağı Ver ("Bu Şehirden Çıkamazsın")',
                  desc: 'Hakem korkar (+Hakem Etkisi), ancak TFF 40.000 € ceza keser.',
                ),
                const SizedBox(height: 8),

                _buildApproachButton(
                  context: context,
                  ref: ref,
                  index: 1,
                  title: ' Diplomatik & Kural Hatası Uyarısı Yap',
                  desc: 'Tabletten pozisyonu göster. Hakem tarafsızlaşır, ceza riski olmaz.',
                ),
                const SizedBox(height: 8),

                _buildApproachButton(
                  context: context,
                  ref: ref,
                  index: 2,
                  title: ' Hakem Odası Kapısını Tekmele & Kameralara Konuş',
                  desc: 'Büyük skandal çıkar. Takım kenetlenir (+Soyunma), 60.000 € para cezası gelir.',
                ),
                const SizedBox(height: 10),

                Center(
                  child: RetroButton(
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: AppColors.win95DarkGrey,
                    textColor: Colors.black,
                    child: const Text('Vazgeç ve Protokol Tribününe Dön', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApproachButton({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required String title,
    required String desc,
  }) {
    return SizedBox(
      width: double.infinity,
      child: RetroButton(
        onPressed: () {
          final outcome = RefTunnelOutcome.executeConfrontation(index);
          final notifier = ref.read(gameStateProvider.notifier);

          if (outcome.cashFine > 0) notifier.adjustCash(-outcome.cashFine);
          if (outcome.lockerRoomDelta != 0) notifier.adjustLockerRoom(outcome.lockerRoomDelta);
          if (outcome.boardTrustDelta != 0) notifier.adjustBoardTrust(outcome.boardTrustDelta);

          Navigator.of(context).pop();
          onConfrontationComplete(outcome);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.win95TitleNavy),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(color: Colors.black87, fontSize: 9.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
