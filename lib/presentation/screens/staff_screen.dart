// presentation/screens/staff_screen.dart
// Full-screen Technical Staff & Backroom Specialists Management screen (§8.2, §13).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/staff.dart';
import '../../domain/president/head_coach.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import 'head_coach_dialogue_screen.dart';
import 'head_coach_hiring_screen.dart';
import 'legal_defense_screen.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final headCoach = gameState.headCoach;
        final staffList = gameState.staff.isEmpty ? StaffGenerator.generateDefaultStaff() : gameState.staff;
        final availableCoaches = HeadCoachCatalog.getCandidateCoaches();

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            title: Text('TEKNİK EKİP & KULÜP YÖNETİMİ', style: AppTypography.h2(color: Colors.white)),
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
                      // 0. Kulüp Hukuk Bürosu Butonu
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          backgroundColor: AppColors.win95TitleNavy,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LegalDefenseScreen()),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('[HUKUK]', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text(
                                'KULÜP HUKUK BÜROSU & TAHKİM KURULU İTİRAZLARI',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 1. Mevcut Teknik Direktör Penceresi
                      RetroWindow(
                        title: 'FAAL TEKNİK DİREKTÖR (HEAD COACH)',
                        icon: '',
                        titleBarColor: const Color(0xFF005500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(color: AppColors.neonLime, width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    headCoach?.archetype.icon ?? '',
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        headCoach?.fullName ?? 'SERGEN HOCA (GEÇİCİ ANTRENÖR)',
                                        style: AppTypography.label(color: Colors.white).copyWith(fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'OYNATTIĞI DİZİLİŞ: ${club.formation} • FELSEFE: ${(headCoach?.tacticalStyle ?? club.tacticalStyle).toUpperCase()}',
                                        style: AppTypography.bodySmall(color: AppColors.neonLime).copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  color: Colors.black,
                                  child: Text(
                                    '${headCoach?.reputation ?? 75} OVR',
                                    style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.win95DarkGrey, height: 1),
                            const SizedBox(height: 10),

                            // Hoca İle İletişim & Yönetim Butonları
                            Row(
                              children: [
                                Expanded(
                                  child: RetroButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const HeadCoachDialogueScreen()),
                                      );
                                    },
                                    backgroundColor: AppColors.neonLime,
                                    textColor: Colors.black,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('[MESAJ]', style: TextStyle(fontSize: 14)),
                                        SizedBox(width: 4),
                                        Text('HOCA İLE SOHBET ET', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RetroButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const HeadCoachHiringScreen()),
                                      );
                                    },
                                    backgroundColor: AppColors.accentGold,
                                    textColor: Colors.black,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('[ATAMA]', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 4),
                                        Text('YÖNETİM & ATAMA', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. Arka Ofis ve Uzman Ekip (Backroom Staff)
                      RetroWindow(
                        title: 'KULÜP ARKA OFİS UZMANLARI (${staffList.length} UZMAN)',
                        icon: '',
                        titleBarColor: const Color(0xFF1E3A8A),
                        child: Column(
                          children: [
                            // Pazar Butonu
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'GÖREVDEKİ UZMAN KADROSU:',
                                  style: TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () => _showStaffMarketModal(context, ref, gameState),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold,
                                      border: Border.all(color: Colors.black, width: 1.5),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('[PAZAR]', style: TextStyle(color: Colors.black, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 4),
                                        Text(
                                          'UZMAN TRANSFER PAZARI',
                                          style: TextStyle(color: Colors.black, fontSize: 9.5, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Mevcut Uzman Listesi
                            ...staffList.map((staff) {
                              final cost = staff.level * 2500;
                              final canUpgrade = staff.level < 5 && club.meters.cash >= cost;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.neoInnerBg,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      color: Colors.black,
                                      alignment: Alignment.center,
                                      child: Text(staff.role.icon, style: const TextStyle(fontSize: 20)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(staff.name, style: AppTypography.label(color: Colors.white).copyWith(fontSize: 11)),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                color: AppColors.neonCyan,
                                                child: Text(
                                                  'SV. ${staff.level}/5',
                                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${staff.role.label} • ${staff.specialtyDescription}',
                                            style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                                          ),
                                          Text(
                                            'Maaş: ₣${staff.weeklySalary}/h',
                                            style: const TextStyle(color: AppColors.neonLime, fontSize: 9, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (staff.level < 5)
                                          RetroButton(
                                            onPressed: () async {
                                              AudioSynthesizer.playClick();
                                              final ok = await ref.read(gameStateProvider.notifier).upgradeStaffMember(staff.id);
                                              if (context.mounted) {
                                                if (ok) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      backgroundColor: AppColors.neonLime,
                                                      content: Text(
                                                        ' ${staff.name} kursu tamamlayarak Seviye ${staff.level + 1} oldu!',
                                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      backgroundColor: AppColors.comicRed,
                                                      content: Text('[UYARI] Yetersiz bütçe!'),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            backgroundColor: canUpgrade ? AppColors.neonLime : AppColors.neutral700,
                                            textColor: canUpgrade ? Colors.black : Colors.white70,
                                            child: Text('GELİŞTİR (₣$cost)', style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            color: AppColors.accentGold,
                                            child: const Text('MAX SEVİYE', style: TextStyle(color: Colors.black, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                          ),
                                        const SizedBox(height: 4),
                                        InkWell(
                                          onTap: () => _showStaffMarketModal(context, ref, gameState),
                                          child: const Text(
                                            'DEĞİŞTİR ',
                                            style: TextStyle(color: AppColors.neonCyan, fontSize: 8.5, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3. Teknik Direktör Borsası
                      RetroWindow(
                        title: 'TEKNİK DİREKTÖR BORSASI & ADAYLAR',
                        icon: '[MENAJER]',
                        titleBarColor: AppColors.neoCardBg,
                        child: Column(
                          children: availableCoaches.map((c) {
                            final isCurrent = headCoach?.id == c.id;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.neoInnerBg,
                                border: Border(
                                  top: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
                                  left: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
                                  right: BorderSide(color: Colors.black, width: 1.5),
                                  bottom: BorderSide(color: Colors.black, width: 1.5),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Text(c.archetype.icon, style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.fullName.toUpperCase(),
                                            style: AppTypography.label(color: Colors.white).copyWith(fontSize: 12),
                                          ),
                                          Text(
                                            'FELSEFE: ${c.tacticalStyle.toUpperCase()} • MAAŞ: ₣${c.weeklyWage}/h',
                                            style: AppTypography.bodySmall(color: AppColors.accentGold).copyWith(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      color: Colors.black,
                                      child: Text(
                                        '${c.reputation}',
                                        style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 15),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    RetroButton(
                                      onPressed: isCurrent
                                          ? null
                                          : () async {
                                              final ok = await ref.read(gameStateProvider.notifier).hireHeadCoach(c);
                                              if (context.mounted && ok) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(' ${c.fullName} yeni teknik direktörünüz olarak göreve başladı!')),
                                                );
                                              }
                                            },
                                      backgroundColor: isCurrent ? AppColors.neutral700 : AppColors.neonLime,
                                      textColor: isCurrent ? Colors.white54 : Colors.black,
                                      child: Text(isCurrent ? 'GÖREVDE' : 'ANLAŞ (₣${c.signingFee})'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
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

  /// Uzman Transfer Pazarı Modalı
  void _showStaffMarketModal(BuildContext context, WidgetRef ref, dynamic gameState) {
    AudioSynthesizer.playClick();
    final candidates = StaffMarketCatalog.getAvailableMarketCandidates();
    final cash = gameState.userClub.meters.cash;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: RetroWindow(
            title: 'UZMAN TRANSFER PAZARI & ADAYLAR',
            icon: '',
            titleBarColor: AppColors.win95TitleNavy,
            onClose: () => Navigator.pop(ctx),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kulübün performansını artırmak için üst düzey uzmanlarla anlaşın:',
                    style: AppTypography.bodySmall(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  ...candidates.map((candidate) {
                    final canAfford = cash >= candidate.signingFee;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neoInnerBg,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            color: Colors.black,
                            alignment: Alignment.center,
                            child: Text(candidate.role.icon, style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      candidate.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      color: AppColors.neonLime,
                                      child: Text(
                                        'SV. ${candidate.level}',
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 8.5),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${candidate.role.label} • ${candidate.specialtyDescription}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                                ),
                                Text(
                                  'İmza: ₣${candidate.signingFee} • Maaş: ₣${candidate.weeklySalary}/h',
                                  style: const TextStyle(color: AppColors.accentGold, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          RetroButton(
                            backgroundColor: canAfford ? AppColors.neonLime : AppColors.neutral700,
                            textColor: canAfford ? Colors.black : Colors.white70,
                            onPressed: () async {
                              AudioSynthesizer.playClick();
                              Navigator.pop(ctx);
                              final ok = await ref.read(gameStateProvider.notifier).hireStaffMember(candidate);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: ok ? AppColors.neonLime : AppColors.comicRed,
                                    content: Text(
                                      ok
                                          ? '[ANLASMA] ${candidate.name} (${candidate.role.label}) göreve başladı!'
                                          : '[UYARI] Yetersiz transfer bütçesi!',
                                      style: TextStyle(color: ok ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('GÖREVE GETİR', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
