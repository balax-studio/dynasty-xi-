// presentation/screens/player_detail_screen.dart
// Dedicated, rich 16-Bit Neo-Brutalist Player Profile & Management Sub-Page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/player.dart';
import '../widgets/contract_renewal_dialog.dart';
import '../widgets/face_avatar_widget.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/player_growth_chart_widget.dart';
import '../widgets/retro_window.dart';
import 'player_agent_meeting_screen.dart';
import 'player_dialogue_screen.dart';

class PlayerDetailScreen extends ConsumerStatefulWidget {
  final Player player;
  final bool isOwned;

  const PlayerDetailScreen({
    super.key,
    required this.player,
    this.isOwned = true,
  });

  @override
  ConsumerState<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends ConsumerState<PlayerDetailScreen> {
  late Player _currentPlayer;

  @override
  void initState() {
    super.initState();
    _currentPlayer = widget.player;
  }

  Color _getAttributeColor(int val) {
    if (val >= 85) return AppColors.neonLime;
    if (val >= 75) return AppColors.neonCyan;
    if (val >= 65) return AppColors.comicYellow;
    if (val >= 50) return AppColors.neonAmber;
    return AppColors.comicRed;
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        // Eğer kendi oyuncumuz ise güncel state'ten bul
        if (widget.isOwned) {
          final livePlayer = club.squad.cast<Player?>().firstWhere(
                (p) => p?.id == _currentPlayer.id,
                orElse: () => null,
              );
          if (livePlayer != null) {
            _currentPlayer = livePlayer;
          }
        }

        final p = _currentPlayer;
        final rarityColor = AppColors.getRarityColor(p.stars);
        final isStarting11 = club.starting11Ids.contains(p.id);

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: Colors.black,
                  child: Text(
                    p.position.code,
                    style: TextStyle(
                      color: rarityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.fullName.toUpperCase(),
                    style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.2),
                    border: Border.all(color: rarityColor, width: 1.5),
                  ),
                  child: Text(
                    '${p.ovr} OVR',
                    style: AppTypography.monoNumber(color: rarityColor).copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
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
                      // 1. Görsel Profil ve Kimlik Kartı
                      _buildHeaderIdentityCard(p, rarityColor, isStarting11),
                      const SizedBox(height: 10),

                      // 2. RPG & Psikoloji Durum Paneli
                      _buildRpgStatusWindow(p),
                      const SizedBox(height: 10),

                      // 3. 6 Ana Nitelik ve Yetenek Barları
                      _buildAttributesWindow(p),
                      const SizedBox(height: 10),

                      // 4. Sezonluk Gelişim Çizgi Grafiği
                      RetroWindow(
                        title: 'SEZONLUK GELİŞİM VE REYTİNG EĞRİSİ',
                        icon: '📈',
                        child: PlayerGrowthChartWidget(
                          seasonRatings: p.seasonRatings.isNotEmpty
                              ? p.seasonRatings
                              : [p.ovr - 3, p.ovr - 2, p.ovr - 1],
                          currentOvr: p.ovr,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 5. Sözleşme & Finansal Durum
                      _buildContractAndFinanceWindow(p, club.meters.cash),
                      const SizedBox(height: 10),

                      // 6. Maç Performansı & İstatistikler
                      _buildSeasonStatsWindow(p),
                      const SizedBox(height: 10),

                      // 7. Dinamik Aksiyon & Yönetim Butonları
                      _buildActionManagementWindow(context, ref, p, club.meters.cash),
                      const SizedBox(height: 20),
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

  /// 1. Görsel Profil ve Kimlik Kartı
  Widget _buildHeaderIdentityCard(Player p, Color rarityColor, bool isStarting11) {
    return RetroWindow(
      title: 'FUTBOLCU KİMLİK KARTI & LİSANS',
      icon: '🪪',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prosedürel 16-Bit Piksel Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: rarityColor, width: 2.0),
              boxShadow: [
                BoxShadow(color: rarityColor.withValues(alpha: 0.3), blurRadius: 8),
              ],
            ),
            child: FaceAvatarWidget(seed: p.faceSeed, size: 72),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (p.isCaptain)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text('🛡️', style: TextStyle(fontSize: 16)),
                      ),
                    Expanded(
                      child: Text(
                        p.fullName,
                        style: AppTypography.h1(color: Colors.white).copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildTag('${p.position.label} (${p.position.code})', AppColors.neonLime),
                    _buildTag('${p.age} Yaş', Colors.white70),
                    _buildTag(p.countryCode, AppColors.neonCyan),
                    if (widget.isOwned)
                      _buildTag(
                        isStarting11 ? '⚡ İLK 11' : '🛋️ YEDEK',
                        isStarting11 ? AppColors.neonLime : Colors.white54,
                      ),
                    if (p.isYouthProduct)
                      _buildTag('⭐ ALTYAPI YILDIZI', AppColors.accentGold),
                    if (p.isTransferListed)
                      _buildTag('🏷️ SATILIK LİSTEDE', AppColors.comicRed),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Potansiyel: ', style: AppTypography.label(color: Colors.white70).copyWith(fontSize: 11)),
                    Text(
                      '${p.potential} POT',
                      style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Text('★' * p.stars, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. RPG & Psikoloji Durum Paneli
  Widget _buildRpgStatusWindow(Player p) {
    return RetroWindow(
      title: 'RPG DURUMU & PSİKOLOJİK PROFİL',
      icon: '🧠',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kişilik Tipi Banner'ı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF161F2E),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎭', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'KİŞİLİK: ${p.personality.label.toUpperCase()}',
                      style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  p.personality.description,
                  style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Moral, Kondisyon ve Form Barları
          Row(
            children: [
              Expanded(
                child: _buildMiniMeterBar('MORAL', p.morale, 100, _getAttributeColor(p.morale)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniMeterBar('KONDİSYON', p.fitness, 100, _getAttributeColor(p.fitness)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildMiniMeterBar('KESKİNLİK', p.sharpness, 100, AppColors.neonCyan),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniMeterBar('FORM (1-10)', (p.form * 10).round(), 100, AppColors.neonLime, customValueText: '${p.form.toStringAsFixed(1)} / 10.0'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Sakatlık Durumu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: p.isInjured ? AppColors.comicRed.withValues(alpha: 0.2) : AppColors.neonLime.withValues(alpha: 0.1),
              border: Border.all(color: p.isInjured ? AppColors.comicRed : AppColors.neonLime),
            ),
            child: Row(
              children: [
                Text(p.isInjured ? '🚑' : '💚', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'SAĞLIK DURUMU: ${p.injuryDescription.toUpperCase()}',
                  style: TextStyle(
                    color: p.isInjured ? AppColors.comicRed : AppColors.neonLime,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. 6 Ana Nitelik ve Yetenek Barları
  Widget _buildAttributesWindow(Player p) {
    return RetroWindow(
      title: '7 ÇEKİRDEK YETENEK VE NİTELİK GRAFİĞİ',
      icon: '📊',
      child: Column(
        children: [
          _buildAttributeRow('HIZ / PACE', p.pace),
          const SizedBox(height: 4),
          _buildAttributeRow('ŞUT / SHOOTING', p.shooting),
          const SizedBox(height: 4),
          _buildAttributeRow('PAS / PASSING', p.passing),
          const SizedBox(height: 4),
          _buildAttributeRow('TEKNİK & DRIBBLE', p.technique),
          const SizedBox(height: 4),
          _buildAttributeRow('SAVUNMA / DEFENSE', p.defending),
          const SizedBox(height: 4),
          _buildAttributeRow('FİZİKSEL / PHYSICAL', p.physical),
          const SizedBox(height: 4),
          _buildAttributeRow('MENTAL / MENTALITY', p.mentality),
          if (p.altPositions.isNotEmpty) ...[
            const Divider(color: Colors.white24, height: 12),
            Row(
              children: [
                Text('Alternatif Mevkiler: ', style: AppTypography.label(color: Colors.white70).copyWith(fontSize: 10)),
                ...p.altPositions.map((pos) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _buildTag(pos.code, AppColors.neonCyan),
                    )),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttributeRow(String label, int value) {
    final color = _getAttributeColor(value);
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTypography.label(color: Colors.white70).copyWith(fontSize: 10)),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            style: AppTypography.monoNumber(color: color).copyWith(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (value / 99.0).clamp(0.05, 1.0),
              backgroundColor: const Color(0xFF0F172A),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  /// 4. Sözleşme & Finansal Durum
  Widget _buildContractAndFinanceWindow(Player p, int clubCash) {
    return RetroWindow(
      title: 'SÖZLEŞME VE FİNANSAL DEĞERLEME',
      icon: '💼',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFinanceTile('HAFTALIK MAAŞ', '₣${p.weeklyWage}', AppColors.neonLime),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFinanceTile('PİYASA DEĞERİ', '₣${p.marketValue}', AppColors.accentGold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildFinanceTile('KALAN SÖZLEŞME', '${p.contractSeasonsLeft} Sezon', Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFinanceTile(
                  'SERBEST KALMA',
                  p.releaseClause > 0 ? '₣${p.releaseClause}' : 'Maddesi Yok',
                  p.releaseClause > 0 ? AppColors.neonPink : Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildFinanceTile('KADRO ROLÜ', p.squadRole.label, AppColors.neonCyan),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFinanceTile('ANTRENMAN TEMPOSU', p.trainingIntensity.label, AppColors.neonAmber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceTile(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neoInnerBg,
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 9)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.monoNumber(color: valueColor).copyWith(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 5. Maç Performansı & İstatistikler
  Widget _buildSeasonStatsWindow(Player p) {
    return RetroWindow(
      title: 'SEZONLUK MAÇ PERFORMANSI (STATS.LOG)',
      icon: '📋',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCircle('MAÇ', '${p.appearances}', Colors.white),
          _buildStatCircle('GOL', '${p.goals}', AppColors.neonLime),
          _buildStatCircle('ASİST', '${p.assists}', AppColors.neonCyan),
          if (p.position.isGoalkeeper)
            _buildStatCircle('GOL YEMEDEN', '${p.cleanSheets}', AppColors.accentGold)
          else
            _buildStatCircle('POTANSİYEL', '${p.potential}', AppColors.accentGold),
        ],
      ),
    );
  }

  Widget _buildStatCircle(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: AppTypography.monoNumber(color: color).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// 6. Dinamik Eylem & Yönetim Butonları
  Widget _buildActionManagementWindow(BuildContext context, WidgetRef ref, Player p, int clubCash) {
    if (widget.isOwned) {
      return RetroWindow(
        title: 'KULÜP İÇİ YÖNETİM VE OPERASYONLAR',
        icon: '⚙️',
        titleBarColor: AppColors.win95TitleNavy,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RetroButton(
                isNeon: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayerDialogueScreen(
                        player: p,
                        isOwned: true,
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.neonCyan,
                textColor: Colors.black,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🗣️', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text('BİREBİR ÖZEL GÖRÜŞME YAP (RPG)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RetroButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayerAgentMeetingScreen(player: p),
                    ),
                  );
                },
                backgroundColor: AppColors.win95Grey,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('💼', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text('MENAJERLE LÜKS RESTORANDA PAZARLIK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: AppColors.win95TitleNavy)),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    isNeon: true,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ContractRenewalDialog(
                          player: p,
                          onContractSigned: (newWage, weeks, role, bonus) async {
                            await ref.read(gameStateProvider.notifier).renewPlayerContract(
                                  p.id,
                                  weeks,
                                  newWage,
                                  role: role,
                                  signingBonus: bonus,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.neonLime,
                                  content: Text('${p.fullName} ile sözleşme yenilendi!', style: const TextStyle(color: Colors.black)),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                    backgroundColor: AppColors.neonLime,
                    textColor: Colors.black,
                    child: const Text('📝 SÖZLEŞME YENİLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RetroButton(
                    onPressed: () async {
                      await ref.read(gameStateProvider.notifier).toggleTransferList(p.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: p.isTransferListed ? AppColors.neonLime : AppColors.comicYellow,
                            content: Text(
                              p.isTransferListed
                                  ? '${p.fullName} transfer listesinden çıkarıldı.'
                                  : '${p.fullName} transfer listesine konuldu!',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }
                    },
                    backgroundColor: p.isTransferListed ? AppColors.comicYellow : AppColors.comicRed,
                    textColor: Colors.white,
                    child: Text(
                      p.isTransferListed ? '🏷️ LİSTEDEN ÇIKAR' : '🏷️ SATILIK LİSTESİNE KOY',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    onPressed: () async {
                      await ref.read(gameStateProvider.notifier).setPlayerCaptain(p.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.neonCyan,
                            content: Text('${p.fullName} yeni takım kaptanı yapıldı!', style: const TextStyle(color: Colors.black)),
                          ),
                        );
                      }
                    },
                    backgroundColor: AppColors.neonCyan,
                    textColor: Colors.black,
                    child: const Text('🛡️ KAPTAN YAP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RetroButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.neoCardBg,
                          title: const Text('Sözleşme Feshi', style: TextStyle(color: Colors.white)),
                          content: Text(
                            '${p.fullName} serbest bırakılacak. 2 haftalık tazminat ödenecek (₣${p.weeklyWage * 2}). Emin misiniz?',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.comicRed),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Feshet'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        final ok = await ref.read(gameStateProvider.notifier).releasePlayer(p);
                        if (context.mounted) {
                          if (ok) {
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Kadro 11 kişiden az kalamaz!')),
                            );
                          }
                        }
                      }
                    },
                    backgroundColor: const Color(0xFF334155),
                    textColor: AppColors.comicRed,
                    child: const Text('❌ SERBEST BIRAK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Antrenman Yoğunluğu Seçici
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neoInnerBg,
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text('BİREYSEL ANTRENMAN TEMPOSU', style: AppTypography.label(color: AppColors.neonAmber).copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: TrainingIntensity.values.map((intensity) {
                      final isSelected = p.trainingIntensity == intensity;
                      return Expanded(
                        child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: RetroButton(
                            onPressed: () {
                              ref.read(gameStateProvider.notifier).setPlayerTraining(p.id, intensity);
                            },
                            backgroundColor: isSelected ? AppColors.neonAmber : AppColors.neoCardBg,
                            textColor: isSelected ? Colors.black : Colors.white70,
                            child: Text(
                              intensity.label.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: isSelected ? Colors.black : Colors.white70),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Rakip / Transfer Pazarındaki Futbolcu
      final canAfford = clubCash >= p.marketValue;

      return RetroWindow(
        title: 'TRANSFER VE KİRALAMA İŞLEMLERİ',
        icon: '🤝',
        titleBarColor: AppColors.accentGold,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RetroButton(
                isNeon: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayerDialogueScreen(
                        player: p,
                        isOwned: false,
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.neonAmber,
                textColor: Colors.black,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🗣️', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 6),
                    Text('TRANSFER MÜLAKATI & İKNA KONUŞMASI (RPG)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    isNeon: true,
                    onPressed: () async {
                      if (!canAfford) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.comicRed,
                            content: Text('Kulüp kasasında yeterli bütçe yok!'),
                          ),
                        );
                        return;
                      }

                      final ok = await ref.read(gameStateProvider.notifier).buyPlayer(p, p.marketValue, p.weeklyWage);
                      if (context.mounted) {
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.neonLime,
                              content: Text('🎉 ${p.fullName} başarıyla transfer edildi!', style: const TextStyle(color: Colors.black)),
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transfer işlemi gerçekleştirilemedi.')),
                          );
                        }
                      }
                    },
                    backgroundColor: canAfford ? AppColors.neonLime : Colors.grey,
                    textColor: Colors.black,
                    child: Text(
                      '💼 TRANSFER ET (₣${p.marketValue})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RetroButton(
                    onPressed: () async {
                      final ok = await ref.read(gameStateProvider.notifier).buyPlayer(p, 0, (p.weeklyWage * 0.7).round());
                      if (context.mounted) {
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.neonCyan,
                              content: Text('🤝 ${p.fullName} kiralık olarak kadroya katıldı!', style: const TextStyle(color: Colors.black)),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                    backgroundColor: AppColors.neonCyan,
                    textColor: Colors.black,
                    child: Text(
                      '🤝 SEZONLUK KİRALA (₣${(p.weeklyWage * 0.7).round()}/h)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMiniMeterBar(String label, int value, int maxVal, Color color, {String? customValueText}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.neoInnerBg,
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8.5)),
              Text(
                customValueText ?? '$value / $maxVal',
                style: AppTypography.monoNumber(color: color).copyWith(fontSize: 9.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (value / maxVal).clamp(0.05, 1.0),
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
