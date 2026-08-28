// presentation/screens/finance_screen.dart
// Comprehensive Cyber-Retro Football Club Finance & Treasury Screen (§15.1, §15.2, §15.3, §A.7)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/economy/financial_statement.dart';
import '../../domain/economy/sponsorship_contract.dart';
import '../../domain/entities/game_state.dart';
import '../widgets/brutalist_icons.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_impact_confirm_modal.dart';
import '../widgets/retro_window.dart';
import '../widgets/tax_audit_inspection_modal.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  int? _simulatedTicketPrice;
  SponsorshipSlot _selectedSponsorSlot = SponsorshipSlot.mainShirt;

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Hata: $err', style: AppTypography.body())),
      ),
      data: (gameState) {
        final club = gameState.userClub;
        final currentTicketPrice = _simulatedTicketPrice ?? club.ticketPrice;
        final simulatedClub = club.copyWith(ticketPrice: currentTicketPrice);

        int sleeveIncome = gameState.sleeveSponsorIncome;
        int stadiumIncome = gameState.stadiumNamingIncome;
        final sleeveContract = gameState.activeSponsorships[SponsorshipSlot.sleeve];
        if (sleeveContract != null) sleeveIncome = sleeveContract.weeklyIncome;
        final stadiumContract = gameState.activeSponsorships[SponsorshipSlot.stadiumNaming];
        if (stadiumContract != null) stadiumIncome = stadiumContract.weeklyIncome;

        final statement = FinancialStatementCalculator.calculateWeeklyStatement(
          club: simulatedClub,
          sleeveSponsorIncome: sleeveIncome,
          stadiumNamingIncome: stadiumIncome,
          activeLoanWeeklyRepayment: gameState.activeLoan?.weeklyPayment ?? 0,
          treasuryDeposit: gameState.treasuryDeposit,
        );

        final ffpReport = FinancialStatementCalculator.evaluateFfp(
          totalWeeklyWages: club.totalWeeklyWages,
          totalWeeklyIncome: statement.totalIncome,
        );

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
            elevation: 0,
            title: Row(
              children: [
                const Text('[KASA]', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KULÜP FİNANS & BORSA MERKEZİ',
                        style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 13),
                      ),
                      Text(
                        'HAFTALIK NAKİT AKIŞI VE BÜTÇE YÖNETİMİ',
                        style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // 1. 4 Göstergeli Windows 95 LED Üst Bar
              MetersBarWidget(meters: club.meters),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Haftalık Bilanço & Nakit Akışı Paneli
                      _buildCashflowLedger(statement, club.meters.cash),
                      const SizedBox(height: 10),

                      // 2. Finansal Fair Play (FFP) Radarı
                      _buildFfpRadarWindow(ffpReport),
                      const SizedBox(height: 10),

                      // 2.5. Maliye Müfettişi Vergi Denetimi Butonu
                      RetroButton(
                        onPressed: () => TaxAuditInspectionModal.show(context),
                        backgroundColor: AppColors.comicRed,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BrutalistIcon(BrutalistIconType.audit, size: 14, color: Colors.white),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'MALİYE MÜFETTİŞİ VE VERGİ DENETİM MASASI',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3. Maç Günü & Bilet Fiyatı Simülatörü
                      _buildTicketPricingSimulator(club, currentTicketPrice),
                      const SizedBox(height: 10),

                      // 4. 3-Slot Sponsorluk Masası
                      _buildSponsorshipNegotiationDesk(gameState, club.leagueTier),
                      const SizedBox(height: 10),

                      // 5. Banka Kredileri & Borç Yönetimi
                      _buildBankLoansWindow(gameState, club.meters.cash),
                      const SizedBox(height: 10),

                      // 6. Kulüp Hazinesi & Vadeli Mevduat Hesabı
                      _buildTreasuryDepositWindow(gameState, club.meters.cash),
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

  /// 1. Haftalık Bilanço ve Nakit Akışı Penceresi
  Widget _buildCashflowLedger(FinancialStatement statement, int clubCash) {
    final isProfitable = statement.netProfitOrLoss >= 0;

    return RetroWindow(
      title: 'HAFTALIK GELİR-GİDER BİLANÇOSU (LEDGER.DAT)',
      icon: '',
      titleBarColor: AppColors.win95TitleNavy,
      child: Column(
        children: [
          // Kasa & Net Kâr Banner'ı
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: isProfitable ? AppColors.neonLime : AppColors.comicRed,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('KULÜP KASASI', style: TextStyle(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(
                      '₣$clubCash',
                      style: AppTypography.monoNumber(
                        color: clubCash >= 0 ? AppColors.neonLime : AppColors.comicRed,
                      ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(height: 30, width: 1.5, color: Colors.white24),
                Column(
                  children: [
                    const Text('HAFTALIK NET AKIŞ', style: TextStyle(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(
                      isProfitable ? '+₣${statement.netProfitOrLoss}' : '-₣${statement.netProfitOrLoss.abs()}',
                      style: AppTypography.monoNumber(
                        color: isProfitable ? AppColors.neonLime : AppColors.comicRed,
                      ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Gelirler ve Giderler Tablosu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gelirler Sütunu
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1812),
                    border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('[GELİR]', style: TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Text('GELİRLER (₣${statement.totalIncome})', style: const TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 8),
                      _buildLedgerRow('Bilet Satışı', statement.ticketIncome, AppColors.neonLime),
                      _buildLedgerRow('Ana Sponsor', statement.mainSponsorIncome, AppColors.neonLime),
                      _buildLedgerRow('Kol Sponsoru', statement.sleeveSponsorIncome, AppColors.neonLime),
                      _buildLedgerRow('Stadyum İsmi', statement.stadiumNamingIncome, AppColors.neonLime),
                      _buildLedgerRow('Fan Shop / Mağaza', statement.fanShopIncome, AppColors.neonLime),
                      if (statement.treasuryInterestIncome > 0)
                        _buildLedgerRow('Mevduat Faizi', statement.treasuryInterestIncome, AppColors.neonCyan),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Giderler Sütunu
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1014),
                    border: Border.all(color: AppColors.comicRed.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('[GİDER]', style: TextStyle(color: AppColors.comicRed, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Text('GİDERLER (₣${statement.totalExpenses})', style: const TextStyle(color: AppColors.comicRed, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 8),
                      _buildLedgerRow('Futbolcu Maaşları', statement.playerWagesExpense, AppColors.comicRed),
                      _buildLedgerRow('12 Tesis Bakımı', statement.facilityUpkeepExpense, AppColors.comicRed),
                      _buildLedgerRow('Kredi Taksiti', statement.loanRepaymentExpense, AppColors.comicRed),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerRow(String label, int amount, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), overflow: TextOverflow.ellipsis),
          ),
          Text(
            '₣$amount',
            style: AppTypography.monoNumber(color: amountColor).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 2. Finansal Fair Play (FFP) Radarı
  Widget _buildFfpRadarWindow(FfpReport ffp) {
    Color riskColor;
    switch (ffp.riskLevel) {
      case FfpRiskLevel.safe:
        riskColor = AppColors.neonLime;
        break;
      case FfpRiskLevel.warning:
        riskColor = AppColors.neonAmber;
        break;
      case FfpRiskLevel.critical:
        riskColor = AppColors.comicRed;
        break;
    }

    final ratioPercent = (ffp.wageToIncomeRatio * 100).toStringAsFixed(1);

    return RetroWindow(
      title: 'UEFA & FEDERASYON FİNANSAL FAIR PLAY (FFP) RADARI',
      icon: 'SHIELD',
      titleBarColor: AppColors.win95TitleNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black,
                child: Text(
                  ffp.riskLevel.label,
                  style: TextStyle(color: riskColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              const Text('Maaş / Gelir Rasyosu: ', style: TextStyle(color: Colors.white70, fontSize: 10)),
              Text(
                '%$ratioPercent',
                style: AppTypography.monoNumber(color: riskColor).copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (ffp.wageToIncomeRatio / 1.0).clamp(0.0, 1.0),
              backgroundColor: Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(riskColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ffp.recommendation,
            style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  /// 3. Maç Günü & Bilet Fiyatı Simülatörü
  Widget _buildTicketPricingSimulator(dynamic club, int currentPrice) {
    final capacity = club.stadiumCapacity;
    final fanRatio = (club.meters.fans / 100.0).clamp(0.2, 1.0);
    // Bilet fiyatı çok yükselirse doluluk çarpanı düşer
    final priceImpactFactor = (1.0 - (currentPrice - 20) * 0.02).clamp(0.4, 1.15);
    final simulatedAttendance = (capacity * fanRatio * priceImpactFactor).round().clamp(0, capacity);
    final estimatedMatchdayIncome = (simulatedAttendance * currentPrice) as int;
    final occupancyPercent = ((simulatedAttendance / (capacity == 0 ? 1 : capacity)) * 100).toStringAsFixed(1);

    String fanReaction;
    Color reactionColor;
    if (currentPrice < 15) {
      fanReaction = ' Halk Tipi / Ucuz Bilet (Taraftar Çok Mutlu)';
      reactionColor = AppColors.neonLime;
    } else if (currentPrice <= 30) {
      fanReaction = '[HUKUK] Dengeli Fiyatlandırma (Optimum Hasılat)';
      reactionColor = AppColors.neonCyan;
    } else if (currentPrice <= 42) {
      fanReaction = '[UYARI] Pahalı Bilet (Seyirci Sayısı Düşüyor)';
      reactionColor = AppColors.neonAmber;
    } else {
      fanReaction = '[ACIL] Fahiş Fiyat! (Tribünler Boş Kalıyor, Taraftar Öfkeli)';
      reactionColor = AppColors.comicRed;
    }

    return RetroWindow(
      title: 'MAÇ GÜNÜ BİLET VE HASILAT SİMÜLATÖRÜ',
      icon: '',
      titleBarColor: AppColors.win95TitleNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BİLET FİYATI: ₣$currentPrice / maç', style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11)),
              Text('Doluluk: %$occupancyPercent', style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.neonLime,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.comicYellow,
              overlayColor: AppColors.neonLime.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: currentPrice.toDouble(),
              min: 5,
              max: 50,
              divisions: 45,
              onChanged: (val) {
                setState(() {
                  _simulatedTicketPrice = val.round();
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('TAHMİNİ SEYİRCİ', style: TextStyle(color: Colors.white60, fontSize: 9)),
                    Text('$simulatedAttendance / $capacity', style: AppTypography.monoNumber(color: Colors.white).copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(height: 24, width: 1, color: Colors.white24),
                Column(
                  children: [
                    const Text('MAÇ BAŞI HASILAT', style: TextStyle(color: Colors.white60, fontSize: 9)),
                    Text('₣$estimatedMatchdayIncome', style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(fanReaction, style: TextStyle(color: reactionColor, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_simulatedTicketPrice != null && _simulatedTicketPrice != club.ticketPrice)
            SizedBox(
              width: double.infinity,
              child: RetroButton(
                isNeon: true,
                onPressed: () async {
                  await ref.read(gameStateProvider.notifier).setTicketPrice(_simulatedTicketPrice!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.neonLime,
                        content: Text(' Bilet fiyatı ₣$_simulatedTicketPrice olarak güncellendi!', style: const TextStyle(color: Colors.black)),
                      ),
                    );
                  }
                },
                backgroundColor: AppColors.neonLime,
                textColor: Colors.black,
                child: const Text('FİYATI ONAYLA VE KAYDET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
        ],
      ),
    );
  }

  /// 4. 3-Slot Sponsorluk Masası & Süreli RPG Sözleşmeleri
  Widget _buildSponsorshipNegotiationDesk(dynamic rawGameState, int leagueTier) {
    final gameState = rawGameState is GameState ? rawGameState : null;
    final activeSponsorships = gameState?.activeSponsorships ?? const <SponsorshipSlot, SponsorshipContract>{};
    final contracts = SponsorshipCatalog.getAvailableContracts(leagueTier)
        .where((c) => c.slot == _selectedSponsorSlot)
        .toList();

    return RetroWindow(
      title: '3-SLOT SPONSORLUK MASASI & RPG SÖZLEŞMELERİ',
      icon: '',
      titleBarColor: AppColors.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A. Aktif Sözleşmeler Mini Paneli (3 Slot)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('[RAPOR]', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 6),
                    Text(
                      'AKTİF SPONSORLUK PROTOKOLLERİ (SLOT DURUMU)',
                      style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: SponsorshipSlot.values.map((slot) {
                    final active = activeSponsorships[slot];
                    final isOccupied = active != null && !active.isExpired;

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isOccupied ? AppColors.neoInnerBg : const Color(0xFF1E293B).withValues(alpha: 0.5),
                          border: Border.all(
                            color: isOccupied ? AppColors.neonLime.withValues(alpha: 0.6) : Colors.white12,
                            width: isOccupied ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${slot.icon} ${slot.label.split(" ").first}', style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                                if (isOccupied)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(color: AppColors.neonLime, borderRadius: BorderRadius.circular(2)),
                                    child: Text('${active.weeksRemaining} Hf', style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                                  )
                                else
                                  const Text('BOŞ', style: TextStyle(color: Colors.white30, fontSize: 8, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (isOccupied) ...[
                              Text(
                                active.brandName,
                                style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '+₣${active.weeklyIncome}/hf',
                                style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: double.infinity,
                                height: 22,
                                child: RetroButton(
                                  onPressed: () {
                                    RetroImpactConfirmModal.show(
                                      context,
                                      title: 'SÖZLEŞMEYİ FESHET',
                                      actionTitle: active.brandName,
                                      description: '${slot.label} anlaşmasını tek taraflı erken feshetmek istiyor musunuz?',
                                      cashDelta: -active.risk.earlyTerminationPenalty,
                                      weeklyWageDelta: active.weeklyIncome,
                                      boardTrustDelta: -2,
                                      confirmButtonText: 'ERKEN FESHET (-₣${active.risk.earlyTerminationPenalty})',
                                      confirmButtonColor: AppColors.comicRed,
                                      onConfirmed: () async {
                                        final ok = await ref.read(gameStateProvider.notifier).terminateSponsorshipContract(slot);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: ok ? AppColors.comicRed : Colors.orange,
                                              content: Text(
                                                ok
                                                    ? '[UYARI] ${active.brandName} sözleşmesi feshedildi. Slot boşa çıktı.'
                                                    : '[RED] Fesih tazminatı için kasada yeterli nakit yok!',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                  backgroundColor: AppColors.comicRed,
                                  textColor: Colors.white,
                                  child: const Text('FESHET', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ] else ...[
                              const Text('Sözleşme Yok', style: TextStyle(color: Colors.white30, fontSize: 9.5)),
                              const Text('0 ₣/hf', style: TextStyle(color: Colors.white24, fontSize: 9)),
                              const SizedBox(height: 4),
                              const Text('Teklif Seçin ⬇', style: TextStyle(color: AppColors.accentGold, fontSize: 8)),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // B. Slot Seçici Butonları
          Row(
            children: SponsorshipSlot.values.map((slot) {
              final isSelected = _selectedSponsorSlot == slot;
              final isOccupied = activeSponsorships[slot] != null && !activeSponsorships[slot]!.isExpired;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: RetroButton(
                    onPressed: () {
                      setState(() {
                        _selectedSponsorSlot = slot;
                      });
                    },
                    backgroundColor: isSelected ? AppColors.accentGold : const Color(0xFF1E293B),
                    textColor: isSelected ? Colors.black : Colors.white,
                    child: Text(
                      '${slot.icon} ${slot.label.split(" ").first.toUpperCase()}${isOccupied ? " (DOLU)" : ""}',
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : (isOccupied ? Colors.white70 : Colors.white),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // C. Müsait Teklifler Listesi
          if (contracts.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              child: const Text('Bu slot için şu an açık teklif bulunmuyor.', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ),

          ...contracts.map((contract) {
            final isSlotOccupied = activeSponsorships[contract.slot] != null && !activeSponsorships[contract.slot]!.isExpired;
            final isThisBrandActive = activeSponsorships[contract.slot]?.id == contract.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.neoInnerBg,
                border: Border.all(
                  color: isThisBrandActive
                      ? AppColors.neonLime
                      : (isSlotOccupied ? Colors.white12 : AppColors.accentGold.withValues(alpha: 0.4)),
                  width: isThisBrandActive ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Marka Başlığı & Kategori & Süre
                  Row(
                    children: [
                      Text(contract.brandIcon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  contract.brandName,
                                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(contract.sector, style: const TextStyle(color: Colors.white70, fontSize: 8)),
                                ),
                              ],
                            ),
                            Text(contract.sector, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text('[SURE] ${contract.durationWeeks} Hf', style: const TextStyle(color: AppColors.accentGold, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 2. Finansal Akışlar (Haftalık & Peşin İmza)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F1D),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('Haftalık:', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                            const SizedBox(width: 4),
                            Text('+₣${contract.weeklyIncome}/hf', style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('İmza Parası:', style: TextStyle(color: Colors.white60, fontSize: 9.5)),
                            const SizedBox(width: 4),
                            Text('+₣${contract.signingBonus}', style: const TextStyle(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. RPG Artı Perk (+) & Eksi Risk (-) Çipleri
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Perk (+)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B).withValues(alpha: 0.3),
                            border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text('[YEŞİL]', style: TextStyle(fontSize: 8)),
                                  SizedBox(width: 4),
                                  Text(
                                    'AVANTAJ (+)',
                                    style: TextStyle(color: AppColors.neonLime, fontSize: 8.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                contract.perk.description,
                                style: const TextStyle(color: Colors.white70, fontSize: 8.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Risk (-)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F1D1D).withValues(alpha: 0.3),
                            border: Border.all(color: AppColors.comicRed.withValues(alpha: 0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text('[KIRMIZI]', style: TextStyle(fontSize: 8)),
                                  SizedBox(width: 4),
                                  Text(
                                    'RİSK / BEDEL (-)',
                                    style: TextStyle(color: AppColors.comicRed, fontSize: 8.5, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                contract.risk.description,
                                style: const TextStyle(color: Colors.white70, fontSize: 8.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 4. Aksiyon Butonu (İncele & İmzala)
                  SizedBox(
                    width: double.infinity,
                    child: isSlotOccupied
                        ? (isThisBrandActive
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.neonLime.withValues(alpha: 0.15),
                                  border: Border.all(color: AppColors.neonLime),
                                ),
                                child: const Text(
                                  ' ŞU ANDA AKTİF SÖZLEŞME',
                                  style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Text(
                                  'SLOT DOLU (Önce mevcut sözleşmeyi feshedin)',
                                  style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 9.5),
                                ),
                              ))
                        : RetroButton(
                            onPressed: () {
                              final totalFan = contract.perk.fanDelta + contract.risk.fanDelta;
                              final totalTrust = contract.perk.boardTrustDelta + contract.risk.boardTrustDelta;
                              final totalLocker = contract.perk.lockerRoomDelta;

                              RetroImpactConfirmModal.show(
                                context,
                                title: 'SPONSORLUK SÖZLEŞMESİ',
                                actionTitle: contract.brandName,
                                description: '${contract.slot.label} için ${contract.durationWeeks} haftalık resmi sponsorluk protokolü',
                                cashDelta: contract.signingBonus,
                                weeklyWageDelta: -contract.weeklyIncome,
                                fanDelta: totalFan,
                                boardTrustDelta: totalTrust,
                                moraleDelta: totalLocker,
                                confirmButtonText: 'SÖZLEŞMEYİ ONAYLA (+₣${contract.signingBonus})',
                                confirmButtonColor: AppColors.neonLime,
                                onConfirmed: () async {
                                  final success = await ref.read(gameStateProvider.notifier).signSponsorshipContract(contract);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: success ? AppColors.neonLime : AppColors.comicRed,
                                        content: Text(
                                          success
                                              ? '[KUTLAMA] ${contract.brandName} ile resmi sponsorluk imzalandı (+₣${contract.signingBonus} kasaya eklendi)!'
                                              : '[RED] Bu slot için zaten aktif bir sözleşmeniz var!',
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            backgroundColor: AppColors.neonLime,
                            textColor: Colors.black,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('[İMZA]', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 6),
                                Text(
                                  'SÖZLEŞMEYİ İNCELE VE İMZALA (+₣${contract.signingBonus} PEŞİN)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 5. Banka Kredileri & Borç Yönetimi
  Widget _buildBankLoansWindow(dynamic gameState, int clubCash) {
    final activeLoan = gameState.activeLoan as BankLoan?;
    final packages = FinancialStatementCalculator.getAvailableLoanPackages();

    return RetroWindow(
      title: 'BANKA KREDİLERİ VE BORÇ YÖNETİMİ',
      icon: '',
      titleBarColor: AppColors.win95TitleNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeLoan != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1014),
                border: Border.all(color: AppColors.comicRed, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('[ACIL] AKTİF BANKA KREDİSİ BORCU', style: TextStyle(color: AppColors.comicRed, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Kalan Hafta: ${activeLoan.remainingWeeks} / ${activeLoan.totalWeeks}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kalan Toplam Borç: ₣${activeLoan.remainingDebt}', style: AppTypography.monoNumber(color: Colors.white).copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Taksit: ₣${activeLoan.weeklyPayment}/h', style: AppTypography.monoNumber(color: AppColors.comicRed).copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: RetroButton(
                      onPressed: clubCash >= activeLoan.earlyRepaymentDiscountedAmount
                          ? () async {
                              final ok = await ref.read(gameStateProvider.notifier).repayBankLoanEarly();
                              if (mounted && ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: AppColors.neonLime,
                                    content: Text('[KUTLAMA] Kredi erken kapatıldı! Kulüp tüm borçlarından kurtuldu.', style: TextStyle(color: Colors.black)),
                                  ),
                                );
                              }
                            }
                          : null,
                      backgroundColor: clubCash >= activeLoan.earlyRepaymentDiscountedAmount ? AppColors.neonLime : Colors.grey,
                      textColor: Colors.black,
                      child: Text('ERKEN KAPAT (₣${activeLoan.earlyRepaymentDiscountedAmount} - %5 İndirimli)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text('Kulübün şu an aktif bir kredi borcu yok. Yatırım için aşağıdaki paketlerden yararlanabilirsiniz:', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
            const SizedBox(height: 8),
            ...packages.map((pkg) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.neoInnerBg,
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Text(pkg.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pkg.name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text(pkg.description, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                          const SizedBox(height: 2),
                          Text('Nakit: +₣${pkg.principalAmount} • Taksit: ₣${pkg.weeklyPayment} × ${pkg.totalWeeks} hafta', style: const TextStyle(color: AppColors.neonLime, fontSize: 9.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    RetroButton(
                      onPressed: () async {
                        final ok = await ref.read(gameStateProvider.notifier).takeBankLoanPackage(pkg);
                        if (mounted && ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.neonLime,
                              content: Text(' ₣${pkg.principalAmount} kredi kasaya eklendi!', style: const TextStyle(color: Colors.black)),
                            ),
                          );
                        }
                      },
                      backgroundColor: AppColors.neonCyan,
                      textColor: Colors.black,
                      child: const Text('KREDİ ÇEK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// 6. Kulüp Hazinesi & Vadeli Mevduat Hesabı
  Widget _buildTreasuryDepositWindow(dynamic gameState, int clubCash) {
    final deposit = gameState.treasuryDeposit as int;
    final weeklyYield = (deposit * 0.025).round();

    return RetroWindow(
      title: 'KULÜP HAZİNESİ & VADELİ MEVDUAT HESABI',
      icon: '[ARTIS]',
      titleBarColor: const Color(0xFF0F2E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: AppColors.neonCyan),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('MEVDUAT BAKİYESİ', style: TextStyle(color: Colors.white60, fontSize: 9)),
                    Text('₣$deposit', style: AppTypography.monoNumber(color: AppColors.neonCyan).copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(height: 24, width: 1, color: Colors.white24),
                Column(
                  children: [
                    const Text('HAFTALIK FAİZ GETİRİSİ (%2.5)', style: TextStyle(color: Colors.white60, fontSize: 9)),
                    Text('+₣$weeklyYield / hafta', style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RetroButton(
                  onPressed: clubCash >= 5000
                      ? () async {
                          await ref.read(gameStateProvider.notifier).depositToTreasury(5000);
                        }
                      : null,
                  backgroundColor: AppColors.neonCyan,
                  textColor: Colors.black,
                  child: const Text('+₣5,000 YATIR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: RetroButton(
                  onPressed: deposit >= 5000
                      ? () async {
                          await ref.read(gameStateProvider.notifier).withdrawFromTreasury(5000);
                        }
                      : null,
                  backgroundColor: const Color(0xFF334155),
                  textColor: Colors.white,
                  child: const Text('-₣5,000 ÇEK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
