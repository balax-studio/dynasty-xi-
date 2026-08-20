// presentation/screens/player_dialogue_screen.dart
// Visual Novel style RPG Player Dialogue and Interview subpage.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../domain/entities/player.dart';
import '../../domain/rpg/player_dialogue_engine.dart';
import '../widgets/face_avatar_widget.dart';
import '../widgets/retro_window.dart';
import '../widgets/under_the_table_bribe_dialog.dart';

class PlayerDialogueScreen extends ConsumerStatefulWidget {
  final Player player;
  final bool isOwned;

  const PlayerDialogueScreen({
    super.key,
    required this.player,
    this.isOwned = true,
  });

  @override
  ConsumerState<PlayerDialogueScreen> createState() => _PlayerDialogueScreenState();
}

class _PlayerDialogueScreenState extends ConsumerState<PlayerDialogueScreen> {
  late Player _currentPlayer;
  late List<DialogueTopic> _topics;
  DialogueTopic? _selectedTopic;
  DialogueResult? _lastResult;
  DialogueOption? _lastChosenOption;
  String _currentReactionEmoji = '💬';

  @override
  void initState() {
    super.initState();
    _currentPlayer = widget.player;
    _topics = PlayerDialogueEngine.getTopicsForPlayer(_currentPlayer, isOwned: widget.isOwned);
    if (_topics.isNotEmpty) {
      _selectedTopic = _topics.first;
    }
  }

