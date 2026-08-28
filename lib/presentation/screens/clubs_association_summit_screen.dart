// presentation/screens/clubs_association_summit_screen.dart
// Super League Clubs Association Summit, Broadcasting Tender & Coalition Voting Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/president/clubs_association.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class ClubsAssociationSummitScreen extends ConsumerWidget {
  const ClubsAssociationSummitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final agendas = AssociationSummitAgenda.getActiveAgendas();

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        backgroundColor: AppColors.neoCardBg,
        title: Text('[YÖNETİM] KULÜPLER BİRLİĞİ VAKFI ZİRVESİ', style: AppTypography.h2(color: Colors.white)),
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
                    title: 'SÜPER LİG BAŞKANLAR MECLİSİ',
                    icon: '[ANLASMA]',
                    child: Row(
                      children: [
                        Text('[YÖNETİM]', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Süper Lig kulüp başkanlarının toplandığı zirvede yayın hakları havuzu, yabancı kuralı ve TFF seçimleri için koalisyonlar kurup oy kullanın.',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...agendas.map((agenda) {
                    final isVoted = state?.votedSummitAgendaIds.contains(agenda.id) ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.win95Grey,
                        border: Border.all(color: isVoted ? AppColors.neonLime : AppColors.win95DarkGrey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(agenda.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.win95TitleNavy)),
                              ),
                              if (isVoted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  color: Colors.black,
                                  child: const Text('OYLANDI', style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 9.5)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(agenda.description, style: const TextStyle(fontSize: 10.5, color: Colors.black87)),
                          const SizedBox(height: 8),

                          if (isVoted)
                            Container(
                              padding: const EdgeInsets.all(6),
                              color: AppColors.win95DarkGrey,
                              child: const Center(
                                child: Text(
                                  ' OY KULLANILDI / ZİRVE KARARI RESMİLEŞTİ',
                                  style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          else
                            ...agenda.options.map((opt) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: RetroButton(
                                    onPressed: () async {
                                      await ref.read(gameStateProvider.notifier).voteSummitAgenda(
                                            agenda.id,
                                            cashDelta: opt.cashDelta,
                                            fansDelta: opt.fansDelta,
                                            boardDelta: opt.boardDelta,
                                            outcomeText: opt.outcomeText,
                                          );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppColors.primaryDeep,
                                            content: Text(
                                              ' OYLAMA SONUCU (%${opt.supportPercent} Destek): ${opt.outcomeText}',
                                              style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(opt.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5))),
                                        Text('%${opt.supportPercent} DESTEK', style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 9.5)),
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
