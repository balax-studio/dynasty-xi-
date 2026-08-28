// presentation/screens/affiliate_clubs_screen.dart
// Affiliate Satellite & Feeder Club Network Management Screen (Pilot Takım İşbirlikleri)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class AffiliateClubsScreen extends ConsumerWidget {
  const AffiliateClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        backgroundColor: AppColors.neoCardBg,
        title: Text('[ANLASMA] PİLOT TAKIM & UYDU KULÜP AĞI', style: AppTypography.h2(color: Colors.white)),
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
                    title: 'PİLOT KULÜP İŞBİRLİĞİ VE GELİŞİM MERKEZİ',
                    icon: '',
                    child: Row(
                      children: [
                        Text('[GOL][ANLASMA]', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Alt liglerdeki pilot takımlarla protokol imzalayarak genç oyuncularınızı düzenli forma garantisiyle kiralayın ve scout ağınızı genişletin.',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildAffiliateCard(
                    context: context,
                    ref: ref,
                    clubName: 'Beyoğlu 1984 FK (TFF 2. Lig)',
                    perk: 'Genç oyunculara %100 ilk 11 garantisi & Hızlı gelişim (+15% XP)',
                    cost: 30000,
                  ),
                  const SizedBox(height: 10),

                  _buildAffiliateCard(
                    context: context,
                    ref: ref,
                    clubName: 'Westerlo SK (Belçika 2. Lig)',
                    perk: 'AB pasaportu çıkarma kolaylığı & Avrupa vitrini',
                    cost: 85000,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAffiliateCard({
    required BuildContext context,
    required WidgetRef ref,
    required String clubName,
    required String perk,
    required int cost,
  }) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final isSigned = state?.activeAffiliateClubIds.contains(clubName) ?? false;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.win95Grey,
        border: Border.all(color: isSigned ? AppColors.neonLime : AppColors.win95DarkGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(clubName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.win95TitleNavy)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black,
                child: Text(
                  isSigned ? 'AKTİF' : 'YILLIK: ₣${(cost / 1000).toInt()}K',
                  style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Avantaj: $perk', style: const TextStyle(fontSize: 10.5, color: Colors.black87)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: RetroButton(
              backgroundColor: isSigned ? AppColors.win95DarkGrey : AppColors.neonLime,
              onPressed: isSigned
                  ? null
                  : () async {
                      final success = await ref.read(gameStateProvider.notifier).signAffiliateProtocol(clubName, cost);
                      if (context.mounted) {
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.primaryDeep,
                              content: Text(
                                '[ANLASMA] $clubName ile 1 yıllık pilot takım protokolü imzalandı (-₣$cost)!',
                                style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.comicRed,
                              content: Text('[RED] Bakiye yetersiz! Pilot takım anlaşması yapılamadı.'),
                            ),
                          );
                        }
                      }
                    },
              child: Text(
                isSigned ? ' PROTOKOL AKTİF (RESMİ PİLOT TAKIM)' : 'PROTOKOL İMZALA VE RESMİ PİLOT TAKIM YAP (-₣${(cost / 1000).toInt()}K)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
