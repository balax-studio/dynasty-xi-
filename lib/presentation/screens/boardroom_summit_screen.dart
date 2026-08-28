// presentation/screens/boardroom_summit_screen.dart
// Boardroom Summit, Capital Injections, VIP Box Sales and Divan Council Screen for Club President (§15.5)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/president/boardroom_summit.dart';
import '../widgets/foreign_takeover_dialog.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';

class BoardroomSummitScreen extends ConsumerStatefulWidget {
  const BoardroomSummitScreen({super.key});

  @override
  ConsumerState<BoardroomSummitScreen> createState() => _BoardroomSummitScreenState();
}

class _BoardroomSummitScreenState extends ConsumerState<BoardroomSummitScreen> {
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
        final capitalOptions = BoardroomCatalog.getCapitalInjections();
        final vipBoxes = gameState.vipBoxDeals.isNotEmpty
            ? gameState.vipBoxDeals
            : BoardroomCatalog.getInitialVipBoxes();
        final motions = BoardroomCatalog.getMotions();

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Text('◀', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const Text('[YÖNETİM]', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BAŞKANLIK ZİRVESİ & SERMAYE ARTIRIMI',
                        style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 13),
                      ),
                      Text(
                        'DİVAN KURULU VE ŞAHSİ SERMAYE ENJEKSİYONU',
                        style: AppTypography.label(color: AppColors.accentGold).copyWith(fontSize: 9),
                      ),
                    ],
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
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 0. Yabancı Fon & Sermaye Ortaklığı Teklifleri Butonu
                      RetroButton(
                        onPressed: () => ForeignTakeoverDialog.show(context),
                        backgroundColor: AppColors.win95TitleNavy,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('[FON]', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 10)),
                              SizedBox(width: 6),
                              Text('YABANCI SERMAYE FONU & HİSSE DEVRİ TEKLİFLERİ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 1. Şahsi Servetten Sermaye Enjeksiyonu
                      _buildCapitalInjectionSection(capitalOptions),
                      const SizedBox(height: 12),

                      // 2. Sezonluk VIP Loca Satış Masası
                      _buildVipBoxSection(vipBoxes),
                      const SizedBox(height: 12),

                      // 3. Divan Kurulu Karar Tasarıları
                      _buildMotionsSection(motions, club.meters.cash),
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

  /// 1. Şahsi Servetten Sermaye Enjeksiyonu
  Widget _buildCapitalInjectionSection(List<CapitalInjectionOption> options) {
    return RetroWindow(
      title: 'BAŞKANLIK ŞAHSİ SERMAYE ENJEKSİYONU & HİBE',
      icon: 'DIAMOND',
      titleBarColor: AppColors.accentGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kulüp kasasını güçlendirmek için başkanın şahsi holdinginden karşılıksız sıcak para enjekte edin:', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
          const SizedBox(height: 8),
          ...options.map((opt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neoInnerBg,
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                children: [
                  RetroPixelIcon.fromEmoji(opt.icon, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt.title, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                        Text(opt.description, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('+₣${opt.cashAmount}', style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text('Güven: +${opt.boardTrustBonus} • Taraftar: +${opt.fanBonus}', style: const TextStyle(color: AppColors.accentGold, fontSize: 9.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  RetroButton(
                    onPressed: () async {
                      final ok = await ref.read(gameStateProvider.notifier).injectPresidentCapital(opt);
                      if (mounted && ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.neonLime,
                            content: Text('DIAMOND +₣${opt.cashAmount} sermaye kulüp kasasına hibe edildi!', style: const TextStyle(color: Colors.black)),
                          ),
                        );
                      }
                    },
                    backgroundColor: AppColors.neonLime,
                    textColor: Colors.black,
                    child: const Text('SERMAYE AKTAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 2. Sezonluk VIP Loca Satış Masası
  Widget _buildVipBoxSection(List<VipBoxDeal> boxes) {
    return RetroWindow(
      title: 'SEZONLUK VIP PROTOKOL LOCA KİRALAMA BORSASI',
      icon: '',
      titleBarColor: AppColors.win95TitleNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Holding patronlarına ve kurumsal şirketlere sezonluk loca satarak peşin milyonluk gelir yaratın:', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
          const SizedBox(height: 8),
          ...boxes.map((box) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: box.isSold ? const Color(0xFF0F2E1E) : AppColors.neoInnerBg,
                border: Border.all(color: box.isSold ? AppColors.neonLime : Colors.white24),
              ),
              child: Row(
                children: [
                  RetroPixelIcon.fromEmoji(box.companyIcon, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(box.companyName, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(box.perkDescription, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                        const SizedBox(height: 2),
                        Text('Peşin Gelir: +₣${box.seasonPrice} • ${box.seatsCount} Kişilik Kapasite', style: const TextStyle(color: AppColors.neonCyan, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (box.isSold)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: AppColors.neonLime,
                      child: const Text('KİRALANDI', style: TextStyle(color: Colors.black, fontSize: 9.5, fontWeight: FontWeight.bold)),
                    )
                  else
                    RetroButton(
                      onPressed: () async {
                        final ok = await ref.read(gameStateProvider.notifier).sellVipBox(box.id);
                        if (mounted && ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.neonLime,
                              content: Text(' ${box.companyName} kiralandı! (+₣${box.seasonPrice} kasaya eklendi)', style: const TextStyle(color: Colors.black)),
                            ),
                          );
                        }
                      },
                      backgroundColor: AppColors.neonCyan,
                      textColor: Colors.black,
                      child: const Text('KİRALA (SAT)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 3. Divan Kurulu Karar Tasarıları
  Widget _buildMotionsSection(List<BoardroomMotion> motions, int clubCash) {
    return RetroWindow(
      title: 'DİVAN KURULU VE YÖNETİM OYLAMALARI',
      icon: '[HUKUK]',
      titleBarColor: AppColors.win95TitleNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kulübün geleceğine yön veren stratejik tüzük ve yatırım tasarıları:', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
          const SizedBox(height: 8),
          ...motions.map((m) {
            return Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.title, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
                      Text('Oy: %${((m.yesVotes / (m.yesVotes + m.noVotes)) * 100).toStringAsFixed(0)} Evet', style: const TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(m.description, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  const SizedBox(height: 3),
                  Text('Kazanım: ${m.rewardDescription}', style: const TextStyle(color: AppColors.accentGold, fontSize: 9.5)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gerekli Bütçe: ₣${m.requiredCost}', style: AppTypography.monoNumber(color: Colors.white70).copyWith(fontSize: 10)),
                      RetroButton(
                        onPressed: clubCash >= m.requiredCost
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.neonLime,
                                    content: Text('[HUKUK] ${m.title} kabul edildi ve yürürlüğe girdi!', style: const TextStyle(color: Colors.black)),
                                  ),
                                );
                              }
                            : null,
                        backgroundColor: clubCash >= m.requiredCost ? AppColors.neonLime : Colors.grey,
                        textColor: Colors.black,
                        child: const Text('ONAYLA & UYGULA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9.5)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
