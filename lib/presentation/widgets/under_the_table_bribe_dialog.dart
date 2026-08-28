// presentation/widgets/under_the_table_bribe_dialog.dart
// Under-the-table incentives: Luxury watches, villas, secret bonuses.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/player.dart';
import 'retro_window.dart';

class UnderTheTableBribeDialog extends ConsumerWidget {
  final Player player;

  const UnderTheTableBribeDialog({super.key, required this.player});

  static Future<void> show(BuildContext context, Player player) {
    return showDialog(
      context: context,
      builder: (_) => UnderTheTableBribeDialog(player: player),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: RetroWindow(
        title: '[ODUL] ELDEN GİZLİ PRİM & HEDİYE MASASI',
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
                  child: Text(
                    '${player.fullName} oyuncusunu resmi sözleşme haricinde elden teşvik etmek için başkanlık hediyesi seçin.',
                    style: const TextStyle(color: AppColors.neonLime, fontSize: 10.5),
                  ),
                ),
                const SizedBox(height: 12),

                _buildIncentiveRow(
                  context: context,
                  ref: ref,
                  title: ' İsviçre Lüks Kol Saati (-10.000 €)',
                  desc: 'Oyuncunun moralini ve bağlılığını anında +15 artırır.',
                  cost: 10000,
                  moraleBoost: 15,
                ),
                const SizedBox(height: 8),

                _buildIncentiveRow(
                  context: context,
                  ref: ref,
                  title: ' Lüks Spor Araba Tahsisi (-40.000 €)',
                  desc: 'Oyuncunun moralini +35 artırır. Transfer tekliflerini reddeder.',
                  cost: 40000,
                  moraleBoost: 35,
                ),
                const SizedBox(height: 8),

                _buildIncentiveRow(
                  context: context,
                  ref: ref,
                  title: ' Şehir Merkezinde Lüks Rezidans Dairesi (-100.000 €)',
                  desc: 'Kulüpte kalma garantisi verir, ömür boyu sadakat kazanır (+60).',
                  cost: 100000,
                  moraleBoost: 60,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncentiveRow({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String desc,
    required int cost,
    required int moraleBoost,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.win95Grey,
        border: Border.all(color: AppColors.win95DarkGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.win95TitleNavy)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 9.5, color: Colors.black87)),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: RetroButton(
              onPressed: () {
                ref.read(gameStateProvider.notifier).adjustCash(-cost);
                ref.read(gameStateProvider.notifier).adjustLockerRoom(10);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primaryDeep,
                    content: Text(
                      '[ODUL] Hediye ${player.fullName} oyuncusuna teslim edildi (-₣$cost)!',
                      style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
              child: const Text('HEDİYEYİ TESLİM ET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
