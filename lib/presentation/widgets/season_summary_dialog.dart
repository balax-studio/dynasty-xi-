// presentation/widgets/season_summary_dialog.dart
// Interactive Season End Celebration, Trophy Award Ceremony & Promotion Dialog (§14, Ek H).

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/game_state.dart';
import 'retro_window.dart';

class SeasonSummaryDialog extends StatelessWidget {
  final GameState state;
  final VoidCallback onStartNextSeason;

  const SeasonSummaryDialog({
    super.key,
    required this.state,
    required this.onStartNextSeason,
  });

  @override
  Widget build(BuildContext context) {
    final rank = state.currentLeague.getRankOfClub(state.userClub.id);
    final isChampion = rank == 1;
    final isPromoted = rank <= 2;
    final isRelegated = rank >= 19 && state.currentLeague.tier < 20;

    final tvMoney = 25000 + (21 - rank) * 4000;
    final prizeMoney = isChampion ? 100000 : (isPromoted ? 50000 : 15000);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: RetroWindow(
        title: 'SEZON ÖDÜL VE TERFİ PROTOKOLÜ v1.0',
        icon: '[KUPA]',
        titleBarColor: isChampion ? const Color(0xFF6E5000) : AppColors.win95TitleNavy,
        onClose: () => Navigator.of(context).pop(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kupa / Madalya İkonu
              Text(
                isChampion ? '[KUPA]' : (isPromoted ? '2.' : (isRelegated ? '[DUSUS]' : '[GOL]')),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),

              // Başlık
              Text(
                isChampion
                    ? 'ŞAMPİYON: ${state.userClub.name.toUpperCase()}!'
                    : (isPromoted
                        ? 'TEBRİKLER! BİR ÜST LİGE YÜKSELDİK!'
                        : (isRelegated
                            ? 'SEZON SONU: BİR ALT LİGE DÜŞTÜK'
                            : 'SEZON PROTOKOLÜ TAMAMLANDI')),
                textAlign: TextAlign.center,
                style: AppTypography.label(
                  color: isChampion
                      ? AppColors.neonPink
                      : (isPromoted ? AppColors.neonLime : (isRelegated ? AppColors.comicRed : Colors.black)),
                ).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),

              Text(
                'SEZON ${state.clock.seasonNumber} • LİG ${state.currentLeague.tier} • SIRALAMA: $rank. SIRA',
                style: AppTypography.bodySmall(color: AppColors.neutral300).copyWith(fontSize: 10),
              ),
              const SizedBox(height: 12),

              // Gelir & Ödül Özeti Kutusu
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.neoInnerBg,
                  border: Border(
                    top: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
                    left: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
                    right: BorderSide(color: Colors.black, width: 1.5),
                    bottom: BorderSide(color: Colors.black, width: 1.5),
                  ),
                ),
                child: Column(
                  children: [
                    _buildRow('[KUPA] DERECE PRİMİ:', '+₣${prizeMoney.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
                    const SizedBox(height: 6),
                    _buildRow('[TV] YAYIN & SIRALAMA GELİRİ:', '+₣${tvMoney.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
                    const Divider(color: AppColors.win95DarkGrey, height: 12),
                    _buildRow('[KASA] TOPLAM SEZON KAZANCI:', '+₣${(prizeMoney + tvMoney).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Altyapı Genç Yetenek İkramiyesi
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B2A1E),
                  border: Border(
                    top: BorderSide(color: AppColors.neonLime, width: 1.5),
                    left: BorderSide(color: AppColors.neonLime, width: 1.5),
                    right: BorderSide(color: Colors.black, width: 1.5),
                    bottom: BorderSide(color: Colors.black, width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('[AKADEMİ]', style: TextStyle(fontSize: 10, color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AKADEMİ GENÇLİK ALIMI', style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 10)),
                          Text('Yeni sezonda altyapıdan 2 genç yıldız adayı A takıma dahil edilecek.', style: AppTypography.bodySmall(color: Colors.white).copyWith(fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Yeni Sezon Butonu
              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  onPressed: () {
                    AudioSynthesizer.playClick();
                    Navigator.of(context).pop();
                    onStartNextSeason();
                  },
                  child: Text(
                    isPromoted
                        ? '${(state.currentLeague.tier - 1)}. LİGE BAŞLA >>'
                        : (isRelegated
                            ? '${(state.currentLeague.tier + 1)}. LİGE DÜŞ >>'
                            : 'YENİ SEZONA BAŞLA >>'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.label(color: Colors.white).copyWith(fontSize: 10)),
        Text(value, style: AppTypography.monoNumber(color: isBold ? AppColors.neonLime : AppColors.neonAmber).copyWith(fontSize: 11)),
      ],
    );
  }
}
