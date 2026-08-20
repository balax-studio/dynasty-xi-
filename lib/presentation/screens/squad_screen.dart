// presentation/screens/squad_screen.dart
// Squad management: Interactive Pitch Lineup Builder, Best XI Generator, Player Swap, Sorting, U19 & Youth Academy Tabs.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/player.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/presidential_directives_modal.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';
import 'head_coach_dialogue_screen.dart';
import 'head_coach_hiring_screen.dart';
import 'player_detail_screen.dart';
import 'staff_screen.dart';
import 'u19_squad_screen.dart';
import 'youth_academy_screen.dart';

enum SquadSortOption {
  position('Mevki Sırası'),
  ovrDesc('En Yüksek Puan (OVR)'),
  ovrAsc('En Düşük Puan (OVR)'),
  nameAsc('İsim (A-Z)'),
  ageAsc('En Genç'),
  ageDesc('En Yaşlı'),
  valueDesc('En Yüksek Değer');

  final String label;
  const SquadSortOption(this.label);
}

enum SquadViewTab {
  senior('A TAKIM KADROSU', RetroPixelIconType.ball),
  u19('U19 GENÇ TAKIMI', RetroPixelIconType.sprout),
  academy('ALTYAPI AKADEMİSİ', RetroPixelIconType.capitol);

  final String label;
  final RetroPixelIconType iconType;
  const SquadViewTab(this.label, this.iconType);
}

