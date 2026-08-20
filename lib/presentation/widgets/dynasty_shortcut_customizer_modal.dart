// presentation/widgets/dynasty_shortcut_customizer_modal.dart
// Interactive modal to customize, pin, and unpin Dynasty HUD navigation shortcuts across all 16 club departments.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/navigation/dynasty_navigation_registry.dart';
import 'retro_window.dart';

class DynastyShortcutCustomizerModal extends ConsumerWidget {
  const DynastyShortcutCustomizerModal({super.key});

  static void show(BuildContext context) {
    AudioSynthesizer.playClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DynastyShortcutCustomizerModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateAsync = ref.watch(gameStateProvider);

    return gameStateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
      error: (err, _) => Center(child: Text('Hata: $err', style: AppTypography.body())),
      data: (gameState) {
        final pinnedIds = gameState.pinnedShortcutIds;
        final totalShortcuts = DynastyNavigationRegistry.allShortcuts;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: RetroWindow(
              title: 'DYNASTY HUD — KISAYOL ÖZELLEŞTİRME',
              icon: '⚙️',
              titleBarColor: const Color(0xFF1E293B),
              onClose: () => Navigator.pop(context),
              child: Column(
                children: [
                  // Bilgi ve Sayaç Başlığı
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: AppColors.neonCyan, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KISAYOLLARI SEÇ VE YÖNET',
                              style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 11),
                            ),
                            Text(
                              'Dynasty menüsünde görmek istediğin sayfaları aç/kapat',
                              style: AppTypography.bodySmall(color: AppColors.neutral300).copyWith(fontSize: 9.5),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: AppColors.accentGold,
                          child: Text(
                            '${pinnedIds.length}/${totalShortcuts.length} SABİT',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Kategori Bazlı Kısayol Listesi
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: DynastyShortcutCategory.values.map((category) {
                        final categoryShortcuts = totalShortcuts.where((s) => s.category == category).toList();
                        if (categoryShortcuts.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Kategori Başlık Şeridi
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: const Color(0xFF1E3A8A),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(category.icon, style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Text(
                                      category.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Kategori İçeriğindeki Kısayol Kartları
                              ...categoryShortcuts.map((shortcut) {
                                final isPinned = pinnedIds.contains(shortcut.id);

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: isPinned ? AppColors.neoInnerBg : Colors.black45,
                                    border: Border.all(
                                      color: isPinned ? shortcut.color : AppColors.neutral700,
                                      width: isPinned ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    leading: Text(shortcut.icon, style: const TextStyle(fontSize: 20)),
                                    title: Text(
                                      shortcut.label,
                                      style: TextStyle(
                                        color: isPinned ? Colors.white : AppColors.neutral300,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    trailing: RetroButton(
                                      backgroundColor: isPinned ? AppColors.comicRed : AppColors.neonLime,
                                      textColor: isPinned ? Colors.white : Colors.black,
                                      onPressed: () {
                                        AudioSynthesizer.playClick();
                                        ref.read(gameStateProvider.notifier).toggleShortcutPinned(shortcut.id);
                                      },
                                      child: Text(
                                        isPinned ? 'ÇIKAR ✕' : '+ EKLE',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Alt Aksiyon Butonları
                  Row(
                    children: [
                      Expanded(
                        child: RetroButton(
                          backgroundColor: AppColors.neutral700,
                          textColor: Colors.white,
                          onPressed: () {
                            AudioSynthesizer.playClick();
                            ref.read(gameStateProvider.notifier).resetShortcutsToDefault();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🔄'),
                              SizedBox(width: 6),
                              Text('VARSAYILANA DÖN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RetroButton(
                          backgroundColor: AppColors.accentGold,
                          textColor: Colors.black,
                          onPressed: () {
                            AudioSynthesizer.playClick();
                            Navigator.pop(context);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('💾'),
                              SizedBox(width: 6),
                              Text('KAYDET VE KAPAT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10.5)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
