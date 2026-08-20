import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/entities/meter.dart';
import 'retro_pixel_icon.dart';

class MetersBarWidget extends StatelessWidget {
  final ClubMeters meters;

  const MetersBarWidget({
    super.key,
    required this.meters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: AppColors.neoBoxDecoration(
        backgroundColor: AppColors.neoCardBg,
        borderColor: Colors.black,
        shadowColor: AppColors.neonLime,
        shadowOffset: const Offset(3, 3),
        borderWidth: 2.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // 1. Kasa (₣) - Windows 95 Inset Data Display
              Expanded(
                flex: 3,
                child: _buildCashPanel(
                  'KASA',
                  '₣${_formatNumber(meters.cash)}',
                  meters.isCashDebt ? AppColors.signalRed : AppColors.neonLime,
                  RetroPixelIconType.cash,
                ),
              ),
              const SizedBox(width: 6),

              // 2. Taraftar (0 - 100) - Segmented LED
              Expanded(
                flex: 2,
                child: _buildMeterPanel(
                  'FAN',
                  meters.fans,
                  RetroPixelIconType.megaphone,
                  meters.isFansCritical,
                ),
              ),
              const SizedBox(width: 6),

              // 3. Soyunma Odası (0 - 100) - Segmented LED
              Expanded(
                flex: 2,
                child: _buildMeterPanel(
                  'MORAL',
                  meters.lockerRoom,
                  RetroPixelIconType.shirt,
                  meters.isLockerRoomCritical,
                ),
              ),
              const SizedBox(width: 6),

              // 4. Yönetim Güveni (0 - 100) - Segmented LED
              Expanded(
                flex: 2,
                child: _buildMeterPanel(
                  'GÜVEN',
                  meters.boardTrust,
                  RetroPixelIconType.capitol,
                  meters.isBoardCritical,
                  warning: meters.isBoardWarning,
                ),
              ),
            ],
          ),
          if (meters.isBoardCritical) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: AppColors.signalRed, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Text(
                    'KRİTİK GÜVEN: ${meters.consecutiveCriticalMatches}/${ClubMeters.graceMatchesAllowed} MAÇ İÇİNDE KOVULMA TEHLİKESİ!',
                    style: AppTypography.label(color: AppColors.signalRed).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCashPanel(String label, String value, Color color, RetroPixelIconType iconType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
          left: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
          right: BorderSide(color: AppColors.win95White, width: 1.5),
          bottom: BorderSide(color: AppColors.win95White, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          RetroPixelIcon(
            type: iconType,
            size: 14,
            color: color,
            secondaryColor: Colors.black,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.label(color: AppColors.neutral300).copyWith(fontSize: 9),
                ),
                Text(
                  value,
                  style: AppTypography.monoNumber(color: color).copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeterPanel(
    String label,
    int value,
    RetroPixelIconType iconType,
    bool isCritical, {
    bool warning = false,
  }) {
    final activeColor = isCritical
        ? AppColors.signalRed
        : (warning ? AppColors.signalAmber : AppColors.neonLime);

    // 5 Bloklu Retro Segmented LED Göstergesi
    final activeBlocks = ((value / 100.0) * 5).round().clamp(0, 5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: isCritical ? AppColors.signalRed : (warning ? AppColors.signalAmber : Colors.black),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RetroPixelIcon(
                    type: iconType,
                    size: 11,
                    color: activeColor,
                    secondaryColor: Colors.black,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    label,
                    style: AppTypography.label(color: AppColors.neutral300).copyWith(fontSize: 9),
                  ),
                ],
              ),
              Text(
                '%$value',
                style: AppTypography.label(color: activeColor).copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 3),
          // 5-Segment LED Bar
          Row(
            children: List.generate(5, (index) {
              final isFilled = index < activeBlocks;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 2),
                  decoration: BoxDecoration(
                    color: isFilled ? activeColor : const Color(0xFF22262B),
                    borderRadius: BorderRadius.circular(0.5),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n.abs() >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    } else if (n.abs() >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toString();
  }
}
