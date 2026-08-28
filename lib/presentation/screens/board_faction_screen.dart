// presentation/screens/board_faction_screen.dart
// Boardroom Political Factions, Internal Lobbying, and Early Election Kongre Screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/president/board_factions.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class BoardFactionScreen extends ConsumerStatefulWidget {
  const BoardFactionScreen({super.key});

  @override
  ConsumerState<BoardFactionScreen> createState() => _BoardFactionScreenState();
}

class _BoardFactionScreenState extends ConsumerState<BoardFactionScreen> {
  late BoardFactionsState _factionsState;

  @override
  void initState() {
    super.initState();
    _factionsState = BoardFactionsState.createInitialState();
  }

  void _lobbyMember(BoardMember member) {
    ref.read(gameStateProvider.notifier).adjustCash(-15000);
    setState(() {
      final updatedMembers = _factionsState.members.map((m) {
        if (m.id == member.id) {
          return BoardMember(
            id: m.id,
            name: m.name,
            role: m.role,
            avatar: m.avatar,
            faction: m.faction,
            votingPowerPercent: m.votingPowerPercent,
            loyaltyScore: (m.loyaltyScore + 20).clamp(0, 100),
            philosophy: m.philosophy,
          );
        }
        return m;
      }).toList();

      _factionsState = BoardFactionsState(
        members: updatedMembers,
        generalAssemblySupportPercent: (_factionsState.generalAssemblySupportPercent + 5).clamp(0, 100),
        isEarlyElectionMotionActive: _factionsState.isEarlyElectionMotionActive,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryDeep,
        content: Text(
          '[ANLASMA] ${member.name} ile akşam yemeği yenildi (-15.000 €). Sadakat +20 arttı!',
          style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final supportPercent = _factionsState.totalPresidentialSupportPercent;

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
            title: Text('YÖNETİM İÇİ HİZİPLER & KULİS ODASI', style: AppTypography.h2(color: Colors.white)),
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
                      // 1. Yönetim Güven & Oy Hakimiyeti Özeti
                      RetroWindow(
                        title: 'YÖNETİM KURULU OY HAKİMİYETİ',
                        icon: '[YÖNETİM]',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('BAŞKANLIK OY GÜCÜ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text(
                                  '%$supportPercent',
                                  style: AppTypography.monoNumber(
                                    color: supportPercent >= 51 ? AppColors.neonLime : AppColors.comicRed,
                                  ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: supportPercent / 100.0,
                              backgroundColor: Colors.black,
                              color: supportPercent >= 51 ? AppColors.neonLime : AppColors.comicRed,
                              minHeight: 10,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              supportPercent >= 51
                                  ? '[ONAY] Yönetim Kurulunda çoğunluk elinizde. Kararlarınız veto edilemez.'
                                  : '[UYARI] DİKKAT: Çoğunluğu kaybettiniz! Muhalif üyeler erken seçim başlatabilir.',
                              style: TextStyle(
                                color: supportPercent >= 51 ? const Color(0xFF006600) : AppColors.comicRed,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2. Yönetim Kurulu Üyeleri Listesi
                      RetroWindow(
                        title: 'YÖNETİM KURULU ÜYELERİ & SADAKAT DURUMU',
                        icon: '',
                        child: Column(
                          children: _factionsState.members.map((member) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.win95Grey,
                                border: Border.all(color: AppColors.win95DarkGrey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(member.avatar, style: const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                            Text(member.role, style: const TextStyle(color: Colors.black54, fontSize: 10)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        color: Colors.black,
                                        child: Text(
                                          'OY: %${member.votingPowerPercent}',
                                          style: const TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Düşüncesi: "${member.philosophy}"',
                                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 10.5, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Sadakat: %${member.loyaltyScore}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      RetroButton(
                                        onPressed: () => _lobbyMember(member),
                                        child: const Text('KULİS & YEMEK (-15K €)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
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

                      // 3. Olağanüstü Seçimli Genel Kurul Çağrısı
                      SizedBox(
                        width: double.infinity,
                        child: RetroButton(
                          backgroundColor: AppColors.comicRed,
                          onPressed: () {
                            ref.read(gameStateProvider.notifier).adjustBoardTrust(15);
                            ref.read(gameStateProvider.notifier).adjustFans(-5);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.primaryDeep,
                                content: Text(
                                  '[DUYURU] OLAĞANÜSTÜ SEÇİMLİ GENEL KURUL ÇAĞRISI YAPILDI! Güvenoyu tazelendi (+15).',
                                  style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                          child: const Text('BOLT OLAĞANÜSTÜ ERKEN SEÇİM ÇAĞRISI YAP (GÜVENOYU TAZELE)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
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
}
