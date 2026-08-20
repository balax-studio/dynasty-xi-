// presentation/screens/transfer_negotiation_screen.dart
// Dedicated Full-Screen 16-Bit Neo-Brutalist Transfer & Contract Negotiation Desk

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/economy/negotiation_model.dart';
import '../../domain/economy/swap_evaluation_engine.dart';
import '../../domain/entities/player.dart';
import '../widgets/face_avatar_widget.dart';
import '../widgets/grand_signing_ceremony_modal.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';

class TransferNegotiationScreen extends ConsumerStatefulWidget {
  final Player player;

  const TransferNegotiationScreen({
    super.key,
    required this.player,
  });

  @override
  ConsumerState<TransferNegotiationScreen> createState() =>
      _TransferNegotiationScreenState();
}

class _TransferNegotiationScreenState
    extends ConsumerState<TransferNegotiationScreen> {
  late NegotiationState _state;
  late int _offeredFee;
  late int _offeredWage;
  int _contractYears = 3;
  int _signingBonus = 0;
  int _sellOnPercentage = 0;
  int _championshipBonus = 0;
  int _goalBonus = 0;
  Player? _selectedSwapPlayer;
  SwapEvaluationResult? _swapResult;

  @override
  void initState() {
    super.initState();
    _state = NegotiationState.start(player: widget.player);
    _offeredFee = (_state.askingFee * 0.85).round();
    _offeredWage = _state.askingWage;
  }

  void _onSwapPlayerChanged(String? id, List<Player> squad) {
    if (id == null) {
      setState(() {
        _selectedSwapPlayer = null;
        _swapResult = null;
      });
      return;
    }
    final sp = squad.firstWhere((p) => p.id == id);
    final result = SwapEvaluationEngine.evaluate(
      targetPlayer: widget.player,
      swapPlayer: sp,
      offeredCash: _offeredFee,
      askingFee: _state.askingFee,
    );
    setState(() {
      _selectedSwapPlayer = sp;
      _swapResult = result;
    });
  }

  TransferOfferClauses _buildCurrentClauses() {
    return TransferOfferClauses(
      sellOnPercentage: _sellOnPercentage,
      championshipBonus: _championshipBonus,
      goalBonus: _goalBonus,
      swapPlayer: _selectedSwapPlayer,
      contractYears: _contractYears,
      signingBonus: _signingBonus,
    );
  }

  void _submitOffer() {
    AudioSynthesizer.playClick();
    final clauses = _buildCurrentClauses();
    final nextState = _state.submitOffer(
      offeredFee: _offeredFee,
      offeredWage: _offeredWage,
      clauses: clauses,
    );

    setState(() {
      _state = nextState;
      if (nextState.outcome == NegotiationOutcome.counterOffered) {
        _offeredFee = nextState.askingFee;
        _offeredWage = nextState.askingWage;
      }
    });

    if (nextState.outcome == NegotiationOutcome.accepted) {
      AudioSynthesizer.playSuccess();
    } else if (nextState.outcome == NegotiationOutcome.walkedAway) {
      AudioSynthesizer.playFailure();
    }
  }

  void _giveAgentKickback() {
    final currentCash = ref.read(gameStateProvider).valueOrNull?.userClub.meters.cash ?? 0;
    const kickbackCost = 5000;
    if (currentCash < kickbackCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Kasada yeterli bakiye yok! (Gereken: ₣5.000)')),
      );
      return;
    }

    AudioSynthesizer.playMoney();
    ref.read(gameStateProvider.notifier).adjustCash(-kickbackCost);
    setState(() {
      _state = _state.applyAgentKickback(kickbackCost);
      _offeredWage = _state.askingWage;
    });
  }

  Future<void> _finalizeTransfer() async {
    final clauses = _buildCurrentClauses();
    final ok = await ref.read(gameStateProvider.notifier).finalizeTransferWithClauses(
          targetPlayer: widget.player,
          fee: _offeredFee,
          wage: _offeredWage,
          clauses: clauses,
        );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
      GrandSigningCeremonyModal.show(context, widget.player, _offeredFee, _offeredWage);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.signalRed,
          content: Text('⚠️ Yetersiz bakiye veya transfer gerçekleştirilemedi!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);
    final isAccepted = _state.outcome == NegotiationOutcome.accepted;
    final isWalkedAway = _state.outcome == NegotiationOutcome.walkedAway;
    final rarityColor = AppColors.getRarityColor(widget.player.stars);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final squad = gameState.userClub.squad;
        final currentCash = gameState.userClub.meters.cash;
        final totalCashRequired = _offeredFee + _signingBonus;
        final canAfford = currentCash >= totalCashRequired;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
            title: Text(
              'TRANSFER PAZARLIK MASASI: ${widget.player.fullName.toUpperCase()}',
              style: AppTypography.h2(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              MetersBarWidget(meters: gameState.userClub.meters),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Hedef Oyuncu & Temsilci Paneli
                      _buildHeaderDeskCard(rarityColor),
                      const SizedBox(height: 10),

                      // 2. Canlı LED Sabır & Durum Konsolu
                      _buildStatusAndPatienceConsole(),
                      const SizedBox(height: 10),

                      // 3. Mali Teklif Parametreleri (Bonservis & Maaş)
                      if (!isWalkedAway) ...[
                        _buildFinancialOfferWindow(isAccepted, isWalkedAway),
                        const SizedBox(height: 10),

                        // 4. Performans & Gelecek Maddeleri (Clauses & Swap)
                        _buildClausesAndSwapWindow(squad, isAccepted, isWalkedAway),
                        const SizedBox(height: 10),

                        // 5. Menajer Gizli Rüşvet & Komisyon Masası
                        if (!_state.hasPaidAgentKickback && !isAccepted)
                          _buildAgentKickbackCard(currentCash),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Alt Sabit Aksiyon Kontrol Çubuğu
              _buildBottomActionBar(isAccepted, isWalkedAway, canAfford, totalCashRequired),
            ],
          ),
        );
      },
    );
  }

  /// 1. Hedef Oyuncu & Masa Kartı
  Widget _buildHeaderDeskCard(Color rarityColor) {
    final p = widget.player;
    return RetroWindow(
      title: 'TRANSFER MASASI VE HEDEF OYUNCU',
      icon: 'handshake',
      child: Row(
        children: [
          FaceAvatarWidget(seed: p.faceSeed, size: 64),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.fullName.toUpperCase(),
                  style: AppTypography.h1(color: Colors.white).copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.position.label} (${p.position.code}) • ${p.age} Yaş • ${p.ovr} OVR',
                  style: TextStyle(color: rarityColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                Text(
                  'Piyasa Değeri: ₣${p.marketValue} • Mevcut Maaşı: ₣${p.weeklyWage}/h',
                  style: const TextStyle(color: AppColors.neonCyan, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Canlı LED Sabır & Durum Konsolu
  Widget _buildStatusAndPatienceConsole() {
    final patience = _state.currentPatience;
    final patienceColor = patience > 60
        ? AppColors.neonLime
        : patience > 25
            ? AppColors.accentGold
            : AppColors.signalRed;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: patienceColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  RetroPixelIcon(type: RetroPixelIconType.clock, size: 14, color: patienceColor),
                  const SizedBox(width: 6),
                  Text(
                    'KARŞI TARAF SABIR SEVİYESİ',
                    style: TextStyle(color: patienceColor, fontWeight: FontWeight.bold, fontSize: 10.5),
                  ),
                ],
              ),
              Text(
                '%$patience',
                style: AppTypography.monoNumber(color: patienceColor).copyWith(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Segmentli Sabır Çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: patience / 100.0,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(patienceColor),
            ),
          ),
          const SizedBox(height: 8),

          // Durum Mesajı Konsolu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: AppColors.neoInnerBg,
            child: Text(
              _state.statusMessage,
              style: TextStyle(
                color: _state.outcome == NegotiationOutcome.walkedAway
                    ? AppColors.signalRed
                    : _state.outcome == NegotiationOutcome.accepted
                        ? AppColors.neonLime
                        : Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Mali Teklif Parametreleri
  Widget _buildFinancialOfferWindow(bool isAccepted, bool isWalkedAway) {
    final p = widget.player;
    final minFee = (p.marketValue * 0.2).toDouble();
    final maxFee = (p.marketValue * 2.5).toDouble();
    final minWage = (p.weeklyWage * 0.4).toDouble();
    final maxWage = (p.weeklyWage * 3.5).toDouble();

    return RetroWindow(
      title: 'MALİ TEKLİF & SÖZLEŞME ŞARTLARI',
      icon: 'cash',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bonservis Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('BONSERVİS BEDELİ TEKLİFİ', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 11)),
              Text('₣$_offeredFee', style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _offeredFee.toDouble().clamp(minFee, maxFee),
            min: minFee,
            max: maxFee,
            divisions: 25,
            activeColor: AppColors.neonCyan,
            onChanged: isAccepted || isWalkedAway ? null : (v) => setState(() => _offeredFee = v.round()),
          ),
          const SizedBox(height: 4),

          // Haftalık Maaş Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HAFTALIK MAAŞ TEKLİFİ', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold, fontSize: 11)),
              Text('₣$_offeredWage / hafta', style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _offeredWage.toDouble().clamp(minWage, maxWage),
            min: minWage,
            max: maxWage,
            divisions: 30,
            activeColor: AppColors.accentGold,
            onChanged: isAccepted || isWalkedAway ? null : (v) => setState(() => _offeredWage = v.round()),
          ),
          const SizedBox(height: 8),

          // Sözleşme Yılı & İmza Parası Satırı
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SÖZLEŞME SÜRESİ', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      value: _contractYears,
                      dropdownColor: Colors.black,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: [1, 2, 3, 4, 5].map((y) => DropdownMenuItem(value: y, child: Text('$y Sezon', style: const TextStyle(color: Colors.white, fontSize: 11)))).toList(),
                      onChanged: isAccepted || isWalkedAway ? null : (v) => setState(() => _contractYears = v ?? 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('İMZA PARASI', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      value: _signingBonus,
                      dropdownColor: Colors.black,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: [0, 5000, 10000, 20000, 35000].map((b) => DropdownMenuItem(value: b, child: Text(b == 0 ? 'Yok' : '₣$b', style: const TextStyle(color: Colors.white, fontSize: 11)))).toList(),
                      onChanged: isAccepted || isWalkedAway ? null : (v) => setState(() => _signingBonus = v ?? 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 4. Performans & Gelecek Maddeleri
  Widget _buildClausesAndSwapWindow(List<Player> squad, bool isAccepted, bool isWalkedAway) {
    return RetroWindow(
      title: 'PERFORMANS MADDELERİ & OYUNCU TAKASI',
      icon: 'tag',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sonraki Satıştan Pay
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sonraki Satıştan Pay (Sell-on):', style: TextStyle(color: Colors.white70, fontSize: 11)),
              DropdownButton<int>(
                value: _sellOnPercentage,
                dropdownColor: Colors.black,
                items: [0, 10, 20, 30].map((p) => DropdownMenuItem(value: p, child: Text('%$p Pay', style: const TextStyle(color: AppColors.neonLime, fontSize: 11)))).toList(),
                onChanged: isAccepted || isWalkedAway ? null : (v) => setState(() => _sellOnPercentage = v ?? 0),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 12),

          // Şampiyonluk Bonusu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Şampiyonluk Primi:', style: TextStyle(color: Colors.white70, fontSize: 11)),
              DropdownButton<int>(
                value: _championshipBonus,
                dropdownColor: Colors.black,
                items: [0, 10000, 20000, 35000].map((b) => DropdownMenuItem(value: b, child: Text(b == 0 ? 'Yok' : '₣$b Bonus', style: const TextStyle(color: AppColors.accentGold, fontSize: 11)))).toList(),
                onChanged: isAccepted || isWalkedAway ? null : (v) => setState(() => _championshipBonus = v ?? 0),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 12),

          // Kadro Takas Oyuncusu Seçici
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Takasa Oyuncu Ekle:', style: TextStyle(color: Colors.white70, fontSize: 11)),
              DropdownButton<String?>(
                value: _selectedSwapPlayer?.id,
                hint: const Text('Oyuncu Seçilmedi', style: TextStyle(color: Colors.white54, fontSize: 11)),
                dropdownColor: Colors.black,
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('Yok (Sadece Nakit)', style: TextStyle(color: Colors.white70, fontSize: 11))),
                  ...squad.where((p) => p.id != widget.player.id).map(
                        (sp) => DropdownMenuItem<String?>(
                          value: sp.id,
                          child: Text('${sp.fullName} (₣${sp.marketValue})', style: const TextStyle(color: AppColors.neonCyan, fontSize: 11)),
                        ),
                      ),
                ],
                onChanged: isAccepted || isWalkedAway
                    ? null
                    : (id) => _onSwapPlayerChanged(id, squad),
              ),
            ],
          ),
          if (_selectedSwapPlayer != null && _swapResult != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _swapResult!.isAccepted
                    ? const Color(0xFF003300)
                    : (_swapResult!.isCounterOffer ? const Color(0xFF332200) : const Color(0xFF330000)),
                border: Border.all(
                  color: _swapResult!.isAccepted
                      ? AppColors.neonLime
                      : (_swapResult!.isCounterOffer ? AppColors.accentGold : AppColors.comicRed),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RetroPixelIcon(
                        type: _swapResult!.isAccepted
                            ? RetroPixelIconType.handshake
                            : (_swapResult!.isCounterOffer ? RetroPixelIconType.briefcase : RetroPixelIconType.cross),
                        size: 14,
                        color: _swapResult!.isAccepted
                            ? AppColors.neonLime
                            : (_swapResult!.isCounterOffer ? AppColors.accentGold : AppColors.comicRed),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _swapResult!.status.title,
                        style: TextStyle(
                          color: _swapResult!.isAccepted
                              ? AppColors.neonLime
                              : (_swapResult!.isCounterOffer ? AppColors.accentGold : AppColors.comicRed),
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _swapResult!.responseMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 9.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 5. Menajere Gizli Komisyon & Rüşvet Kartı
  Widget _buildAgentKickbackCard(int currentCash) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1500),
        border: Border.all(color: AppColors.accentGold, width: 1.5),
      ),
      child: Row(
        children: [
          const RetroPixelIcon(type: RetroPixelIconType.suit, size: 28, color: AppColors.accentGold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MENAJERE EL ALTINDAN KOMİSYON',
                  style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                const Text(
                  '₣5.000 gizli prim vererek menajerin sabrını +%30 yenileyin ve oyuncunun maaş talebini %18 indirin.',
                  style: TextStyle(color: Colors.white70, fontSize: 9.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RetroButton(
            onPressed: currentCash >= 5000 ? _giveAgentKickback : null,
            backgroundColor: currentCash >= 5000 ? AppColors.accentGold : AppColors.win95DarkGrey,
            textColor: Colors.black,
            child: const Text('₣5K VER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  /// Alt Sabit Aksiyon Kontrol Çubuğu
  Widget _buildBottomActionBar(bool isAccepted, bool isWalkedAway, bool canAfford, int totalCashRequired) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.neoCardBg,
        border: Border(top: BorderSide(color: Colors.white24, width: 2)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: RetroButton(
                onPressed: () {
                  AudioSynthesizer.playClick();
                  Navigator.of(context).pop();
                },
                backgroundColor: AppColors.win95DarkGrey,
                textColor: Colors.white,
                child: const Text('MASADAN KALK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ),
            const SizedBox(width: 8),
            if (!isAccepted && !isWalkedAway)
              Expanded(
                flex: 3,
                child: RetroButton(
                  onPressed: _submitOffer,
                  backgroundColor: AppColors.neonCyan,
                  textColor: Colors.black,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RetroPixelIcon(type: RetroPixelIconType.handshake, size: 14, color: Colors.black),
                      SizedBox(width: 4),
                      Text('TEKLİFİ SUN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              )
            else if (isAccepted)
              Expanded(
                flex: 3,
                child: RetroButton(
                  onPressed: canAfford ? _finalizeTransfer : null,
                  backgroundColor: canAfford ? AppColors.neonLime : AppColors.win95DarkGrey,
                  textColor: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const RetroPixelIcon(type: RetroPixelIconType.pen, size: 14, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        canAfford ? 'TRANSFERİ BİTİR (₣$totalCashRequired)' : 'YETERSİZ BAKİYE',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
