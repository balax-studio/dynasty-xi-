// presentation/screens/squad_screen.dart
// Squad management: Tactics, Formations, Lineup, and Comprehensive RPG Player detail bottom sheet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/player.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
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
            backgroundColor: AppColors.win95TitleNavy,
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
                        titleBarColor: const Color(0xFF005500),
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
        color: const Color(0xFF141A24),
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
    final rarityColor = AppColors.getRarityColor(p.stars);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.neutral900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (scrollCtx, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (p.isCaptain) const Text('🛡️ ', style: TextStyle(fontSize: 18)),
                                    Expanded(
                                      child: Text(
                                        p.fullName,
                                        style: AppTypography.h2(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.position.label} • ${p.age} Yaş • ${p.personality.label}',
                                  style: AppTypography.bodySmall(color: AppColors.accentGoldLight),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: rarityColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: rarityColor, width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${p.ovr}',
                                  style: AppTypography.display(color: rarityColor).copyWith(fontSize: 22, height: 1.0),
                                ),
                                Text('OVR', style: TextStyle(color: rarityColor, fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Doğal Dil RPG Durum Özeti (§21.4)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: AppColors.win95DarkGrey),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💬', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.naturalLanguageSummary,
                                style: AppTypography.bodySmall(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 4'lü Durum Barı (§9.5): Moral, Form, Fitness, Keskinlik
                      Text('DİNAMİK DURUM GOSTERGELERİ', style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 11)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141A24),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            _buildStatusBar('Moral', p.morale, 100, AppColors.neonLime, '%'),
                            const SizedBox(height: 6),
                            _buildStatusBar('Form', (p.form * 10).round(), 100, AppColors.accentGold, '/10.0', displayVal: p.form.toStringAsFixed(1)),
                            const SizedBox(height: 6),
                            _buildStatusBar('Kondisyon / Fitness', p.fitness, 100, AppColors.neonCyan, '%'),
                            const SizedBox(height: 6),
                            _buildStatusBar('Maç Keskinliği', p.sharpness, 100, AppColors.neonPink, '%'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // RPG Nitelikleri ve Kişilik Bilgisi (§9.4)
                      Text('KİŞİLİK & RPG NİTELİKLERİ', style: AppTypography.label(color: AppColors.accentGold).copyWith(fontSize: 11)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141A24),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Kişilik Tipi: ', style: AppTypography.bodySmall(color: Colors.white70)),
                                Text(p.personality.label, style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text('Sadakat: %${p.loyalty}', style: const TextStyle(color: AppColors.neonCyan, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(p.personality.description, style: AppTypography.bodySmall(color: Colors.white54).copyWith(fontSize: 10)),
                            if (p.isInjured) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                color: AppColors.comicRed.withValues(alpha: 0.2),
                                child: Row(
                                  children: [
                                    const Text('🚑 ', style: TextStyle(fontSize: 14)),
                                    Expanded(
                                      child: Text(
                                        p.injuryDescription,
                                        style: const TextStyle(color: AppColors.comicRed, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Temel Nitelikler (6'lı Kart)
                      Text('TEKNİK & FİZİKSEL YETENEKLER', style: AppTypography.label(color: AppColors.neutral300).copyWith(fontSize: 11)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatPill('HIZ', p.pac),
                          _buildStatPill('ŞUT', p.sho),
                          _buildStatPill('PAS', p.pas),
                          _buildStatPill('DRİ', p.dri),
                          _buildStatPill('DEF', p.def),
                          _buildStatPill('FİZ', p.phy),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // RPG Eylem Kontrolleri: Antrenman, Kaptanlık, Rol Vaadi (§9.6, §10.6)
                      Text('YÖNETİM VE TALİMATLAR', style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141A24),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Antrenman Yoğunluğu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Antrenman Yükü:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                DropdownButton<TrainingIntensity>(
                                  value: p.trainingIntensity,
                                  dropdownColor: Colors.black,
                                  style: const TextStyle(color: AppColors.neonLime, fontSize: 11, fontWeight: FontWeight.bold),
                                  underline: Container(),
                                  items: TrainingIntensity.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      ref.read(gameStateProvider.notifier).setPlayerTraining(p.id, val);
                                      Navigator.pop(ctx);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white12, height: 12),
                            // Rol Vaadi
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Kadro Rolü:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                DropdownButton<SquadRole>(
                                  value: p.squadRole,
                                  dropdownColor: Colors.black,
                                  style: const TextStyle(color: AppColors.neonAmber, fontSize: 11, fontWeight: FontWeight.bold),
                                  underline: Container(),
                                  items: SquadRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      ref.read(gameStateProvider.notifier).setPlayerSquadRole(p.id, val);
                                      Navigator.pop(ctx);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white12, height: 12),
                            // Kaptanlık Butonu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(p.isCaptain ? '★ Takım Kaptanı' : 'Kaptan Değil', style: TextStyle(color: p.isCaptain ? AppColors.accentGold : Colors.white70, fontSize: 11)),
                                if (!p.isCaptain)
                                  RetroButton(
                                    onPressed: () {
                                      ref.read(gameStateProvider.notifier).setPlayerCaptain(p.id);
                                      Navigator.pop(ctx);
                                    },
                                    backgroundColor: AppColors.accentGold,
                                    textColor: Colors.black,
                                    child: const Text('🛡️ KAPTAN YAP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Finans ve Sözleşme Bilgileri
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Piyasa: ₣${p.marketValue}', style: AppTypography.label(color: AppColors.neonLime)),
                          Text('Maaş: ₣${p.weeklyWage}/hafta (${p.contractSeasonsLeft} Yıl)', style: AppTypography.bodySmall(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Alt Butonlar (Değiştir, Sat, Feshet, Sözleşme Müzakeresi)
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showSwapDialog(context, ref, p, club);
                          },
                          backgroundColor: AppColors.neonCyan,
                          textColor: Colors.black,
                          child: Text(
                            club.starting11Ids.contains(p.id)
                                ? '🔄 YEDEK OYUNCUYLA DEĞİŞTİR'
                                : '⚡ İLK 11\'E AL (DEĞİŞTİR)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RetroButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _confirmSellPlayer(context, ref, p);
                              },
                              backgroundColor: AppColors.neonLime,
                              textColor: Colors.black,
                              child: Text(
                                '💰 SAT (₣${p.marketValue})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: RetroButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _confirmReleasePlayer(context, ref, p);
                              },
                              backgroundColor: AppColors.comicRed,
                              textColor: Colors.white,
                              child: Text(
                                '❌ FESHET (-₣${p.weeklyWage * 2})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showContractNegotiationDialog(context, ref, p);
                          },
                          backgroundColor: AppColors.neonAmber,
                          textColor: Colors.black,
                          child: const Text(
                            '📝 SÖZLEŞME MÜZAKERESİ (+3 YIL)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBar(String title, int current, int max, Color color, String unit, {String? displayVal}) {
    final ratio = (current / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(displayVal ?? '$current$unit', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.black,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  void _showContractNegotiationDialog(BuildContext context, WidgetRef ref, Player p) {
    int offeredWage = (p.weeklyWage * 1.25).round();
    int seasons = 3;
    int signingBonus = p.weeklyWage * 2;
    SquadRole promisedRole = p.squadRole;

    showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final eval = p.evaluateContractOffer(
              offeredWeeklyWage: offeredWage,
              seasons: seasons,
              signingBonus: signingBonus,
              promisedRole: promisedRole,
            );

            return AlertDialog(
              backgroundColor: const Color(0xFF141A24),
              title: Text('SÖZLEŞME MÜZAKERESİ: ${p.fullName.toUpperCase()}', style: AppTypography.h3(color: AppColors.neonAmber)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mevcut Maaş: ₣${p.weeklyWage}/hafta', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 10),
                    Text('Teklif Edilen Maaş: ₣$offeredWage/hafta', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 12)),
                    Slider(
                      value: offeredWage.toDouble(),
                      min: (p.weeklyWage * 0.7).clamp(100, 1000000).toDouble(),
                      max: (p.weeklyWage * 3.0).clamp(500, 5000000).toDouble(),
                      divisions: 20,
                      activeColor: AppColors.neonLime,
                      onChanged: (val) {
                        setDialogState(() => offeredWage = val.round());
                      },
                    ),
                    const SizedBox(height: 6),
                    Text('Sözleşme Süresi: $seasons Yıl', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    Slider(
                      value: seasons.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: AppColors.neonCyan,
                      onChanged: (val) {
                        setDialogState(() => seasons = val.round());
                      },
                    ),
                    const SizedBox(height: 6),
                    Text('İmza Bonusu: ₣$signingBonus', style: const TextStyle(color: AppColors.accentGold, fontSize: 11)),
                    Slider(
                      value: signingBonus.toDouble(),
                      min: 0,
                      max: (p.weeklyWage * 10).toDouble(),
                      divisions: 10,
                      activeColor: AppColors.accentGold,
                      onChanged: (val) {
                        setDialogState(() => signingBonus = val.round());
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: eval.accepted ? const Color(0xFF0B2E20) : const Color(0xFF2E0B0B),
                        border: Border.all(color: eval.accepted ? AppColors.neonLime : AppColors.comicRed),
                      ),
                      child: Row(
                        children: [
                          Text(eval.accepted ? '✅ ' : '❌ ', style: const TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              eval.reason,
                              style: TextStyle(
                                color: eval.accepted ? AppColors.neonLime : AppColors.comicRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx),
                  child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
                ),
                RetroButton(
                  onPressed: eval.accepted
                      ? () async {
                          Navigator.pop(dCtx);
                          await ref.read(gameStateProvider.notifier).renewContract(p, offeredWage);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('🎉 ${p.fullName} ile $seasons yıllık yeni sözleşme imzalandı!')),
                            );
                          }
                        }
                      : null,
                  backgroundColor: eval.accepted ? AppColors.neonLime : Colors.grey,
                  textColor: Colors.black,
                  child: const Text('İMZALAT'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmSellPlayer(BuildContext context, WidgetRef ref, Player p) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF141A24),
        title: Text('${p.fullName.toUpperCase()} SATILSIN MI?', style: AppTypography.h3(color: AppColors.neonLime)),
        content: Text(
          'Bu oyuncu transfer piyasasında ₣${p.marketValue} karşılığında başka bir kulübe satılacak. Kasaya +₣${p.marketValue} eklenecek.',
          style: AppTypography.body(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
          ),
          RetroButton(
            onPressed: () async {
              Navigator.pop(dCtx);
              final success = await ref.read(gameStateProvider.notifier).sellPlayer(p, p.marketValue);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '💰 ${p.fullName} ₣${p.marketValue} bedelle satıldı!'
                          : '⚠️ Satış başarısız: Takımda en az 11 oyuncu kalmalıdır.',
                    ),
                  ),
                );
              }
            },
            backgroundColor: AppColors.neonLime,
            textColor: Colors.black,
            child: const Text('ONAYLA VE SAT'),
          ),
        ],
      ),
    );
  }

  void _confirmReleasePlayer(BuildContext context, WidgetRef ref, Player p) {
    final severance = p.weeklyWage * 2;
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF141A24),
        title: Text('${p.fullName.toUpperCase()} SERBEST BIRAKILSIN MI?', style: AppTypography.h3(color: AppColors.comicRed)),
        content: Text(
          'Sözleşmeyi tek taraflı feshetmek ₣$severance tazminat bedeline mal olacaktır. Emin misiniz?',
          style: AppTypography.body(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
          ),
          RetroButton(
            onPressed: () async {
              Navigator.pop(dCtx);
              final success = await ref.read(gameStateProvider.notifier).releasePlayer(p);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '❌ ${p.fullName} serbest bırakıldı.'
                          : '⚠️ Fesih başarısız: Yetersiz bakiye veya minimum kadro sınırı.',
                    ),
                  ),
                );
              }
            },
            backgroundColor: AppColors.comicRed,
            textColor: Colors.white,
            child: const Text('FESHET'),
          ),
        ],
      ),
    );
  }

  void _showSwapDialog(BuildContext context, WidgetRef ref, Player selectedPlayer, dynamic club) {
    final isStarting = club.starting11Ids.contains(selectedPlayer.id);
    final targetList = isStarting ? club.substitutes : club.starting11;

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF141A24),
        title: Text(
          isStarting ? 'KİMİNLE DEĞİŞTİRİLSİN?' : 'İLK 11\'DEN KİMİN YERİNE GİRSİN?',
          style: AppTypography.h3(color: AppColors.neonCyan),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: targetList.isEmpty
              ? const Text('Değiştirilecek uygun oyuncu bulunamadı.', style: TextStyle(color: Colors.white54))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: targetList.length,
                  itemBuilder: (ctx, index) {
                    final target = targetList[index] as Player;
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(4),
                        color: Colors.black,
                        child: Text(target.position.code, style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(target.fullName, style: const TextStyle(color: Colors.white)),
                      subtitle: Text('${target.ovr} OVR • Form: ${target.form.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      trailing: RetroButton(
                        onPressed: () {
                          Navigator.pop(dCtx);
                          ref.read(gameStateProvider.notifier).swapPlayers(
                                isStarting ? selectedPlayer.id : target.id,
                                isStarting ? target.id : selectedPlayer.id,
                              );
                        },
                        backgroundColor: AppColors.neonLime,
                        textColor: Colors.black,
                        child: const Text('SEÇ', style: TextStyle(fontSize: 10)),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('KAPAT', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: AppColors.win95DarkGrey, width: 1),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: AppTypography.monoNumber(
              color: value >= 75 ? AppColors.neonLime : (value >= 60 ? AppColors.accentGold : AppColors.neutral300),
            ).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
