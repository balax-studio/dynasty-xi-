// presentation/screens/transfer_hijack_screen.dart
// Live Transfer Hijacking (Ezeli Rakipten Transfer Çalımı Masası)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/transfers/transfer_hijack.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class TransferHijackScreen extends ConsumerWidget {
  const TransferHijackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final targets = TransferHijackTarget.getAvailableHijacks();

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        backgroundColor: AppColors.win95TitleNavy,
        title: Text('SON DAKİKA TRANSFER ÇALIMI MASASI', style: AppTypography.h2(color: Colors.white)),
      ),
      body: Column(
        children: [
          if (state != null) MetersBarWidget(meters: state.userClub.meters),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RetroWindow(
                    title: 'OTEL BASKINI VE TRANSFERİ KAÇIRMA',
                    icon: '🕵️‍♂️',
                    child: Row(
                      children: [
                        Text('🏨✈️', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ezeli rakiplerinizin imza aşamasına getirdiği yıldız oyuncuları daha yüksek nakit teklifi ve özel jetle kaçırarak taraftarı coşturun!',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...targets.map((target) {
                    final totalCost = target.requiredHijackBid + target.requiredAgentCommission;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.win95Grey,
                        border: Border.all(color: AppColors.comicRed, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                target.playerName.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.win95TitleNavy),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: Colors.black,
                                child: Text(
                                  'OVR: ${target.overallRating}',
                                  style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pozisyon: ${target.playerPosition} • Anlaştığı Kulüp: ${target.rivalClubName}',
                            style: const TextStyle(color: Colors.black87, fontSize: 10.5),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(6),
                            color: Colors.black87,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Rakibin Teklifi: ₣${target.rivalBidAmount}', style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
                                Text('Çalım Bedeli: ₣${target.requiredHijackBid} + ₣${target.requiredAgentCommission} Komisyon', style: const TextStyle(color: AppColors.accentGold, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                Text('🌟 TARAFTAR COŞKUSU BONUSU: +%${target.fansHypeBonus}', style: const TextStyle(color: AppColors.neonLime, fontSize: 9.5, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: RetroButton(
                              backgroundColor: AppColors.comicRed,
                              onPressed: () {
                                ref.read(gameStateProvider.notifier).adjustCash(-totalCost);
                                ref.read(gameStateProvider.notifier).adjustFans(target.fansHypeBonus);
                                ref.read(gameStateProvider.notifier).adjustBoardTrust(8);
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.primaryDeep,
                                    content: Text(
                                      '🔥 DEV TRANSFER ÇALIMI! ${target.playerName} özel jetle kulübe getirildi (-₣$totalCost)!',
                                      style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              },
                              child: Text('✈️ ÖZEL JET KALDIR & ÇALIMI AT (-₣${(totalCost / 1000).toInt()}K)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
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
        ],
      ),
    );
  }
}
