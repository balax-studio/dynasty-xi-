// presentation/widgets/flame_match_pitch_widget.dart
// Embedded Flame GameWidget displaying 2D 60 FPS live soccer pitch with animated player nodes, ball trajectories, and tactical radar.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../domain/entities/player.dart';
import '../../domain/sim/match_events.dart';
import '../flame/live_match_flame_game.dart';
import 'brutalist_icons.dart';

class FlameMatchPitchWidget extends StatefulWidget {
  final List<Player> homePlayers;
  final List<Player> awayPlayers;
  final String homeFormation;
  final String awayFormation;
  final bool isUserHome;
  final int currentMinute;
  final List<MatchEvent> visibleEvents;

  const FlameMatchPitchWidget({
    super.key,
    required this.homePlayers,
    required this.awayPlayers,
    this.homeFormation = '4-3-3',
    this.awayFormation = '4-3-3',
    this.isUserHome = true,
    required this.currentMinute,
    required this.visibleEvents,
  });

  @override
  State<FlameMatchPitchWidget> createState() => _FlameMatchPitchWidgetState();
}

class _FlameMatchPitchWidgetState extends State<FlameMatchPitchWidget> {
  late LiveMatchFlameGame _game;
  int _lastHandledMinute = -1;

  @override
  void initState() {
    super.initState();
    _game = LiveMatchFlameGame(
      homePlayers: widget.homePlayers,
      awayPlayers: widget.awayPlayers,
      homeFormation: widget.homeFormation,
      awayFormation: widget.awayFormation,
      isUserHome: widget.isUserHome,
    );
  }

  @override
  void didUpdateWidget(covariant FlameMatchPitchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.homePlayers != oldWidget.homePlayers ||
        widget.awayPlayers != oldWidget.awayPlayers ||
        widget.homeFormation != oldWidget.homeFormation ||
        widget.awayFormation != oldWidget.awayFormation) {
      _game.updatePlayers(
        newHomePlayers: widget.homePlayers,
        newAwayPlayers: widget.awayPlayers,
        newHomeFormation: widget.homeFormation,
        newAwayFormation: widget.awayFormation,
      );
    }

    if (widget.currentMinute != _lastHandledMinute) {
      _lastHandledMinute = widget.currentMinute;
      final eventsInMinute = widget.visibleEvents
          .where((e) => e.minute == widget.currentMinute)
          .toList();
      _game.onMinuteTick(widget.currentMinute, eventsInMinute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: AppColors.win95DarkGrey, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            // Flame 60 FPS Game Canvas
            GameWidget(game: _game),

            // Retro Arcade HUD Corner Overlays
            Positioned(
              top: 6,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  border: Border.all(color: AppColors.neonLime, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrutalistIcon(BrutalistIconType.radar, size: 10, color: AppColors.neonLime),
                    SizedBox(width: 4),
                    Text(
                      'FLAME 2D RADAR • 60 FPS',
                      style: TextStyle(
                        color: AppColors.neonLime,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 6,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  border: Border.all(color: AppColors.accentGold, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrutalistIcon(BrutalistIconType.analytics, size: 10, color: AppColors.accentGold),
                    SizedBox(width: 4),
                    Text(
                      'AI: BEHAVIOR TREE',
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
