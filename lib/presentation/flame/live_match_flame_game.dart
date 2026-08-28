// presentation/flame/live_match_flame_game.dart
// Hardware-accelerated 2D 60 FPS live match simulation engine powered by Flame.
// Incorporates BehaviorTree tactical decisions, ball physics, player movement lerping, and goal celebrations.

import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../domain/entities/player.dart';
import '../../domain/sim/match_events.dart';
import '../../domain/tactics/behavior_tree_tactics.dart';

class LiveMatchFlameGame extends FlameGame {
  List<Player> homePlayers;
  List<Player> awayPlayers;
  String homeFormation;
  String awayFormation;
  bool isUserHome;

  late PitchFieldComponent _field;
  late BallComponent _ball;
  final List<PlayerNodeComponent> _homePlayerComponents = [];
  final List<PlayerNodeComponent> _awayPlayerComponents = [];
  final List<TacticalRadarPingComponent> _radarPings = [];

  int currentMinute = 0;
  MatchEvent? lastEvent;
  TacticalActionType? currentTacticalAction;
  String currentActionLabel = '';
  double shakeIntensity = 0.0;
  final math.Random _rng = math.Random(42);

  LiveMatchFlameGame({
    required this.homePlayers,
    required this.awayPlayers,
    this.homeFormation = '4-3-3',
    this.awayFormation = '4-3-3',
    this.isUserHome = true,
  });

  @override
  Color backgroundColor() => const Color(0xFF0A1F11);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Saha Zemin Bileşeni
    _field = PitchFieldComponent();
    await add(_field);

    // 2. Top Bileşeni
    _ball = BallComponent();
    await add(_ball);

