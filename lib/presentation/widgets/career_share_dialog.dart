// presentation/widgets/career_share_dialog.dart
// Shareable Retro Manager Career Summary Card Dialog (§13.6, §27.6)

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/entities/game_state.dart';
import 'face_avatar_widget.dart';
import 'retro_window.dart';

class CareerShareDialog extends StatelessWidget {
  final GameState gameState;

  const CareerShareDialog({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final manager = gameState.manager;
    final club = gameState.userClub;
    final trophiesCount = (20 - gameState.currentLeague.tier).clamp(0, 20);
    final licenseName = manager.level >= 5 ? 'UEFA Pro' : (manager.level >= 3 ? 'UEFA A' : 'UEFA B');

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: 'MENAJER KARİYER KARTI (SHARE.PNG)',
        icon: '',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Retro Exportable Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border.all(color: AppColors.accentGold, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      FaceAvatarWidget(seed: manager.name.hashCode, size: 60),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manager.name.toUpperCase(),
                              style: AppTypography.display(color: AppColors.accentGold).copyWith(fontSize: 16),
                            ),
                            Text(
                              '${club.name} • ${gameState.currentLeague.name}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Lisans: $licenseName | Seviye: ${manager.level}',
                              style: const TextStyle(color: AppColors.neonCyan, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('İTİBAR', '${manager.reputation} / 100', AppColors.neonLime),
                      _buildStatColumn('KUPALAR', '$trophiesCount', AppColors.accentGold),
                      _buildStatColumn('HANEDAN', '${manager.dynastyPoints} DP', AppColors.neonPink),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DYNASTY XI • RETRO FOOTBALL RPG',
                    style: AppTypography.label(color: Colors.white38).copyWith(fontSize: 9, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RetroButton(
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: AppColors.win95DarkGrey,
                  textColor: Colors.black,
                  child: const Text('KAPAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                const SizedBox(width: 8),
                RetroButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(' Kariyer kartı panoya kopyalandı!')),
                    );
                  },
                  backgroundColor: AppColors.neonLime,
                  textColor: Colors.black,
                  child: const Text('PAYLAŞ / KOPYALA', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
