// presentation/screens/shop_screen.dart
// Ethical store with 30-tier Season Pass, cosmetic badges, and rewarded sponsor boosts (no P2W energy bars).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
            title: Text('CYBER SHOP & SEZON BİLETİ BORSASI', style: AppTypography.h2(color: Colors.white)),
          ),
          body: Column(
            children: [
              MetersBarWidget(meters: gameState.userClub.meters),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Sezon Bileti (Dynasty Pass) Penceresi
                      RetroWindow(
                        title: 'DYNASTY PASS SEZON KART PROVİZYONU',
                        icon: '🎫',
                        titleBarColor: const Color(0xFF6E5000),
                        child: _buildSeasonPassBanner(context),
                      ),
                      const SizedBox(height: 10),

                      // 2. Sponsor Destekleri Penceresi
                      RetroWindow(
                        title: 'SPONSOR REKLAM VE HIZLANDIRMA MODÜLÜ',
                        icon: '📡',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          children: [
                            _buildRewardedAdCard(
                              context,
                              title: 'YEREL SPONSOR REKLAMI (+₣5.000)',
                              description: '30 saniyelik video ile kulüp kasasına doğrudan ₣5.000 ekleyin.',
                              icon: '📺',
                              rewardLabel: '+₣5.000 AL',
                              onClaim: () {
                                ref.read(gameStateProvider.notifier).claimSponsorReward(5000);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sponsor desteği kasaya aktarıldı: +₣5.000!')),
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            _buildRewardedAdCard(
                              context,
                              title: 'İNŞAAT HIZLANDIRICI (-30 DAKİKA)',
                              description: 'Devam eden tesis bakım sürelerini 30 dakika kısaltın.',
                              icon: '⚡',
                              rewardLabel: 'HIZLANDIR',
                              onClaim: () {
                                ref.read(gameStateProvider.notifier).claimSponsorReward(0, reduceConstructionMinutes: 30);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tesis inşaatı 30 dakika hızlandırıldı!')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3. Altın Rozet Paketleri Penceresi
                      RetroWindow(
                        title: 'ALTIN ROZET MAĞAZASI (KOZMETİK & TEMA)',
                        icon: '💎',
                        titleBarColor: AppColors.neoCardBg,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildIapPackCard(
                                context,
                                ref,
                                amount: '100 ROZET',
                                price: '₺29,99',
                                bonus: 'BAŞLANGIÇ',
                                icon: '🥉',
                                cashReward: 10000,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildIapPackCard(
                                context,
                                ref,
                                amount: '500 ROZET',
                                price: '₺119,99',
                                bonus: '+%20 BONUS',
                                icon: '🥈',
                                cashReward: 60000,
                                isPopular: true,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildIapPackCard(
                                context,
                                ref,
                                amount: '1200 ROZET',
                                price: '₺249,99',
                                bonus: '+%40 BONUS',
                                icon: '🥇',
                                cashReward: 150000,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeasonPassBanner(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Text('SEZON BİLETİ SEVİYESİ', style: AppTypography.label(color: Colors.black).copyWith(fontSize: 11)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.black,
              child: Text('30 KADEME', style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 9)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Maçları kazandıkça özel retro formalar, stadyum temaları ve kasa bonusları kazanın.',
          style: AppTypography.bodySmall(color: Colors.black87).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: AppColors.win95DarkGrey),
              left: BorderSide(color: AppColors.win95DarkGrey),
              right: BorderSide(color: AppColors.win95White),
              bottom: BorderSide(color: AppColors.win95White),
            ),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.25,
            child: Container(color: AppColors.neonLime),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('MEVCUT KADEME: 7 / 30', style: AppTypography.label(color: Colors.black).copyWith(fontSize: 9)),
            Text('ÖDÜL: ₣15.000 KASA DESTEĞİ', style: AppTypography.label(color: AppColors.win95TitleNavy).copyWith(fontSize: 9)),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardedAdCard(
    BuildContext context, {
    required String title,
    required String description,
    required String icon,
    required String rewardLabel,
    required VoidCallback onClaim,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFF141A24),
        border: Border(
          top: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
          left: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
          right: BorderSide(color: Colors.black, width: 1.5),
          bottom: BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.label(color: Colors.white).copyWith(fontSize: 10)),
                Text(description, style: AppTypography.bodySmall(color: AppColors.neutral300).copyWith(fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          RetroButton(
            onPressed: onClaim,
            child: Text(rewardLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildIapPackCard(
    BuildContext context,
    WidgetRef ref, {
    required String amount,
    required String price,
    required String bonus,
    required String icon,
    required int cashReward,
    bool isPopular = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: AppColors.comicBoxDecoration(
        backgroundColor: const Color(0xFF141A24),
        borderColor: isPopular ? AppColors.neonPink : Colors.black,
        shadowColor: isPopular ? AppColors.neonPink : AppColors.neonCyan,
        borderWidth: 2.0,
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(amount, style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 11)),
          Text(bonus, style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 8)),
          const SizedBox(height: 6),
          RetroButton(
            isNeon: isPopular,
            backgroundColor: isPopular ? AppColors.neonPink : AppColors.win95Grey,
            textColor: isPopular ? Colors.white : Colors.black,
            onPressed: () {
              ref.read(gameStateProvider.notifier).claimSponsorReward(cashReward);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$amount paket provizyonu onaylandı! Kasanıza +₣$cashReward eklendi.'),
                ),
              );
            },
            child: Text(price),
          ),
        ],
      ),
    );
  }
}
