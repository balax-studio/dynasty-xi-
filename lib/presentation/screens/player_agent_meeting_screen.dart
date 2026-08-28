// presentation/screens/player_agent_meeting_screen.dart
// Luxury Restaurant Meeting with Player's Agent

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/player.dart';
import '../../domain/player/player_agent_deals.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class PlayerAgentMeetingScreen extends ConsumerWidget {
  final Player player;

  const PlayerAgentMeetingScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final options = PlayerAgentMeetingOption.getOptions();

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        backgroundColor: AppColors.win95TitleNavy,
        title: Text('MENAJER ZİRVESİ: ${player.fullName.toUpperCase()}', style: AppTypography.h2(color: Colors.white)),
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
                  RetroWindow(
                    title: 'LÜKS RESTORAN GİZLİ PAZARLIK MASASI',
                    icon: '',
                    child: Row(
                      children: [
                        const Text('[MENAJER]', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${player.fullName} oyuncusunun FIFA lisanslı menajeri masada. Oyuncunun yeni sözleşmesi ve maaş indirimi için menajer komisyonu pazarlığı yapıyorsunuz.',
                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...options.map((opt) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.win95Grey,
                        border: Border.all(color: AppColors.win95DarkGrey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opt.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.win95TitleNavy)),
                          const SizedBox(height: 4),
                          Text(opt.description, style: const TextStyle(fontSize: 10, color: Colors.black87)),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: RetroButton(
                              onPressed: () async {
                                final success = await ref.read(gameStateProvider.notifier).resolveAgentMeeting(
                                      playerId: player.id,
                                      wageDiscountPercent: opt.wageDiscountPercent,
                                      extendSeasons: 1,
                                      cost: opt.cashCost,
                                      loyaltyBonus: opt.loyaltyBonus,
                                    );

                                if (context.mounted) {
                                  if (success) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.primaryDeep,
                                        content: Text(
                                          '[ANLASMA] Menajerle anlaşma sağlandı! ${player.fullName} sözleşmesi güncellendi.',
                                          style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: AppColors.comicRed,
                                        content: Text('[RED] Bakiye yetersiz! Komisyon ödenemedi.'),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text('ŞARTLARI KABUL ET & İMZALA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
