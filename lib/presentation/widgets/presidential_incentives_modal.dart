// presentation/widgets/presidential_incentives_modal.dart
// Presidential Direct Intervention Modal: Match Bonuses, Luxury Gifts, Jersey Numbering, Disciplinary Fines.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/player.dart';
import 'retro_window.dart';

class PresidentialIncentivesModal extends ConsumerStatefulWidget {
  final Player player;

  const PresidentialIncentivesModal({
    super.key,
    required this.player,
  });

  static void show(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PresidentialIncentivesModal(player: player),
    );
  }

  @override
  ConsumerState<PresidentialIncentivesModal> createState() => _PresidentialIncentivesModalState();
}

class _PresidentialIncentivesModalState extends ConsumerState<PresidentialIncentivesModal> {
  int _selectedJerseyNumber = 10;
  final TextEditingController _jerseyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedJerseyNumber = widget.player.jerseyNumber;
    _jerseyController.text = '$_selectedJerseyNumber';
  }

  @override
  void dispose() {
    _jerseyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SizedBox(height: 200, child: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final p = widget.player;
        final cash = club.meters.cash;

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.primaryDeep,
            border: Border(
              top: BorderSide(color: AppColors.accentGold, width: 3),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: AppColors.win95TitleNavy,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('CROWN', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'BAŞKANLIK ÖZEL MÜDAHALELERİ & TEŞVİK',
                          style: AppTypography.h3(color: Colors.white).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Oyuncu Özeti
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.neoInnerBg,
                          border: Border.all(color: AppColors.accentGold),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              color: AppColors.accentGold,
                              child: Text(
                                '#${p.jerseyNumber}',
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.fullName, style: AppTypography.h3(color: Colors.white).copyWith(fontSize: 12)),
                                  Text(
                                    'Moral: %${p.morale} • Sadakat: %${p.loyalty} • Kasa: ₣$cash',
                                    style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 1. Özel Maç Primi
                      RetroWindow(
                        title: '1. ÖZEL MAÇ PRİMİ TANIMLA (GALİBİYET TEŞVİĞİ)',
                        icon: '[KASA]',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Önemli maçlar öncesinde futbolcuya doğrudan başkanlık kasasından ek galibiyet primi vaat edin. Morali ve motivasyonu yükseltir.',
                              style: AppTypography.bodySmall(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: RetroButton(
                                    backgroundColor: cash >= 2500 ? AppColors.neonLime : AppColors.neutral700,
                                    textColor: Colors.black,
                                    onPressed: cash < 2500
                                        ? null
                                        : () async {
                                            AudioSynthesizer.playClick();
                                            await ref.read(gameStateProvider.notifier).givePresidentialBonus(p.id, 2500, false);
                                            if (context.mounted) Navigator.pop(context);
                                          },
                                    child: const Text('₣2.500 PRİM', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: RetroButton(
                                    backgroundColor: cash >= 5000 ? AppColors.neonLime : AppColors.neutral700,
                                    textColor: Colors.black,
                                    onPressed: cash < 5000
                                        ? null
                                        : () async {
                                            AudioSynthesizer.playClick();
                                            await ref.read(gameStateProvider.notifier).givePresidentialBonus(p.id, 5000, false);
                                            if (context.mounted) Navigator.pop(context);
                                          },
                                    child: const Text('₣5.000 PRİM', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. Lüks Hediye Takdim Et
                      RetroWindow(
                        title: '2. LÜKS HEDİYE TAKDİM ET (SAAT / LÜKS ARABA)',
                        icon: '[ODUL]',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Başkan olarak oyuncunun gönlünü fethedin. Sadakati (+15) ve morali (+25) anında artar.',
                              style: AppTypography.bodySmall(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: RetroButton(
                                backgroundColor: cash >= 7500 ? AppColors.neonPink : AppColors.neutral700,
                                textColor: Colors.white,
                                onPressed: cash < 7500
                                    ? null
                                    : () async {
                                        AudioSynthesizer.playClick();
                                        await ref.read(gameStateProvider.notifier).givePresidentialBonus(p.id, 7500, true);
                                        if (context.mounted) Navigator.pop(context);
                                      },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('[HEDİYE]', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 6),
                                    Text('LÜKS HEDİYE SUN (₣7.500)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3. Sırt Numarası Atama
                      RetroWindow(
                        title: '3. ÖZEL SIRT NUMARASI ATA (1 - 99)',
                        icon: '',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sembolik numaralar (#10, #7, #9) oyuncunun liderlik hissini ve moralini perçinler.',
                              style: AppTypography.bodySmall(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: _jerseyController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 14),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.black,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RetroButton(
                                    backgroundColor: AppColors.neonCyan,
                                    textColor: Colors.black,
                                    onPressed: () async {
                                      final numVal = int.tryParse(_jerseyController.text);
                                      if (numVal != null && numVal >= 1 && numVal <= 99) {
                                        AudioSynthesizer.playClick();
                                        await ref.read(gameStateProvider.notifier).assignJerseyNumber(p.id, numVal);
                                        if (context.mounted) Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('NUMARAYI KAYDET', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 4. Disiplin Para Cezası Kes
                      RetroWindow(
                        title: '4. DİSİPLİN CEZASI & MAAŞ KESİNTİSİ',
                        icon: '[HUKUK]',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Disiplinsiz davranışlar için oyuncunun maaşından kesinti yapın. Para kulüp kasasına döner, yönetim güveni (+3) artar ancak oyuncu morali düşer.',
                              style: AppTypography.bodySmall(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: RetroButton(
                                backgroundColor: const Color(0xFF334155),
                                textColor: AppColors.comicRed,
                                onPressed: () async {
                                  AudioSynthesizer.playClick();
                                  await ref.read(gameStateProvider.notifier).finePlayer(p.id, 2000);
                                  if (context.mounted) Navigator.pop(context);
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('[HUKUK]', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 6),
                                    Text('₣2.000 DİSİPLİN CEZASI KES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
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
}