class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key});

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  SquadSortOption _sortOption = SquadSortOption.position;
  SquadViewTab _activeTab = SquadViewTab.senior;
  bool _showPitchView = true;
  String? _selectedPlayerForSwap; // Swap için seçilen oyuncunun ID'si

  List<Player> _sortPlayers(List<Player> players) {
    final list = List<Player>.from(players);
    switch (_sortOption) {
      case SquadSortOption.position:
        list.sort((a, b) => a.position.index.compareTo(b.position.index));
        break;
      case SquadSortOption.ovrDesc:
        list.sort((a, b) => b.ovr.compareTo(a.ovr));
        break;
      case SquadSortOption.ovrAsc:
        list.sort((a, b) => a.ovr.compareTo(b.ovr));
        break;
      case SquadSortOption.nameAsc:
        list.sort((a, b) => a.fullName.compareTo(b.fullName));
        break;
      case SquadSortOption.ageAsc:
        list.sort((a, b) => a.age.compareTo(b.age));
        break;
      case SquadSortOption.ageDesc:
        list.sort((a, b) => b.age.compareTo(a.age));
        break;
      case SquadSortOption.valueDesc:
        list.sort((a, b) => b.marketValue.compareTo(a.marketValue));
        break;
    }
    return list;
  }

  void _handlePlayerTap(BuildContext context, dynamic club, Player player, bool isStarting) {
    AudioSynthesizer.playClick();
    if (_selectedPlayerForSwap == null) {
      // Birinci oyuncuyu seç
      setState(() {
        _selectedPlayerForSwap = player.id;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.neonCyan,
          content: Text(
            '🔄 ${player.fullName} seçildi. Değiştirmek istediğiniz diğer oyuncuya dokunun.',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      );
    } else {
      // İkinci oyuncuya dokunuldu -> Swap yap
      final firstId = _selectedPlayerForSwap!;
      if (firstId != player.id) {
        ref.read(gameStateProvider.notifier).swapStartingAndBench(firstId, player.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.neonLime,
            content: Text(
              '⚡ Kadro güncellendi! Oyuncular yer değiştirdi.',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        );
      }
      setState(() {
        _selectedPlayerForSwap = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final squad = club.squad;
        final starting11 = _sortPlayers(club.starting11);
        final subs = _sortPlayers(club.substitutes);
        final headCoach = gameState.headCoach;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            title: Text(
              'KADRO & TAKTİK MERKEZİ (${squad.length} OYUNCU)',
              style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 13),
            ),
          ),
          body: Column(
            children: [
              MetersBarWidget(meters: club.meters),

              // Üst Kategori Sekmeleri (A Takım / U19 / Altyapı)
              Container(
                color: AppColors.neoInnerBg,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: SquadViewTab.values.map((tab) {
                    final isSelected = _activeTab == tab;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: InkWell(
                          onTap: () {
                            AudioSynthesizer.playClick();
                            if (tab == SquadViewTab.u19) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const U19SquadScreen()));
                            } else if (tab == SquadViewTab.academy) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const YouthAcademyScreen()));
                            } else {
                              setState(() => _activeTab = tab);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.neonLime : Colors.black,
                              border: Border.all(
                                color: isSelected ? Colors.black : AppColors.win95DarkGrey,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RetroPixelIcon(
                                  type: tab.iconType,
                                  size: 14,
                                  color: isSelected ? Colors.black : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tab.label,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Kadro Ana İçerik
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 0. Başkanlık Talimatları
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          backgroundColor: AppColors.win95TitleNavy,
                          onPressed: () {
                            PresidentialDirectivesModal.show(context, squad);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RetroPixelIcon(type: RetroPixelIconType.crown, size: 16, color: AppColors.accentGold),
                                SizedBox(width: 6),
                                Text(
                                  'BAŞKANLIK TALİMATI & VETO (KADRO DIŞI / KAPTANLIK)',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.neonLime),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 1. Taktik, Diziliş ve Teknik Direktör Kartı
                      RetroWindow(
                        title: 'TAKTIKSEL FORMASYON VE TEKNİK DİREKTÖR',
                        icon: 'tacticsBoard',
                        child: _buildTacticsCard(context, ref, club, headCoach),
                      ),
                      const SizedBox(height: 10),

                      // 2. İlk 11 & Yedekler Araç Çubuğu (Otomatik 11 ve Sıralama)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.neoInnerBg,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RetroButton(
                                    backgroundColor: AppColors.neonLime,
                                    textColor: Colors.black,
                                    onPressed: () {
                                      AudioSynthesizer.playClick();
                                      ref.read(gameStateProvider.notifier).autoSelectBest11();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: AppColors.neonLime,
                                          content: Text(
                                            '⚡ En iyi 11 oyuncu otomatik olarak sahaya dizildi!',
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        RetroPixelIcon(type: RetroPixelIconType.lightning, size: 14, color: Colors.black),
                                        SizedBox(width: 4),
                                        Text('EN İYİ 11\'İ OTOMATİK DİZ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                RetroButton(
                                  backgroundColor: _showPitchView ? AppColors.neonCyan : Colors.black,
                                  textColor: _showPitchView ? Colors.black : Colors.white,
                                  onPressed: () {
                                    setState(() => _showPitchView = !_showPitchView);
                                  },
                                  child: Text(
                                    _showPitchView ? 'LİSTE GÖRÜNÜMÜ' : 'SAHA GÖRÜNÜMÜ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text('Sırala: ', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<SquadSortOption>(
                                      value: _sortOption,
                                      isDense: true,
                                      dropdownColor: Colors.black,
                                      style: const TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold),
                                      items: SquadSortOption.values.map((opt) {
                                        return DropdownMenuItem(
                                          value: opt,
                                          child: Text(opt.label),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _sortOption = val);
                                      },
                                    ),
                                  ),
                                ),
                                if (_selectedPlayerForSwap != null)
                                  TextButton(
                                    onPressed: () => setState(() => _selectedPlayerForSwap = null),
                                    child: const Text('Seçimi İptal Et ✕', style: TextStyle(color: AppColors.comicRed, fontSize: 9.5)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3. Saha / İlk 11 Görsel Panosu
                      if (_showPitchView)
                        RetroWindow(
                          title: 'İLK 11 SAHA DİZİLİMİ (${club.formation})',
                          icon: '🏟️',
                          titleBarColor: const Color(0xFF005500),
                          child: _buildVisualPitchLineup(context, club, club.starting11),
                        ),
                      const SizedBox(height: 10),

                      // 4. İlk 11 Liste Penceresi
                      RetroWindow(
                        title: 'İLK 11 KADROSU (${starting11.length} OYUNCU)',
                        icon: '⭐',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: Column(
                          children: starting11.map((p) => _buildPlayerCard(context, ref, club, p, isStarting: true)).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 5. Yedekler Penceresi
                      RetroWindow(
                        title: 'YEDEK KULÜBESİ (${subs.length} OYUNCU)',
                        icon: '🪑',
                        titleBarColor: AppColors.win95TitleNavy,
                        child: subs.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Yedek kulübesinde oyuncu kalmadı.', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              )
                            : Column(
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

  /// Görsel İlk 11 Taktik Sahası
  Widget _buildVisualPitchLineup(BuildContext context, dynamic club, List<Player> s11) {
    return Container(
      height: 310,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A1C),
        border: Border.all(color: AppColors.neonLime, width: 2),
      ),
      child: Stack(
        children: [
          // Saha Çizgileri
          Center(
            child: Container(
              width: double.infinity,
              height: 1.5,
              color: Colors.white24,
            ),
          ),
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
            ),
          ),

          // Saha Üzerindeki Oyuncu Düğümleri (Formasyona göre satırlar)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Forvet Hattı
                  _buildPitchRow(context, club, s11.where((p) => p.position.isForward).toList()),
                  // Orta Saha Hattı
                  _buildPitchRow(context, club, s11.where((p) => p.position.isMidfielder).toList()),
                  // Defans Hattı
                  _buildPitchRow(context, club, s11.where((p) => p.position.isDefender).toList()),
                  // Kaleci
                  _buildPitchRow(context, club, s11.where((p) => p.position.isGoalkeeper).toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPitchRow(BuildContext context, dynamic club, List<Player> players) {
    if (players.isEmpty) return const SizedBox(height: 40);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: players.map((p) {
        final isSelected = _selectedPlayerForSwap == p.id;
        final rarityColor = AppColors.getRarityColor(p.stars);

        return InkWell(
          onTap: () => _handlePlayerTap(context, club, p, true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.neonCyan : Colors.black.withValues(alpha: 0.85),
              border: Border.all(
                color: isSelected ? Colors.white : rarityColor,
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? [const BoxShadow(color: AppColors.neonCyan, blurRadius: 8, spreadRadius: 1)]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p.position.code,
                      style: TextStyle(
                        color: isSelected ? Colors.black : rarityColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 9.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                      color: AppColors.accentGold,
                      child: Text(
                        '${p.ovr}',
                        style: const TextStyle(color: Colors.black, fontSize: 8.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  p.lastName.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 8.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTacticsCard(BuildContext context, WidgetRef ref, dynamic club, dynamic headCoach) {
    const formations = ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1', '5-3-2'];
    const styles = ['Dengeli', 'Ofansif', 'Defansif', 'Kontra Atak', 'Baskılı'];

    final coachName = headCoach?.fullName ?? 'SERGEN HOCA (GEÇİCİ)';
    final coachStyle = (headCoach?.tacticalStyle ?? club.tacticalStyle).toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              color: Colors.black,
              alignment: Alignment.center,
              child: Text(headCoach?.archetype.icon ?? '👔', style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEKNİK DİREKTÖR: $coachName',
                    style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11),
                  ),
                  Text(
                    'Felsefe: $coachStyle • Başarı Odaklı Taktik Yönetimi',
                    style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 9.5),
                  ),
                ],
              ),
            ),
            RetroButton(
              onPressed: () {
                if (headCoach != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HeadCoachDialogueScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HeadCoachHiringScreen()),
                  );
                }
              },
              backgroundColor: AppColors.accentGold,
              textColor: Colors.black,
              child: const Text('💬 HOCA ODASI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
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
    final isSelectedForSwap = _selectedPlayerForSwap == p.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelectedForSwap ? const Color(0xFF1E3A8A) : AppColors.neoInnerBg,
        border: Border(
          top: BorderSide(color: isSelectedForSwap ? AppColors.neonCyan : (isStarting ? AppColors.neonLime : AppColors.win95DarkGrey), width: 1.5),
          left: BorderSide(color: isSelectedForSwap ? AppColors.neonCyan : (isStarting ? AppColors.neonLime : AppColors.win95DarkGrey), width: 1.5),
          right: const BorderSide(color: Colors.black, width: 1.5),
          bottom: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        onTap: () => _handlePlayerTap(context, club, p, isStarting),
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
              Text(
                '★' * p.stars,
                style: TextStyle(
                  color: rarityColor,
                  fontSize: 7,
                ),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                p.fullName,
                style: AppTypography.h3(color: Colors.white).copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (p.isCaptain)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: AppColors.accentGold,
                child: const Text('C', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9)),
              ),
            if (p.isInjured)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: AppColors.comicRed,
                child: Text('🚑 ${p.injuryMatchesLeft}M', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9)),
              ),
          ],
        ),
        subtitle: Text(
          'Yaş: ${p.age} • Moral: %${p.morale} • Maaş: ₣${p.weeklyWage}/h',
          style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 9.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.black,
              child: Text(
                '${p.ovr}',
                style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.info_outline, color: AppColors.neonCyan, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PlayerDetailScreen(player: p)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