  void _onSelectOption(DialogueOption option, int clubCash, int clubLockerRoom) {
    if (_selectedTopic == null) return;

    final result = PlayerDialogueEngine.evaluateChoice(
      player: _currentPlayer,
      topic: _selectedTopic!,
      option: option,
      clubCash: clubCash,
      clubLockerRoom: clubLockerRoom,
    );

    setState(() {
      _lastChosenOption = option;
      _lastResult = result;
      _currentReactionEmoji = result.reactionEmoji;

      // Local player deltas for instantaneous responsiveness
      _currentPlayer = _currentPlayer.copyWith(
        morale: (_currentPlayer.morale + result.deltaMorale).clamp(0, 100),
        loyalty: (_currentPlayer.loyalty + result.deltaLoyalty).clamp(0, 100),
        form: (_currentPlayer.form + result.deltaForm).clamp(1.0, 10.0),
        sharpness: (_currentPlayer.sharpness + result.deltaSharpness).clamp(0, 100),
        fitness: (_currentPlayer.fitness + result.deltaFitness).clamp(0, 100),
      );
    });

    // Update centralized GameState
    ref.read(gameStateProvider.notifier).applyPlayerDialogueResult(
          playerId: _currentPlayer.id,
          result: result,
          isOwned: widget.isOwned,
          unownedPlayer: widget.isOwned ? null : _currentPlayer,
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
        final rarityColor = AppColors.getRarityColor(_currentPlayer.stars);

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.win95TitleNavy,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  color: Colors.black,
                  child: Text(
                    _currentPlayer.position.code,
                    style: TextStyle(
                      color: rarityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.isOwned
                        ? 'ÖZEL GÖRÜŞME ODASI: ${_currentPlayer.fullName}'
                        : 'TRANSFER MÜLAKATI: ${_currentPlayer.fullName}',
                    style: AppTypography.h1(color: Colors.white).copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // 1. Konuşmacı Portresi ve Görsel Roman Konuşma Balonu
              _buildSpeakerHeroSection(_currentPlayer, rarityColor),

              // 2. Etkileşim ve Seçenek Alanı (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sonuç Kartı (Eğer bir seçenek tıklandıysa)
                      if (_lastResult != null) ...[
                        _buildOutcomeCard(_lastResult!, _lastChosenOption!),
                        const SizedBox(height: 12),
                      ],

                      // Konu Seçim Sekmeleri
                      _buildTopicSelector(),
                      const SizedBox(height: 8),

                      // Başkanlık Özel Hediye / Gizli Prim Butonu
                      RetroButton(
                        onPressed: () => UnderTheTableBribeDialog.show(context, _currentPlayer),
                        backgroundColor: AppColors.win95Grey,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🎁', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 6),
                            Text('ELDEN GİZLİ PRİM / LÜKS HEDİYE VER (SAAT, ARABA, REZİDANS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.win95TitleNavy)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Seçilen Konunun Seçenekleri
                      if (_selectedTopic != null)
                        _buildOptionsWindow(_selectedTopic!, club.meters.cash, club.meters.lockerRoom),

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

  /// 1. Üst Portre ve Görsel Roman Diyalog Balonu
  Widget _buildSpeakerHeroSection(Player p, Color rarityColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF0D131F),
        border: Border(bottom: BorderSide(color: Colors.white24, width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 16-Bit Avatar ve Anlık Reaksiyon Emojisi
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: rarityColor, width: 2),
                ),
                child: FaceAvatarWidget(seed: p.faceSeed, size: 68),
              ),
              Positioned(
                bottom: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 1.5),
                  ),
                  child: Text(_currentReactionEmoji, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Diyalog Konuşma Balonu
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF161E2E),
                border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.fullName.toUpperCase(),
                        style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        color: Colors.black,
                        child: Text(
                          p.personality.label.toUpperCase(),
                          style: const TextStyle(color: AppColors.neonAmber, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 8),
                  Text(
                    _lastResult != null
                        ? _lastResult!.playerReplyText
                        : (widget.isOwned
                            ? '"Buyrun hocam, sizi dinliyorum. Takım veya kendi durumumla ilgili konuşmak istediğiniz bir şey mi vardı?"'
                            : '"Merhaba patron. Kulübünüzün benimle ilgilendiğini duydum. Nasıl bir planınız var?"'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Seçim Sonrası Anlık Etki Kartı
  Widget _buildOutcomeCard(DialogueResult result, DialogueOption chosenOption) {
    return RetroWindow(
      title: 'GÖRÜŞME SONUCU & RPG ETKİLERİ',
      icon: '📊',
      titleBarColor: AppColors.neonLime,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  chosenOption.tone,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: result.summaryDeltas.map((delta) {
              final isPositive = delta.startsWith('+') || delta.contains('%');
              final isNegative = delta.startsWith('-');
              final chipColor = isPositive ? AppColors.neonLime : (isNegative ? AppColors.comicRed : AppColors.neonCyan);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: chipColor, width: 1.5),
                ),
                child: Text(
                  delta,
                  style: AppTypography.monoNumber(color: chipColor).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 3. Konu Seçim Butonları
  Widget _buildTopicSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GÖRÜŞME KONUSU SEÇİN:',
          style: AppTypography.label(color: AppColors.neonAmber).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _topics.map((topic) {
              final isSelected = _selectedTopic?.id == topic.id;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: RetroButton(
                  onPressed: () {
                    setState(() {
                      _selectedTopic = topic;
                    });
                  },
                  backgroundColor: isSelected ? AppColors.neonCyan : const Color(0xFF1E293B),
                  textColor: isSelected ? Colors.black : Colors.white,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(topic.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        topic.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 4. Seçilen Konunun Seçenekler Penceresi
  Widget _buildOptionsWindow(DialogueTopic topic, int clubCash, int clubLockerRoom) {
    return RetroWindow(
      title: '${topic.icon} ${topic.title.toUpperCase()}',
      icon: '💬',
      titleBarColor: AppColors.win95TitleNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              topic.subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
          ...topic.options.map((option) {
            final isRecentlyChosen = _lastChosenOption?.id == option.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _onSelectOption(option, clubCash, clubLockerRoom),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isRecentlyChosen ? const Color(0xFF1E3A5F) : AppColors.neoInnerBg,
                    border: Border.all(
                      color: isRecentlyChosen ? AppColors.neonLime : Colors.white24,
                      width: isRecentlyChosen ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: Colors.black,
                            child: Text(
                              option.tone,
                              style: const TextStyle(
                                color: AppColors.neonLime,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text('Seç ▶', style: TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"${option.title}"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
