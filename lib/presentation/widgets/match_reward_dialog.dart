// presentation/widgets/match_reward_dialog.dart
// Post-Match Reward, XP Distribution, Cash Earnings and MOTM Dialog (§14.3, §21.3)

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/match/match_depth_models.dart';
import 'face_avatar_widget.dart';
import 'retro_button.dart';
import 'retro_window.dart';

class MatchRewardDialog extends StatelessWidget {
  final int userScore;
  final int oppScore;
  final String oppName;
  final int cashEarned;
  final int managerXpEarned;
  final int fanDelta;
  final String motmPlayerName;
  final int motmPlayerRating;
  final int motmSeed;
  final List<PlayerMatchSummary> topPerformers;
  final VoidCallback onContinue;

  const MatchRewardDialog({
    super.key,
    required this.userScore,
    required this.oppScore,
    required this.oppName,
    required this.cashEarned,
    required this.managerXpEarned,
    required this.fanDelta,
    required this.motmPlayerName,
    required this.motmPlayerRating,
    required this.motmSeed,
    required this.topPerformers,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isWin = userScore > oppScore;
    final isDraw = userScore == oppScore;
    final outcomeText = isWin ? 'GALİBİYET PRİMİ & KAZANÇ' : (isDraw ? 'BERABERLİK KAZANCI' : 'MAĞLUBİYET TELAFİSİ');
    final outcomeColor = isWin ? AppColors.neonLime : (isDraw ? AppColors.neonAmber : AppColors.comicRed);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: 'MAÇ SONU RAPORU & ÖDÜLLER',
        icon: '🏆',
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Result Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.black,
                child: Column(
                  children: [
                    Text(
                      '$userScore - $oppScore',
                      style: AppTypography.display(color: outcomeColor).copyWith(fontSize: 32),
                    ),
                    Text(
                      outcomeText,
                      style: TextStyle(color: outcomeColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Rewards Table
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141A24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    _buildRewardRow('💰 Maç Günü Geliri:', '+₣$cashEarned', AppColors.neonLime),
                    const SizedBox(height: 4),
                    _buildRewardRow('⭐ Menajer Deneyim Puanı:', '+$managerXpEarned XP', AppColors.accentGold),
                    const SizedBox(height: 4),
                    _buildRewardRow(
                      '👥 Taraftar Değişimi:',
                      '${fanDelta >= 0 ? "+" : ""}$fanDelta',
                      fanDelta >= 0 ? AppColors.neonCyan : AppColors.comicRed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // MOTM Star Card
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2405),
                  border: Border.all(color: AppColors.accentGold, width: 1.5),
                ),
                child: Row(
                  children: [
                    FaceAvatarWidget(seed: motmSeed, size: 44),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🌟 MAÇIN ADAMI (MOTM)', style: TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(motmPlayerName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('Maç Puanı: $motmPlayerRating / 10 • +50 Ekstra XP', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Continue Button
              Align(
                alignment: Alignment.centerRight,
                child: RetroButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onContinue();
                  },
                  backgroundColor: AppColors.neonLime,
                  textColor: Colors.black,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('DEVAM ET', style: TextStyle(fontWeight: FontWeight.w900)),
                      SizedBox(width: 4),
                      Text('▶'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
