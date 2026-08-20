// presentation/widgets/player_sale_offer_modal.dart
// Detailed Transfer Sale Offer Modal.
// Shows interested buyer club bids, fan sentiment impact, and allows confirming the sale or rejecting.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/player.dart';
import 'retro_pixel_icon.dart';
import 'retro_window.dart';

class PlayerSaleOfferModal extends StatefulWidget {
  final Player player;
  final int salePrice;

  const PlayerSaleOfferModal({
    super.key,
    required this.player,
    required this.salePrice,
  });

  static Future<bool?> show(BuildContext context, Player player, int salePrice) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PlayerSaleOfferModal(player: player, salePrice: salePrice),
    );
  }

  @override
  State<PlayerSaleOfferModal> createState() => _PlayerSaleOfferModalState();
}

class _PlayerSaleOfferModalState extends State<PlayerSaleOfferModal> {
  late String _buyerClub;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final clubs = ['AFC Ajax', 'Sevilla FC', 'Bologna FC', 'Lille OSC', 'Sporting CP', 'Eintracht Frankfurt', 'Atalanta BC'];
    clubs.shuffle();
    _buyerClub = clubs.first;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    final rarityColor = AppColors.getRarityColor(p.stars);
    final fanImpact = p.ovr >= 82 ? -4 : (p.ovr >= 76 ? -2 : 0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: RetroWindow(
        title: 'TRANSFER SATIŞ MASASI & RESMİ TEKLİF',
        icon: 'cash',
        titleBarColor: const Color(0xFF005500),
        child: Consumer(
          builder: (context, ref, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Alıcı Kulüp ve Faks İletisi
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neoInnerBg,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const RetroPixelIcon(type: RetroPixelIconType.newspaper, size: 24, color: AppColors.neonCyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RESMİ TRANSFER TEKLİFİ: $_buyerClub', style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 11)),
                            Text(
                              '$_buyerClub kulübü, ${p.fullName} için resmi bonservis bedelini ödemeyi kabul etti.',
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Oyuncu Kartı
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: rarityColor.withOpacity(0.6)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        color: AppColors.neoInnerBg,
                        child: Text(p.position.code, style: TextStyle(color: rarityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.fullName, style: AppTypography.label(color: Colors.white).copyWith(fontSize: 12)),
                            Text('${p.age} Yaş • ${p.ovr} OVR • POT ${p.potential}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₣${widget.salePrice}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Maaş: ₣${p.weeklyWage}/h', style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 3. Kulübe Net Etki
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neoInnerBg,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SATIŞ SONRASI KULÜP BİLANÇOSU', style: TextStyle(color: AppColors.accentGold, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kasaya Girecek Net Bedel:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text('+₣${widget.salePrice}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Açılacak Maaş Bütçesi:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text('+₣${p.weeklyWage}/hafta', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10)),
                        ],
                      ),
                      if (fanImpact != 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Yıldız Kaybı Taraftar Tepkisi:', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            Text('$fanImpact% Fan', style: const TextStyle(color: AppColors.comicRed, fontWeight: FontWeight.bold, fontSize: 10)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. İşlem Butonları
                if (_isProcessing)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.black, border: Border.all(color: AppColors.neonLime)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonLime)),
                        SizedBox(width: 8),
                        Text('SÖZLEŞME FESİH VE BONSERVİS ONAYLANIYOR...', style: TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: RetroButton(
                          backgroundColor: AppColors.win95LightGrey,
                          textColor: Colors.black,
                          onPressed: () {
                            AudioSynthesizer.playClick();
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('REDDET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: RetroButton(
                          backgroundColor: AppColors.neonLime,
                          textColor: Colors.black,
                          onPressed: () async {
                            setState(() => _isProcessing = true);
                            AudioSynthesizer.playMoney();
                            await Future.delayed(const Duration(milliseconds: 500));
                            final ok = await ref.read(gameStateProvider.notifier).sellPlayer(p, widget.salePrice);
                            if (context.mounted) {
                              Navigator.of(context).pop(ok);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? '💰 ${p.fullName} $_buyerClub kulübüne ₣${widget.salePrice} bedelle satıldı!'
                                        : '⚠️ Kadroda en az 11 oyuncu bulunmalıdır!',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text('₣${widget.salePrice} KABUL ET', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
