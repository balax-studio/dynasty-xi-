// presentation/widgets/tax_audit_inspection_modal.dart
// Tax Audit Inspection & Interrogation Modal Dialog

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/economy/tax_audit.dart';
import 'retro_window.dart';

class TaxAuditInspectionModal extends ConsumerWidget {
  const TaxAuditInspectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TaxAuditInspectionModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final cash = state?.userClub.meters.cash ?? 100000;
    final scenario = TaxAuditScenario.generateInspection(cash);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: RetroWindow(
        title: '[HUKUK] MALİYE MÜFETTİŞİ VERGİ DENETİMİ',
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
                  child: Row(
                    children: [
                      const Text('[SCOUT][RAPOR]', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(scenario.title, style: AppTypography.label(color: AppColors.comicRed).copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(scenario.description, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Text('BAŞKANLIK SAVUNMASI VE MÜDAHALE:', style: AppTypography.label(color: Colors.black).copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 8),

                // Seçenek 1: Cezayı Tam Öde
                _buildChoice(
                  context: context,
                  ref: ref,
                  title: 'Resmi Cezayı Tam Öde (-₣${(scenario.auditFineAmount / 1000).toInt()}K)',
                  desc: 'Kanunlara tam uy, kasadan ceza öde. Yönetim güveni temiz kalır.',
                  onTap: () {
                    ref.read(gameStateProvider.notifier).adjustCash(-scenario.auditFineAmount);
                    ref.read(gameStateProvider.notifier).adjustBoardTrust(5);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),

                // Seçenek 2: Siyasi Lobicilik & Vergi Barı
                _buildChoice(
                  context: context,
                  ref: ref,
                  title: 'Bakanlık & Siyasi Lobi Yap (-₣${(scenario.lobbyCost / 1000).toInt()}K)',
                  desc: 'Ankara lobisini devreye sok, cezayı %80 indirimle yapılandır.',
                  onTap: () {
                    ref.read(gameStateProvider.notifier).adjustCash(-scenario.lobbyCost);
                    ref.read(gameStateProvider.notifier).adjustFans(-3);
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 8),

                // Seçenek 3: Müfettişle Anlaş / Rüşvet
                _buildChoice(
                  context: context,
                  ref: ref,
                  title: 'Müfettişe Gizli Protokol Öner (-₣${(scenario.bribeCost / 1000).toInt()}K)',
                  desc: 'Dosyayı kapattır. Riskli fakat en ucuz yöntem.',
                  onTap: () {
                    ref.read(gameStateProvider.notifier).adjustCash(-scenario.bribeCost);
                    ref.read(gameStateProvider.notifier).adjustLockerRoom(-2);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoice({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: RetroButton(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.win95TitleNavy)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Colors.black87, fontSize: 9.5)),
            ],
          ),
        ),
      ),
    );
  }
}