    // 3. Oyuncu Bileşenlerini Yükle
    _spawnPlayers();
  }

  void updatePlayers({
    required List<Player> newHomePlayers,
    required List<Player> newAwayPlayers,
    String? newHomeFormation,
    String? newAwayFormation,
  }) {
    homePlayers = newHomePlayers;
    awayPlayers = newAwayPlayers;
    if (newHomeFormation != null) homeFormation = newHomeFormation;
    if (newAwayFormation != null) awayFormation = newAwayFormation;
    _spawnPlayers();
  }

  void _spawnPlayers() {
    for (final comp in _homePlayerComponents) {
      comp.removeFromParent();
    }
    for (final comp in _awayPlayerComponents) {
      comp.removeFromParent();
    }
    _homePlayerComponents.clear();
    _awayPlayerComponents.clear();

    // Ev Sahibi (Yeşil / Neon Lime)
    final homeCoords = _getFormationAnchors(homeFormation, isHome: true);
    for (var i = 0; i < 11; i++) {
      final p = i < homePlayers.length ? homePlayers[i] : null;
      final anchor = i < homeCoords.length ? homeCoords[i] : Vector2(0.5, 0.7);
      final comp = PlayerNodeComponent(
        player: p,
        isHome: true,
        anchorRatio: anchor,
        number: i + 1,
        fallbackName: p != null ? p.lastName : 'Oyuncu ${i + 1}',
        fallbackPosition: _getPositionCode(i),
      );
      _homePlayerComponents.add(comp);
      add(comp);
    }

    // Deplasman (Neon Cyan / Mavi)
    final awayCoords = _getFormationAnchors(awayFormation, isHome: false);
    for (var i = 0; i < 11; i++) {
      final p = i < awayPlayers.length ? awayPlayers[i] : null;
      final anchor = i < awayCoords.length ? awayCoords[i] : Vector2(0.5, 0.3);
      final comp = PlayerNodeComponent(
        player: p,
        isHome: false,
        anchorRatio: anchor,
        number: i + 1,
        fallbackName: p != null ? p.lastName : 'Rakip ${i + 1}',
        fallbackPosition: _getPositionCode(i),
      );
      _awayPlayerComponents.add(comp);
      add(comp);
    }
  }

  /// Her dakika değiştiğinde çağrılır: Taktik kararlar ve top/oyuncu aksiyonlarını günceller
  void onMinuteTick(int minute, List<MatchEvent> eventsThisMinute) {
    currentMinute = minute;
    if (eventsThisMinute.isNotEmpty) {
      lastEvent = eventsThisMinute.last;
    }

    final hasGoal = eventsThisMinute.any((e) => e.type == MatchEventType.goal);
    final hasShot = eventsThisMinute.any((e) => e.type == MatchEventType.shotSaved || e.type == MatchEventType.shotOffTarget);
    final isHomeTeamEvent = lastEvent?.isHomeTeam ?? (minute % 2 == 0);

    // 1. Taktik Karar Motoru Değerlendirmesi (Behavior Tree)
    _evaluateTacticalBehavior(minute, isHomeTeamEvent, hasGoal, hasShot);

    // 2. Top Hedef Noktası Hesapla
    final targetBallRatio = _calculateBallTarget(minute, eventsThisMinute, isHomeTeamEvent);
    _ball.setTargetRatio(targetBallRatio, isHighTrajectory: hasGoal || hasShot || (minute % 5 == 0));

    // 3. Gol Kutlaması & Ekran Titremesi
    if (hasGoal) {
      shakeIntensity = 12.0;
      add(GoalCelebrationParticleEmitter(
        isHomeGoal: isHomeTeamEvent,
        positionRatio: isHomeTeamEvent ? Vector2(0.5, 0.08) : Vector2(0.5, 0.92),
      ));
    } else if (hasShot) {
      shakeIntensity = 4.0;
    }

    // 4. Oyuncu Pozisyonlarını Dinamik Kaydır (Shift & Press)
    _updatePlayerTacticalPositions(minute, targetBallRatio, isHomeTeamEvent);
  }

  void _evaluateTacticalBehavior(int minute, bool isHomeAttacking, bool hasGoal, bool hasShot) {
    // Topu taşıyan oyuncuyu belirle
    Player? carrier;
    if (isHomeAttacking && _homePlayerComponents.isNotEmpty) {
      final activeIndex = (minute * 3) % _homePlayerComponents.length;
      carrier = _homePlayerComponents[activeIndex].player;
    } else if (!isHomeAttacking && _awayPlayerComponents.isNotEmpty) {
      final activeIndex = (minute * 3) % _awayPlayerComponents.length;
      carrier = _awayPlayerComponents[activeIndex].player;
    }

    if (carrier == null && homePlayers.isNotEmpty) {
      carrier = homePlayers.first;
    }

    if (carrier != null) {
      final distanceToGoal = hasGoal ? 12.0 : (hasShot ? 18.0 : (25.0 + (minute % 20)));
      final ctx = TacticalContext(
        actor: carrier,
        distanceToGoal: distanceToGoal,
        defendersInFront: (minute % 3),
        passingLaneOpenness: 0.5 + (_rng.nextDouble() * 0.4),
        hasSupportRunner: (minute % 2 == 0),
        matchMomentum: isHomeAttacking ? 0.7 : 0.3,
      );

      currentTacticalAction = TacticalBehaviorTree.evaluateBestAction(ctx);
      currentActionLabel = _getActionLabel(currentTacticalAction!, hasGoal, hasShot);

      // Topu taşıyan oyuncuya vurgu yap
      for (final comp in _homePlayerComponents) {
        comp.hasBall = (comp.player?.id == carrier.id);
        if (comp.hasBall) {
          comp.showActionBubble(currentActionLabel);
          _addRadarPing(comp.positionRatio);
        }
      }
      for (final comp in _awayPlayerComponents) {
        comp.hasBall = (comp.player?.id == carrier.id);
        if (comp.hasBall) {
          comp.showActionBubble(currentActionLabel);
          _addRadarPing(comp.positionRatio);
        }
      }
    }
  }

  void _addRadarPing(Vector2 ratio) {
    if (_radarPings.length > 4) {
      _radarPings.first.removeFromParent();
      _radarPings.removeAt(0);
    }
    final ping = TacticalRadarPingComponent(positionRatio: ratio);
    _radarPings.add(ping);
    add(ping);
  }

  String _getActionLabel(TacticalActionType action, bool hasGoal, bool hasShot) {
    if (hasGoal) return 'GOL';
    if (hasShot) return 'İSABETLİ ŞUT';
    switch (action) {
      case TacticalActionType.shoot:
        return 'ŞUT DENEMESİ';
      case TacticalActionType.throughBall:
        return 'DERİN ARA PASI';
      case TacticalActionType.wingCross:
        return 'KANAT ORTASI';
      case TacticalActionType.dribblePast:
        return 'DRİBLİNG & ÇALIM';
      case TacticalActionType.retainPossession:
        return 'KONTROLLÜ PAS';
      case TacticalActionType.tacticalFoul:
        return 'TAKTİK FAUL';
    }
  }

  Vector2 _calculateBallTarget(int minute, List<MatchEvent> events, bool isHomeAttacking) {
    if (minute == 0) return Vector2(0.5, 0.5);

    if (events.isNotEmpty) {
      final ev = events.last;
      if (ev.type == MatchEventType.goal) {
        return ev.isHomeTeam ? Vector2(0.50, 0.06) : Vector2(0.50, 0.94);
      }
      if (ev.type == MatchEventType.shotSaved || ev.type == MatchEventType.shotOffTarget) {
        final spreadX = 0.40 + (_rng.nextDouble() * 0.20);
        return ev.isHomeTeam ? Vector2(spreadX, 0.14) : Vector2(spreadX, 0.86);
      }
      if (ev.type == MatchEventType.foul) {
        return Vector2(0.35 + (_rng.nextDouble() * 0.30), 0.50);
      }
    }

    final waveX = 0.20 + 0.60 * ((minute * 4) % 9) / 9.0;
    if (isHomeAttacking) {
      final progressY = 0.60 - ((minute % 6) / 6.0) * 0.45;
      return Vector2(waveX, progressY.clamp(0.10, 0.90));
    } else {
      final progressY = 0.40 + ((minute % 6) / 6.0) * 0.45;
      return Vector2(waveX, progressY.clamp(0.10, 0.90));
    }
  }

  void _updatePlayerTacticalPositions(int minute, Vector2 ballPos, bool isHomeAttacking) {
    // Ev Sahibi Oyuncularının Hareketlenmesi
    for (var i = 0; i < _homePlayerComponents.length; i++) {
      final comp = _homePlayerComponents[i];
      final base = comp.anchorRatio;
      final driftX = (math.sin(minute * 0.6 + i) * 0.05);
      final driftY = isHomeAttacking
          ? -0.08 + (math.cos(minute * 0.5 + i) * 0.04) // Hücumda öne çıkış
          : 0.04 + (math.cos(minute * 0.5 + i) * 0.03);  // Savunmada geri çekiliş
      comp.setTargetRatio(Vector2(
        (base.x + driftX).clamp(0.08, 0.92),
        (base.y + driftY).clamp(0.52, 0.96),
      ));
    }

    // Deplasman Oyuncularının Hareketlenmesi
    for (var i = 0; i < _awayPlayerComponents.length; i++) {
      final comp = _awayPlayerComponents[i];
      final base = comp.anchorRatio;
      final driftX = (math.sin(minute * 0.6 + i + 2) * 0.05);
      final driftY = !isHomeAttacking
          ? 0.08 + (math.cos(minute * 0.5 + i) * 0.04) // Hücumda öne çıkış
          : -0.04 + (math.cos(minute * 0.5 + i) * 0.03); // Savunmada geri çekiliş
      comp.setTargetRatio(Vector2(
        (base.x + driftX).clamp(0.08, 0.92),
        (base.y + driftY).clamp(0.04, 0.48),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (shakeIntensity > 0) {
      shakeIntensity = math.max(0.0, shakeIntensity - dt * 15.0);
    }
  }

  List<Vector2> _getFormationAnchors(String formation, {required bool isHome}) {
    if (isHome) {
      return [
        Vector2(0.50, 0.93), // GK
        Vector2(0.15, 0.81), // LB
        Vector2(0.38, 0.83), // CB
        Vector2(0.62, 0.83), // CB
        Vector2(0.85, 0.81), // RB
        Vector2(0.28, 0.70), // CM
        Vector2(0.50, 0.72), // DM
        Vector2(0.72, 0.70), // CM
        Vector2(0.18, 0.58), // LW
        Vector2(0.50, 0.56), // ST
        Vector2(0.82, 0.58), // RW
      ];
    } else {
      return [
        Vector2(0.50, 0.07), // GK
        Vector2(0.85, 0.19), // RB
        Vector2(0.62, 0.17), // CB
        Vector2(0.38, 0.17), // CB
        Vector2(0.15, 0.19), // LB
        Vector2(0.72, 0.30), // CM
        Vector2(0.50, 0.28), // DM
        Vector2(0.28, 0.30), // CM
        Vector2(0.82, 0.42), // RW
        Vector2(0.50, 0.44), // ST
        Vector2(0.18, 0.42), // LW
      ];
    }
  }

  String _getPositionCode(int i) {
    if (i == 0) return 'GK';
    if (i == 1) return 'RB';
    if (i == 2 || i == 3) return 'CB';
    if (i == 4) return 'LB';
    if (i == 5) return 'CM';
    if (i == 6) return 'DM';
    if (i == 7) return 'CM';
    if (i == 8) return 'RW';
    if (i == 9) return 'ST';
    return 'LW';
  }
}

/// 1. Saha Zemin Bileşeni
class PitchFieldComponent extends Component with HasGameReference<LiveMatchFlameGame> {
  @override
  void render(Canvas canvas) {
    final size = game.size;
    final w = size.x;
    final h = size.y;

    // Yeşil Zemin Şeritleri
    const grassDark = Color(0xFF0F381E);
    const grassLight = Color(0xFF144D2A);
    const stripeCount = 10;
    final stripeH = h / stripeCount;

    for (var i = 0; i < stripeCount; i++) {
      final paint = Paint()..color = i % 2 == 0 ? grassDark : grassLight;
      canvas.drawRect(Rect.fromLTWH(0, i * stripeH, w, stripeH), paint);
    }

    // CRT Scanlines
    final scanline = Paint()..color = Colors.black.withValues(alpha: 0.12);
    for (var y = 0.0; y < h; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(w, y), scanline);
    }

    // Neon Çizgiler
    final linePaint = Paint()
      ..color = AppColors.neonLime.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    const margin = 12.0;
    final pitchRect = Rect.fromLTRB(margin, margin, w - margin, h - margin);

    // Dış Sınır
    canvas.drawRect(pitchRect, linePaint);

    // Orta Çizgi & Orta Daire
    canvas.drawLine(Offset(margin, h / 2), Offset(w - margin, h / 2), linePaint);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.15, linePaint);
    canvas.drawCircle(Offset(w / 2, h / 2), 3.0, Paint()..color = AppColors.neonLime);

    // Ceza Sahaları
    final boxW = w * 0.54;
    final boxH = h * 0.15;
    final goalAreaW = w * 0.28;
    final goalAreaH = h * 0.055;

    // Üst Ceza Sahası (Deplasman Kalesi)
    canvas.drawRect(Rect.fromCenter(center: Offset(w / 2, margin + boxH / 2), width: boxW, height: boxH), linePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(w / 2, margin + goalAreaH / 2), width: goalAreaW, height: goalAreaH), linePaint);

    // Alt Ceza Sahası (Ev Sahibi Kalesi)
    canvas.drawRect(Rect.fromCenter(center: Offset(w / 2, h - margin - boxH / 2), width: boxW, height: boxH), linePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(w / 2, h - margin - goalAreaH / 2), width: goalAreaW, height: goalAreaH), linePaint);

    // Kale Direkleri (Neon Glow)
    final goalPostPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w / 2 - goalAreaW / 2, margin), Offset(w / 2 + goalAreaW / 2, margin), goalPostPaint);
    canvas.drawLine(Offset(w / 2 - goalAreaW / 2, h - margin), Offset(w / 2 + goalAreaW / 2, h - margin), goalPostPaint);
  }
}

