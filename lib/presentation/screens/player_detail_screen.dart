// presentation/screens/player_detail_screen.dart
// Dedicated 16-Bit Neo-Brutalist Player Profile & Management: 3-Tab Bento UI, Radar Chart, Factions & Presidential Controls.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/player.dart';
import '../../domain/progression/player_natural_summary.dart';
import '../widgets/contract_renewal_dialog.dart';
import '../widgets/face_avatar_widget.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/player_comparison_modal.dart';
import '../widgets/player_growth_chart_widget.dart';
import '../widgets/player_radar_chart_widget.dart';
import '../widgets/presidential_incentives_modal.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';
import 'player_agent_meeting_screen.dart';
import 'player_dialogue_screen.dart';

enum PlayerDetailTab {
  general('GENEL & YETENEK', RetroPixelIconType.chart),
  contract('SÖZLEŞME & PİYASA', RetroPixelIconType.cash),
  presidential('BAŞKANLIK & SOYUNMA ODASI', RetroPixelIconType.crown);

  final String label;
  final RetroPixelIconType iconType;
  const PlayerDetailTab(this.label, this.iconType);
}

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
  PlayerDetailTab _activeTab = PlayerDetailTab.general;

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
              icon: const Text('◀', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: Colors.black,
                  child: Text(
                    '#${p.jerseyNumber}',
                    style: const TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.fullName.toUpperCase(),
                    style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 13),
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

              // 3 Sekmeli Bento Bar
              Container(
                color: AppColors.neoInnerBg,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: PlayerDetailTab.values.map((tab) {
                    final isSelected = _activeTab == tab;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: GestureDetector(
                          key: Key('tab_${tab.name}'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            AudioSynthesizer.playClick();
                            setState(() => _activeTab = tab);
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
                                  size: 13,
                                  color: isSelected ? Colors.black : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tab.label,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.0,
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

              // Ana İçerik
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kimlik Kartı Her Sekmede Sabit Üstte Kalır
                      _buildHeaderIdentityCard(p, rarityColor, isStarting11),
                      const SizedBox(height: 8),

                      // Birebir Görüşme Hızlı Erişim Butonu
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          backgroundColor: AppColors.win95TitleNavy,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PlayerDialogueScreen(player: p)),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RetroPixelIcon(type: RetroPixelIconType.chat, size: 15, color: AppColors.neonLime),
                                SizedBox(width: 6),
                                Text(
                                  'BİREBİR ÖZEL GÖRÜŞME YAP (RPG DİYALOG)',
                                  style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sekme İçerikleri
                      if (_activeTab == PlayerDetailTab.general)
                        _buildGeneralAttributesTab(p)
                      else if (_activeTab == PlayerDetailTab.contract)
                        _buildContractAndFinanceTab(context, ref, p, club.meters.cash)
                      else
                        _buildPresidentialAndLockerRoomTab(context, ref, p, club, gameState.headCoach),

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

  /// 1. Kimlik Kartı
  Widget _buildHeaderIdentityCard(Player p, Color rarityColor, bool isStarting11) {
    return RetroWindow(
      title: 'FUTBOLCU KİMLİK KARTI & LİSANS',
      icon: '',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: rarityColor, width: 2.0),
            ),
            child: FaceAvatarWidget(seed: p.faceSeed, size: 68),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (p.isCaptain)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Text('SHIELD', style: TextStyle(fontSize: 15)),
                      ),
                    Expanded(
                      child: Text(
                        '#${p.jerseyNumber} ${p.fullName}',
                        style: AppTypography.h1(color: Colors.white).copyWith(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _buildTag('${p.position.label} (${p.position.code})', AppColors.neonLime),
                    _buildTag('${p.age} Yaş', Colors.white70),
                    _buildTag(p.countryCode, AppColors.neonCyan),
                    if (widget.isOwned)
                      _buildTag(
                        isStarting11 ? 'BOLT İLK 11' : ' YEDEK',
                        isStarting11 ? AppColors.neonLime : Colors.white54,
                      ),
                    if (p.isYouthProduct) _buildTag('STAR ALTYAPI', AppColors.accentGold),
                    if (p.isTransferListed) _buildTag('[ETIKET] SATILIK', AppColors.comicRed),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Potansiyel: ', style: AppTypography.label(color: Colors.white70).copyWith(fontSize: 10)),
                    Text(
                      '${p.potential} POT',
                      style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Text('' * p.stars, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SEKME 1: GENEL & YETENEKLER
  Widget _buildGeneralAttributesTab(Player p) {
    return Column(
      children: [
        // 6 Eksenli Hexagonal Siber Radar Grafiği
        RetroWindow(
          title: '6 EKSENLİ NİTELİK VE BECERİ RADARI',
          icon: '',
          child: PlayerRadarChartWidget(player: p),
        ),
        const SizedBox(height: 10),

        // Teknik Direktör & Scout Değerlendirme Raporu (§21.4)
        RetroWindow(
          title: 'TEKNİK DİREKTÖR & SCOUT DEĞERLENDİRME RAPORU',
          icon: '[RAPOR]',
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('[RAPOR]', style: TextStyle(fontSize: 10, color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    PlayerNaturalSummary.generateSummary(p),
                    style: const TextStyle(
                      color: AppColors.neonLime,
                      fontSize: 11,
                      height: 1.35,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Nitelik Barları
        _buildAttributesWindow(p),
        const SizedBox(height: 10),

        // Sezonluk Gelişim Çizgi Grafiği
        RetroWindow(
          title: 'SEZONLUK GELİŞİM VE REYTİNG EĞRİSİ',
          icon: '[ARTIS]',
          child: PlayerGrowthChartWidget(
            seasonRatings: p.seasonRatings.isNotEmpty ? p.seasonRatings : [p.ovr - 3, p.ovr - 2, p.ovr - 1],
            currentOvr: p.ovr,
          ),
        ),
        const SizedBox(height: 10),

        // Maç İstatistikleri
        _buildSeasonStatsWindow(p),
      ],
    );
  }

  /// SEKME 2: SÖZLEŞME & PİYASA
  Widget _buildContractAndFinanceTab(BuildContext context, WidgetRef ref, Player p, int clubCash) {
    final canAfford = clubCash >= p.marketValue;

    return Column(
      children: [
        RetroWindow(
          title: 'SÖZLEŞME & MALİ HÜKÜMLER',
          icon: '[KASA]',
          child: Column(
            children: [
              _buildFinanceRow('Haftalık Maaş', '₣${p.weeklyWage}', isHighlight: true),
              _buildFinanceRow('Yıllık Maliyet', '₣${p.weeklyWage * 52}'),
              _buildFinanceRow('Kalan Sözleşme', '${p.contractSeasonsLeft} Sezon'),
              _buildFinanceRow('Tahmini Piyasa Değeri', '₣${p.marketValue}', isHighlight: true),
              _buildFinanceRow('Serbest Kalma Bedeli', p.releaseClause > 0 ? '₣${p.releaseClause}' : 'Yok (Korumalı)'),
              const Divider(color: AppColors.win95DarkGrey, height: 16),
              _buildFinanceRow('Sadakat Primi', p.loyaltyBonus > 0 ? '₣${p.loyaltyBonus}' : 'Tanımlanmadı'),
              _buildFinanceRow('Gol / Asist Başı Prim', p.goalBonus > 0 ? '₣${p.goalBonus}' : 'Tanımlanmadı'),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Aksiyon Butonları
        RetroWindow(
          title: widget.isOwned ? 'KULÜP SÖZLEŞME VE TRANSFER İŞLEMLERİ' : 'TRANSFER VE KİRALAMA MASASI',
          icon: '[ANLASMA]',
          titleBarColor: AppColors.accentGold,
          child: widget.isOwned
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RetroButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ContractRenewalDialog(
                                  player: p,
                                  onContractSigned: (offeredWage, contractWeeks, role, bonus) async {
                                    final seasons = (contractWeeks / 20).ceil().clamp(1, 4);
                                    await ref.read(gameStateProvider.notifier).renewContract(
                                          p.id,
                                          newWeeklyWage: offeredWage,
                                          additionalSeasons: seasons,
                                          signingBonus: bonus,
                                        );
                                  },
                                ),
                              );
                            },
                            backgroundColor: AppColors.neonLime,
                            textColor: Colors.black,
                            child: const Text(' SÖZLEŞME YENİLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RetroButton(
                            onPressed: () async {
                              await ref.read(gameStateProvider.notifier).toggleTransferList(p.id);
                            },
                            backgroundColor: p.isTransferListed ? AppColors.comicYellow : AppColors.comicRed,
                            textColor: Colors.white,
                            child: Text(
                              p.isTransferListed ? '[ETIKET] LİSTEDEN ÇIKAR' : '[ETIKET] SATILIK LİSTESİNE KOY',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5),
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => PlayerAgentMeetingScreen(player: p)),
                              );
                            },
                            backgroundColor: AppColors.win95TitleNavy,
                            textColor: Colors.white,
                            child: const Text('[MENAJER] MENAJERİ İLE GÖRÜŞ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RetroButton(
                            onPressed: () async {
                              final ok = await ref.read(gameStateProvider.notifier).releasePlayer(p);
                              if (context.mounted && ok) Navigator.pop(context);
                            },
                            backgroundColor: const Color(0xFF334155),
                            textColor: AppColors.comicRed,
                            child: const Text('[RED] SERBEST BIRAK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: RetroButton(
                        backgroundColor: canAfford ? AppColors.neonLime : AppColors.neutral700,
                        textColor: canAfford ? Colors.black : Colors.white70,
                        onPressed: canAfford
                            ? () async {
                                final ok = await ref.read(gameStateProvider.notifier).signPlayer(p, p.marketValue, p.weeklyWage);
                                if (context.mounted && ok) Navigator.pop(context);
                              }
                            : null,
                        child: Text(
                          '[KASA] DOĞRUDAN TRANSFER ET (₣${p.marketValue})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  /// SEKME 3: BAŞKANLIK & SOYUNMA ODASI
  Widget _buildPresidentialAndLockerRoomTab(
    BuildContext context,
    WidgetRef ref,
    Player p,
    dynamic club,
    dynamic headCoach,
  ) {
    final chemistry = p.getCoachChemistry(club.tacticalStyle);
    final squad = club.squad as List<Player>;

    return Column(
      children: [
        // 1. Soyunma Odası Kliği ve Hoca Uyum Durumu
        RetroWindow(
          title: 'SOYUNMA ODASI KLİĞİ VE HOCA KİMYASI',
          icon: '[TARAFTAR]',
          titleBarColor: AppColors.win95TitleNavy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Text(p.faction.icon, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KLİK: ${p.faction.label.toUpperCase()}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11)),
                        Text(p.faction.description, style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: AppColors.win95DarkGrey, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('HOCA UYUM SKORU:', style: AppTypography.label(color: Colors.white70).copyWith(fontSize: 10)),
                  Text(
                    '%$chemistry UYUMLU',
                    style: TextStyle(
                      color: chemistry >= 75 ? AppColors.neonLime : (chemistry >= 50 ? AppColors.accentGold : AppColors.comicRed),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. Başkanlık Doğrudan Müdahale ve Prim Kartı
        RetroWindow(
          title: 'BAŞKANLIK DOĞRUDAN MÜDAHALE MERKEZİ',
          icon: 'CROWN',
          titleBarColor: AppColors.accentGold,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  backgroundColor: AppColors.accentGold,
                  textColor: Colors.black,
                  onPressed: () {
                    PresidentialIncentivesModal.show(context, p);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('CROWN', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text(
                          'ÖZEL PRİM / HEDİYE / NUMARA / CEZA MENÜSÜ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RetroButton(
                      backgroundColor: AppColors.neonCyan,
                      textColor: Colors.black,
                      onPressed: () {
                        PlayerComparisonModal.show(context, p, squad);
                      },
                      child: const Text('[HUKUK] TAKIMLA KIYASLA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RetroButton(
                      backgroundColor: AppColors.neonLime,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlayerDialogueScreen(player: p)),
                        );
                      },
                      child: const Text('[MESAJ] BİREBİR GÖRÜŞ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  backgroundColor: p.isCaptain ? AppColors.comicYellow : AppColors.win95TitleNavy,
                  textColor: Colors.white,
                  onPressed: () async {
                    await ref.read(gameStateProvider.notifier).setPlayerCaptain(p.id);
                  },
                  child: Text(
                    p.isCaptain ? 'SHIELD KAPTANLIK BANDINI AL' : 'SHIELD TAKIM KAPTANI YAP',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 3. Nitelik Barları
  Widget _buildAttributesWindow(Player p) {
    return RetroWindow(
      title: '7 ÇEKİRDEK FUTBOLCU NİTELİĞİ (1 - 99)',
      icon: 'BOLT',
      child: Column(
        children: [
          _buildAttrBar('HIZ & ÇEVİKLİK (PAC)', p.pace),
          _buildAttrBar('TOP TEKNİĞİ & TOP KONTROL (DRI)', p.technique),
          _buildAttrBar('BİTİRİCİLİK & ŞUT (SHO)', p.shooting),
          _buildAttrBar('VİZYON & PAS (PAS)', p.passing),
          _buildAttrBar('SAVUNMA & POZİSYON (DEF)', p.defending),
          _buildAttrBar('FİZİK & GÜÇ (PHY)', p.physical),
          _buildAttrBar('MENTALİTE & KARARLILIK (MEN)', p.mentality),
        ],
      ),
    );
  }

  Widget _buildAttrBar(String label, int value) {
    final color = _getAttributeColor(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTypography.label(color: Colors.white70).copyWith(fontSize: 9.5)),
          ),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (value / 99.0).clamp(0.0, 1.0),
                child: Container(color: color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$value',
              style: AppTypography.monoNumber(color: color).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonStatsWindow(Player p) {
    return RetroWindow(
      title: 'SEZONLUK MAÇ PERFORMANSI',
      icon: '[GRAFIK]',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatBox('MAÇ', '${p.appearances}'),
          _buildStatBox('GOL', '${p.goals}', color: AppColors.neonLime),
          _buildStatBox('ASİST', '${p.assists}', color: AppColors.neonCyan),
          _buildStatBox('GOL YEMEME', '${p.cleanSheets}', color: AppColors.accentGold),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(value, style: AppTypography.h1(color: color).copyWith(fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFinanceRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10)),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? AppColors.neonLime : Colors.white,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1.0),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold)),
    );
  }
}
