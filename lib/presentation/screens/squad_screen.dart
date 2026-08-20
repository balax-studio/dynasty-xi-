// presentation/screens/squad_screen.dart
// Squad management: Tactics, Formations, Lineup, and Comprehensive RPG Player detail bottom sheet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/player.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/presidential_directives_modal.dart';
import '../widgets/retro_window.dart';
import 'player_detail_screen.dart';
import 'staff_screen.dart';

class SquadScreen extends ConsumerWidget {
  const SquadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final squad = club.squad;
        final starting11 = club.starting11;
        final subs = club.substitutes;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            title: Text('KADRO & TAKTİK MERKEZİ (${squad.length} OYUNCU)', style: AppTypography.h2(color: Colors.white)),
          ),
          body: Column(
            children: [
              MetersBarWidget(meters: club.meters),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 0. Başkanlık Kadro Talimatları & Veto Butonu
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          backgroundColor: AppColors.win95TitleNavy,
                          onPressed: () {
                            PresidentialDirectivesModal.show(context, squad);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('👑', style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  'BAŞKANLIK TALİMATI & VETO (KADRO DIŞI / KAPTANLIK)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.neonLime),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 1. Taktik ve Diziliş Penceresi
                      RetroWindow(
                        title: 'TAKTIKSEL FORMASYON VE DİZİLİŞ',
                        icon: '📋',
                        child: _buildTacticsCard(context, ref, club),
                      ),
                      const SizedBox(height: 10),

                      // 2. İlk 11 Penceresi
                      RetroWindow(
                        title: 'İLK 11 KADROSU (${starting11.length} OYUNCU)',
                        icon: '⭐',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          children: starting11.map((p) => _buildPlayerCard(context, ref, club, p, isStarting: true)).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3. Yedekler Penceresi
                      RetroWindow(
                        title: 'YEDEK KULÜBESİ (${subs.length} OYUNCU)',
                        icon: '🪑',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          children: subs.map((p) => _buildPlayerCard(context, ref, club, p, isStarting: false)).toList(),
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

  Widget _buildTacticsCard(BuildContext context, WidgetRef ref, dynamic club) {
    const formations = ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1', '5-3-2'];
    const styles = ['Dengeli', 'Ofansif', 'Defansif', 'Kontra Atak', 'Baskılı'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('👔', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEKNİK DİREKTÖR: SERGEN HOCA',
                    style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 12),
                  ),
                  Text(
                    'Başkan olarak taktik felsefeyi belirleyen teknik ekibi yönetirsiniz.',
                    style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            RetroButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StaffScreen()),
                );
              },
              backgroundColor: AppColors.neonLime,
              textColor: Colors.black,
              child: const Text('👔 TEKNİK EKİP'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(color: AppColors.win95DarkGrey, height: 1),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TAVSİYE DİZİLİŞ:', style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 10)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: club.formation,
                    dropdownColor: Colors.black,
                    style: AppTypography.label(color: Colors.white),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                    items: formations.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(gameStateProvider.notifier).updateTactics(formation: val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OYUN STİLİ:', style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 10)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: club.tacticalStyle,
                    dropdownColor: Colors.black,
                    style: AppTypography.label(color: Colors.white),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                    items: styles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(gameStateProvider.notifier).updateTactics(style: val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerCard(BuildContext context, WidgetRef ref, dynamic club, Player p, {required bool isStarting}) {
    final rarityColor = AppColors.getRarityColor(p.stars);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.neoInnerBg,
        border: Border(
          top: BorderSide(color: isStarting ? AppColors.neonLime : AppColors.win95DarkGrey, width: 1.5),
          left: BorderSide(color: isStarting ? AppColors.neonLime : AppColors.win95DarkGrey, width: 1.5),
          right: const BorderSide(color: Colors.black, width: 1.5),
          bottom: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        onTap: () => _showPlayerDetailsModal(context, ref, club, p),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: rarityColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                p.position.code,
                style: TextStyle(
                  color: rarityColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              if (p.isCaptain)
                const Text('🛡️', style: TextStyle(fontSize: 9))
              else if (p.isInjured)
                const Text('🚑', style: TextStyle(fontSize: 9)),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${p.isCaptain ? "★ " : ""}${p.fullName.toUpperCase()}',
                style: AppTypography.label(color: p.isCaptain ? AppColors.accentGold : Colors.white).copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.black,
              child: Text(
                '${p.ovr}',
                style: AppTypography.monoNumber(color: rarityColor).copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Text('${p.stars}★', style: TextStyle(color: rarityColor, fontSize: 10)),
            const SizedBox(width: 6),
            Text('Y:${p.age}', style: AppTypography.bodySmall(color: AppColors.neutral300).copyWith(fontSize: 10)),
            const SizedBox(width: 6),
            Text('M:%${p.morale}', style: AppTypography.bodySmall(color: p.morale < 40 ? AppColors.comicRed : AppColors.neonLime).copyWith(fontSize: 10)),
            const SizedBox(width: 6),
            Text('F:%${p.fitness}', style: AppTypography.bodySmall(color: p.fitness < 70 ? AppColors.neonAmber : AppColors.neonCyan).copyWith(fontSize: 10)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.white24, width: 0.5)),
              child: Text(
                p.personality.label,
                style: const TextStyle(fontSize: 9, color: Colors.white70),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.tune, size: 16, color: AppColors.win95White),
      ),
    );
  }

  void _showPlayerDetailsModal(BuildContext context, WidgetRef ref, dynamic club, Player p) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerDetailScreen(player: p, isOwned: true),
      ),
    );
  }
}
