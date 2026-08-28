// presentation/screens/transfer_screen.dart
// Cyber Transfer & Scout Market with Advanced Filter Bar, Free Agents, Loan Market, and Dedicated Negotiation Desk.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/economy/transfer_models.dart';
import '../../domain/entities/player.dart';
import '../../domain/transfers/transfer_window_rules.dart';
import '../../core/time/game_clock.dart';
import 'player_detail_screen.dart';
import 'transfer_hijack_screen.dart';
import 'transfer_negotiation_screen.dart';
import '../widgets/contract_renewal_dialog.dart';
import '../widgets/loan_contract_summary_modal.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/player_sale_offer_modal.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';

enum TransferPositionFilter {
  all('TÜMÜ'),
  gk('KALECİ'),
  def('SAVUNMA'),
  mid('ORTA SAHA'),
  fwd('HÜCUM');

  final String label;
  const TransferPositionFilter(this.label);

  bool matches(Position pos) {
    switch (this) {
      case TransferPositionFilter.all:
        return true;
      case TransferPositionFilter.gk:
        return pos == Position.gk;
      case TransferPositionFilter.def:
        return pos == Position.cb || pos == Position.lb || pos == Position.rb;
      case TransferPositionFilter.mid:
        return pos == Position.dm || pos == Position.cm || pos == Position.am;
      case TransferPositionFilter.fwd:
        return pos == Position.st || pos == Position.lw || pos == Position.rw;
    }
  }
}

enum TransferSortOption {
  ovrDesc('En Yüksek Puan (OVR)'),
  potDesc('En Yüksek Potansiyel (POT)'),
  valueAsc('En Uygun Bonservis'),
  valueDesc('En Değerli Yıldızlar'),
  wageAsc('En Düşük Maaş');

