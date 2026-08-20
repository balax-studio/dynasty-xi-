// presentation/widgets/president_origin_selection_widget.dart
// FTUE President Origin Archetype Selection Widget

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../domain/president/president_origin.dart';

class PresidentOriginSelectionWidget extends StatelessWidget {
  final PresidentOriginType selectedOrigin;
  final Function(PresidentOriginType origin) onOriginSelected;

  const PresidentOriginSelectionWidget({
    super.key,
    required this.selectedOrigin,
    required this.onOriginSelected,
  });

  @override
  Widget build(BuildContext context) {
    final origins = PresidentOrigin.getAllOrigins();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BAŞKANLIK GEÇMİŞİ & KÖKEN HİKAYENİZİ SEÇİN:',
          style: AppTypography.label(color: AppColors.accentGold).copyWith(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        ...origins.map((origin) {
          final isSelected = origin.type == selectedOrigin;

          return GestureDetector(
            onTap: () => onOriginSelected(origin.type),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.win95TitleNavy : AppColors.win95Grey,
                border: Border.all(
                  color: isSelected ? AppColors.neonLime : AppColors.win95DarkGrey,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(origin.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              origin.title,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              origin.subtitle,
                              style: TextStyle(
                                color: isSelected ? AppColors.neonLime : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.neonLime, size: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    color: Colors.black87,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🌟 AVANTAJ: ${origin.perkDescription}',
                          style: const TextStyle(color: AppColors.neonLime, fontSize: 9.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '⚠️ DEZAVANTAJ: ${origin.flawDescription}',
                          style: const TextStyle(color: AppColors.comicRed, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
