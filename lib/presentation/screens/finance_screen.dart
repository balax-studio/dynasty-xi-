// presentation/screens/finance_screen.dart
// Comprehensive Cyber-Retro Football Club Finance & Treasury Screen (§15.1, §15.2, §15.3, §A.7)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/economy/financial_statement.dart';
import '../widgets/meters_bar_widget.dart';
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

        final statement = FinancialStatementCalculator.calculateWeeklyStatement(
          club: simulatedClub,
          sleeveSponsorIncome: gameState.sleeveSponsorIncome,
          stadiumNamingIncome: gameState.stadiumNamingIncome,
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
                const Text('💰', style: TextStyle(fontSize: 20)),
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
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('⚖️', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text('MALİYE MÜFETTİŞİ VE VERGİ DENETİM MASASI (RİSK İNCELEMESİ)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
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
      icon: '📑',
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
                          const Text('📥', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
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
                          const Text('📤', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
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
      icon: '🛡️',
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
      fanReaction = '💚 Halk Tipi / Ucuz Bilet (Taraftar Çok Mutlu)';
      reactionColor = AppColors.neonLime;
    } else if (currentPrice <= 30) {
      fanReaction = '⚖️ Dengeli Fiyatlandırma (Optimum Hasılat)';
      reactionColor = AppColors.neonCyan;
    } else if (currentPrice <= 42) {
      fanReaction = '⚠️ Pahalı Bilet (Seyirci Sayısı Düşüyor)';
      reactionColor = AppColors.neonAmber;
    } else {
      fanReaction = '🚨 Fahiş Fiyat! (Tribünler Boş Kalıyor, Taraftar Öfkeli)';
      reactionColor = AppColors.comicRed;
    }

    return RetroWindow(
      title: 'MAÇ GÜNÜ BİLET VE HASILAT SİMÜLATÖRÜ',
      icon: '🎟️',
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
                        content: Text('🎟️ Bilet fiyatı ₣$_simulatedTicketPrice olarak güncellendi!', style: const TextStyle(color: Colors.black)),
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

  /// 4. 3-Slot Sponsorluk Masası
  Widget _buildSponsorshipNegotiationDesk(dynamic gameState, int leagueTier) {
    final deals = FinancialStatementCalculator.getAvailableSponsorshipDeals(leagueTier)
        .where((d) => d.slot == _selectedSponsorSlot)
        .toList();

    return RetroWindow(
      title: '3-SLOT SPONSORLUK MASASI & SÖZLEŞMELER',
      icon: '✍️',
      titleBarColor: AppColors.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot Seçici Butonları
          Row(
            children: SponsorshipSlot.values.map((slot) {
              final isSelected = _selectedSponsorSlot == slot;
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
                      '${slot.icon} ${slot.label.split(" ").first.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Mevcut Sponsorluk Paketleri
          ...deals.map((deal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neoInnerBg,
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  Text(deal.brandIcon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deal.brandName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(deal.perkDescription, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('+₣${deal.weeklyIncome}/h', style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text('İmza Parası: +₣${deal.signingBonus}', style: const TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  RetroButton(
                    onPressed: () async {
                      await ref.read(gameStateProvider.notifier).signSponsorshipDeal(
                            slot: deal.slot,
                            weeklyIncome: deal.weeklyIncome,
                            signingBonus: deal.signingBonus,
                            brandName: deal.brandName,
                          );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.neonLime,
                            content: Text('🎉 ${deal.brandName} ile sponsorluk imzalandı (+₣${deal.signingBonus} kasaya eklendi)!', style: const TextStyle(color: Colors.black)),
                          ),
                        );
                      }
                    },
                    backgroundColor: AppColors.neonLime,
                    textColor: Colors.black,
                    child: const Text('İMZALA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
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
      icon: '🏦',
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
                      const Text('🚨 AKTİF BANKA KREDİSİ BORCU', style: TextStyle(color: AppColors.comicRed, fontSize: 11, fontWeight: FontWeight.bold)),
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
                                    content: Text('🎉 Kredi erken kapatıldı! Kulüp tüm borçlarından kurtuldu.', style: TextStyle(color: Colors.black)),
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
                              content: Text('🏦 ₣${pkg.principalAmount} kredi kasaya eklendi!', style: const TextStyle(color: Colors.black)),
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
      icon: '📈',
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
