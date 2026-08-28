// presentation/widgets/loan_contract_summary_modal.dart
// Loan Contract Summary & Terms Review Modal.
// Displays parent club terms, wage share, buyout clause, and provides confirmation before borrowing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/economy/transfer_models.dart';
import 'retro_window.dart';

class LoanContractSummaryModal extends StatefulWidget {
  final LoanDeal deal;

  const LoanContractSummaryModal({
    super.key,
    required this.deal,
  });

  static Future<bool?> show(BuildContext context, LoanDeal deal) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LoanContractSummaryModal(deal: deal),
    );
  }

  @override
  State<LoanContractSummaryModal> createState() => _LoanContractSummaryModalState();
}

class _LoanContractSummaryModalState extends State<LoanContractSummaryModal> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final p = deal.player;
    final rarityColor = AppColors.getRarityColor(p.stars);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: 'KİRALIK TRANSFER SÖZLEŞME MASASI',
        icon: 'handshake',
        titleBarColor: const Color(0xFF1E3A8A),
        child: Consumer(
          builder: (context, ref, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Oyuncu Kartı
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neoInnerBg,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        color: Colors.black,
                        child: Text(p.position.code, style: TextStyle(color: rarityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.fullName, style: AppTypography.label(color: Colors.white).copyWith(fontSize: 12)),
                            Text('Sahibi: ${deal.parentClubName} • OVR ${p.ovr} • POT ${p.potential}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Sözleşme Detayları & Maddeleri
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('KİRALAMA PROTOKOLÜ VE ŞARTLAR', style: TextStyle(color: AppColors.neonCyan, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kiralama Süresi:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text('${deal.seasons} Sezon (1 Yıl)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bonservis Ödemesi:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text('₣0 (Ücretsiz Geçici Transfer)', style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10.5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Üstlenilen Haftalık Maaş:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text('₣${deal.weeklyWageToPay}/hafta (%${(deal.borrowingClubWageShare * 100).round()})', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 10.5)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sezon Sonu Satın Alma Opsiyonu:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text('₣${deal.buyoutClause}', style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 10.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Butonlar
                if (_isProcessing)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black, border: Border.all(color: AppColors.neonCyan)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonCyan)),
                        SizedBox(width: 8),
                        Text('KİRALIK SÖZLEŞMESİ ONAYLANIP İMZALANIYOR...', style: TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: RetroButton(
                          backgroundColor: AppColors.win95LightGrey,
                          textColor: Colors.black,
                          onPressed: () {
                            AudioSynthesizer.playClick();
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('VAZGEÇ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: RetroButton(
                          backgroundColor: AppColors.neonCyan,
                          textColor: Colors.black,
                          onPressed: () async {
                            setState(() => _isProcessing = true);
                            AudioSynthesizer.playSuccess();
                            await Future.delayed(const Duration(milliseconds: 450));
                            final ok = await ref.read(gameStateProvider.notifier).loanInPlayer(deal);
                            if (context.mounted) {
                              Navigator.of(context).pop(ok);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? '[KUTLAMA] ${p.fullName} 1 sezonluğuna kiralandı! Haftalık maaş: ₣${deal.weeklyWageToPay}'
                                        : '[UYARI] Kiralama gerçekleştirilemedi.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('SÖZLEŞMEYİ İMZALA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