/// 2. Oyuncu Düğüm Bileşeni (60 FPS Lerp Hareketli)
class PlayerNodeComponent extends Component with HasGameReference<LiveMatchFlameGame> {
  final Player? player;
  final bool isHome;
  final Vector2 anchorRatio;
  final int number;
  final String? fallbackName;
  final String? fallbackPosition;

  Vector2 currentRatio;
  Vector2 targetRatio;
  bool hasBall = false;
  String? actionBubbleText;
  double bubbleTimer = 0.0;

  PlayerNodeComponent({
    required this.player,
    required this.isHome,
    required this.anchorRatio,
    required this.number,
    this.fallbackName,
    this.fallbackPosition,
  })  : currentRatio = Vector2.copy(anchorRatio),
        targetRatio = Vector2.copy(anchorRatio);

  Vector2 get positionRatio => currentRatio;

  void setTargetRatio(Vector2 target) {
    targetRatio = target;
  }

  void showActionBubble(String text) {
    actionBubbleText = text;
    bubbleTimer = 2.0; // 2 saniye görünür
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Smooth lerp hareketi
    currentRatio.x += (targetRatio.x - currentRatio.x) * dt * 4.0;
    currentRatio.y += (targetRatio.y - currentRatio.y) * dt * 4.0;

    if (bubbleTimer > 0) {
      bubbleTimer -= dt;
      if (bubbleTimer <= 0) actionBubbleText = null;
    }
  }

  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;
    final px = currentRatio.x * w;
    final py = currentRatio.y * h;
    final pos = Offset(px, py);

