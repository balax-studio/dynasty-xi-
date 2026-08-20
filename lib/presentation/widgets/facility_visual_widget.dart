// presentation/widgets/facility_visual_widget.dart
// Procedural retro-pixel & isometric visual renderer for all 12 facilities and 5 tiers.
// Includes active construction animation (scaffolding, animated cranes, welding sparks, caution tape).

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../domain/entities/facility.dart';
import '../../domain/entities/facility_tiers_data.dart';

class FacilityVisualWidget extends StatefulWidget {
  final FacilityType type;
  final int level;
  final bool isUpgrading;
  final double height;
  final bool isCelebration;

  const FacilityVisualWidget({
    super.key,
    required this.type,
    required this.level,
    this.isUpgrading = false,
    this.height = 200,
    this.isCelebration = false,
  });

  @override
  State<FacilityVisualWidget> createState() => _FacilityVisualWidgetState();
}

class _FacilityVisualWidgetState extends State<FacilityVisualWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tierInfo = FacilityTiersData.getTierInfo(widget.type, widget.level);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0D121B),
            border: Border.all(
              color: widget.isUpgrading
                  ? AppColors.neonAmber
                  : (widget.level >= 5 ? const Color(0xFFFFD700) : AppColors.neonLime),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isUpgrading
                    ? AppColors.neonAmber.withValues(alpha: 0.3)
                    : (widget.level >= 5
                        ? const Color(0xFFFFD700).withValues(alpha: 0.35)
                        : AppColors.neonLime.withValues(alpha: 0.2)),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Custom Painter for Facility Environment & Buildings
              CustomPaint(
                size: Size(double.infinity, widget.height),
                painter: _FacilityCanvasPainter(
                  type: widget.type,
                  level: widget.level,
                  isUpgrading: widget.isUpgrading,
                  animValue: _animController.value,
                  isCelebration: widget.isCelebration,
                ),
              ),

              // Top Tier Badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    border: Border.all(
                      color: widget.isUpgrading ? AppColors.neonAmber : AppColors.neonLime,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.type.icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'AŞAMA ${widget.level}/5 : ${tierInfo.name.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Construction Ribbon Overlay
              if (widget.isUpgrading)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonAmber,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          'İNŞAAT DEVAM EDİYOR',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (widget.level >= 5)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Text(
                      '★ MAKSİMUM HANEDAN SEVİYESİ ★',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

              // Bottom Info Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: Colors.black.withValues(alpha: 0.8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tierInfo.subtitle,
                        style: const TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${tierInfo.perkTitle}: ${tierInfo.perkValue}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
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

class _FacilityCanvasPainter extends CustomPainter {
  final FacilityType type;
  final int level;
  final bool isUpgrading;
  final double animValue;
  final bool isCelebration;

  _FacilityCanvasPainter({
    required this.type,
    required this.level,
    required this.isUpgrading,
    required this.animValue,
    required this.isCelebration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky & Background Grid
    _drawSkyAndHorizon(canvas, size);

    // 2. Base Pitch / Ground Landscape
    _drawGroundBase(canvas, size);

    // 3. Facility Main Structure
    switch (type) {
      case FacilityType.stadium:
        _drawStadium(canvas, size);
        break;
      case FacilityType.trainingGround:
        _drawTrainingGround(canvas, size);
        break;
      case FacilityType.youthAcademy:
        _drawYouthAcademy(canvas, size);
        break;
      case FacilityType.medicalCenter:
        _drawMedicalCenter(canvas, size);
        break;
      case FacilityType.scoutCenter:
        _drawScoutCenter(canvas, size);
        break;
      case FacilityType.clubMuseum:
        _drawClubMuseum(canvas, size);
        break;
      case FacilityType.fanShop:
        _drawFanShop(canvas, size);
        break;
      case FacilityType.analyticsDept:
        _drawAnalyticsDept(canvas, size);
        break;
      case FacilityType.pitchMaintenance:
        _drawPitchMaintenance(canvas, size);
        break;
      case FacilityType.pressRoom:
        _drawPressRoom(canvas, size);
        break;
      case FacilityType.nutritionCenter:
        _drawNutritionCenter(canvas, size);
        break;
      case FacilityType.vipLounge:
        _drawVipLounge(canvas, size);
        break;
    }

    // 4. Construction Overlay if upgrading
    if (isUpgrading) {
      _drawConstructionOverlay(canvas, size);
    }

    // 5. Celebration Sparks
    if (isCelebration || (level >= 5 && !isUpgrading)) {
      _drawCelebrationSparks(canvas, size);
    }
  }

  void _drawSkyAndHorizon(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF060B12),
          const Color(0xFF0F1B2B),
          const Color(0xFF1B2C44),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.65));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.65), skyPaint);

    // Retro Stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (int i = 0; i < 20; i++) {
      final x = ((i * 37 + 13) % size.width.toInt()).toDouble();
      final y = ((i * 23 + 7) % (size.height * 0.45).toInt()).toDouble();
      canvas.drawCircle(Offset(x, y), (i % 3 == 0) ? 1.5 : 0.8, starPaint);
    }
  }

  void _drawGroundBase(Canvas canvas, Size size) {
    final groundPaint = Paint()
      ..color = level >= 3 ? const Color(0xFF163E20) : const Color(0xFF263321);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.60, size.width, size.height * 0.40),
      groundPaint,
    );

    // Pitch grass stripes
    final stripePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15);
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * 0.60, 12, size.height * 0.40),
        stripePaint,
      );
    }
  }

  void _drawStadium(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.60;

    final baseWidth = size.width * (0.45 + (level * 0.08)).clamp(0.45, 0.88);
    final baseHeight = size.height * (0.28 + (level * 0.05)).clamp(0.28, 0.50);

    // Outer Stadium Shell
    final shellPaint = Paint()
      ..color = level >= 4 ? const Color(0xFF334155) : const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = level >= 5 ? const Color(0xFFFFD700) : AppColors.neonLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final stadiumRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 10), width: baseWidth, height: baseHeight),
      Radius.circular(level >= 4 ? 24 : 10),
    );

    canvas.drawRRect(stadiumRect, shellPaint);
    canvas.drawRRect(stadiumRect, strokePaint);

    // Inner Green Pitch
    final innerPitch = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 10), width: baseWidth * 0.65, height: baseHeight * 0.50),
      const Radius.circular(6),
    );
    final pitchPaint = Paint()..color = const Color(0xFF22C55E);
    canvas.drawRRect(innerPitch, pitchPaint);

    // White Pitch Markings
    final markPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(innerPitch, markPaint);
    canvas.drawCircle(Offset(cx, cy - 10), 12, markPaint);

    // Floodlight Towers
    if (level >= 2) {
      _drawFloodlight(canvas, Offset(cx - baseWidth / 2 - 12, cy - baseHeight / 2 - 15), 35);
      _drawFloodlight(canvas, Offset(cx + baseWidth / 2 + 12, cy - baseHeight / 2 - 15), 35);
    }
    if (level >= 4) {
      _drawFloodlight(canvas, Offset(cx - baseWidth / 2 - 20, cy + 10), 25);
      _drawFloodlight(canvas, Offset(cx + baseWidth / 2 + 20, cy + 10), 25);
    }

    // Level 5 Dome Ring
    if (level >= 5) {
      final domePaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy - baseHeight / 2 - 10), width: baseWidth * 0.8, height: 20),
        domePaint,
      );
    }
  }

  void _drawTrainingGround(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.62;

    // Grass fields (multiple pitches for higher levels)
    final pitchCount = level.clamp(1, 4);
    final pw = (size.width * 0.70) / pitchCount;

    for (int i = 0; i < pitchCount; i++) {
      final px = (cx - (size.width * 0.35)) + (i * pw) + (pw / 2);
      final pRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(px, cy), width: pw - 8, height: 60),
        const Radius.circular(4),
      );
      canvas.drawRRect(pRect, Paint()..color = const Color(0xFF15803D));
      canvas.drawRRect(pRect, Paint()..color = Colors.white.withValues(alpha: 0.6)..style = PaintingStyle.stroke..strokeWidth = 1.0);

      // Cones
      final conePaint = Paint()..color = const Color(0xFFF97316);
      canvas.drawCircle(Offset(px - 10, cy - 8), 3, conePaint);
      canvas.drawCircle(Offset(px + 10, cy + 8), 3, conePaint);
    }

    // High level: Gym / Biomechanics Lab Building in background
    if (level >= 2) {
      final gymRect = Rect.fromCenter(center: Offset(cx, cy - 50), width: 100 + (level * 20), height: 40);
      canvas.drawRect(gymRect, Paint()..color = const Color(0xFF1E293B));
      canvas.drawRect(gymRect, Paint()..color = AppColors.neonLime..style = PaintingStyle.stroke..strokeWidth = 1.5);
      // Gym windows
      final winPaint = Paint()..color = const Color(0xFF38BDF8);
      canvas.drawRect(Rect.fromCenter(center: Offset(cx - 20, cy - 50), width: 14, height: 12), winPaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(cx + 20, cy - 50), width: 14, height: 12), winPaint);
    }
  }

  void _drawYouthAcademy(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    // Campus Main Building
    final bWidth = 90 + (level * 22.0);
    final bHeight = 50 + (level * 10.0);
    final bRect = Rect.fromCenter(center: Offset(cx, cy - 10), width: bWidth, height: bHeight);

    canvas.drawRect(bRect, Paint()..color = const Color(0xFF334155));
    canvas.drawRect(bRect, Paint()..color = const Color(0xFF22C55E)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Roof Triangle
    final path = Path()
      ..moveTo(cx - (bWidth / 2) - 8, cy - 10 - (bHeight / 2))
      ..lineTo(cx, cy - 10 - (bHeight / 2) - 20)
      ..lineTo(cx + (bWidth / 2) + 8, cy - 10 - (bHeight / 2))
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF16A34A));

    // Star Emblem
    final starPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(cx, cy - 10 - (bHeight / 2) - 8), 6, starPaint);

    // Youth Pitch in front
    final yPitch = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 38), width: size.width * 0.55, height: 35),
      const Radius.circular(4),
    );
    canvas.drawRRect(yPitch, Paint()..color = const Color(0xFF15803D));
    canvas.drawRRect(yPitch, Paint()..color = Colors.white70..style = PaintingStyle.stroke..strokeWidth = 1.0);
  }

  void _drawMedicalCenter(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.56;

    final mWidth = 100 + (level * 24.0);
    final mHeight = 55 + (level * 12.0);
    final mRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: mWidth, height: mHeight),
      const Radius.circular(8),
    );

    canvas.drawRRect(mRect, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawRRect(mRect, Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.stroke..strokeWidth = 2.5);

    // Red Cross Emblem
    final crossPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - 12), width: 10, height: 26), crossPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - 12), width: 26, height: 10), crossPaint);

    // Heartbeat waveform pulse line
    final pulsePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final pulsePath = Path();
    final px = cx - 35;
    final py = cy + 16;
    pulsePath.moveTo(px, py);
    pulsePath.lineTo(px + 15, py);
    pulsePath.lineTo(px + 22, py - 12);
    pulsePath.lineTo(px + 30, py + 12);
    pulsePath.lineTo(px + 38, py - 6);
    pulsePath.lineTo(px + 45, py);
    pulsePath.lineTo(px + 70, py);
    canvas.drawPath(pulsePath, pulsePaint);
  }

  void _drawScoutCenter(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    // Radar Tower
    final towerPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx - 20, cy + 30), Offset(cx, cy - 35), towerPaint);
    canvas.drawLine(Offset(cx + 20, cy + 30), Offset(cx, cy - 35), towerPaint);
    canvas.drawLine(Offset(cx - 15, cy + 10), Offset(cx + 15, cy + 10), towerPaint);

    // Radar Dish
    final dishCenter = Offset(cx, cy - 38);
    final radarAngle = animValue * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: dishCenter, radius: 20 + (level * 3.0)),
      radarAngle,
      math.pi / 2,
      true,
      Paint()..color = AppColors.neonLime.withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      dishCenter,
      20 + (level * 3.0),
      Paint()..color = AppColors.neonLime..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // Satellite Dot
    canvas.drawCircle(dishCenter, 4, Paint()..color = const Color(0xFF38BDF8));
  }

  void _drawClubMuseum(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.56;

    final mWidth = 110 + (level * 20.0);
    final mHeight = 60 + (level * 10.0);

    // Classical Marble Temple Style
    final templeRect = Rect.fromCenter(center: Offset(cx, cy), width: mWidth, height: mHeight);
    canvas.drawRect(templeRect, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawRect(templeRect, Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Pillars
    final pillarPaint = Paint()..color = const Color(0xFF94A3B8);
    final pillarCount = 3 + level;
    final gap = mWidth / (pillarCount + 1);
    for (int i = 1; i <= pillarCount; i++) {
      final px = cx - (mWidth / 2) + (i * gap);
      canvas.drawRect(Rect.fromCenter(center: Offset(px, cy + 4), width: 6, height: mHeight - 16), pillarPaint);
    }

    // Golden Trophy in Center Pedestal
    final trophyCenter = Offset(cx, cy - 4);
    canvas.drawCircle(trophyCenter, 10, Paint()..color = const Color(0xFFFFD700));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 10), width: 14, height: 6), Paint()..color = const Color(0xFFCA8A04));
  }

  void _drawFanShop(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    final sWidth = 95 + (level * 22.0);
    final sHeight = 55 + (level * 10.0);

    final shopRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: sWidth, height: sHeight),
      const Radius.circular(6),
    );
    canvas.drawRRect(shopRect, Paint()..color = const Color(0xFF1E293B));
    canvas.drawRRect(shopRect, Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Awning Stripes (Kırmızı/Beyaz ya da Sarı/Lacivert Tente)
    final awningPath = Path()
      ..moveTo(cx - (sWidth / 2) - 4, cy - (sHeight / 2))
      ..lineTo(cx + (sWidth / 2) + 4, cy - (sHeight / 2))
      ..lineTo(cx + (sWidth / 2) + 4, cy - (sHeight / 2) + 14)
      ..lineTo(cx - (sWidth / 2) - 4, cy - (sHeight / 2) + 14)
      ..close();
    canvas.drawPath(awningPath, Paint()..color = const Color(0xFFDC2626));

    // Jersey in display window
    final jerseyCenter = Offset(cx, cy + 8);
    canvas.drawRect(Rect.fromCenter(center: jerseyCenter, width: 22, height: 20), Paint()..color = const Color(0xFF38BDF8));
  }

  void _drawAnalyticsDept(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    // Server Rack & Holographic Screens
    final sRect = Rect.fromCenter(center: Offset(cx, cy), width: 100 + (level * 20.0), height: 55);
    canvas.drawRect(sRect, Paint()..color = const Color(0xFF0F172A));
    canvas.drawRect(sRect, Paint()..color = const Color(0xFF06B6D4)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Holographic Graph Grid
    final gPaint = Paint()..color = const Color(0xFF06B6D4).withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final graphPath = Path();
    graphPath.moveTo(cx - 35, cy + 12);
    graphPath.lineTo(cx - 15, cy - 2);
    graphPath.lineTo(cx + 5, cy + 4);
    graphPath.lineTo(cx + 25, cy - 14);
    graphPath.lineTo(cx + 38, cy - 8);
    canvas.drawPath(graphPath, gPaint);

    // Blinking Server LEDs
    for (int i = 0; i < 4; i++) {
      final ledColor = ((animValue * 10).toInt() % 2 == i % 2) ? const Color(0xFF10B981) : const Color(0xFFEF4444);
      canvas.drawCircle(Offset(cx - 30 + (i * 20), cy - 16), 2.5, Paint()..color = ledColor);
    }
  }

  void _drawPitchMaintenance(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.60;

    // Lush Emerald Pitch Grid
    final pRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.70, height: 60),
      const Radius.circular(6),
    );
    canvas.drawRRect(pRect, Paint()..color = const Color(0xFF047857));
    canvas.drawRRect(pRect, Paint()..color = const Color(0xFF10B981)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Sprinkler Water Jets
    final jetPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final waterDist = 15 + (animValue * 10);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx - 40, cy), radius: waterDist), -math.pi * 0.8, math.pi * 0.6, false, jetPaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx + 40, cy), radius: waterDist), -math.pi * 0.8, math.pi * 0.6, false, jetPaint);
  }

  void _drawPressRoom(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    // Press Conference Podium
    final pRect = Rect.fromCenter(center: Offset(cx, cy + 4), width: 90 + (level * 20.0), height: 45);
    canvas.drawRect(pRect, Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(pRect, Paint()..color = const Color(0xFF8B5CF6)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Backdrop with Sponsor Logos
    final bRect = Rect.fromCenter(center: Offset(cx, cy - 25), width: 110 + (level * 20.0), height: 28);
    canvas.drawRect(bRect, Paint()..color = const Color(0xFF475569));
    canvas.drawRect(bRect, Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Microphones
    final micPaint = Paint()..color = Colors.white..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx - 10, cy - 4), Offset(cx - 6, cy - 14), micPaint);
    canvas.drawLine(Offset(cx + 10, cy - 4), Offset(cx + 6, cy - 14), micPaint);
    canvas.drawCircle(Offset(cx - 6, cy - 14), 2.5, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(Offset(cx + 6, cy - 14), 2.5, Paint()..color = const Color(0xFFEF4444));
  }

  void _drawNutritionCenter(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    final nRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 95 + (level * 20.0), height: 50),
      const Radius.circular(8),
    );
    canvas.drawRRect(nRect, Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(nRect, Paint()..color = const Color(0xFF84CC16)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Apple / Leaf / Energy Icon
    canvas.drawCircle(Offset(cx, cy - 4), 10, Paint()..color = const Color(0xFF84CC16));
    canvas.drawLine(Offset(cx, cy - 14), Offset(cx + 4, cy - 18), Paint()..color = const Color(0xFF65A30D)..strokeWidth = 2.0);
  }

  void _drawVipLounge(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.58;

    final vWidth = 100 + (level * 25.0);
    final vHeight = 55 + (level * 10.0);

    final vRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: vWidth, height: vHeight),
      const Radius.circular(8),
    );
    canvas.drawRRect(vRect, Paint()..color = const Color(0xFF18181B));
    canvas.drawRRect(vRect, Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 2.5);

    // Chandelier / Luxury Lights
    for (int i = -2; i <= 2; i++) {
      final lx = cx + (i * 18);
      canvas.drawCircle(Offset(lx, cy - 12), 4, Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.8));
    }

    // Glass Champagne Flutes
    canvas.drawRect(Rect.fromCenter(center: Offset(cx - 10, cy + 10), width: 5, height: 12), Paint()..color = const Color(0xFFFDE047));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + 10, cy + 10), width: 5, height: 12), Paint()..color = const Color(0xFFFDE047));
  }

  void _drawFloodlight(Canvas canvas, Offset pos, double height) {
    final polePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.5;
    canvas.drawLine(pos, Offset(pos.dx, pos.dy - height), polePaint);

    final lampRect = Rect.fromCenter(center: Offset(pos.dx, pos.dy - height), width: 14, height: 8);
    canvas.drawRect(lampRect, Paint()..color = const Color(0xFFFEF08A));

    // Light Beam Cone
    final beamPath = Path()
      ..moveTo(pos.dx - 6, pos.dy - height + 4)
      ..lineTo(pos.dx + 6, pos.dy - height + 4)
      ..lineTo(pos.dx + 25, pos.dy + 15)
      ..lineTo(pos.dx - 25, pos.dy + 15)
      ..close();
    canvas.drawPath(
      beamPath,
      Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawConstructionOverlay(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;

    // Scaffolding Grid
    final scaffoldPaint = Paint()
      ..color = AppColors.neonAmber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final scWidth = size.width * 0.65;
    final scHeight = size.height * 0.45;
    final scRect = Rect.fromCenter(center: Offset(cx, cy), width: scWidth, height: scHeight);

    canvas.drawRect(scRect, scaffoldPaint);
    for (double y = scRect.top; y <= scRect.bottom; y += 18) {
      canvas.drawLine(Offset(scRect.left, y), Offset(scRect.right, y), scaffoldPaint);
    }
    for (double x = scRect.left; x <= scRect.right; x += 22) {
      canvas.drawLine(Offset(x, scRect.top), Offset(x, scRect.bottom), scaffoldPaint);
    }

    // Animated Construction Crane (Vinç)
    final craneX = cx + (math.sin(animValue * 2 * math.pi) * 30);
    final craneTop = Offset(craneX, size.height * 0.15);
    final craneBase = Offset(craneX, size.height * 0.55);

    final cranePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 3.0;
    canvas.drawLine(craneBase, craneTop, cranePaint);
    canvas.drawLine(craneTop, Offset(craneTop.dx + 40, craneTop.dy), cranePaint);
    canvas.drawLine(craneTop, Offset(craneTop.dx - 20, craneTop.dy), cranePaint);

    // Crane Cable and Hook
    final hookY = craneTop.dy + 25 + (math.sin(animValue * 4 * math.pi) * 8);
    canvas.drawLine(Offset(craneTop.dx + 30, craneTop.dy), Offset(craneTop.dx + 30, hookY), Paint()..color = Colors.white70..strokeWidth = 1.0);
    canvas.drawCircle(Offset(craneTop.dx + 30, hookY), 3.5, Paint()..color = const Color(0xFFF59E0B));

    // Welding Sparks
    final sparkCount = 6;
    for (int i = 0; i < sparkCount; i++) {
      final angle = (animValue * 6 * math.pi) + (i * (math.pi / 3));
      final sparkDist = 8 + (i * 2.0);
      final sx = craneTop.dx + 30 + (math.cos(angle) * sparkDist);
      final sy = hookY + (math.sin(angle) * sparkDist);
      canvas.drawCircle(Offset(sx, sy), 1.5, Paint()..color = const Color(0xFFFEF08A));
    }
  }

  void _drawCelebrationSparks(Canvas canvas, Size size) {
    final random = math.Random(42);
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFF22C55E),
      const Color(0xFF38BDF8),
      const Color(0xFFEC4899),
      Colors.white,
    ];

    for (int i = 0; i < 25; i++) {
      final x = (random.nextDouble() * size.width);
      final speed = (random.nextDouble() * 30) + 15;
      final y = (size.height * 0.1) + ((animValue * speed * 4) % (size.height * 0.7));
      final color = colors[i % colors.length];
      canvas.drawCircle(Offset(x, y), (i % 2 == 0) ? 2.5 : 1.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _FacilityCanvasPainter oldDelegate) => true;
}
