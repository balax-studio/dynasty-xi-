// presentation/screens/staff_screen.dart
// Full-screen Technical Staff & Backroom Specialists Management screen (§8.2, §13).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/staff.dart';
import '../../domain/president/head_coach.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';
import 'head_coach_hiring_screen.dart';
import 'legal_defense_screen.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  late List<StaffMember> _staffMembers;

  @override
  void initState() {
    super.initState();
    _staffMembers = StaffGenerator.generateDefaultStaff();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (ctx, ref, _) {
        final stateAsync = ref.watch(gameStateProvider);

        return stateAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
          data: (gameState) {
            final club = gameState.userClub;
            final headCoach = gameState.headCoach;
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
                          // 0. Kulüp Hukuk Bürosu & Tahkim Kurulu Butonu
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
                                  Text('⚖️', style: TextStyle(fontSize: 16)),
                                  SizedBox(width: 6),
                                  Text('KULÜP HUKUK BÜROSU & TAHKİM KURULU İTİRAZLARI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 1. Mevcut Teknik Direktör Penceresi
                          RetroWindow(
                            title: 'FAAL TEKNİK DİREKTÖR (HEAD COACH)',
                            icon: '👔',
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
                                      child: const Text('👔', style: TextStyle(fontSize: 26)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            headCoach?.fullName ?? 'SERGEN HOCA (BAŞ ANTRENÖR)',
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
                                        '${headCoach?.reputation ?? 79} OVR',
                                        style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(color: AppColors.win95DarkGrey, height: 1),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'BAŞKANLIK TALİMATI (BAŞKAN DİREKTİFİ):',
                                      style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 10),
                                    ),
                                    RetroButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const HeadCoachHiringScreen()),
                                        );
                                      },
                                      backgroundColor: AppColors.accentGold,
                                      textColor: Colors.black,
                                      child: const Text('DETAYLI YÖNETİM & VİZYON', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Siz kulüp başkanısınız. Taktiksel detaylar teknik direktörün yetkisindedir. Direktif vererek hocayı yönlendirebilirsiniz.',
                                  style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _buildDirectiveChip(context, ref, '🎯 Genç Oyuncuları Oynat', AppColors.neonLime),
                                    _buildDirectiveChip(context, ref, '⚡ En Güçlü 11\'i Sahaya Sür', AppColors.neonCyan),
                                    _buildDirectiveChip(context, ref, '🛡️ Skoru Koru & Savunma Yap', AppColors.neonAmber),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 2. Arka Ofis ve Uzman Ekip (Backroom Staff) (§8.2)
                          RetroWindow(
                            title: 'KULÜP ARKA OFİS UZMANLARI (BACKROOM STAFF)',
                            icon: '🔬',
                            titleBarColor: const Color(0xFF1E3A8A),
                            child: Column(
                              children: _staffMembers.map((staff) {
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
                                        child: Text(staff.role.icon, style: const TextStyle(fontSize: 18)),
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
                                            Text(
                                              '${staff.role.label} • ${staff.specialtyDescription}',
                                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('₣${staff.weeklySalary}/h', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 11)),
                                          const SizedBox(height: 2),
                                          if (staff.level < 5)
                                            RetroButton(
                                              onPressed: () {
                                                final cost = staff.level * 2500;
                                                if (club.meters.cash >= cost) {
                                                  setState(() {
                                                    final idx = _staffMembers.indexOf(staff);
                                                    _staffMembers[idx] = StaffMember(
                                                      id: staff.id,
                                                      role: staff.role,
                                                      name: staff.name,
                                                      level: staff.level + 1,
                                                      weeklySalary: staff.weeklySalary + 400,
                                                      specialtyDescription: staff.specialtyDescription,
                                                    );
                                                  });
                                                  ref.read(gameStateProvider.notifier).claimSponsorReward(-cost);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('🎓 ${staff.name} kursu tamamlayarak Seviye ${staff.level + 1} oldu!')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('⚠️ Yetersiz bütçe!')),
                                                  );
                                                }
                                              },
                                              backgroundColor: AppColors.neonCyan,
                                              textColor: Colors.black,
                                              child: Text('GELİŞTİR (₣${staff.level * 2500})', style: const TextStyle(fontSize: 8)),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 3. Teknik Direktör Transfer Pazarı
                          RetroWindow(
                            title: 'TEKNİK DİREKTÖR BORSASI & ADAYLAR',
                            icon: '💼',
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
                                                      SnackBar(content: Text('👔 ${c.fullName} yeni teknik direktörünüz olarak göreve başladı!')),
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
      },
    );
  }

  Widget _buildDirectiveChip(BuildContext context, WidgetRef ref, String text, Color color) {
    return ActionChip(
      backgroundColor: Colors.black,
      side: BorderSide(color: color, width: 1.5),
      label: Text(text, style: AppTypography.label(color: color).copyWith(fontSize: 10)),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎯 Başkanlık talimatı iletildi: "$text"')),
        );
      },
    );
  }
}