    final nodeColor = isHome ? AppColors.neonLime : AppColors.neonCyan;

    // Topa Sahip Olma Aurası (Spotlight Glow)
    if (hasBall) {
      final glowPaint = Paint()
        ..color = (isHome ? AppColors.neonLime : AppColors.neonPink).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, 18.0, glowPaint);
    }

    // Kondisyon Çemberi (Stamina Ring)
    final fitness = player?.fitness ?? 90;
    final staminaPaint = Paint()
      ..color = fitness > 70 ? AppColors.signalGreen : (fitness > 45 ? AppColors.accentGold : AppColors.comicRed)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final staminaSweep = (fitness / 100.0) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: pos, radius: 13.5),
      -math.pi / 2,
      staminaSweep,
      false,
      staminaPaint,
    );

    // Gövde (Retro Arcade Beveled Düğüm)
    final bodyPaint = Paint()..color = Colors.black;
    final borderPaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(pos, 11.0, bodyPaint);
    canvas.drawCircle(pos, 11.0, borderPaint);

    // Pozisyon Kodu (ST, GK, CM vs.)
    final posCode = player?.position.code ?? fallbackPosition ?? 'MF';
    final textPainter = TextPainter(
      text: TextSpan(
        text: posCode,
        style: TextStyle(
          color: nodeColor,
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, pos - Offset(textPainter.width / 2, textPainter.height / 2));

    // Oyuncu Soyadı
    final lastName = player?.lastName ?? fallbackName ?? 'Oyuncu';
    final namePainter = TextPainter(
      text: TextSpan(
        text: lastName.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 3),
            Shadow(color: Colors.black, blurRadius: 1),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    namePainter.paint(
      canvas,
      Offset(pos.dx - (namePainter.width / 2), pos.dy + (isHome ? 14 : -21)),
    );

    // Canlı Taktik Baloncuğu (Action Bubble)
    if (actionBubbleText != null) {
      final bubbleBg = Paint()..color = Colors.black87;
      final bubbleBorder = Paint()
        ..color = AppColors.accentGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      final bPainter = TextPainter(
        text: TextSpan(
          text: actionBubbleText!,
          style: const TextStyle(color: AppColors.accentGold, fontSize: 8.5, fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final bubbleRect = Rect.fromCenter(
        center: Offset(pos.dx, pos.dy - 22),
        width: bPainter.width + 10,
        height: bPainter.height + 6,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(bubbleRect, const Radius.circular(4)), bubbleBg);
      canvas.drawRRect(RRect.fromRectAndRadius(bubbleRect, const Radius.circular(4)), bubbleBorder);
      bPainter.paint(canvas, Offset(bubbleRect.left + 5, bubbleRect.top + 3));
    }
  }
}

/// 3. Top Bileşeni (3D Yay Yüksekliği & Hareket İzi)
class BallComponent extends Component with HasGameReference<LiveMatchFlameGame> {
  Vector2 currentRatio = Vector2(0.5, 0.5);
  Vector2 targetRatio = Vector2(0.5, 0.5);
  double heightRatio = 0.0;
  bool isHigh = false;
  double flightProgress = 1.0;

  void setTargetRatio(Vector2 target, {bool isHighTrajectory = false}) {
    targetRatio = target;
    isHigh = isHighTrajectory;
    flightProgress = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (flightProgress < 1.0) {
      flightProgress = math.min(1.0, flightProgress + dt * 3.5);
      currentRatio.x += (targetRatio.x - currentRatio.x) * dt * 5.0;
      currentRatio.y += (targetRatio.y - currentRatio.y) * dt * 5.0;

      if (isHigh) {
        // Parabolik yay (0 -> 1 -> 0)
        heightRatio = math.sin(flightProgress * math.pi) * 14.0;
      } else {
        heightRatio = 0.0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;
    final groundPos = Offset(currentRatio.x * w, currentRatio.y * h);
    final ballPos = Offset(groundPos.dx, groundPos.dy - heightRatio);

    // Top Gölgesi (Yere Yansıyan)
    if (heightRatio > 0) {
      final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
      canvas.drawOval(
        Rect.fromCenter(center: groundPos, width: 8.0 - (heightRatio * 0.2), height: 4.0),
        shadowPaint,
      );
    }

    // Neon Top Parlaması
    final glowPaint = Paint()
      ..color = AppColors.neonPink.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(ballPos, 9.0 + (heightRatio * 0.15), glowPaint);

    // Top Gövdesi
    final ballPaint = Paint()..color = Colors.white;
    canvas.drawCircle(ballPos, 5.5, ballPaint);

    // Top Kenar Çizgisi
    final ballBorder = Paint()
      ..color = AppColors.neonPink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(ballPos, 5.5, ballBorder);
  }
}

/// 4. Taktik Radar Dalgalanma Bileşeni
class TacticalRadarPingComponent extends Component with HasGameReference<LiveMatchFlameGame> {
  final Vector2 positionRatio;
  double radius = 6.0;
  double opacity = 0.8;

  TacticalRadarPingComponent({required this.positionRatio});

  @override
  void update(double dt) {
    super.update(dt);
    radius += dt * 35.0;
    opacity -= dt * 0.9;
    if (opacity <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (opacity <= 0) return;
    final w = game.size.x;
    final h = game.size.y;
    final center = Offset(positionRatio.x * w, positionRatio.y * h);

    final pingPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, pingPaint);
  }
}

/// 5. Gol Kutlaması Parçacık Patlaması
class GoalCelebrationParticleEmitter extends Component with HasGameReference<LiveMatchFlameGame> {
  final bool isHomeGoal;
  final Vector2 positionRatio;
  final List<_GoalParticle> _particles = [];
  double lifetime = 2.5;

  GoalCelebrationParticleEmitter({
    required this.isHomeGoal,
    required this.positionRatio,
  }) {
    final rng = math.Random();
    final colors = [
      AppColors.accentGold,
      AppColors.neonLime,
      AppColors.neonPink,
      AppColors.neonCyan,
      Colors.white,
    ];

    for (var i = 0; i < 40; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final speed = 40.0 + rng.nextDouble() * 120.0;
      _particles.add(_GoalParticle(
        velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
        color: colors[i % colors.length],
        radius: 2.0 + rng.nextDouble() * 3.5,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifetime -= dt;
    if (lifetime <= 0) {
      removeFromParent();
      return;
    }
    for (final p in _particles) {
      p.position.x += p.velocity.x * dt;
      p.position.y += p.velocity.y * dt;
      p.velocity.y += 60.0 * dt; // Yerçekimi
      p.opacity = (lifetime / 2.5).clamp(0.0, 1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;
    final center = Offset(positionRatio.x * w, positionRatio.y * h);

    for (final p in _particles) {
      if (p.opacity <= 0) continue;
      final paint = Paint()..color = p.color.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(center.dx + p.position.x, center.dy + p.position.y), p.radius, paint);
    }
  }
}

class _GoalParticle {
  Vector2 position = Vector2.zero();
  final Vector2 velocity;
  final Color color;
  final double radius;
  double opacity = 1.0;

  _GoalParticle({
    required this.velocity,
    required this.color,
    required this.radius,
  });
}
