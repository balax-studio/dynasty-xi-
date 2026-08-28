// presentation/widgets/foreign_takeover_dialog.dart
// Foreign Takeover & Strategic Investment Offer Dialog

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/economy/stock_market.dart';
import 'retro_window.dart';

class ForeignTakeoverDialog extends ConsumerWidget {
  const ForeignTakeoverDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ForeignTakeoverDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final currentSold = state?.soldClubSharePercent ?? 0;
    final offers = ForeignTakeoverOffer.getAvailableOffers();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: RetroWindow(
        title: ' YABANCI FON & SERMAYE ORTAKLIĞI TEKLİFLERİ',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Uluslararası konsorsiyumlar kulübünüze azınlık hissesi ortaklığı teklif ediyor. Hisse devri büyük nakit sağlar ancak yönetimde söz sahibi olurlar.',
                        style: TextStyle(color: AppColors.neonLime, fontSize: 10.5),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'DEVREDİLEN HİSSE: %$currentSold / MAKSİMUM KOTA: %49',
                        style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                ...offers.map((offer) {
                  final canSell = (currentSold + offer.stakePercentage) <= 49;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.win95Grey,
                      border: Border.all(color: canSell ? AppColors.win95DarkGrey : AppColors.comicRed),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(offer.investorBadge, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                offer.investorName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.win95TitleNavy),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              color: Colors.black,
                              child: Text(
                                '+₣${(offer.cashOfferAmount / 1000).toInt()}K',
                                style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(offer.investorAgenda, style: const TextStyle(fontSize: 10.5, color: Colors.black87)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: RetroButton(
                            backgroundColor: canSell ? AppColors.neonLime : AppColors.win95DarkGrey,
                            onPressed: !canSell
                                ? null
                                : () async {
                                    final success = await ref.read(gameStateProvider.notifier).sellClubShares(
                                          percent: offer.stakePercentage,
                                          cashAmount: offer.cashOfferAmount,
                                        );
                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.primaryDeep,
                                            content: Text(
                                              '[ANLASMA] ${offer.investorName} hisse devri onaylandı! Kasaya +₣${offer.cashOfferAmount} eklendi.',
                                              style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: AppColors.comicRed,
                                            content: Text('[RED] Hisse satış limiti (%49) aşılamaz!'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: Text(
                              canSell
                                  ? '%${offer.stakePercentage} HİSSEYİ SAT & ANLAŞMAYI İMZALA'
                                  : 'KOTA DOLDU (MAKS %49 AŞILAMAZ)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: canSell ? Colors.black : Colors.white60),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
