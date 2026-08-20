// main.dart
// Dynasty XI - Main Flutter application entry point with Riverpod, Neo-Brutalist 16-Bit Arcade Navigation Deck & Start Menu.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_typography.dart';
import 'application/providers/game_state_provider.dart';
import 'core/audio/audio_synthesizer.dart';
import 'presentation/screens/board_room_screen.dart';
import 'presentation/screens/facilities_screen.dart';
import 'presentation/screens/ftue_screen.dart';
import 'presentation/screens/league_screen.dart';
import 'presentation/screens/manager_screen.dart';
import 'presentation/screens/office_screen.dart';
import 'presentation/screens/press_conference_screen.dart';
import 'presentation/screens/scouting_screen.dart';
import 'presentation/screens/shop_screen.dart';
import 'presentation/screens/squad_screen.dart';
import 'presentation/screens/staff_screen.dart';
import 'presentation/screens/transfer_screen.dart';
import 'presentation/screens/trophy_room_screen.dart';
import 'presentation/widgets/retro_window.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: DynastyXIApp(),
    ),
  );
}

class DynastyXIApp extends StatelessWidget {
  const DynastyXIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynasty XI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainLayoutScreen(),
    );
  }
}

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentTabIndex = 0;
  Timer? _clockTimer;

  final List<Widget> _screens = const [
    OfficeScreen(),
    SquadScreen(),
    TransferScreen(),
    FacilitiesScreen(),
    LeagueScreen(),
    ManagerScreen(),
    ShopScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 1 saniyelik dijital saat ve tesis inşaat kontrol zamanlayıcısı
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        ref.read(gameStateProvider.notifier).checkFacilityUpgrades();
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.neoPitchBlack,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: AppColors.neoBoxDecoration(
              backgroundColor: AppColors.neoCardBg,
              borderColor: Colors.black,
              shadowColor: AppColors.neonLime,
              borderWidth: 2.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚽', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text('DYNASTY XI', style: AppTypography.h1(color: AppColors.neonLime)),
                const SizedBox(height: 6),
                Text('VERİLER YÜKLENİYOR...', style: AppTypography.label(color: Colors.white)),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(color: AppColors.neonLime, strokeWidth: 3),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.neoPitchBlack,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RetroWindow(
              title: 'SİSTEM HATASI',
              icon: '⚠️',
              titleBarColor: AppColors.comicRed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Oyun verisi yüklenirken bir sorun oluştu:', style: AppTypography.bodySmall(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('$error', style: AppTypography.monoNumber(color: AppColors.comicRed).copyWith(fontSize: 11)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.comicRed),
                    onPressed: () {
                      ref.read(gameStateProvider.notifier).resetGame();
                    },
                    child: const Text('Kariyeri Sıfırla ve Yeniden Başlat'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      data: (gameState) {
        // FTUE Onboarding Kontrolü
        if (gameState.isFtueActive) {
          return FtueScreen(
            onComplete: () {
              setState(() {
                _currentTabIndex = 0;
              });
            },
          );
        }

        return Scaffold(
          backgroundColor: AppColors.neoPitchBlack,
          body: IndexedStack(
            index: _currentTabIndex,
            children: _screens,
          ),
          bottomNavigationBar: _buildNeoArcadeDeck(context, gameState),
        );
      },
    );
  }

  /// Neo-Brutalist 16-Bit Arcade Navigasyon Çubuğu
  Widget _buildNeoArcadeDeck(BuildContext context, dynamic gameState) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final navItems = [
      (icon: '🏢', label: 'OFİS'),
      (icon: '⚽', label: 'KADRO'),
      (icon: '🔍', label: 'TRANSFER'),
      (icon: '🏗️', label: 'TESİS'),
      (icon: '🏆', label: 'LİG'),
      (icon: '👔', label: 'MENAJER'),
      (icon: '💎', label: 'MAĞAZA'),
    ];

    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.neoCardBg,
        border: Border(
          top: BorderSide(color: Colors.black, width: 3.0),
        ),
      ),
      child: Row(
        children: [
          // 1. Neo-Brutalist "DYNASTY MENU" Ana Buton
          GestureDetector(
            onTap: () => _showStartMenuModal(context, gameState),
            child: Container(
              margin: const EdgeInsets.only(left: 6, right: 4, top: 5, bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: AppColors.neoBoxDecoration(
                backgroundColor: AppColors.comicYellow,
                borderColor: Colors.black,
                shadowColor: AppColors.neonPink,
                shadowOffset: const Offset(3, 3),
                borderWidth: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    'DYNASTY',
                    style: AppTypography.label(color: Colors.black).copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 8, thickness: 2.0, color: Colors.black),

          // 2. Neo-Brutalist Arcade Sekme Butonları
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = _currentTabIndex == index;

                return GestureDetector(
                  onTap: () {
                    AudioSynthesizer.playClick();
                    setState(() {
                      _currentTabIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: AppColors.neoBoxDecoration(
                      backgroundColor: isSelected ? AppColors.neonLime : AppColors.neoInnerBg,
                      borderColor: Colors.black,
                      shadowColor: isSelected ? AppColors.neonCyan : Colors.transparent,
                      shadowOffset: isSelected ? const Offset(2.5, 2.5) : Offset.zero,
                      borderWidth: isSelected ? 2.2 : 1.5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          item.label,
                          style: AppTypography.label(
                            color: isSelected ? Colors.black : AppColors.neutral50,
                          ).copyWith(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Neo-Brutalist Canlı Saat & Ses Paneli
          Container(
            margin: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: AppColors.neonLime, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AudioSynthesizer.soundEnabled ? Icons.volume_up : Icons.volume_off,
                  size: 13,
                  color: AudioSynthesizer.soundEnabled ? AppColors.neonLime : AppColors.comicRed,
                ),
                const SizedBox(width: 6),
                Text(
                  timeStr,
                  style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Neo-Brutalist Dynasty HUD Menüsü
  void _showStartMenuModal(BuildContext context, dynamic gameState) {
    AudioSynthesizer.playClick();
    final club = gameState.userClub;
    var currentTicketPrice = club.ticketPrice;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: RetroWindow(
                title: 'DYNASTY HUD — AYARLAR VE KULÜP PANELİ',
                icon: '🎮',
                titleBarColor: AppColors.neoCardBg,
                onClose: () => Navigator.pop(ctx),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Kulüp Başlık Alanı
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: AppColors.comicBoxDecoration(
                        backgroundColor: AppColors.neoInnerBg,
                        borderColor: Colors.black,
                        shadowColor: AppColors.neonLime,
                      ),
                      child: Row(
                        children: [
                          Text(club.badgeIcon, style: const TextStyle(fontSize: 34)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  club.name.toUpperCase(),
                                  style: AppTypography.h3(color: AppColors.neonLime),
                                ),
                                Text(
                                  'Menajer: ${gameState.manager.name} • Seviye ${gameState.manager.level}',
                                  style: AppTypography.bodySmall(color: AppColors.neutral300),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bilet Fiyatı Ayarlama Sürgüsü
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: AppColors.neonCyan, width: 2.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '🎟️ STADYUM BİLET FİYATI:',
                                style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 11),
                              ),
                              Text(
                                '₣$currentTicketPrice / bilet',
                                style: AppTypography.monoNumber(color: AppColors.accentGold).copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                          Slider(
                            value: currentTicketPrice.toDouble(),
                            min: 5,
                            max: 50,
                            divisions: 45,
                            activeColor: AppColors.neonLime,
                            inactiveColor: AppColors.neutral700,
                            onChanged: (val) {
                              setModalState(() {
                                currentTicketPrice = val.round();
                              });
                              ref.read(gameStateProvider.notifier).updateTicketPrice(val.round());
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                     // Hızlı Aksiyon Butonları
                    Row(
                      children: [
                        Expanded(
                          child: RetroButton(
                            backgroundColor: AudioSynthesizer.soundEnabled ? AppColors.neonLime : AppColors.comicRed,
                            textColor: AudioSynthesizer.soundEnabled ? Colors.black : Colors.white,
                            onPressed: () {
                              AudioSynthesizer.toggleSound();
                              setModalState(() {});
                              setState(() {});
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AudioSynthesizer.soundEnabled ? '🔊' : '🔇'),
                                const SizedBox(width: 6),
                                Text(
                                  AudioSynthesizer.soundEnabled ? 'SES: AÇIK' : 'SES: KAPALI',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RetroButton(
                            backgroundColor: AppColors.comicYellow,
                            textColor: Colors.black,
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TrophyRoomScreen()),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🏆'),
                                SizedBox(width: 6),
                                Text('KUPA ODASI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // BAŞKANLIK DEPARTMANLARI (Tam Sayfa Yönlendirme)
                    Row(
                      children: [
                        Expanded(
                          child: RetroButton(
                            backgroundColor: AppColors.neonLime,
                            textColor: Colors.black,
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffScreen()));
                            },
                            child: const Text('👔 TEKNİK EKİP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: RetroButton(
                            backgroundColor: AppColors.neonCyan,
                            textColor: Colors.black,
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const BoardRoomScreen()));
                            },
                            child: const Text('🏛️ YÖNETİM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: RetroButton(
                            backgroundColor: AppColors.neonPink,
                            textColor: Colors.black,
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const PressConferenceScreen()));
                            },
                            child: const Text('🎙️ BASIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: RetroButton(
                            backgroundColor: AppColors.comicYellow,
                            textColor: Colors.black,
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ScoutingScreen()));
                            },
                            child: const Text('🛰️ SCOUT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Kariyeri Baştan Başlat Butonu
                    SizedBox(
                      width: double.infinity,
                      child: RetroButton(
                        backgroundColor: AppColors.comicRed,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showResetConfirmDialog(context);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('⚠️'),
                            SizedBox(width: 6),
                            Text('KARİYERİ SIFIRLA (BAŞTAN BAŞLA)', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.neoCardBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.comicRed, width: 3),
          borderRadius: BorderRadius.circular(0),
        ),
        title: Text('⚠️ KARİYERİ SIFIRLA?', style: AppTypography.h2(color: AppColors.comicRed)),
        content: Text(
          'Tüm ilerlemeniz, tesisleriniz ve kupalarınız silinecek. Baştan başlamak istediğinize emin misiniz?',
          style: AppTypography.body(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.comicRed),
            onPressed: () {
              ref.read(gameStateProvider.notifier).resetGame();
              Navigator.pop(ctx);
            },
            child: const Text('Evet, Sıfırla'),
          ),
        ],
      ),
    );
  }
}
