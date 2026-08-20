// presentation/screens/ftue_screen.dart
// First Time User Experience (FTUE) scripted 8-step onboarding flow.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/player.dart';
import '../../domain/president/president_origin.dart';
import '../widgets/decision_card_widget.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/president_origin_selection_widget.dart';
import '../widgets/retro_window.dart';

class FtueScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const FtueScreen({super.key, required this.onComplete});

  @override
  ConsumerState<FtueScreen> createState() => _FtueScreenState();
}

class _FtueScreenState extends ConsumerState<FtueScreen> {
  int _step = 0;
  final TextEditingController _clubNameController = TextEditingController(text: 'Angora Gücü');
  final TextEditingController _managerNameController = TextEditingController(text: 'Hoca');
  String _selectedBadge = '🛡️';
  PresidentOriginType _selectedOrigin = PresidentOriginType.industrialist;

  @override
  void dispose() {
    _clubNameController.dispose();
    _managerNameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step >= 7) {
      ref.read(gameStateProvider.notifier).advanceFtue();
      widget.onComplete();
    } else {
      setState(() {
        _step++;
      });
      ref.read(gameStateProvider.notifier).advanceFtue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        backgroundColor: AppColors.win95TitleNavy,
        title: Text('DYNASTY XI SETUP WIZARD — ADIM ${_step + 1} / 8', style: AppTypography.h3(color: Colors.white)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Üst İlerleme Barı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              color: AppColors.win95Grey,
              child: Row(
                children: [
                  Text('KURULUM: ${_step + 1}/8', style: AppTypography.label(color: Colors.black).copyWith(fontSize: 10)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 12,
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        border: Border(
                          top: BorderSide(color: AppColors.win95DarkGrey),
                          left: BorderSide(color: AppColors.win95DarkGrey),
                          right: BorderSide(color: AppColors.win95White),
                          bottom: BorderSide(color: AppColors.win95White),
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_step + 1) / 8.0,
                        child: Container(color: AppColors.win95TitleNavy),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_step >= 2) MetersBarWidget(meters: state.userClub.meters),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10.0),
                child: RetroWindow(
                  title: 'KURULUM SİHİRBAZI MODÜLÜ',
                  icon: '💾',
                  child: _buildCurrentStepView(state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepView(dynamic state) {
    switch (_step) {
      case 0:
        return _buildColdOpenStep();
      case 1:
        return _buildRecepIntroStep();
      case 2:
        return _buildMetersExplanationStep(state);
      case 3:
        return _buildClubBrandingStep();
      case 4:
        return _buildFirstDilemmaStep(state);
      case 5:
        return _buildFirstMatchStep(state);
      case 6:
        return _buildFirstSigningStep(state);
      case 7:
      default:
        return _buildFirstFacilityStep(state);
    }
  }

  // Adım 0: Mnemonic Cold Open
  Widget _buildColdOpenStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('⚽', style: TextStyle(fontSize: 54)),
        const SizedBox(height: 10),
        Text('DYNASTY XI', style: AppTypography.display(color: AppColors.neonPink)),
        const SizedBox(height: 4),
        Text(
          'BİR KULÜP. BİR ŞEHİR. BİR HANEDAN.',
          style: AppTypography.label(color: AppColors.win95DarkGrey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
              left: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
              right: BorderSide(color: AppColors.win95White, width: 1.5),
              bottom: BorderSide(color: AppColors.win95White, width: 1.5),
            ),
          ),
          child: Text(
            '20. Ligin tozlu sahalarından Şampiyonlar Ligi zirvesine giden yolculuk burada başlıyor.\n\nSadece bir teknik direktör değil, bir kulüp mimarısın.',
            style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        RetroButton(
          onPressed: _nextStep,
          child: const Text('KULÜBÜN BAŞINA GEÇ >>'),
        ),
      ],
    );
  }

  // Adım 1: Recep Vardar ile Tanışma
  Widget _buildRecepIntroStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.accentGold, width: 2),
          ),
          alignment: Alignment.center,
          child: const Text('👔', style: TextStyle(fontSize: 44)),
        ),
        const SizedBox(height: 12),
        Text('Recep Vardar', style: AppTypography.h2()),
        Text('Kulüp Başkanı & Yerel İş İnsanı', style: AppTypography.bodySmall(color: AppColors.accentGoldLight)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral900,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neutral700),
          ),
          child: Text(
            '"Hocam, sana kulübün tüm yetkilerini veriyorum. Ama unutma: Kasada kuruş yok, taraftar sabırsız, soyunma odası kaynıyor. Şehri gururlandır, yoksa ilk otobüsle gönderirim!"',
            style: AppTypography.story(),
          ),
        ),
        const SizedBox(height: 28),
        RetroButton(
          onPressed: _nextStep,
          backgroundColor: AppColors.accentGold,
          textColor: AppColors.neutral900,
          child: const Text('GÖREVİ KABUL EDİYORUM', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Adım 2: 4 Metre Eğitimi
  Widget _buildMetersExplanationStep(dynamic state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('DÖRT HAYATİ METRE', style: AppTypography.h2(color: AppColors.accentGold)),
        const SizedBox(height: 8),
        Text(
          'Kulübü yönetirken bu 4 dengeyi asla sıfıra düşürmemelisin:',
          style: AppTypography.bodySmall(),
        ),
        const SizedBox(height: 16),
        _buildMeterInfo('💰 KASA (₣)', 'Maaşlar, transferler ve tesis yatırımları için nakit para. Borca batarsan transfer yasağı alırsın.'),
        _buildMeterInfo('📢 TARAFTAR (%)', 'Tribünlerin desteği. Yüksek taraftar maç gelirini ve ev sahibi atmosferini katlar.'),
        _buildMeterInfo('👕 SOYUNMA ODASI (%)', 'Futbolcuların morali ve bağlılığı. Düşerse takım sahada mücadele etmeyi bırakır.'),
        _buildMeterInfo('🏛️ YÖNETİM GÜVENİ (%)', 'Başkanın sana olan sabrı. 3 maç üst üste %15 altına inerse kovulursun!'),
        const SizedBox(height: 24),
        RetroButton(
          onPressed: _nextStep,
          backgroundColor: AppColors.neonLime,
          textColor: Colors.black,
          child: const Text('ANLADIM, DEVAM ET', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Adım 3: Kulüp Kimliği Oluşturma
  Widget _buildClubBrandingStep() {
    final badges = ['🛡️', '🦁', '🦅', '⚡', '⚓', '🐺'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('KULÜP KİMLİĞİNİ BELİRLE', style: AppTypography.h2(color: AppColors.accentGold)),
          const SizedBox(height: 4),
          Text('Hanedanının adını ve armasını seç:', style: AppTypography.bodySmall()),
          const SizedBox(height: 16),
          TextField(
            controller: _clubNameController,
            decoration: const InputDecoration(
              labelText: 'Kulüp Adı',
              filled: true,
              fillColor: AppColors.neutral900,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _managerNameController,
            decoration: const InputDecoration(
              labelText: 'Menajer Adı',
              filled: true,
              fillColor: AppColors.neutral900,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Kulüp Arması / Sembolü', style: AppTypography.label(color: AppColors.neutral300)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: badges.map((b) {
              final isSel = _selectedBadge == b;
              return InkWell(
                onTap: () => setState(() => _selectedBadge = b),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.accentGold.withValues(alpha: 0.2) : AppColors.neutral900,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? AppColors.accentGold : AppColors.neutral700,
                      width: isSel ? 2 : 1,
                    ),
                  ),
                  child: Text(b, style: const TextStyle(fontSize: 26)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Başkanlık Kökeni Seçimi
          PresidentOriginSelectionWidget(
            selectedOrigin: _selectedOrigin,
            onOriginSelected: (origin) {
              setState(() => _selectedOrigin = origin);
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: RetroButton(
              onPressed: () {
                final allOrigins = PresidentOrigin.getAllOrigins();
                final chosenOrigin = allOrigins.firstWhere((o) => o.type == _selectedOrigin);
                final notifier = ref.read(gameStateProvider.notifier);

                notifier.updateClubProfile(
                      clubName: _clubNameController.text.trim().isNotEmpty ? _clubNameController.text.trim() : null,
                      managerName: _managerNameController.text.trim().isNotEmpty ? _managerNameController.text.trim() : null,
                      badgeIcon: _selectedBadge,
                    );

                // Köken avantajlarını kasaya yansıt
                if (chosenOrigin.startingCashBonus > 0) {
                  notifier.claimSponsorReward(chosenOrigin.startingCashBonus);
                }
                if (chosenOrigin.startingBoardTrustBonus != 0) {
                  notifier.adjustBoardTrust(chosenOrigin.startingBoardTrustBonus);
                }
                if (chosenOrigin.startingFansBonus != 0) {
                  notifier.adjustFans(chosenOrigin.startingFansBonus);
                }
                if (chosenOrigin.startingLockerRoomBonus != 0) {
                  notifier.adjustLockerRoom(chosenOrigin.startingLockerRoomBonus);
                }

                _nextStep();
              },
              backgroundColor: AppColors.accentGold,
              textColor: Colors.black,
              child: const Text('BAŞKANLIK KİMLİĞİNİ & KULÜBÜ ONAYLA', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Adım 4: Kaptan Osman Yalçın ile İlk Karar Kartı
  Widget _buildFirstDilemmaStep(dynamic state) {
    final firstCard = state.pendingCards.isNotEmpty ? state.pendingCards.first : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İLK KARAR ANI', style: AppTypography.h2(color: AppColors.accentGold)),
          const SizedBox(height: 4),
          Text('Ofisine ilk kriz dosyası geldi. Bir seçim yap:', style: AppTypography.bodySmall()),
          const SizedBox(height: 14),
          if (firstCard != null)
            DecisionCardWidget(
              card: firstCard,
              onOptionSelected: (opt) {
                ref.read(gameStateProvider.notifier).chooseCardOption(firstCard, opt);
                _nextStep();
              },
            )
          else
            RetroButton(
              onPressed: _nextStep,
              backgroundColor: AppColors.neonLime,
              textColor: Colors.black,
              child: const Text('İlerle', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // Adım 5: 1. Hafta Maçı
  Widget _buildFirstMatchStep(dynamic state) {
    final fixture = state.currentLeague.fixtures.isNotEmpty ? state.currentLeague.fixtures.first : null;
    final oppId = fixture != null ? (fixture.homeClubId == state.userClub.id ? fixture.awayClubId : fixture.homeClubId) : '';
    final oppName = state.currentLeague.getClubName(oppId);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🏟️', style: TextStyle(fontSize: 54)),
        const SizedBox(height: 12),
        Text('İLK RESMİ MAÇ GÜNÜ!', style: AppTypography.h2(color: AppColors.accentGold)),
        const SizedBox(height: 8),
        Text(
          '20. Lig 1. Hafta: ${state.userClub.name} vs $oppName',
          style: AppTypography.body(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.neutral900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral700),
          ),
          child: Text(
            'Takımın sahaya çıkmaya hazır. İlk maçında galibiyet alarak taraftarı arkana al ve lige moralli başla!',
            style: AppTypography.story(),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 28),
        RetroButton(
          onPressed: () async {
            await ref.read(gameStateProvider.notifier).playMatch(isLiveMode: false);
            _nextStep();
          },
          backgroundColor: AppColors.signalGreen,
          textColor: AppColors.neutral900,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_soccer, size: 18, color: Colors.black),
              SizedBox(width: 8),
              Text('MAÇI OYNA VE KAZAN', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  // Adım 6: İlk Transfer Deneyimi
  Widget _buildFirstSigningStep(dynamic state) {
    final firstTarget = state.transferMarket.isNotEmpty
        ? state.transferMarket.first
        : const Player(
            id: 'ftue_gift',
            firstName: 'Mert',
            lastName: 'Kaya',
            countryCode: 'TR',
            age: 20,
            position: Position.cm,
            pace: 75,
            technique: 76,
            shooting: 72,
            passing: 78,
            defending: 68,
            physical: 74,
            mentality: 75,
            potential: 82,
            weeklyWage: 800,
          );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İLK TRANSFERİNİ YAP', style: AppTypography.h2(color: AppColors.accentGold)),
          const SizedBox(height: 4),
          Text('Scout ekibi serbest bir yetenek buldu:', style: AppTypography.bodySmall()),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.neutral900,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accentGold),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(firstTarget.fullName, style: AppTypography.h3()),
                          Text('${firstTarget.position.label} • ${firstTarget.age} Yaş • ${firstTarget.ovr} OVR',
                              style: AppTypography.bodySmall(color: AppColors.accentGoldLight)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RetroButton(
                  onPressed: () async {
                    await ref.read(gameStateProvider.notifier).signPlayer(
                          firstTarget,
                          0, // Bedelsiz FTUE transferi
                          firstTarget.weeklyWage,
                        );
                    _nextStep();
                  },
                  backgroundColor: AppColors.accentGold,
                  textColor: Colors.black,
                  child: const Text('ÜCRETSİZ İMZALA (FTUE HEDİYESİ)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Adım 7: İlk Tesis İnşaatı ve Ofise Giriş
  Widget _buildFirstFacilityStep(dynamic state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🏗️', style: TextStyle(fontSize: 54)),
        const SizedBox(height: 12),
        Text('İLK TESİS YATIRIMI', style: AppTypography.h2(color: AppColors.accentGold)),
        const SizedBox(height: 8),
        Text(
          'Kulübün geleceği altyapı ve tesislerden geçer. Antrenman Sahasını 1. Seviyeye yükselterek oyuncularının haftalık gelişimini hızlandır.',
          style: AppTypography.body(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        RetroButton(
          onPressed: () async {
            await ref.read(gameStateProvider.notifier).upgradeFacility(FacilityType.trainingGround);
            _nextStep();
          },
          backgroundColor: AppColors.accentGold,
          textColor: AppColors.neutral900,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.build, size: 18, color: Colors.black),
              SizedBox(width: 8),
              Text('ANTRENMAN SAHASINI İNŞA ET', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeterInfo(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutral700),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.h3(color: AppColors.accentGold)),
            const SizedBox(height: 2),
            Text(desc, style: AppTypography.bodySmall()),
          ],
        ),
      ),
    );
  }
}
