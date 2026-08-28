// presentation/widgets/decision_card_widget.dart
// Nostalgic Comic Book / Y2K Trading Card Decision Card with Dialogue Bubbles.

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/card.dart';
import 'retro_window.dart';

class DecisionCardWidget extends StatelessWidget {
  final DecisionCard card;
  final Function(CardOption) onOptionSelected;

  const DecisionCardWidget({
    super.key,
    required this.card,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.accentGold,
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Windows 95 & Çizgi Roman Başlık Şeridi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.neoInnerBg,
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 2.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Text(
                    card.characterAvatar,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.characterName.toUpperCase(),
                        style: AppTypography.label(color: Colors.white).copyWith(
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        card.characterRole,
                        style: AppTypography.bodySmall(color: AppColors.neonCyan).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                RetroBadge(
                  text: card.category.label,
                  icon: card.category.icon,
                  backgroundColor: AppColors.comicYellow,
                  textColor: Colors.black,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Çizgi Roman Manşeti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonPink.withValues(alpha: 0.15),
                    border: const Border(
                      left: BorderSide(color: AppColors.neonPink, width: 4),
                    ),
                  ),
                  child: Text(
                    card.headline.toUpperCase(),
                    style: AppTypography.h2(color: AppColors.accentGold).copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Çizgi Roman Konuşma / Hikaye Balonu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2230),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('[MESAJ]', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          card.storyText,
                          style: AppTypography.story(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 4. Karar Seçenek Butonları (Y2K Neon Kutuları)
                Text(
                  'BOLT MENAJER KARARI:',
                  style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11),
                ),
                const SizedBox(height: 6),
                ...card.options.map((option) => _buildRetroOptionButton(option)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroOptionButton(CardOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RetroButton(
        onPressed: () {
          AudioSynthesizer.playClick();
          onOptionSelected(option);
        },
        backgroundColor: AppColors.neoInnerBg,
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('▶', style: TextStyle(color: AppColors.neonAmber, fontSize: 11)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    option.text,
                    style: AppTypography.body(color: Colors.white).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Etki Göstergeleri (Piksel Delta Etiketleri)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (option.deltaCash != 0)
                  _buildPixelDeltaTag(
                    '₣${option.deltaCash > 0 ? '+' : ''}${_formatCash(option.deltaCash)}',
                    option.deltaCash > 0 ? AppColors.neonLime : AppColors.comicRed,
                  ),
                if (option.deltaFans != 0)
                  _buildPixelDeltaTag(
                    'FAN ${option.deltaFans > 0 ? '+' : ''}${option.deltaFans}',
                    option.deltaFans > 0 ? AppColors.neonLime : AppColors.comicRed,
                  ),
                if (option.deltaLockerRoom != 0)
                  _buildPixelDeltaTag(
                    'MORAL ${option.deltaLockerRoom > 0 ? '+' : ''}${option.deltaLockerRoom}',
                    option.deltaLockerRoom > 0 ? AppColors.neonLime : AppColors.comicRed,
                  ),
                if (option.deltaBoardTrust != 0)
                  _buildPixelDeltaTag(
                    'GÜVEN ${option.deltaBoardTrust > 0 ? '+' : ''}${option.deltaBoardTrust}',
                    option.deltaBoardTrust > 0 ? AppColors.neonLime : AppColors.comicRed,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPixelDeltaTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: AppTypography.label(color: color).copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _formatCash(int n) {
    if (n.abs() >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toString();
  }
}