  final String label;
  const TransferSortOption(this.label);
}

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  TransferPositionFilter _selectedPosition = TransferPositionFilter.all;
  TransferSortOption _selectedSort = TransferSortOption.ovrDesc;
  bool _onlyAffordable = false;
  final bool _showFreeAgents = true;

  List<Player> _filterAndSortPlayers(List<Player> players, int currentCash) {
    var list = players.where((p) {
      if (!_selectedPosition.matches(p.position)) return false;
      if (_onlyAffordable && p.marketValue > currentCash) return false;
      return true;
    }).toList();

    switch (_selectedSort) {
      case TransferSortOption.ovrDesc:
        list.sort((a, b) => b.ovr.compareTo(a.ovr));
        break;
      case TransferSortOption.potDesc:
        list.sort((a, b) => b.potential.compareTo(a.potential));
        break;
      case TransferSortOption.valueAsc:
        list.sort((a, b) => a.marketValue.compareTo(b.marketValue));
        break;
      case TransferSortOption.valueDesc:
        list.sort((a, b) => b.marketValue.compareTo(a.marketValue));
        break;
      case TransferSortOption.wageAsc:
        list.sort((a, b) => a.weeklyWage.compareTo(b.weeklyWage));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final currentCash = gameState.userClub.meters.cash;
        final squadIds = gameState.userClub.squad.map((p) => p.id).toSet();
        final signedSet = {...gameState.signedMarketIds, ...squadIds};
        final rawMarket = gameState.transferMarket.where((p) => !signedSet.contains(p.id)).toList();
        final squad = gameState.userClub.squad;
        final loans = LoanMarketGenerator.generateLoanCandidates().where((l) => !signedSet.contains(l.player.id)).toList();
        final freeAgents = FreeAgentMarketGenerator.generateFreeAgents().where((p) => !signedSet.contains(p.id)).toList();

        final filteredMarket = _filterAndSortPlayers(rawMarket, currentCash);
        final filteredFreeAgents = _filterAndSortPlayers(freeAgents, currentCash);

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.primaryDeep,
            appBar: AppBar(
              backgroundColor: AppColors.neoCardBg,
              title: Text('CYBER TRANSFER & SCOUT BORSASI', style: AppTypography.h2(color: Colors.white)),
              bottom: const TabBar(
                indicatorColor: AppColors.neonLime,
                indicatorWeight: 3,
                labelColor: AppColors.neonLime,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: RetroPixelIcon(type: RetroPixelIconType.cart, size: 20, color: AppColors.neonLime),
                    text: 'TRANSFER PAZARI',
                  ),
                  Tab(
                    icon: RetroPixelIcon(type: RetroPixelIconType.tag, size: 20, color: AppColors.neonCyan),
                    text: 'SATIŞ LİSTESİ',
                  ),
                  Tab(
                    icon: RetroPixelIcon(type: RetroPixelIconType.handshake, size: 20, color: AppColors.accentGold),
                    text: 'KİRALIK PAZARI',
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                MetersBarWidget(meters: gameState.userClub.meters),
                Expanded(
                  child: TabBarView(
                    children: [
                      // TAB 1: TRANSFER PAZARI & SERBEST OYUNCULAR
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 0. Transfer Penceresi & Kadro Kotası Durum Paneli
                            _buildTransferWindowBanner(gameState),
                            const SizedBox(height: 10),

                            // 1. Son Dakika Transfer Çalımı Butonu
                            SizedBox(
                              width: double.infinity,
                              child: RetroButton(
                                backgroundColor: AppColors.comicRed,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TransferHijackScreen()),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RetroPixelIcon(type: RetroPixelIconType.plane, size: 16, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('SON DAKİKA TRANSFER ÇALIMI & OTEL BASKINI MASASI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 2. Çok Kriterli Siber Arama & Filtreleme Araç Çubuğu
                            _buildAdvancedFilterToolbar(currentCash),
                            const SizedBox(height: 10),

                            // 2. Scout Bilgi ve İstihbarat Akışı
                            RetroWindow(
                              title: 'SCOUT BİLGİ VE İSTİHBARAT AKIŞI',
                              icon: 'satellite',
                              child: Row(
                                children: [
                                  const RetroPixelIcon(type: RetroPixelIconType.satellite, size: 28, color: AppColors.neonCyan),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'DÜNYA TRANSFER BORSASI & SERBEST OYUNCULAR',
                                          style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 11),
                                        ),
                                        Text(
                                          'Piyasadaki yıldızlarla ve serbest oyuncularla doğrudan tam ekran pazarlık masasına oturun.',
                                          style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 3. Serbest Oyuncular (Free Agents & Bosman) Havuzu
                            if (_showFreeAgents && filteredFreeAgents.isNotEmpty) ...[
                              RetroWindow(
                                title: 'SERBEST OYUNCULAR & BOSMAN LİSTESİ (${filteredFreeAgents.length})',
                                icon: 'sprout',
                                titleBarColor: const Color(0xFF1E3A8A),
                                child: Column(
                                  children: filteredFreeAgents
                                      .map((p) => _buildMarketPlayerCard(context, ref, p, gameState, isFreeAgent: true))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],

                            // 4. Satın Alınabilir Pazar Oyuncuları
                            RetroWindow(
                              title: 'SATIN ALINABİLİR OYUNCULAR (${filteredMarket.length})',
                              icon: 'cart',
                              titleBarColor: AppColors.neoCardBg,
                              child: filteredMarket.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Center(
                                        child: Text('FİLTREYE UYGUN OYUNCU BULUNAMADI.', style: AppTypography.label(color: Colors.white)),
                                      ),
                                    )
                                  : Column(
                                      children: filteredMarket
                                          .map((p) => _buildMarketPlayerCard(context, ref, p, gameState))
                                          .toList(),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      // TAB 2: OYUNCU SATMA (KADRO SATIŞI)
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RetroWindow(
                              title: 'KULÜP TRANSFER VE SATIŞ MERKEZİ',
                              icon: 'tag',
                              child: Row(
                                children: [
                                  const RetroPixelIcon(type: RetroPixelIconType.tag, size: 28, color: AppColors.neonLime),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'KADRONUZDAKİ OYUNCULARI SATIN VE GELİR ELDE EDİN',
                                          style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11),
                                        ),
                                        Text(
                                          'Gözden çıkardığınız oyuncuları piyasa değerinden transfer borsasına sunarak kulüp kasasını doldurun.',
                                          style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            RetroWindow(
                              title: 'SATILABİLİR KADRO OYUNCULARI (${squad.length})',
                              icon: 'cash',
                              titleBarColor: const Color(0xFF005500),
                              child: Column(
                                children: squad.map((p) => _buildSellableSquadPlayerCard(context, ref, p, gameState)).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // TAB 3: KİRALIK PAZARI (§10.5)
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RetroWindow(
                              title: 'KİRALIK OYUNCU BORSASI (LOAN MARKET)',
                              icon: 'handshake',
                              titleBarColor: const Color(0xFF1E3A8A),
                              child: Row(
                                children: [
                                  const RetroPixelIcon(type: RetroPixelIconType.handshake, size: 28, color: AppColors.accentGold),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'BÜYÜK KULÜPLERDEN GENÇ YETENEK KİRALA',
                                          style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 11),
                                        ),
                                        Text(
                                          'Bonservis ödemeden sadece maaş payı ödeyerek 1 sezonluk kiralayın.',
                                          style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            RetroWindow(
                              title: 'KİRALANABİLİR YILDIZ ADAYLARI (${loans.length})',
                              icon: 'star',
                              child: Column(
                                children: loans.map((deal) => _buildLoanDealCard(context, ref, deal, gameState)).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Çok Kriterli Gelişmiş Filtreleme Araç Çubuğu
  Widget _buildAdvancedFilterToolbar(int currentCash) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neoInnerBg,
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mevki Filtre Butonları
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TransferPositionFilter.values.map((filter) {
                final isSelected = _selectedPosition == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: InkWell(
                    onTap: () {
                      AudioSynthesizer.playClick();
                      setState(() => _selectedPosition = filter);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.neonLime : Colors.black,
                        border: Border.all(
                          color: isSelected ? Colors.black : AppColors.win95DarkGrey,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        filter.label,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Sıralama & Bütçe Kontrolleri
          Row(
            children: [
              const Text('Sırala: ', style: TextStyle(color: Colors.white70, fontSize: 10)),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TransferSortOption>(
                      value: _selectedSort,
                      dropdownColor: Colors.black,
                      isExpanded: true,
                      style: const TextStyle(color: AppColors.neonCyan, fontSize: 10),
                      items: TransferSortOption.values.map((opt) {
                        return DropdownMenuItem(
                          value: opt,
                          child: Text(opt.label, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (opt) {
                        if (opt != null) setState(() => _selectedSort = opt);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Bütçeye Uygun Filtresi
              InkWell(
                onTap: () => setState(() => _onlyAffordable = !_onlyAffordable),
                child: Row(
                  children: [
                    Checkbox(
                      value: _onlyAffordable,
                      activeColor: AppColors.neonLime,
                      checkColor: Colors.black,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (v) => setState(() => _onlyAffordable = v ?? false),
                    ),
                    const Text('Kasa Yeten', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDealCard(BuildContext context, WidgetRef ref, LoanDeal deal, dynamic gameState) {
    final p = deal.player;
    final rarityColor = AppColors.getRarityColor(p.stars);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlayerDetailScreen(player: p, isOwned: false),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
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
                  Container(
                    padding: const EdgeInsets.all(6),
                    color: Colors.black,
                    child: Text(p.position.code, style: TextStyle(color: rarityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.fullName, style: AppTypography.label(color: Colors.white).copyWith(fontSize: 12)),
                        Text(
                          'Kulüp: ${deal.parentClubName} • OVR: ${p.ovr} • POT: ${p.potential}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₣${deal.weeklyWageToPay}/h', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11)),
                      Text('(%${(deal.borrowingClubWageShare * 100).round()} Maaş Payı)', style: const TextStyle(color: Colors.white54, fontSize: 9)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Opsiyon: ₣${deal.buyoutClause}', style: const TextStyle(color: AppColors.accentGold, fontSize: 10)),
                  RetroButton(
                    onPressed: () => LoanContractSummaryModal.show(context, deal),
                    backgroundColor: AppColors.neonCyan,
                    textColor: Colors.black,
                    child: const Text('KİRALA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketPlayerCard(BuildContext context, WidgetRef ref, Player p, dynamic gameState, {bool isFreeAgent = false}) {
    final rarityColor = AppColors.getRarityColor(p.stars);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlayerDetailScreen(player: p, isOwned: false),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.neoInnerBg,
            border: Border.all(color: isFreeAgent ? AppColors.neonCyan : Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    color: Colors.black,
                    child: Text(p.position.code, style: TextStyle(color: rarityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(p.fullName, style: AppTypography.label(color: Colors.white).copyWith(fontSize: 12)),
                            if (isFreeAgent) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                color: AppColors.neonCyan,
                                child: const Text('SERBEST', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${p.age} Yaş • ${p.personality.label} • ${p.stars}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: Colors.black,
                    child: Text(
                      '${p.ovr}',
                      style: AppTypography.monoNumber(color: rarityColor).copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isFreeAgent ? 'Bonservis: ₣0 (Serbest)' : 'Piyasa: ₣${p.marketValue}',
                    style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  RetroButton(
                    onPressed: () {
                      final isOpen = (gameState.clock.isTransferWindowOpen as bool);
                      if (!isOpen) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.signalRed,
                            content: Text('[TESCİL KAPALI] ${TransferWindowRules.getWindowStatusLabel(gameState.clock.phase)}. Resmi imza atılamaz!'),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TransferNegotiationScreen(player: p),
                        ),
                      );
                    },
                    backgroundColor: (gameState.clock.isTransferWindowOpen as bool) ? AppColors.neonLime : AppColors.win95DarkGrey,
                    textColor: (gameState.clock.isTransferWindowOpen as bool) ? Colors.black : Colors.white70,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RetroPixelIcon(
                          type: (gameState.clock.isTransferWindowOpen as bool) ? RetroPixelIconType.handshake : RetroPixelIconType.lock,
                          size: 12,
                          color: (gameState.clock.isTransferWindowOpen as bool) ? Colors.black : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (gameState.clock.isTransferWindowOpen as bool) ? 'PAZARLIK YAP' : 'PENCERE KAPALI',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransferWindowBanner(dynamic gameState) {
    final phase = gameState.clock.phase as SeasonPhase;
    final isOpen = gameState.clock.isTransferWindowOpen as bool;
    final squad = gameState.userClub.squad as List<Player>;
    const maxQuota = TransferWindowRules.maxSquadRegistrationLimit;
    final currentRegCount = squad.where((p) => p.age > TransferWindowRules.u21AgeThreshold).length;

    final bannerColor = isOpen ? AppColors.neonLime : AppColors.neonAmber;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFF072212) : const Color(0xFF261904),
        border: Border.all(color: bannerColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    RetroPixelIcon(
                      type: isOpen ? RetroPixelIconType.handshake : RetroPixelIconType.lock,
                      size: 16,
                      color: bannerColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        TransferWindowRules.getWindowStatusLabel(phase).toUpperCase(),
                        style: TextStyle(color: bannerColor, fontWeight: FontWeight.bold, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black,
                child: Text(
                  isOpen ? 'RESMİ TESCİL AÇIK' : 'TESCİL DÖNEMİ KAPALI',
                  style: TextStyle(
                    color: isOpen ? AppColors.neonLime : AppColors.signalRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'A-Takım Kadro Kotası: $currentRegCount/$maxQuota (U21 Sınırsız)',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'Toplam Kadro: ${squad.length} Oyuncu',
                style: const TextStyle(color: Colors.white70, fontSize: 9.5),
              ),
            ],
          ),
          if (!isOpen) ...[
            const SizedBox(height: 4),
            const Text(
              'Bilgi: Lig maçları sürerken tescil dönemi kapalıdır. Yeni oyuncu transferleri devre arası (10. Maç) veya sezon başında tescil edilir.',
              style: TextStyle(color: Colors.white60, fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSellableSquadPlayerCard(BuildContext context, WidgetRef ref, Player p, dynamic gameState) {
    final rarityColor = AppColors.getRarityColor(p.stars);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlayerDetailScreen(player: p, isOwned: true),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.neoInnerBg,
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                color: Colors.black,
                child: Text(p.position.code, style: TextStyle(color: rarityColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.fullName, style: AppTypography.label(color: Colors.white).copyWith(fontSize: 12)),
                    Text('${p.age} Yaş • ${p.ovr} OVR • ₣${p.weeklyWage}/h', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              RetroButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ContractRenewalDialog(
                      player: p,
                      onContractSigned: (newWage, contractWeeks, role, signingBonus) {
                        final seasons = (contractWeeks / 21).round().clamp(1, 5);
                        ref.read(gameStateProvider.notifier).renewPlayerContract(p.id, seasons, newWage);
                      },
                    ),
                  );
                },
                backgroundColor: AppColors.win95TitleNavy,
                textColor: Colors.white,
                child: const Text('SÖZLEŞME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
              ),
              const SizedBox(width: 6),
              RetroButton(
                onPressed: () => PlayerSaleOfferModal.show(context, p, p.marketValue),
                backgroundColor: AppColors.neonLime,
                textColor: Colors.black,
                child: Text('₣${p.marketValue}\nSAT', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
