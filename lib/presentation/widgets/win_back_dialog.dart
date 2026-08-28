// presentation/widgets/win_back_dialog.dart
// Win-Back Welcome Screen for Returning Managers (§18.6)

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import 'retro_window.dart';

class WinBackDialog extends StatelessWidget {
  final int daysAway;
  final int welcomeBonusCash;
  final int welcomeBonusXp;
  final VoidCallback onClaim;

  const WinBackDialog({
    super.key,
    required this.daysAway,
    required this.welcomeBonusCash,
    required this.welcomeBonusXp,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: 'KULÜBE TEKRAR HOŞ GELDİN HOCAM!',
        icon: '[KUTLAMA]',
        titleBarColor: const Color(0xFF0F3826),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('[KULÜP]', style: TextStyle(fontSize: 18, color: AppColors.accentGold, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Sensiz geçen $daysAway günün ardından takım seni bekliyordu!',
              style: AppTypography.h3(color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'Yönetim kurulu ve taraftarlar dönüşünü kutlamak için sana özel bir bütçe ve moral paketi hazırladı:',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('[KASA] Sadakat Teşvik Primi:', style: TextStyle(color: Colors.white, fontSize: 11)),
                      Text('+₣$welcomeBonusCash', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('STAR Motivasyon XP Desteği:', style: TextStyle(color: Colors.white, fontSize: 11)),
                      Text('+$welcomeBonusXp XP', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerRight,
              child: RetroButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClaim();
                },
                backgroundColor: AppColors.neonLime,
                textColor: Colors.black,
                child: const Text('HEDİYELERİ AL & SAHAYA İN', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
