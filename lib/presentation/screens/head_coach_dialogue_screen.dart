// presentation/screens/head_coach_dialogue_screen.dart
// RPG Head Coach Interactive Dialogue, Management & License Upgrade Screen (§15.4)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/rpg/head_coach_dialogue_engine.dart';
import '../widgets/meters_bar_widget.dart';
import '../widgets/retro_window.dart';

class HeadCoachDialogueScreen extends ConsumerStatefulWidget {
  const HeadCoachDialogueScreen({super.key});

  @override
  ConsumerState<HeadCoachDialogueScreen> createState() => _HeadCoachDialogueScreenState();
}

class _HeadCoachDialogueScreenState extends ConsumerState<HeadCoachDialogueScreen> {
  CoachDialogueTopic _selectedTopic = CoachDialogueTopic.tacticalPlan;
  final List<Map<String, String>> _chatHistory = [];
  bool _isThinking = false;

  @override
  void initState() {
    super.initState();
    // Başlangıç karşılama mesajı
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(gameStateProvider).valueOrNull;
      final coach = state?.headCoach;
      if (coach != null) {
        setState(() {
          _chatHistory.add({
            'sender': 'coach',
            'text': 'Sayın Başkanım hoş geldiniz! Kulübümüzün durumu, taktik planlarımız ve kadro hakkında ne konuşmak istersiniz?',
          });
        });
      }
    });
  }

  void _handleOptionSelect(CoachDialogueOption option) async {
    AudioSynthesizer.playClick();
    setState(() {
      _chatHistory.add({'sender': 'president', 'text': option.presidentSpeech});
      _isThinking = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    setState(() {
      _isThinking = false;
      _chatHistory.add({'sender': 'coach', 'text': option.coachReply});
    });

    await ref.read(gameStateProvider.notifier).executeCoachDialogueChoice(option);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.neonLime,
          content: Text(
            '[RAPOR] ${option.resultSummary}',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(gameStateProvider);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (gameState) {
        final club = gameState.userClub;
        final coach = gameState.headCoach;

        if (coach == null) {
          return Scaffold(
            backgroundColor: AppColors.primaryDeep,
            appBar: AppBar(
              backgroundColor: AppColors.neoCardBg,
              title: const Text('TEKNİK DİREKTÖR ODASI'),
            ),
            body: const Center(
              child: RetroWindow(
                title: 'RESMİ HOCA YOK',
                icon: '[UYARI]',
                titleBarColor: AppColors.comicRed,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Şu anda kulüpte sözleşmeli bir teknik direktör bulunmuyor.\nÖnce Teknik Direktör Merkezinden bir hoca ile sözleşme imzalayın.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        final options = HeadCoachDialogueEngine.getOptionsForTopic(_selectedTopic, coach, gameState);

        return Scaffold(
          backgroundColor: AppColors.primaryDeep,
          appBar: AppBar(
            backgroundColor: AppColors.neoCardBg,
            leading: IconButton(
              icon: const Text('◀', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Text(coach.archetype.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coach.fullName.toUpperCase(), style: AppTypography.h3(color: Colors.white)),
                      Text(
                        '${coach.archetype.label} • ${coach.reputation} OVR • Güven: %${coach.boardConfidence}',
                        style: const TextStyle(color: AppColors.neonLime, fontSize: 9.5, fontWeight: FontWeight.bold),
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

              // 1. Konu Başlıkları Sekmesi
              Container(
                color: AppColors.neoInnerBg,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: CoachDialogueTopic.values.map((topic) {
                      final isSelected = topic == _selectedTopic;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: InkWell(
                          onTap: () {
                            AudioSynthesizer.playClick();
                            setState(() => _selectedTopic = topic);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.neonCyan : Colors.black,
                              border: Border.all(
                                color: isSelected ? Colors.black : AppColors.win95DarkGrey,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              topic.title,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // 2. Diyalog Sohbet Alanı (Chat Log)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _chatHistory.length + (_isThinking ? 1 : 0),
                  itemBuilder: (ctx, index) {
                    if (index == _chatHistory.length && _isThinking) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: AppColors.neonLime),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonLime),
                              ),
                              SizedBox(width: 8),
                              Text('Hoca düşünüyor...', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                            ],
                          ),
                        ),
                      );
                    }

                    final msg = _chatHistory[index];
                    final isPresident = msg['sender'] == 'president';

                    return Align(
                      alignment: isPresident ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isPresident ? const Color(0xFF1E3A8A) : AppColors.neoCardBg,
                          border: Border.all(
                            color: isPresident ? AppColors.accentGold : AppColors.neonLime,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isPresident ? 'CROWN BAŞKAN (${gameState.manager.name})' : ' ${coach.fullName}',
                                  style: TextStyle(
                                    color: isPresident ? AppColors.accentGold : AppColors.neonLime,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['text'] ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 3. Konuşma / Talimat Seçenekleri Paneli
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.neoInnerBg,
                  border: Border(top: BorderSide(color: Colors.black, width: 2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _selectedTopic.description,
                      style: const TextStyle(color: AppColors.neutral300, fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    ...options.map((opt) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: RetroButton(
                          backgroundColor: opt.coachOvrBonus > 0 ? AppColors.accentGold : AppColors.neonLime,
                          textColor: Colors.black,
                          onPressed: () => _handleOptionSelect(opt),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Text('[MESAJ]', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    opt.label,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
                                    overflow: TextOverflow.ellipsis,
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
              ),
            ],
          ),
        );
      },
    );
  }
}
