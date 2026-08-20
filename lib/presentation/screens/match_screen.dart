// presentation/screens/match_screen.dart
// Live match simulation screen featuring 2D CustomPainter pitch, commentary feed, half-time talks, and in-game substitutions (§11.3, §11.4).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../application/providers/game_state_provider.dart';
import '../../core/audio/audio_synthesizer.dart';
import '../../domain/entities/club.dart';
import '../../domain/sim/half_time_talk.dart';
import '../../domain/sim/match_engine.dart';
import '../../domain/sim/match_events.dart';
import '../../domain/media/press_conference.dart';
import '../../domain/media/fan_social_buzz.dart';
import '../widgets/pitch_painter.dart';
import '../widgets/ref_tunnel_confrontation_dialog.dart';
import '../widgets/retro_window.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final bool isLiveMode;

  const MatchScreen({
    super.key,
    this.isLiveMode = true,
  });

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  int currentMinute = 0;
  Timer? _ticker;
  List<MatchEvent> visibleEvents = [];
  dynamic _matchResult;
  bool isFinished = false;
  bool hasHalfTimeTalked = false;
  bool isHalfTimeModalActive = false;
  MatchEvent? activeKeyMoment;
  int simulationSpeedMs = 300; // 1x=400ms, 2x=200ms, 4x=80ms

  @override
  void initState() {
    super.initState();
    AudioSynthesizer.playWhistle();
    _startSimulation();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _startSimulation() async {
    final state = ref.read(gameStateProvider).valueOrNull;
    if (state == null) return;

    final fixture = state.currentLeague.fixtures.firstWhere(
      (f) => f.matchday == state.clock.matchday && !f.isPlayed,
      orElse: () => state.currentLeague.fixtures.first,
    );
    final isUserHome = fixture.homeClubId == state.userClub.id;
    final oppId = isUserHome ? fixture.awayClubId : fixture.homeClubId;
    final oppName = state.currentLeague.getClubName(oppId);
    final oppBadge = state.currentLeague.getClubBadge(oppId);

    final result = await ref.read(gameStateProvider.notifier).playMatch(isLiveMode: true);
    if (!mounted) return;

    // Sonuç null dönerse (örn. maç daha önce simüle edilmişse) fallback maç motorunu çalıştır
    final matchRes = result ?? MatchEngine(DateTime.now().millisecondsSinceEpoch).simulate(
      MatchSetup(
        home: isUserHome ? state.userClub : Club(
          id: oppId,
          name: oppName,
          city: 'Anadolu',
          leagueTier: state.userClub.leagueTier,
          badgeIcon: oppBadge,
          squad: state.userClub.squad,
          starting11Ids: state.userClub.starting11Ids,
        ),
        away: !isUserHome ? state.userClub : Club(
          id: oppId,
          name: oppName,
          city: 'Anadolu',
          leagueTier: state.userClub.leagueTier,
          badgeIcon: oppBadge,
          squad: state.userClub.squad,
          starting11Ids: state.userClub.starting11Ids,
        ),
        seed: DateTime.now().millisecondsSinceEpoch,
        isLiveMode: true,
      ),
    );

    setState(() {
      _matchResult = matchRes;
    });

    _startTimer();
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(Duration(milliseconds: simulationSpeedMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Devre Arası Kontrolü (45. Dakika)
      if (currentMinute == 45 && !hasHalfTimeTalked) {
        timer.cancel();
        setState(() {
          isHalfTimeModalActive = true;
          hasHalfTimeTalked = true;
        });
        return;
      }

      if (currentMinute >= 90) {
        timer.cancel();
        AudioSynthesizer.playWhistle();
        setState(() {
          isFinished = true;
        });
        return;
      }

      setState(() {
        currentMinute++;
        final eventsInMinute = _matchResult.events.where((e) => (e as MatchEvent).minute == currentMinute).cast<MatchEvent>().toList();
        visibleEvents.addAll(eventsInMinute);

        // Gol sesi
        if (eventsInMinute.any((e) => e.type == MatchEventType.goal)) {
          AudioSynthesizer.playGoalFanfare();
        }

        // Key Moment kontrolü
        final keyMoment = eventsInMinute.where((e) => e.type == MatchEventType.keyMoment).firstOrNull;
        if (keyMoment != null && activeKeyMoment == null) {
          activeKeyMoment = keyMoment;
          _ticker?.cancel();
        }
      });
    });
  }

  void _resumeAfterKeyMoment(LiveDecisionOption option) {
    AudioSynthesizer.playClick();
    setState(() {
      activeKeyMoment = null;
      visibleEvents.add(MatchEvent(
        minute: currentMinute,
        type: MatchEventType.keyMoment,
        description: 'Taktik Talimatı Verildi: ${option.label}',
      ));
    });

    _startTimer();
  }

  void _applyHalfTimeTalk(HalfTimeTalkType talkType) {
    AudioSynthesizer.playClick();
    final state = ref.read(gameStateProvider).valueOrNull;
    if (state != null) {
      final talkResult = HalfTimeTalkHandler.applyTalk(
        club: state.userClub,
        talkType: talkType,
        isTrailing: false,
      );

      visibleEvents.add(MatchEvent(
        minute: 45,
        type: MatchEventType.halfTimeTalk,
        description: 'Devre Arası: ${talkResult.description}',
      ));
    }

    setState(() {
      isHalfTimeModalActive = false;
    });

    _startTimer();
  }

  void _openSubstitutionModal() {
    _ticker?.cancel();
    final state = ref.read(gameStateProvider).valueOrNull;
    if (state == null) return;

    final starters = state.userClub.starting11;
    final bench = state.userClub.bench;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.neutral900,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CANLI OYUNCU DEĞİŞİKLİĞİ', style: AppTypography.h3()),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _startTimer();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Çıkarmak istediğiniz oyuncuyu ve yerine girecek yedeği seçin:', style: AppTypography.bodySmall()),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: starters.length,
                      itemBuilder: (context, index) {
                        final starter = starters[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: AppColors.neutral800,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.signalGreen,
                              child: Text(starter.position.code, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(starter.fullName, style: AppTypography.body()),
                            subtitle: Text('Kondisyon: %${starter.fitness} • OVR: ${starter.overall}', style: AppTypography.bodySmall(color: AppColors.neutral300)),
                            trailing: bench.isNotEmpty
                                ? DropdownButton<String>(
                                    hint: const Text('Değiştir', style: TextStyle(fontSize: 12, color: AppColors.accentGold)),
                                    dropdownColor: AppColors.neutral900,
                                    underline: const SizedBox(),
                                    items: bench.map((b) {
                                      return DropdownMenuItem<String>(
                                        value: b.id,
                                        child: Text('${b.position.code} - ${b.fullName} (${b.overall})', style: const TextStyle(fontSize: 12)),
                                      );
                                    }).toList(),
                                    onChanged: (subId) {
                                      if (subId != null) {
                                        AudioSynthesizer.playClick();
                                        final subResult = InMatchSubstitutionHandler.substitutePlayer(
                                          club: state.userClub,
                                          playerOutId: starter.id,
                                          playerInId: subId,
                                        );
                                        if (subResult.success) {
                                          visibleEvents.add(MatchEvent(
                                            minute: currentMinute,
                                            type: MatchEventType.substitution,
                                            description: subResult.message,
                                          ));
                                        }
                                        Navigator.pop(ctx);
                                        _startTimer();
                                      }
                                    },
                                  )
                                : const Text('Yedek Yok', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ),
                        );
                      },
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider).valueOrNull;
    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final homeClub = state.userClub;
    final fixture = state.currentLeague.fixtures.firstWhere(
      (f) => f.matchday == state.clock.matchday && !f.isPlayed,
      orElse: () => state.currentLeague.fixtures.first,
    );
    final isUserHome = fixture.homeClubId == state.userClub.id;
    final oppId = isUserHome ? fixture.awayClubId : fixture.homeClubId;
    final oppName = state.currentLeague.getClubName(oppId);
    final oppBadge = state.currentLeague.getClubBadge(oppId);

    final homeName = isUserHome ? state.userClub.name : oppName;
    final homeBadge = isUserHome ? state.userClub.badgeIcon : oppBadge;
    final awayName = !isUserHome ? state.userClub.name : oppName;
    final awayBadge = !isUserHome ? state.userClub.badgeIcon : oppBadge;

    final currentScoreHome = visibleEvents.isNotEmpty ? visibleEvents.last.scoreHome : 0;
    final currentScoreAway = visibleEvents.isNotEmpty ? visibleEvents.last.scoreAway : 0;

    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      appBar: AppBar(
        title: Text('CANLI MAÇ — $currentMinute\'', style: AppTypography.h3()),
        actions: [
          // Oyuncu Değişikliği Butonu
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: AppColors.accentGold),
            tooltip: 'Oyuncu Değişikliği Yap',
            onPressed: _openSubstitutionModal,
          ),
          // Hız Seçici
          PopupMenuButton<int>(
            icon: const Icon(Icons.speed, color: AppColors.signalGreen),
            tooltip: 'Simülasyon Hızı',
            onSelected: (speed) {
              setState(() {
                simulationSpeedMs = speed;
              });
              _startTimer();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 450, child: Text('1x Normal Hız')),
              const PopupMenuItem(value: 200, child: Text('2x Hızlı')),
              const PopupMenuItem(value: 60, child: Text('4x Çok Hızlı')),
            ],
          ),
          // Hızlı Bitir
          IconButton(
            icon: const Icon(Icons.fast_forward),
            tooltip: 'Hızlı Bitir',
            onPressed: () {
              _ticker?.cancel();
              AudioSynthesizer.playWhistle();
              setState(() {
                currentMinute = 90;
                visibleEvents = _matchResult?.events ?? [];
                isFinished = true;
                activeKeyMoment = null;
                isHalfTimeModalActive = false;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Skor Tabelası
              _buildScoreboard(
                homeName: homeName,
                homeBadge: homeBadge,
                awayName: awayName,
                awayBadge: awayBadge,
                scoreHome: currentScoreHome,
                scoreAway: currentScoreAway,
              ),

              // 2. 2D Saha Görselleştirmesi
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomPaint(
                      painter: PitchPainter(
                        homePlayers: homeClub.starting11,
                        homeFormation: homeClub.formation,
                        ballPosition: _calculateBallOffset(currentMinute),
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ),

              // 2.5. BAŞKAN CANLI MAÇ MÜDAHALE BARINI (CHAIRMAN LIVE MATCH BAR)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: AppColors.neonLime, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Text('👔 BAŞKAN:', style: TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 10)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ActionChip(
                              backgroundColor: AppColors.neoInnerBg,
                              side: const BorderSide(color: AppColors.comicRed, width: 1.5),
                              label: const Text('⚡ HAKEM ODASI BASKINI', style: TextStyle(color: AppColors.comicRed, fontSize: 10, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                RefTunnelConfrontationDialog.show(context, (outcome) {
                                  setState(() {
                                    visibleEvents.add(MatchEvent(
                                      minute: currentMinute,
                                      type: MatchEventType.yellowCard,
                                      description: '🚨 BAŞKAN KORİDORDA: ${outcome.title}! ${outcome.narrative}',
                                    ));
                                  });
                                });
                              },
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              backgroundColor: AppColors.neoInnerBg,
                              side: const BorderSide(color: AppColors.accentGold, width: 1.5),
                              label: const Text('💰 PRİM VADET (-₣10K)', style: TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                ref.read(gameStateProvider.notifier).claimSponsorReward(-10000);
                                setState(() {
                                  visibleEvents.add(MatchEvent(
                                    minute: currentMinute,
                                    type: MatchEventType.keyMoment,
                                    description: '💰 BAŞKAN: Soyunma Odasına +₣10,000 Maç Primi Vadetti! Takım Ateşlendi!',
                                  ));
                                });
                                AudioSynthesizer.playGoalFanfare();
                              },
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              backgroundColor: AppColors.neoInnerBg,
                              side: const BorderSide(color: AppColors.neonPink, width: 1.5),
                              label: const Text('🔥 DEV DERBİ PRİMİ (-₣25K)', style: TextStyle(color: AppColors.neonPink, fontSize: 10, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                ref.read(gameStateProvider.notifier).claimSponsorReward(-25000);
                                setState(() {
                                  visibleEvents.add(MatchEvent(
                                    minute: currentMinute,
                                    type: MatchEventType.keyMoment,
                                    description: '🔥 BAŞKAN: Soyunma Odasına ₣25.000 Dev Derbi Prim Sözü Verdi! Oyuncular Sahayı Yakıyor!',
                                  ));
                                });
                                AudioSynthesizer.playGoalFanfare();
                              },
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              backgroundColor: AppColors.neoInnerBg,
                              side: const BorderSide(color: AppColors.neonCyan, width: 1.5),
                              label: const Text('🎆 MEŞALE & PANKART ŞOVU', style: TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                setState(() {
                                  visibleEvents.add(MatchEvent(
                                    minute: currentMinute,
                                    type: MatchEventType.keyMoment,
                                    description: '🎆 TRİBÜNLER: Dev Pankart ve Meşale Şovu Başladı! Stat Alev Alev!',
                                  ));
                                });
                              },
                            ),
                            const SizedBox(width: 6),
                            ActionChip(
                              backgroundColor: AppColors.neoInnerBg,
                              side: const BorderSide(color: AppColors.neonLime, width: 1.5),
                              label: const Text('⚡ HOCAYA: HÜCUM ET', style: TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                setState(() {
                                  visibleEvents.add(MatchEvent(
                                    minute: currentMinute,
                                    type: MatchEventType.keyMoment,
                                    description: '⚡ BAŞKAN TALİMATI: Hoca Takımı Tüm Hatlarıyla Hücuma Sürdü!',
                                  ));
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Canlı Anlatım / Yorum Kutusu
              Expanded(
                flex: 4,
                child: _buildCommentaryFeed(),
              ),
            ],
          ),

          // 4. Devre Arası Konuşması Modalı
          if (isHalfTimeModalActive) _buildHalfTimeTalkOverlay(),

          // 5. Key Moment Taktik Diyaloğu
          if (activeKeyMoment != null) _buildKeyMomentDialog(activeKeyMoment!),

          // 6. Maç Sonu Özet Ekranı
          if (isFinished)
            _buildMatchSummaryOverlay(
              context,
              homeName: homeName,
              homeBadge: homeBadge,
              awayName: awayName,
              awayBadge: awayBadge,
            ),
        ],
      ),
    );
  }

  Widget _buildHalfTimeTalkOverlay() {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accentGold, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('☕', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text('DEVRE ARASI SOYUNMA ODASI', style: AppTypography.h2(color: AppColors.accentGold)),
            const SizedBox(height: 6),
            Text('Takıma ikinci yarı öncesi nasıl bir taktik konuşma yapacaksın?', style: AppTypography.bodySmall(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ...HalfTimeTalkType.values.map((talk) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RetroButton(
                  backgroundColor: AppColors.neutral800,
                  textColor: Colors.white,
                  onPressed: () => _applyHalfTimeTalk(talk),
                  child: Row(
                    children: [
                      Text(talk.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(talk.title, style: AppTypography.body().copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                            Text(talk.description, style: AppTypography.bodySmall(color: AppColors.neutral300).copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboard({
    required String homeName,
    required String homeBadge,
    required String awayName,
    required String awayBadge,
    required int scoreHome,
    required int scoreAway,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.win95Grey,
        border: Border(
          bottom: BorderSide(color: AppColors.win95DarkGrey, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Ev Sahibi
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
                  left: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
                  right: BorderSide(color: AppColors.win95White, width: 1.5),
                  bottom: BorderSide(color: AppColors.win95White, width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  Text(homeBadge, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 2),
                  Text(
                    homeName.toUpperCase(),
                    style: AppTypography.label(color: Colors.white).copyWith(fontSize: 12),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('xG: ${_matchResult?.xgHome ?? "0.0"}', style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 9)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Dijital Skor Kutusu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: AppColors.neonPink, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.neonPink,
                  blurRadius: 4,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Text(
              '$scoreHome : $scoreAway',
              style: AppTypography.display(color: AppColors.neonLime).copyWith(fontSize: 34),
            ),
          ),
          const SizedBox(width: 8),

          // Deplasman
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
                  left: BorderSide(color: AppColors.win95DarkGrey, width: 1.5),
                  right: BorderSide(color: AppColors.win95White, width: 1.5),
                  bottom: BorderSide(color: AppColors.win95White, width: 1.5),
                ),
              ),
              child: Column(
                children: [
                  Text(awayBadge, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 2),
                  Text(
                    awayName.toUpperCase(),
                    style: AppTypography.label(color: Colors.white).copyWith(fontSize: 12),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('xG: ${_matchResult?.xgAway ?? "0.0"}', style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 9)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentaryFeed() {
    if (visibleEvents.isEmpty) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: AppColors.neonLime, strokeWidth: 2),
            ),
            const SizedBox(height: 10),
            Text(
              '> HAKEM DÜDÜĞÜ ÇALDI, MAÇ BAŞLIYOR...',
              style: AppTypography.label(color: AppColors.neonLime).copyWith(fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFF0D1117),
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.all(10),
        itemCount: visibleEvents.length,
        itemBuilder: (context, index) {
          final event = visibleEvents[visibleEvents.length - 1 - index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  color: Colors.black,
                  child: Text(
                    '${event.minute.toString().padLeft(2, '0')}\'',
                    style: AppTypography.monoNumber(color: AppColors.neonLime).copyWith(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 6),
                Text(event.type.icon, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.description,
                    style: AppTypography.bodySmall(color: Colors.white).copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeyMomentDialog(MatchEvent keyMoment) {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentGold, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡ CANLI TAKTİK KARARI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
            const SizedBox(height: 12),
            Text(keyMoment.description, textAlign: TextAlign.center, style: AppTypography.body()),
            const SizedBox(height: 20),
            if (keyMoment.decisionOptions != null)
              ...keyMoment.decisionOptions!.map((opt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RetroButton(
                      backgroundColor: AppColors.neutral800,
                      textColor: Colors.white,
                      onPressed: () => _resumeAfterKeyMoment(opt),
                      child: Text(opt.label, style: AppTypography.label(color: Colors.white)),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  PressOption? _selectedPressOption;

  Widget _buildMatchSummaryOverlay(
    BuildContext context, {
    required String homeName,
    required String homeBadge,
    required String awayName,
    required String awayBadge,
  }) {
    final result = _matchResult;
    final userClubHome = homeName == ref.read(gameStateProvider).value?.userClub.name;
    final userGoals = userClubHome ? (result?.homeGoals ?? 0) : (result?.awayGoals ?? 0);
    final oppGoals = userClubHome ? (result?.awayGoals ?? 0) : (result?.homeGoals ?? 0);
    final oppName = userClubHome ? awayName : homeName;

    final pressConf = PressConferenceGenerator.generatePostMatchConference(
      userGoals: userGoals,
      oppGoals: oppGoals,
      opponentName: oppName,
    );

    final fanTweets = FanSocialBuzzGenerator.generateFanTweets(
      userClubName: userClubHome ? homeName : awayName,
      userGoals: userGoals,
      oppGoals: oppGoals,
      opponentName: oppName,
    );

    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.neutral900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentGold, width: 2),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('MAÇ SONA ERDİ', style: AppTypography.h2(color: AppColors.accentGold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(homeBadge, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(homeName, style: AppTypography.h3(), overflow: TextOverflow.ellipsis),
                  const SizedBox(width: 12),
                  Text(
                    '${result?.homeGoals ?? 0} - ${result?.awayGoals ?? 0}',
                    style: AppTypography.h1(color: AppColors.signalGreen).copyWith(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Text(awayName, style: AppTypography.h3(), overflow: TextOverflow.ellipsis),
                  const SizedBox(width: 8),
                  Text(awayBadge, style: const TextStyle(fontSize: 24)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Topla Oynama: %${result?.possessionHome ?? 50} - %${result?.possessionAway ?? 50} • xG: ${result?.xgHome ?? "0.0"} - ${result?.xgAway ?? "0.0"}', style: AppTypography.bodySmall()),
              const SizedBox(height: 12),

              // BASIN TOPLANTISI (§16)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neoInnerBg,
                  border: Border.all(color: AppColors.neonCyan),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🎙️ ', style: TextStyle(fontSize: 14)),
                        Text('${pressConf.reporterName} (${pressConf.mediaOutlet})', style: AppTypography.label(color: AppColors.neonCyan).copyWith(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(pressConf.question, style: AppTypography.bodySmall(color: Colors.white).copyWith(fontSize: 10)),
                    const SizedBox(height: 8),
                    Column(
                      children: pressConf.options.map((opt) {
                        final isSelected = _selectedPressOption == opt;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPressOption = opt;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF003322) : Colors.black45,
                                border: Border.all(color: isSelected ? AppColors.neonLime : Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  Text(opt.stance.icon, style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      opt.text,
                                      style: TextStyle(color: isSelected ? AppColors.neonLime : Colors.white70, fontSize: 9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // TRİBÜN VE SOSYAL MEDYA SESİ (§16.2)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📢 TRİBÜN & SOSYAL MEDYA SESİ', style: AppTypography.label(color: AppColors.accentGold).copyWith(fontSize: 10)),
                    const SizedBox(height: 4),
                    ...fanTweets.take(2).map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '${t.authorName} (${t.handle}): ${t.content}',
                            style: const TextStyle(color: Colors.white70, fontSize: 9),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  backgroundColor: AppColors.signalGreen,
                  textColor: Colors.black,
                  onPressed: () {
                    AudioSynthesizer.playClick();
                    Navigator.of(context).pop();
                  },
                  child: Text('KULÜP OFİSİNE DÖN', style: AppTypography.label(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Offset _calculateBallOffset(int minute) {
    if (_matchResult == null || minute == 0) {
      return const Offset(0.50, 0.50); // Santra noktası
    }

    // O anki veya en son gerçekleşen olay
    final recentEvent = visibleEvents.isNotEmpty ? visibleEvents.last : null;
    if (recentEvent != null && recentEvent.minute == minute) {
      if (recentEvent.type == MatchEventType.goal) {
        return recentEvent.isHomeTeam ? const Offset(0.50, 0.08) : const Offset(0.50, 0.92);
      }
      if (recentEvent.type == MatchEventType.shotSaved || recentEvent.type == MatchEventType.shotOffTarget) {
        return recentEvent.isHomeTeam ? const Offset(0.50, 0.16) : const Offset(0.50, 0.84);
      }
      if (recentEvent.type == MatchEventType.foul) {
        return const Offset(0.40, 0.50);
      }
    }

    // Dinamik saha içi pas ve hücum hareketliliği
    final phase = (minute % 8);
    final isHomeAttacking = (minute % 6) < 3;
    final waveX = 0.20 + 0.60 * ((minute * 3) % 7) / 7.0;

    if (isHomeAttacking) {
      // Ev sahibi hücumda: top 0.55'ten 0.15'e doğru ilerler
      final progressY = 0.55 - (phase / 8.0) * 0.38;
      return Offset(waveX, progressY.clamp(0.12, 0.88));
    } else {
      // Deplasman hücumda: top 0.45'ten 0.85'e doğru ilerler
      final progressY = 0.45 + (phase / 8.0) * 0.38;
      return Offset(waveX, progressY.clamp(0.12, 0.88));
    }
  }
}
