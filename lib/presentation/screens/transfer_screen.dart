// presentation/screens/transfer_screen.dart
// Transfer market listing, interactive negotiation dialog with patience meter, Loan Market tab, and Agent fees (§10).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/economy/negotiation_model.dart';
import '../../domain/economy/transfer_models.dart';
import '../../domain/entities/player.dart';
import 'player_detail_screen.dart';
import '../widgets/contract_renewal_dialog.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import 'transfer_hijack_screen.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, ref, _) {
        final stateAsync = ref.watch(gameStateProvider);

        return stateAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
          data: (gameState) {
            final market = gameState.transferMarket;
            final squad = gameState.userClub.squad;
            final loans = LoanMarketGenerator.generateLoanCandidates();

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
                      Tab(icon: Icon(Icons.shopping_cart), text: 'TRANSFER PAZARI'),
                      Tab(icon: Icon(Icons.sell), text: 'SATIŞ LİSTESİ'),
                      Tab(icon: Icon(Icons.handshake), text: 'KİRALIK PAZARI'),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    MetersBarWidget(meters: gameState.userClub.meters),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // TAB 1: OYUNCU ALMA (PAZAR)
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 0. Transfer Çalımı Butonu
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
                                        Text('✈️', style: TextStyle(fontSize: 16)),
                                        SizedBox(width: 6),
                                        Text('SON DAKİKA TRANSFER ÇALIMI & OTEL BASKINI MASASI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                RetroWindow(
                                  title: 'SCOUT BİLGİ VE İSTİHBARAT AKIŞI',
                                  icon: '🛰️',
                                  child: Row(
                                    children: [
                                      const Text('📡', style: TextStyle(fontSize: 26)),
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
                                              'Piyasadaki yıldızlarla ve scout keşifleriyle doğrudan masaya oturup pazarlık yapın.',
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
                                  title: 'SATIN ALINABİLİR OYUNCULAR (${market.length})',
                                  icon: '💼',
                                  titleBarColor: AppColors.neoCardBg,
                                  child: market.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Center(
                                            child: Text('ŞU AN PİYASADA OYUNCU BULUNAMADI.', style: AppTypography.label(color: Colors.white)),
                                          ),
                                        )
                                      : Column(
                                          children: market.map((p) => _buildMarketPlayerCard(context, ref, p, gameState)).toList(),
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
                                  icon: '💸',
                                  child: Row(
                                    children: [
                                      const Text('🏷️', style: TextStyle(fontSize: 26)),
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
                                  icon: '💰',
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
                                  icon: '🤝',
                                  titleBarColor: const Color(0xFF1E3A8A),
                                  child: Row(
                                    children: [
                                      const Text('📑', style: TextStyle(fontSize: 26)),
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
                                  icon: '🌟',
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
      },
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
                    onPressed: () async {
                      final ok = await ref.read(gameStateProvider.notifier).buyPlayer(p, 0, deal.weeklyWageToPay);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(ok ? '🎉 ${p.fullName} 1 sezonluğuna kiralandı!' : '⚠️ Kiralama başarısız oldu.')),
                        );
                      }
                    },
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

  Widget _buildMarketPlayerCard(BuildContext context, WidgetRef ref, Player p, dynamic gameState) {
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
                          '${p.age} Yaş • ${p.personality.label} • ${p.stars}★',
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
                  Text('Piyasa: ₣${p.marketValue}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11)),
                  Row(
                    children: [
                      RetroButton(
                        onPressed: () {
                          _showSwapPlayerModal(context, ref, p, gameState);
                        },
                        backgroundColor: AppColors.accentGold,
                        textColor: Colors.black,
                        child: const Text('TAKAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                      const SizedBox(width: 6),
                      RetroButton(
                        onPressed: () {
                          _showNegotiationModal(context, ref, p, gameState);
                        },
                        backgroundColor: AppColors.neonLime,
                        textColor: Colors.black,
                        child: const Text('PAZARLIK YAP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✍️ ${p.fullName} ile sözleşme yenilendi!')),
                        );
                      },
                    ),
                  );
                },
                backgroundColor: AppColors.neonCyan,
                textColor: Colors.black,
                child: const Text('SÖZLEŞME', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
              ),
              const SizedBox(width: 4),
              RetroButton(
                onPressed: () async {
                  final ok = await ref.read(gameStateProvider.notifier).sellPlayer(p, p.marketValue);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ok ? '💰 ${p.fullName} ₣${p.marketValue} bedelle satıldı!' : '⚠️ Satış başarısız: Minimum kadro şartı.')),
                    );
                  }
                },
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

  void _showSwapPlayerModal(BuildContext context, WidgetRef ref, Player targetPlayer, dynamic gameState) {
    final squad = gameState.userClub.squad as List<Player>;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.neoCardBg,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TAKAS TEKLİFİ: ${targetPlayer.fullName.toUpperCase()}', style: AppTypography.h2(color: AppColors.accentGold)),
              const SizedBox(height: 4),
              Text('Takas etmek için kulübünüzden bir oyuncu seçin (Piyasa: ₣${targetPlayer.marketValue}):', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: squad.length,
                  itemBuilder: (context, idx) {
                    final sp = squad[idx];
                    final diff = targetPlayer.marketValue - sp.marketValue;
                    return Card(
                      color: AppColors.neoInnerBg,
                      child: ListTile(
                        leading: Text(sp.position.code, style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                        title: Text(sp.fullName, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        subtitle: Text('${sp.ovr} OVR • ₣${sp.marketValue} Değer • Fark: ₣${diff > 0 ? "+$diff" : "$diff"}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        trailing: RetroButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final cashDiff = diff > 0 ? diff : 0;
                            final ok = await ref.read(gameStateProvider.notifier).swapPlayerTransfer(sp, targetPlayer, cashDiff);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(ok ? '🤝 Takas tamamlandı! ${sp.fullName} verildi, ${targetPlayer.fullName} alındı.' : '⚠️ Yetersiz nakit bakiye!')),
                              );
                            }
                          },
                          backgroundColor: AppColors.accentGold,
                          textColor: Colors.black,
                          child: const Text('TAKAS ET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNegotiationModal(BuildContext context, WidgetRef ref, Player p, dynamic gameState) {
    var state = NegotiationState.start(player: p);
    int offerFee = (p.marketValue * 0.85).round();
    int offerWage = p.weeklyWage;
    final agentFee = (p.marketValue * 0.08).round();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.neoCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isAccepted = state.outcome == NegotiationOutcome.accepted;
            final isWalkedAway = state.outcome == NegotiationOutcome.walkedAway;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TRANSFER PAZARLIĞI: ${p.fullName.toUpperCase()}', style: AppTypography.h2(color: AppColors.neonLime)),
                    const SizedBox(height: 4),
                    Text(
                      'Piyasa: ₣${p.marketValue} • İstenen: ₣${state.askingFee} Bonservis / ₣${state.askingWage}/h • Sabır: %${state.currentPatience}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 12),

                    // Bonservis Teklif Slider
                    Text('Bonservis Teklifi: ₣$offerFee', style: const TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                    Slider(
                      value: offerFee.toDouble().clamp((p.marketValue * 0.3), (p.marketValue * 2.0)),
                      min: (p.marketValue * 0.3).toDouble(),
                      max: (p.marketValue * 2.0).toDouble(),
                      divisions: 24,
                      activeColor: AppColors.neonCyan,
                      onChanged: isAccepted || isWalkedAway
                          ? null
                          : (val) {
                              setModalState(() => offerFee = val.round());
                            },
                    ),

                    // Maaş Teklif Slider
                    Text('Haftalık Maaş Teklifi: ₣$offerWage', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 12)),
                    Slider(
                      value: offerWage.toDouble().clamp((p.weeklyWage * 0.5), (p.weeklyWage * 3.0)),
                      min: (p.weeklyWage * 0.5).toDouble(),
                      max: (p.weeklyWage * 3.0).toDouble(),
                      divisions: 20,
                      activeColor: AppColors.neonLime,
                      onChanged: isAccepted || isWalkedAway
                          ? null
                          : (val) {
                              setModalState(() => offerWage = val.round());
                            },
                    ),

                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isAccepted
                            ? const Color(0xFF0B2E20)
                            : isWalkedAway
                                ? const Color(0xFF2E0B0B)
                                : const Color(0xFF1E293B),
                        border: Border.all(
                          color: isAccepted
                              ? AppColors.neonLime
                              : isWalkedAway
                                  ? AppColors.comicRed
                                  : AppColors.neonCyan,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(isAccepted ? '✅ ' : isWalkedAway ? '❌ ' : '💬 ', style: const TextStyle(fontSize: 18)),
                          Expanded(
                            child: Text(
                              state.statusMessage,
                              style: TextStyle(
                                color: isAccepted
                                    ? AppColors.neonLime
                                    : isWalkedAway
                                        ? AppColors.comicRed
                                        : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('MASADAN KALK', style: TextStyle(color: Colors.white54)),
                        ),
                        const SizedBox(width: 8),
                        if (!isAccepted && !isWalkedAway)
                          RetroButton(
                            onPressed: () {
                              setModalState(() {
                                state = state.submitOffer(offeredFee: offerFee, offeredWage: offerWage);
                              });
                            },
                            backgroundColor: AppColors.neonCyan,
                            textColor: Colors.black,
                            child: const Text('TEKLİFİ SUN'),
                          )
                        else if (isAccepted)
                          RetroButton(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              final totalCost = offerFee + agentFee;
                              final ok = await ref.read(gameStateProvider.notifier).buyPlayer(p, totalCost, offerWage);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok
                                          ? '🎉 Transfer Başarılı! ${p.fullName} kulübe katıldı (Maliyet: ₣$totalCost).'
                                          : '⚠️ Yetersiz bakiye!',
                                    ),
                                  ),
                                );
                              }
                            },
                            backgroundColor: AppColors.neonLime,
                            textColor: Colors.black,
                            child: const Text('İMZALAT (ANLAŞILDI)'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
