// presentation/screens/manager_screen.dart
// Manager RPG progression, Level 1-30 XP curve, 5-Branch Skill Tree, and UEFA Coaching Licenses (§13, §14).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/manager.dart';
import '../../domain/progression/coaching_license.dart';
import '../../domain/progression/manager_skill_tree.dart';
import '../widgets/career_share_dialog.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_pixel_icon.dart';
import '../widgets/retro_window.dart';
import 'affiliate_clubs_screen.dart';
import 'head_coach_hiring_screen.dart';
import 'staff_screen.dart';
import 'trophy_room_screen.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  late ManagerSkillTree _skillTree;

  @override
  void initState() {
    super.initState();
    _skillTree = ManagerSkillTree.createInitialTree();
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
            final manager = gameState.manager;

            return Scaffold(
              backgroundColor: AppColors.primaryDeep,
              appBar: AppBar(
                backgroundColor: AppColors.win95TitleNavy,
                title: Text('MENAJER PROFİLİ & RPG YETENEK MATRİSİ', style: AppTypography.h2(color: Colors.white)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: AppColors.neonCyan),
                    tooltip: 'Kariyer Kartını Paylaş',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CareerShareDialog(gameState: gameState),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_events, color: AppColors.accentGold),
                    tooltip: 'Kupa Odası & Kulüp Müzesi',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TrophyRoomScreen()),
                      );
                    },
                  ),
                ],
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
                          // 0. Pilot Takım Ağ Protokolleri Butonu
                          SizedBox(
                            width: double.infinity,
                            child: RetroButton(
                              backgroundColor: AppColors.win95TitleNavy,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AffiliateClubsScreen()),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RetroPixelIcon(type: RetroPixelIconType.handshake, size: 16, color: AppColors.accentGold),
                                  SizedBox(width: 8),
                                  Text('PİLOT TAKIM & UYDU KULÜP AĞI PROTOKOLLERİ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 1. Menajer Profil Kartı & XP Barı
                          RetroWindow(
                            title: 'KULLANICI VE KARİYER KİMLİĞİ',
                            icon: 'user',
                            child: Column(
                              children: [
                                _buildProfileCard(manager),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RetroButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const StaffScreen()),
                                          );
                                        },
                                        backgroundColor: AppColors.win95TitleNavy,
                                        textColor: Colors.white,
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              RetroPixelIcon(type: RetroPixelIconType.suit, size: 15, color: Colors.white),
                                              SizedBox(width: 6),
                                              Text('TEKNİK EKİP (STAFF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                            ],
                                          ),
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
                                        backgroundColor: AppColors.neonLime,
                                        textColor: Colors.black,
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 4.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              RetroPixelIcon(type: RetroPixelIconType.tacticsBoard, size: 15, color: Colors.black),
                                              SizedBox(width: 6),
                                              Text('HOCA TRANSFERİ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 1.5. Kulüp Teknik Heyeti & Yardımcı Uzmanlar Paneli
                          RetroWindow(
                            title: 'KULÜP TEKNİK HEYETİ & ASİSTANLAR (${gameState.staff.length} UZMAN)',
                            icon: '',
                            titleBarColor: AppColors.win95TitleNavy,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'YARDIMCI KADROSU & UZMANLAR',
                                      style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 10.5),
                                    ),
                                    Text(
                                      '${gameState.staff.length} / 5 Aktif Kadro',
                                      style: const TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: gameState.staff.map((s) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        border: Border.all(color: AppColors.win95DarkGrey),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(s.role.icon, style: const TextStyle(fontSize: 12)),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${s.name} (Lv.${s.level})',
                                            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: RetroButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const StaffScreen()),
                                      );
                                    },
                                    backgroundColor: AppColors.accentGold,
                                    textColor: Colors.black,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('[KADRO]', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                          SizedBox(width: 8),
                                          Text(
                                            'TEKNİK EKİP YÖNETİMİ & UZMAN GELİŞTİR (STAFF)',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 2. UEFA Antrenörlük Lisansı Modülü (§13.2)
                          RetroWindow(
                            title: 'UEFA ANTRENÖRLÜK LİSANSI & AKREDİTASYON',
                            icon: '',
                            titleBarColor: const Color(0xFF6E5000),
                            child: Row(
                              children: [
                                Text(manager.license.badge, style: const TextStyle(fontSize: 32)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(manager.license.title, style: AppTypography.label(color: AppColors.accentGold).copyWith(fontSize: 12)),
                                      Text(
                                        'Tüm Yetenek Çarpanı: +%${((manager.license.allPerkMultiplier - 1.0) * 100).round()} • İtibar Desteği',
                                        style: AppTypography.bodySmall(color: Colors.white70).copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                if (manager.license != CoachingLicense.uefaPro)
                                  RetroButton(
                                    onPressed: () {
                                      _showLicenseUpgradeDialog(context, ref, manager, gameState.userClub.meters.cash);
                                    },
                                    backgroundColor: AppColors.accentGold,
                                    textColor: Colors.black,
                                    child: const Text('KURS BAŞLAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // 3. 5-Branş Yetenek Ağacı
                          RetroWindow(
                            title: 'RPG YETENEK AĞACI (5 ANA BRANŞ - 25 PERK)',
                            icon: 'BOLT',
                            titleBarColor: AppColors.win95TitleNavy,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('KULLANILABİLİR YETENEK PUANI:', style: AppTypography.label(color: Colors.white).copyWith(fontSize: 11)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      color: Colors.black,
                                      child: Text(
                                        'PUAN: ${manager.availableSkillPoints}',
                                        style: AppTypography.label(
                                          color: manager.availableSkillPoints > 0
                                              ? AppColors.neonLime
                                              : AppColors.win95DarkGrey,
                                        ).copyWith(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                ..._skillTree.branches.map((branch) {
                                  return _buildBranchSection(context, ref, branch, manager);
                                }),
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
      },
    );
  }

  Widget _buildBranchSection(BuildContext context, WidgetRef ref, SkillBranch branch, Manager manager) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Text(branch.type.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(branch.name.toUpperCase(), style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: branch.skills.map((skill) {
              final isUnlocked = manager.unlockedPerkIds.contains(skill.id) || skill.isUnlocked;
              final canUnlock = !isUnlocked && manager.availableSkillPoints >= skill.costPoints;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isUnlocked ? const Color(0xFF1E3A1E) : Colors.black45,
                  border: Border.all(
                    color: isUnlocked ? AppColors.neonLime : (canUnlock ? AppColors.accentGold : Colors.white12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(skill.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(skill.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          Text(skill.description, style: const TextStyle(color: Colors.white60, fontSize: 9.5)),
                        ],
                      ),
                    ),
                    if (!isUnlocked)
                      RetroButton(
                        onPressed: canUnlock
                            ? () {
                                ref.read(gameStateProvider.notifier).spendSkillPoint(skill.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('[YETENEK] "${skill.name}" yeteneği başarıyla açıldı!')),
                                );
                              }
                            : null,
                        backgroundColor: canUnlock ? AppColors.neonLime : AppColors.win95DarkGrey,
                        textColor: Colors.black,
                        child: Text('${skill.costPoints} PUAN', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: Colors.black,
                        child: const Text('AÇIK', style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 9)),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showLicenseUpgradeDialog(BuildContext context, WidgetRef ref, Manager manager, int cash) {
    final nextLicense = manager.license == CoachingLicense.uefaC
        ? CoachingLicense.uefaB
        : (manager.license == CoachingLicense.uefaB ? CoachingLicense.uefaA : CoachingLicense.uefaPro);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.neoCardBg,
        title: Text('UEFA LİSANS KURSU', style: AppTypography.h2(color: AppColors.accentGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hedef: ${nextLicense.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Text('Gereken Menajer Seviyesi: Sv.${nextLicense.requiredManagerLevel} (Mevcut: Sv.${manager.level})', style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text('Kurs Harcı: ₣${nextLicense.courseCost} (Kasa: ₣$cash)', style: const TextStyle(color: AppColors.neonLime, fontSize: 11)),
          ],
        ),
        actions: [
          RetroButton(
            onPressed: () => Navigator.pop(ctx),
            backgroundColor: AppColors.win95DarkGrey,
            textColor: Colors.black,
            child: const Text('VAZGEÇ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          RetroButton(
            onPressed: (manager.level >= nextLicense.requiredManagerLevel && cash >= nextLicense.courseCost)
                ? () {
                    Navigator.pop(ctx);
                    ref.read(gameStateProvider.notifier).upgradeCoachingLicense(nextLicense);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('[KUTLAMA] Tebrikler! ${nextLicense.title} başarıyla alındı!')),
                    );
                  }
                : null,
            backgroundColor: AppColors.accentGold,
            textColor: Colors.black,
            child: const Text('ÖDE VE BAŞLA'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Manager manager) {
    final progress = manager.levelProgress;
    final nextLvlXp = manager.xpRequiredForNextLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: AppColors.neonLime, width: 2),
              ),
              alignment: Alignment.center,
              child: const RetroPixelIcon(type: RetroPixelIconType.suit, size: 26, color: AppColors.neonLime),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(manager.name.toUpperCase(), style: AppTypography.h2(color: Colors.white).copyWith(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(
                    'SEVİYE ${manager.level} TEKNİK DİREKTÖR • ${manager.license.badge}',
                    style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('XP GELİŞİMİ:', style: AppTypography.label(color: Colors.white70).copyWith(fontSize: 10)),
            Text('${manager.currentXp} / $nextLvlXp XP', style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.black,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonLime),
          minHeight: 8,
        ),
      ],
    );
  }
}
