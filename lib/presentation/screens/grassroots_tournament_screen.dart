// presentation/screens/grassroots_tournament_screen.dart
// Grassroots Youth Scouting Cup & Amateur Talents Scouting Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class GrassrootsTournamentScreen extends ConsumerWidget {
  const GrassrootsTournamentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        backgroundColor: AppColors.neoCardBg,
        title: Text('BAŞKANLIK GELECEĞİN YILDIZLARI TURNUVASI', style: AppTypography.h2(color: Colors.white)),
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
                    title: 'AMATÖR VE SOKAK YETENEKLERİ TURNUVASI',
                    icon: 'STAR',
                    child: Row(
                      children: [
                        Text('[TURNUVA]', style: TextStyle(fontSize: 12, color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Başkanın himayesinde düzenlenen amatör hazırlık turnuvasında keşfedilen genç yetenekleri bedelsiz olarak akademimize katabilirsiniz.',
                            style: TextStyle(fontSize: 11, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildTalentCard(
                    context: context,
                    ref: ref,
                    name: 'Yasin Karaca (16 Yaşında)',
                    position: '10 Numara / Forvet Arkası',
                    potential: 'STARSTARSTARSTARSTAR (88-92 Potansiyel)',
                    scoutNote: 'İnanılmaz dripling ve top tekniği var. Sokak futbolundan keşfedildi.',
                    overallRating: 68,
                    potentialRating: 90,
                  ),
                  const SizedBox(height: 10),

                  _buildTalentCard(
                    context: context,
                    ref: ref,
                    name: 'Kerem Demir (17 Yaşında)',
                    position: 'Stoper / Defans Lideri',
                    potential: 'STARSTARSTARSTAR (82-86 Potansiyel)',
                    scoutNote: 'Hava toplarında geçilmez, lider karakterli.',
                    overallRating: 66,
                    potentialRating: 84,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTalentCard({
    required BuildContext context,
    required WidgetRef ref,
    required String name,
    required String position,
    required String potential,
    required String scoutNote,
    required int overallRating,
    required int potentialRating,
  }) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    final isAlreadySigned = state?.userClub.u19Squad.any((p) => p.fullName.contains(name.split(' ').first)) ?? false;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.win95Grey,
        border: Border.all(color: isAlreadySigned ? AppColors.neonLime : AppColors.win95DarkGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.win95TitleNavy)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black,
                child: Text(
                  isAlreadySigned ? 'AKADEMİDE' : 'BEDELSİZ',
                  style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(position, style: const TextStyle(fontSize: 10.5, color: Colors.black87)),
          const SizedBox(height: 4),
          Text('Potansiyel: $potential', style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 10)),
          const SizedBox(height: 4),
          Text('Scout Raporu: "$scoutNote"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 9.5, color: Colors.black54)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: RetroButton(
              backgroundColor: isAlreadySigned ? AppColors.win95DarkGrey : AppColors.neonLime,
              onPressed: isAlreadySigned
                  ? null
                  : () async {
                      await ref.read(gameStateProvider.notifier).signGrassrootsTalent(
                            name: name,
                            position: position,
                            overallRating: overallRating,
                            potentialRating: potentialRating,
                          );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.primaryDeep,
                            content: Text(
                              'STAR $name ($overallRating OVR / $potentialRating POT) kulüp U19 akademisine kazandırıldı!',
                              style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                    },
              child: Text(
                isAlreadySigned ? ' AKADEMİYE KATILDI' : 'AKADEMİYE BEDELSİZ DAHİL ET & İMZA ATTIR',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
