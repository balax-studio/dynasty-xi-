// presentation/screens/legal_defense_screen.dart
// Club Legal Counsel, TFF/UEFA Disciplinary Appeals, and CAS Court Screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/president/legal_defense.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class LegalDefenseScreen extends ConsumerWidget {
  const LegalDefenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final cases = LegalCaseItem.getActiveCases();

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        backgroundColor: AppColors.neoCardBg,
        title: Text('KULÜP HUKUK BÜROSU & TAHKİM KURULU', style: AppTypography.h2(color: Colors.white)),
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
                    title: 'BAŞKANLIK HUKUK VE TAHKİM MERKEZİ',
                    icon: '[HUKUK]',
                    child: Row(
                      children: [
                        Text('[HUKUK]', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Kulübün aleyhine açılan davalar, TFF Disiplin Kurulu tribün/para cezaları ve FIFA sözleşme fesih itirazlarını buradan yönetin.',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...cases.map((c) {
                    final isResolved = state?.resolvedLegalCaseIds.contains(c.id) ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.win95Grey,
                        border: Border.all(color: isResolved ? AppColors.neonLime : AppColors.win95DarkGrey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.win95TitleNavy)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: Colors.black,
                                child: Text(
                                  isResolved ? 'SONUÇLANDI' : 'RİSK: ₣${(c.initialPenalty / 1000).toInt()}K',
                                  style: TextStyle(color: isResolved ? AppColors.neonLime : AppColors.comicRed, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.summary, style: const TextStyle(fontSize: 10.5, color: Colors.black87)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(6),
                            color: Colors.black87,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('İtiraz Masrafı: ₣${c.appealCost}', style: const TextStyle(color: AppColors.accentGold, fontSize: 10)),
                                Text('Kazanma Şansı: %${c.successChancePercent}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: RetroButton(
                              backgroundColor: isResolved ? AppColors.win95DarkGrey : AppColors.neonLime,
                              onPressed: isResolved
                                  ? null
                                  : () async {
                                      final won = await ref.read(gameStateProvider.notifier).resolveLegalAppeal(c);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.primaryDeep,
                                            content: Text(
                                              won
                                                  ? '[HUKUK] KAZANILDI! ${c.victoryOutcome}'
                                                  : '[RED] TAHKİM REDDETTİ! Ceza onandı (-₣${c.initialPenalty})',
                                              style: TextStyle(
                                                color: won ? AppColors.neonLime : AppColors.comicRed,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              child: Text(
                                isResolved ? ' DAVA TAHKİMDE SONUÇLANDI' : 'TAHKİM KURULUNA İTİRAZ DİLEKÇESİ VER (-₣${(c.appealCost / 1000).toInt()}K)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
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
        ],
      ),
    );
  }
}
