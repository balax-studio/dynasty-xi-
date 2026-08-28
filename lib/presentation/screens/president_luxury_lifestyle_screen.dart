// presentation/screens/president_luxury_lifestyle_screen.dart
// President Personal Garage, Private Jets, Yachts and Luxury Real Estate Showcase

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/president/president_lifestyle.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class PresidentLuxuryLifestyleScreen extends ConsumerWidget {
  const PresidentLuxuryLifestyleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final assets = PresidentLuxuryAsset.getDefaultCatalog();

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        backgroundColor: AppColors.win95TitleNavy,
        title: Text('CROWN BAŞKANIN LÜKS YAŞAMI & ŞAHSİ ENVANTERİ', style: AppTypography.h2(color: Colors.white)),
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
                    title: 'ŞAHSİ SERVET VE PRESTİJ KOLEKSİYONU',
                    icon: 'DIAMOND',
                    child: Row(
                      children: [
                        Text('CASTLE', style: TextStyle(fontSize: 32)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Başkanlık makamının gücünü simgeleyen özel jetler, zırhlı makam araçları, yatlar ve yalılar satın alarak camiadaki ve transfer pazarındaki etkinizi artırın.',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...assets.map((asset) {
                    final isOwned = state?.ownedLuxuryAssetIds.contains(asset.id) ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.win95Grey,
                        border: Border.all(color: isOwned ? AppColors.neonLime : AppColors.accentGold, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(asset.icon, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 6),
                                  Text(asset.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.win95TitleNavy)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: Colors.black,
                                child: Text(
                                  isOwned ? 'SAHİPSİNİZ' : '₣${(asset.purchaseCost / 1000).toInt()}K',
                                  style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(asset.description, style: const TextStyle(fontSize: 10.5, color: Colors.black87)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text('STAR Prestij: +${asset.prestigeBonus}', style: const TextStyle(color: AppColors.win95TitleNavy, fontWeight: FontWeight.bold, fontSize: 10)),
                              const SizedBox(width: 12),
                              Text('[DUYURU] Taraftar Hype: +${asset.fansBonus}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: RetroButton(
                              backgroundColor: isOwned ? AppColors.win95DarkGrey : AppColors.accentGold,
                              textColor: Colors.black,
                              onPressed: isOwned
                                  ? null
                                  : () async {
                                      final success = await ref.read(gameStateProvider.notifier).buyLuxuryAsset(asset);
                                      if (context.mounted) {
                                        if (success) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: AppColors.primaryDeep,
                                              content: Text(
                                                'DIAMOND ${asset.name} başkanlık envanterinize eklendi!',
                                                style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: AppColors.comicRed,
                                              content: Text('[RED] Bakiye yetersiz! Bu varlığı satın almak için yeterli kulüp fonu yok.'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              child: Text(
                                isOwned ? ' BAŞKANLIK ENVANTERİNDE (SAHİPSİNİZ)' : 'ŞAHSİ SERVETTEN SATIN AL (-₣${(asset.purchaseCost / 1000).toInt()}K)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: isOwned ? Colors.white70 : Colors.black),
                              ),
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
