// presentation/screens/sacked_screen.dart
// Dramatic Full-Screen Sacking Experience & Lower League Comeback Offer (§12.8, §6.3)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../widgets/retro_window.dart';

class SackedScreen extends ConsumerWidget {
  final String clubName;
  final String sackingReason;

  const SackedScreen({
    super.key,
    required this.clubName,
    required this.sackingReason,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: RetroWindow(
              title: 'YÖNETİM KURULU KARARI: GÖREVDEN ALINDINIZ!',
              icon: '❌',
              titleBarColor: AppColors.comicRed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  Text(
                    'SÖZLEŞMENİZ FESHEDİLDİ',
                    style: AppTypography.display(color: AppColors.comicRed).copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: const Color(0xFF261014),
                    child: Text(
                      '$clubName Yönetim Kurulu, $sackingReason nedeniyle teknik direktörlük görevinize tek taraflı olarak son vermiştir.',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Comeback Offer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F291E),
                      border: Border.all(color: AppColors.neonLime, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('📩', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              'YENİ KULÜP TEKLİFİ (KÜLLERİNDEN DOĞUŞ)',
                              style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Anadolu 3. Lig ekiplerinden "Yıldıztepe SK" sana yeni bir şans vermek istiyor.',
                          style: TextStyle(color: Colors.white70, fontSize: 10.5),
                        ),
                        const Text(
                          'Başlangıç Bütçesi: ₣15.000 • Sezon Hedefi: İlk 5',
                          style: TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  RetroButton(
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).recoverFromSacking();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    backgroundColor: AppColors.neonLime,
                    textColor: Colors.black,
                    child: const Text('YENİ KULÜBÜ DEVRAL & DEVAM ET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
