// presentation/screens/midnight_tv_debate_screen.dart
// Midnight Live Sports TV Show & Pundit Duel Screen (Gece 02:00 Canlı Yayın Düellosu)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/president/midnight_tv_debate.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class MidnightTvDebateScreen extends ConsumerWidget {
  const MidnightTvDebateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final debates = TvDebateTopic.getAvailableDebates();

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        backgroundColor: AppColors.neoCardBg,
        title: Text('📺 GECE 02:00 CANLI YAYIN DÜELLOSU', style: AppTypography.h2(color: Colors.white)),
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
                    title: 'CANLI YAYIN STÜDYOSU VE TELEFON BAĞLANTISI',
                    icon: '🎙️',
                    child: Row(
                      children: [
                        Text('📺🔥', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Gece yarısı spor programlarında kulübünüz hakkında ortaya atılan iddialara canlı yayına bağlanarak ya da baskın yaparak cevap verin!',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...debates.map((debate) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
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
                              Text(debate.showName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.win95TitleNavy)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: Colors.black,
                                child: Text('YORUMCU: ${debate.punditName}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 9.5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.black87,
                            child: Text(
                              '🗣️ "${debate.accusation}"',
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontStyle: FontStyle.italic),
                            ),
                          ),
                          const SizedBox(height: 8),

                          ...debate.choices.map((choice) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: SizedBox(
                                width: double.infinity,
                                child: RetroButton(
                                  onPressed: () {
                                    if (choice.cashDelta != 0) {
                                      ref.read(gameStateProvider.notifier).adjustCash(choice.cashDelta);
                                    }
                                    ref.read(gameStateProvider.notifier).adjustFans(choice.fansDelta);
                                    ref.read(gameStateProvider.notifier).adjustBoardTrust(choice.boardDelta);
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.primaryDeep,
                                        content: Text(
                                          '📺 REYTİNG: ${choice.ratingScore}/10! ${choice.outcomeText}',
                                          style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(choice.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                      Text(choice.dialogue, style: const TextStyle(fontSize: 9, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
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
