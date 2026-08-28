// presentation/screens/sacked_screen.dart
// Dramatic Full-Screen Sacking Experience & Lower League Comeback Offer (§12.8, §6.3)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../widgets/hostile_takeover_rescue_modal.dart';
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
              title: 'DİVAN KURULU KARARI: BAŞKANLIK DÜŞÜRÜLDÜ!',
              icon: '[RED]',
              titleBarColor: AppColors.comicRed,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('[ACIL]', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 10),
                    Text(
                      'BAŞKANLIK YETKİLERİ DONDURULDU',
                      style: AppTypography.display(color: AppColors.comicRed).copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.neoInnerBg,
                        border: Border.all(color: AppColors.comicRed.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '$clubName Divan Kurulu ve Hissedarlar Heyeti, $sackingReason gerekçesiyle kulüp başkanlığı yetkilerinizi dondurmuş ve yönetime kayyum atamıştır.',
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
                        color: AppColors.neoInnerBg,
                        border: Border.all(color: AppColors.neonLime, width: 1.5),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('[KULÜP]', style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10)),
                              SizedBox(width: 6),
                              Text(
                                'YENİ KULÜP SAHİPLİĞİ TEKLİFİ (KÜLLERİNDEN DOĞUŞ)',
                                style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Anadolu 3. Lig ekiplerinden "Yıldıztepe SK" çoğunluk hisselerini devralmanız için davette bulundu.',
                            style: TextStyle(color: Colors.white70, fontSize: 10.5),
                          ),
                          Text(
                            'Başlangıç Kasası: ₣15.000 • Sezon Hedefi: İlk 5',
                            style: TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: RetroButton(
                        backgroundColor: AppColors.accentGold,
                        textColor: Colors.black,
                        onPressed: () => HostileTakeoverRescueModal.show(context),
                        child: const Text('[KASA] ACİL KULÜP KURTARMA & SERMAYE ARTIRIMI (İFLASI ÖNLE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    RetroButton(
                      onPressed: () {
                        ref.read(gameStateProvider.notifier).recoverFromSacking();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      backgroundColor: AppColors.neonLime,
                      textColor: Colors.black,
                      child: const Text('YENİ KULÜP BAŞKANLIĞINI DEVRAL & DEVAM ET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
