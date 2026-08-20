// presentation/screens/board_room_screen.dart
// Dedicated full-screen page for Chairman Board Meetings, Financial Statements, Sponsorships & Bank Loans.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/economy/financial_statement.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import 'board_faction_screen.dart';
import 'boardroom_summit_screen.dart';

class BoardRoomScreen extends ConsumerWidget {
  const BoardRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final boardTrust = club.meters.boardTrust;
        final activeLoan = gameState.activeLoan;

        final statement = FinancialStatementCalculator.calculateWeeklyStatement(
          club: club,
          sleeveSponsorIncome: gameState.sleeveSponsorIncome,
          stadiumNamingIncome: gameState.stadiumNamingIncome,
          activeLoanWeeklyRepayment: activeLoan?.weeklyPayment ?? 0,
        );

        final trustColor = boardTrust >= 70
            ? AppColors.neonLime
            : (boardTrust >= 40 ? AppColors.neonAmber : AppColors.comicRed);

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            title: Text('YÖNETİM KURULU & MALİ RAPOR', style: AppTypography.h2(color: Colors.white)),
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
                      // 0. Başkanlık Zirvesi & Sermaye Artırımı Hızlı Erişim Butonu
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BoardroomSummitScreen()),
                            );
                          },
                          backgroundColor: AppColors.accentGold,
                          textColor: Colors.black,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🏛️', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text('BAŞKANLIK ZİRVESİ & SERMAYE ARTIRIMI (ÖZEL TOPLANTI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 0.5. Yönetim İçi Hizipler & Kulis Odası Butonu
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BoardFactionScreen()),
                            );
                          },
                          backgroundColor: AppColors.win95Grey,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('👔', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text('YÖNETİM İÇİ HİZİPLER & KULİS ODASI (ERKEN SEÇİM / OY ORANLARI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.win95TitleNavy)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 1. Yönetim Kurulu Güven İndeksi & Kovulma Riski (§12.8)
                      RetroWindow(
                        title: 'BAŞKANLIK GÜVEN & İSTİKRAR İNDEKSİ',
                        icon: '🏛️',
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('YÖNETİM GÜVENİ', style: AppTypography.label(color: AppColors.neutral300).copyWith(fontSize: 10)),
                                    Text(
                                      '%$boardTrust',
                                      style: AppTypography.display(color: trustColor).copyWith(fontSize: 32),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(color: trustColor, width: 2),
                                  ),
                                  child: Text(
                                    boardTrust >= 70 ? 'GÜVEN TAM' : (boardTrust >= 40 ? 'SALLANTIDA' : '⚠️ KOVULMA TEHLİKESİ!'),
                                    style: AppTypography.label(color: trustColor).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: boardTrust / 100.0,
                              backgroundColor: Colors.black,
                              color: trustColor,
                              minHeight: 8,
                            ),
                            if (boardTrust < 30) ...[
                              const SizedBox(height: 8),
                              const Text(
                                '⚠️ DİKKAT: Güven %30 altına indi. 2 mağlubiyet daha alırsanız yönetim kurulu sözleşmenizi tek taraflı feshedecektir!',
                                style: TextStyle(color: AppColors.comicRed, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. Haftalık Mali Bütçe Raporu (§15.2, §15.3)
                      RetroWindow(
                        title: 'HAFTALIK MALİ GELİR / GİDER BİLANÇOSU',
                        icon: '📊',
                        titleBarColor: const Color(0xFF0F3826),
                        child: _buildFinancialStatementWidget(context, statement),
                      ),
                      const SizedBox(height: 10),

                      // 3. 3-Slot Sponsorluk Yönetimi (§15.2)
                      RetroWindow(
                        title: 'KULÜP SPONSORLUK YÖNETİMİ (3 SLOT)',
                        icon: '🤝',
                        titleBarColor: const Color(0xFF1E3A8A),
                        child: _buildSponsorshipSlotsWidget(context, ref, gameState),
                      ),
                      const SizedBox(height: 10),

                      // 4. Banka Kredisi ve Borç Yönetimi (§A.7)
                      RetroWindow(
                        title: 'BANKA KREDİSİ & BORÇ MERKEZİ',
                        icon: '🏦',
                        child: _buildBankLoanWidget(context, ref, activeLoan, club.meters.cash),
                      ),
                      const SizedBox(height: 10),

                      // 5. Sezon Hedefi Taahhüdü (§A.3)
                      RetroWindow(
                        title: 'SEZON HEDEFİ VE BAŞKAN TAAHHÜDÜ',
                        icon: '🎯',
                        child: _buildSeasonTargetWidget(context, ref, gameState.targetLeaguePosition),
                      ),
                      const SizedBox(height: 10),

                      // 6. Yönetim Kurulu Acil Talepleri
                      RetroWindow(
                        title: 'YÖNETİM KURULU TALEP & BÜTÇE İSTEKLERİ',
                        icon: '💎',
                        child: Column(
                          children: [
                            _buildBoardActionButton(
                              title: '💰 EK TRANSFER BÜTÇESİ İSTE (+₣15,000)',
                              desc: 'Kulüp kasasına acil ödenek sağlar. (Yönetim Güveni -12 Düşer)',
                              btnText: 'BÜTÇE ÇEK',
                              color: AppColors.neonLime,
                              onPressed: () async {
                                final ok = await ref.read(gameStateProvider.notifier).requestExtraBudget(15000);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ok
                                            ? '💰 Yönetim Kurulu onayladı! Kasaya +₣15,000 aktarıldı.'
                                            : '⚠️ İstek reddedildi: Yönetim kurulu güveni yetersiz (%30 altı).',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
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

  Widget _buildFinancialStatementWidget(BuildContext context, FinancialStatement s) {
    final netColor = s.netProfitOrLoss >= 0 ? AppColors.neonLime : AppColors.comicRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GELİRLER (HAFTALIK TAHMİNİ)', style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        _buildStatementRow('Bilet ve Maç Günü Hasılatı', '₣${s.ticketIncome}'),
        _buildStatementRow('Forma Göğüs Sponsoru (Ana)', '₣${s.mainSponsorIncome}'),
        _buildStatementRow('Forma Kol Sponsoru', '₣${s.sleeveSponsorIncome}'),
        _buildStatementRow('Stadyum İsim Hakkı', '₣${s.stadiumNamingIncome}'),
        _buildStatementRow('Fan Shop Ürün Satışı', '₣${s.fanShopIncome}'),
        const Divider(color: Colors.white24, height: 12),
        _buildStatementRow('TOPLAM GELİR', '₣${s.totalIncome}', isBold: true, color: AppColors.neonLime),
        const SizedBox(height: 10),

        Text('GİDERLER (HAFTALIK SABİT)', style: AppTypography.label(color: AppColors.comicRed).copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        _buildStatementRow('Futbolcu ve Personel Maaşları', '-₣${s.playerWagesExpense}'),
        _buildStatementRow('Tesis Bakım & İşletme Masrafı', '-₣${s.facilityUpkeepExpense}'),
        if (s.loanRepaymentExpense > 0)
          _buildStatementRow('Banka Kredisi Taksit Ödemesi', '-₣${s.loanRepaymentExpense}'),
        const Divider(color: Colors.white24, height: 12),
        _buildStatementRow('TOPLAM GİDER', '-₣${s.totalExpenses}', isBold: true, color: AppColors.comicRed),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('HAFTALIK NET KÂR / ZARAR:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              Text(
                '${s.netProfitOrLoss >= 0 ? "+" : ""}₣${s.netProfitOrLoss}',
                style: AppTypography.monoNumber(color: netColor).copyWith(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatementRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? Colors.white : Colors.white70, fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildSponsorshipSlotsWidget(BuildContext context, WidgetRef ref, dynamic gameState) {
    return Column(
      children: [
        _buildSponsorSlotItem(
          slotName: '1. FORMA GÖĞÜS SPONSORU (ANA)',
          sponsorBrand: 'Turkcell / Aygaz Konsorsiyumu',
          income: gameState.userClub.sponsorWeeklyIncome,
          badge: 'ANA SPONSOR',
        ),
        const SizedBox(height: 6),
        _buildSponsorSlotItem(
          slotName: '2. FORMA KOL SPONSORU',
          sponsorBrand: 'Puma Sports Turkey',
          income: gameState.sleeveSponsorIncome,
          badge: 'KOL',
        ),
        const SizedBox(height: 6),
        _buildSponsorSlotItem(
          slotName: '3. STADYUM İSİM HAKKI SPONSORU',
          sponsorBrand: 'Passo Arena Grubu',
          income: gameState.stadiumNamingIncome,
          badge: 'STAT',
        ),
      ],
    );
  }

  Widget _buildSponsorSlotItem({
    required String slotName,
    required String sponsorBrand,
    required int income,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neoInnerBg,
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(slotName, style: const TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(sponsorBrand, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.black,
            child: Text('+₣$income/h', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildBankLoanWidget(BuildContext context, WidgetRef ref, BankLoan? activeLoan, int cash) {
    if (activeLoan != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Aktif Kredi Borcu:', style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text('₣${activeLoan.remainingDebt}', style: const TextStyle(color: AppColors.comicRed, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Haftalık Taksit: ₣${activeLoan.weeklyPayment} (${activeLoan.remainingWeeks} hafta kaldı)',
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (activeLoan.totalWeeks - activeLoan.remainingWeeks) / activeLoan.totalWeeks,
              backgroundColor: Colors.black,
              color: AppColors.neonLime,
              minHeight: 6,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kulüp finansmanı için 8 haftalık geri ödemeli banka kredisi çekebilirsiniz (%10 sabit faiz).',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: RetroButton(
                onPressed: () {
                  ref.read(gameStateProvider.notifier).takeBankLoan(25000);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🏦 ₣25,000 banka kredisi kasaya eklendi!')),
                  );
                },
                backgroundColor: AppColors.neonCyan,
                textColor: Colors.black,
                child: const Text('₣25.000 AL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: RetroButton(
                onPressed: () {
                  ref.read(gameStateProvider.notifier).takeBankLoan(50000);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🏦 ₣50,000 banka kredisi kasaya eklendi!')),
                  );
                },
                backgroundColor: AppColors.neonLime,
                textColor: Colors.black,
                child: const Text('₣50.000 AL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: RetroButton(
                onPressed: () {
                  ref.read(gameStateProvider.notifier).takeBankLoan(100000);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🏦 ₣100,000 banka kredisi kasaya eklendi!')),
                  );
                },
                backgroundColor: AppColors.accentGold,
                textColor: Colors.black,
                child: const Text('₣100.000 AL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeasonTargetWidget(BuildContext context, WidgetRef ref, int currentTarget) {
    const targets = [
      MapEntry(1, 'Şampiyonluk (1. Sıra) • Ödül: ₣50.000 + 500 XP'),
      MapEntry(3, 'İlk 3 (Play-Off / Terfi) • Ödül: ₣35.000 + 350 XP'),
      MapEntry(5, 'İlk 5 (Üst Sıralar) • Ödül: ₣25.000 + 250 XP'),
      MapEntry(10, 'Ligde Kalma (Düşmeme) • Ödül: ₣15.000 + 150 XP'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mevcut Taahhüt: Ligi $currentTarget. sıra veya üzerinde bitirmek.',
          style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: currentTarget,
          dropdownColor: Colors.black,
          style: const TextStyle(color: Colors.white, fontSize: 11),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: Colors.black,
            border: OutlineInputBorder(borderRadius: BorderRadius.zero),
          ),
          items: targets.map((t) => DropdownMenuItem(value: t.key, child: Text(t.value))).toList(),
          onChanged: (val) {
            if (val != null) {
              ref.read(gameStateProvider.notifier).setTargetLeaguePosition(val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎯 Yeni sezon hedefi: İlk $val sıra taahhüt edildi!')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildBoardActionButton({
    required String title,
    required String desc,
    required String btnText,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.neoInnerBg,
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.label(color: color).copyWith(fontSize: 11)),
          const SizedBox(height: 2),
          Text(desc, style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: RetroButton(
              onPressed: onPressed,
              backgroundColor: color,
              textColor: Colors.black,
              child: Text(btnText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}
