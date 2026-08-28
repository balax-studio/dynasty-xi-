// lib/presentation/widgets/brutalist_icons.dart
// Brutalist Vector Icon System — Pure geometric vector CustomPainters without unicode emojis.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum BrutalistIconType {
  cash,
  fans,
  lockerRoom,
  boardTrust,
  ball,
  whistle,
  trophy,
  shield,
  bolt,
  briefcase,
  tv,
  scale,
  mic,
  hammer,
  stadium,
  star,
  crown,
  flame,
  analytics,
  radar,
  check,
  cross,
  warning,
  cardYellow,
  cardRed,
  substitute,
  scout,
  academy,
  transfer,
  law,
  bribe,
  statue,
  bus,
  audit,
}

class BrutalistIcon extends StatelessWidget {
  final BrutalistIconType type;
  final double size;
  final Color? color;

  const BrutalistIcon(
    this.type, {
    super.key,
    this.size = 16.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.neonLime;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrutalistIconPainter(type, effectiveColor),
      ),
    );
  }
}

class _BrutalistIconPainter extends CustomPainter {
  final BrutalistIconType type;
  final Color color;

  _BrutalistIconPainter(this.type, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (type) {
      case BrutalistIconType.cash:
        // Brutalist Banknote / Currency Vault Matrix
        canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.2, w * 0.8, h * 0.6), strokePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.18, strokePaint);
        canvas.drawLine(Offset(w * 0.22, h * 0.5), Offset(w * 0.22, h * 0.5), fillPaint..strokeWidth = 2);
        canvas.drawLine(Offset(w * 0.78, h * 0.5), Offset(w * 0.78, h * 0.5), fillPaint..strokeWidth = 2);
        break;

      case BrutalistIconType.fans:
        // Triple Geometric Head & Crowd Array
        canvas.drawCircle(Offset(w * 0.5, h * 0.3), w * 0.15, strokePaint);
        final path = Path()
          ..moveTo(w * 0.2, h * 0.85)
          ..lineTo(w * 0.3, h * 0.55)
          ..lineTo(w * 0.7, h * 0.55)
          ..lineTo(w * 0.8, h * 0.85)
          ..close();
        canvas.drawPath(path, strokePaint);
        // Flanking supporters
        canvas.drawCircle(Offset(w * 0.2, h * 0.4), w * 0.1, strokePaint);
        canvas.drawCircle(Offset(w * 0.8, h * 0.4), w * 0.1, strokePaint);
        break;

      case BrutalistIconType.lockerRoom:
        // Geometric Jersey / Armor Silhouette
        final jersey = Path()
          ..moveTo(w * 0.35, h * 0.15)
          ..lineTo(w * 0.2, h * 0.25)
          ..lineTo(w * 0.08, h * 0.45)
          ..lineTo(w * 0.25, h * 0.55)
          ..lineTo(w * 0.28, h * 0.85)
          ..lineTo(w * 0.72, h * 0.85)
          ..lineTo(w * 0.75, h * 0.55)
          ..lineTo(w * 0.92, h * 0.45)
          ..lineTo(w * 0.8, h * 0.25)
          ..lineTo(w * 0.65, h * 0.15)
          ..close();
        canvas.drawPath(jersey, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.15), Offset(w * 0.5, h * 0.4), strokePaint);
        break;

      case BrutalistIconType.boardTrust:
        // Executive Pillar / Classical Monolith
        canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.8, w * 0.8, h * 0.12), fillPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.7, h * 0.1), fillPaint);
        canvas.drawLine(Offset(w * 0.3, h * 0.25), Offset(w * 0.3, h * 0.8), strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.25), Offset(w * 0.5, h * 0.8), strokePaint);
        canvas.drawLine(Offset(w * 0.7, h * 0.25), Offset(w * 0.7, h * 0.8), strokePaint);
        break;

      case BrutalistIconType.ball:
        // High-contrast Vector Football with Pentagons
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.42, strokePaint);
        final pentagon = Path()
          ..moveTo(w * 0.5, h * 0.35)
          ..lineTo(w * 0.62, h * 0.45)
          ..lineTo(w * 0.58, h * 0.6)
          ..lineTo(w * 0.42, h * 0.6)
          ..lineTo(w * 0.38, h * 0.45)
          ..close();
        canvas.drawPath(pentagon, fillPaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.35), Offset(w * 0.5, h * 0.08), strokePaint);
        canvas.drawLine(Offset(w * 0.62, h * 0.45), Offset(w * 0.9, h * 0.4), strokePaint);
        canvas.drawLine(Offset(w * 0.58, h * 0.6), Offset(w * 0.78, h * 0.82), strokePaint);
        canvas.drawLine(Offset(w * 0.42, h * 0.6), Offset(w * 0.22, h * 0.82), strokePaint);
        canvas.drawLine(Offset(w * 0.38, h * 0.45), Offset(w * 0.1, h * 0.4), strokePaint);
        break;

      case BrutalistIconType.whistle:
        // Referee Whistle
        final whistle = Path()
          ..moveTo(w * 0.15, h * 0.3)
          ..lineTo(w * 0.5, h * 0.3)
          ..arcToPoint(Offset(w * 0.85, h * 0.65), radius: Radius.circular(w * 0.25))
          ..arcToPoint(Offset(w * 0.4, h * 0.7), radius: Radius.circular(w * 0.25))
          ..lineTo(w * 0.15, h * 0.5)
          ..close();
        canvas.drawPath(whistle, strokePaint);
        canvas.drawCircle(Offset(w * 0.6, h * 0.55), w * 0.08, fillPaint);
        break;

      case BrutalistIconType.trophy:
        // Geometric Cup
        final cup = Path()
          ..moveTo(w * 0.2, h * 0.15)
          ..lineTo(w * 0.8, h * 0.15)
          ..lineTo(w * 0.7, h * 0.55)
          ..arcToPoint(Offset(w * 0.3, h * 0.55), radius: Radius.circular(w * 0.25))
          ..close();
        canvas.drawPath(cup, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.65), Offset(w * 0.5, h * 0.8), strokePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.3, h * 0.8, w * 0.4, h * 0.12), fillPaint);
        // Handles
        canvas.drawArc(Rect.fromLTWH(w * 0.08, h * 0.2, w * 0.2, h * 0.25), math.pi / 2, math.pi, false, strokePaint);
        canvas.drawArc(Rect.fromLTWH(w * 0.72, h * 0.2, w * 0.2, h * 0.25), -math.pi / 2, math.pi, false, strokePaint);
        break;

      case BrutalistIconType.shield:
        // Crest Shield
        final shield = Path()
          ..moveTo(w * 0.15, h * 0.15)
          ..lineTo(w * 0.85, h * 0.15)
          ..lineTo(w * 0.85, h * 0.55)
          ..quadraticBezierTo(w * 0.5, h * 0.95, w * 0.5, h * 0.95)
          ..quadraticBezierTo(w * 0.15, h * 0.55, w * 0.15, h * 0.55)
          ..close();
        canvas.drawPath(shield, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.15), Offset(w * 0.5, h * 0.85), strokePaint);
        break;

      case BrutalistIconType.bolt:
        // High-Voltage Lightning
        final bolt = Path()
          ..moveTo(w * 0.55, h * 0.08)
          ..lineTo(w * 0.2, h * 0.52)
          ..lineTo(w * 0.48, h * 0.52)
          ..lineTo(w * 0.38, h * 0.92)
          ..lineTo(w * 0.8, h * 0.42)
          ..lineTo(w * 0.52, h * 0.42)
          ..close();
        canvas.drawPath(bolt, fillPaint);
        break;

      case BrutalistIconType.briefcase:
        // Boardroom Case
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.3, w * 0.7, h * 0.55), strokePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.15, w * 0.3, h * 0.15), strokePaint);
        canvas.drawLine(Offset(w * 0.15, h * 0.55), Offset(w * 0.85, h * 0.55), strokePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.45, h * 0.5, w * 0.1, h * 0.1), fillPaint);
        break;

      case BrutalistIconType.tv:
        // Retro CRT Broadcast Screen
        canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.25, w * 0.76, h * 0.6), strokePaint);
        canvas.drawLine(Offset(w * 0.28, h * 0.1), Offset(w * 0.45, h * 0.25), strokePaint);
        canvas.drawLine(Offset(w * 0.72, h * 0.1), Offset(w * 0.55, h * 0.25), strokePaint);
        canvas.drawLine(Offset(w * 0.72, h * 0.35), Offset(w * 0.72, h * 0.75), strokePaint);
        break;

      case BrutalistIconType.scale:
        // Legal Justice Scale
        canvas.drawLine(Offset(w * 0.5, h * 0.15), Offset(w * 0.5, h * 0.85), strokePaint);
        canvas.drawLine(Offset(w * 0.2, h * 0.3), Offset(w * 0.8, h * 0.3), strokePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.85, w * 0.3, h * 0.08), fillPaint);
        // Left pan
        canvas.drawLine(Offset(w * 0.2, h * 0.3), Offset(w * 0.1, h * 0.55), strokePaint);
        canvas.drawLine(Offset(w * 0.2, h * 0.3), Offset(w * 0.3, h * 0.55), strokePaint);
        canvas.drawLine(Offset(w * 0.08, h * 0.55), Offset(w * 0.32, h * 0.55), strokePaint);
        // Right pan
        canvas.drawLine(Offset(w * 0.8, h * 0.3), Offset(w * 0.7, h * 0.55), strokePaint);
        canvas.drawLine(Offset(w * 0.8, h * 0.3), Offset(w * 0.9, h * 0.55), strokePaint);
        canvas.drawLine(Offset(w * 0.68, h * 0.55), Offset(w * 0.92, h * 0.55), strokePaint);
        break;

      case BrutalistIconType.mic:
        // Press Conference Mic
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.35, h * 0.12, w * 0.3, h * 0.45), Radius.circular(w * 0.15)), strokePaint);
        canvas.drawArc(Rect.fromLTWH(w * 0.22, h * 0.25, w * 0.56, h * 0.4), 0, math.pi, false, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.65), Offset(w * 0.5, h * 0.88), strokePaint);
        canvas.drawLine(Offset(w * 0.3, h * 0.88), Offset(w * 0.7, h * 0.88), strokePaint);
        break;

      case BrutalistIconType.hammer:
        // Contractor / Facility Gavel
        final head = Path()
          ..moveTo(w * 0.2, h * 0.3)
          ..lineTo(w * 0.5, h * 0.1)
          ..lineTo(w * 0.65, h * 0.25)
          ..lineTo(w * 0.35, h * 0.45)
          ..close();
        canvas.drawPath(head, fillPaint);
        canvas.drawLine(Offset(w * 0.42, h * 0.35), Offset(w * 0.85, h * 0.85), strokePaint);
        break;

      case BrutalistIconType.stadium:
        // Stadium Colosseum
        canvas.drawOval(Rect.fromLTWH(w * 0.1, h * 0.2, w * 0.8, h * 0.6), strokePaint);
        canvas.drawOval(Rect.fromLTWH(w * 0.3, h * 0.35, w * 0.4, h * 0.3), strokePaint);
        canvas.drawLine(Offset(w * 0.1, h * 0.5), Offset(w * 0.3, h * 0.5), strokePaint);
        canvas.drawLine(Offset(w * 0.7, h * 0.5), Offset(w * 0.9, h * 0.5), strokePaint);
        break;

      case BrutalistIconType.star:
        // 4-Point Neo Star
        final star = Path()
          ..moveTo(w * 0.5, h * 0.05)
          ..lineTo(w * 0.62, h * 0.38)
          ..lineTo(w * 0.95, h * 0.5)
          ..lineTo(w * 0.62, h * 0.62)
          ..lineTo(w * 0.5, h * 0.95)
          ..lineTo(w * 0.38, h * 0.62)
          ..lineTo(w * 0.05, h * 0.5)
          ..lineTo(w * 0.38, h * 0.38)
          ..close();
        canvas.drawPath(star, fillPaint);
        break;

      case BrutalistIconType.crown:
        // Presidential Crown
        final crown = Path()
          ..moveTo(w * 0.15, h * 0.75)
          ..lineTo(w * 0.15, h * 0.35)
          ..lineTo(w * 0.35, h * 0.55)
          ..lineTo(w * 0.5, h * 0.25)
          ..lineTo(w * 0.65, h * 0.55)
          ..lineTo(w * 0.85, h * 0.35)
          ..lineTo(w * 0.85, h * 0.75)
          ..close();
        canvas.drawPath(crown, strokePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.75, w * 0.7, h * 0.1), fillPaint);
        break;

      case BrutalistIconType.flame:
        // Industrial Combustion Flame
        final flame = Path()
          ..moveTo(w * 0.5, h * 0.1)
          ..quadraticBezierTo(w * 0.85, h * 0.45, w * 0.85, h * 0.7)
          ..arcToPoint(Offset(w * 0.15, h * 0.7), radius: Radius.circular(w * 0.35))
          ..quadraticBezierTo(w * 0.15, h * 0.45, w * 0.5, h * 0.1)
          ..close();
        canvas.drawPath(flame, strokePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.68), w * 0.15, fillPaint);
        break;

      case BrutalistIconType.analytics:
        // Matrix Step Chart
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.6, w * 0.18, h * 0.3), fillPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.41, h * 0.4, w * 0.18, h * 0.5), fillPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.67, h * 0.18, w * 0.18, h * 0.72), fillPaint);
        canvas.drawLine(Offset(w * 0.1, h * 0.9), Offset(w * 0.9, h * 0.9), strokePaint);
        break;

      case BrutalistIconType.radar:
        // Scanning Crosshair
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.4, strokePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.2, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.05), Offset(w * 0.5, h * 0.95), strokePaint);
        canvas.drawLine(Offset(w * 0.05, h * 0.5), Offset(w * 0.95, h * 0.5), strokePaint);
        break;

      case BrutalistIconType.check:
        // Sharp Angular Vector Check
        final check = Path()
          ..moveTo(w * 0.15, h * 0.5)
          ..lineTo(w * 0.4, h * 0.8)
          ..lineTo(w * 0.85, h * 0.2);
        canvas.drawPath(check, strokePaint..strokeWidth = 2.2);
        break;

      case BrutalistIconType.cross:
        // Sharp Angular X
        canvas.drawLine(Offset(w * 0.2, h * 0.2), Offset(w * 0.8, h * 0.8), strokePaint..strokeWidth = 2.2);
        canvas.drawLine(Offset(w * 0.8, h * 0.2), Offset(w * 0.2, h * 0.8), strokePaint..strokeWidth = 2.2);
        break;

      case BrutalistIconType.warning:
        // Hazard Delta
        final delta = Path()
          ..moveTo(w * 0.5, h * 0.12)
          ..lineTo(w * 0.9, h * 0.85)
          ..lineTo(w * 0.1, h * 0.85)
          ..close();
        canvas.drawPath(delta, strokePaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.38), Offset(w * 0.5, h * 0.6), strokePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.74), 1.5, fillPaint);
        break;

      case BrutalistIconType.cardYellow:
        canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.15, w * 0.56, h * 0.7), Paint()..color = AppColors.accentGold);
        canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.15, w * 0.56, h * 0.7), strokePaint..color = Colors.black);
        break;

      case BrutalistIconType.cardRed:
        canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.15, w * 0.56, h * 0.7), Paint()..color = AppColors.comicRed);
        canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.15, w * 0.56, h * 0.7), strokePaint..color = Colors.black);
        break;

      case BrutalistIconType.substitute:
        // Dual Reversing Arrows
        final up = Path()
          ..moveTo(w * 0.3, h * 0.2)
          ..lineTo(w * 0.15, h * 0.4)
          ..lineTo(w * 0.45, h * 0.4)
          ..close();
        canvas.drawPath(up, fillPaint);
        canvas.drawLine(Offset(w * 0.3, h * 0.4), Offset(w * 0.3, h * 0.8), strokePaint);

        final down = Path()
          ..moveTo(w * 0.7, h * 0.8)
          ..lineTo(w * 0.55, h * 0.6)
          ..lineTo(w * 0.85, h * 0.6)
          ..close();
        canvas.drawPath(down, Paint()..color = AppColors.comicRed);
        canvas.drawLine(Offset(w * 0.7, h * 0.6), Offset(w * 0.7, h * 0.2), strokePaint..color = AppColors.comicRed);
        break;

      case BrutalistIconType.scout:
        // Binoculars Vector
        canvas.drawCircle(Offset(w * 0.32, h * 0.5), w * 0.22, strokePaint);
        canvas.drawCircle(Offset(w * 0.68, h * 0.5), w * 0.22, strokePaint);
        canvas.drawLine(Offset(w * 0.45, h * 0.5), Offset(w * 0.55, h * 0.5), strokePaint);
        break;

      case BrutalistIconType.academy:
        // Graduation Cap
        final cap = Path()
          ..moveTo(w * 0.5, h * 0.2)
          ..lineTo(w * 0.88, h * 0.4)
          ..lineTo(w * 0.5, h * 0.6)
          ..lineTo(w * 0.12, h * 0.4)
          ..close();
        canvas.drawPath(cap, strokePaint);
        canvas.drawArc(Rect.fromLTWH(w * 0.28, h * 0.45, w * 0.44, h * 0.35), 0, math.pi, false, strokePaint);
        canvas.drawLine(Offset(w * 0.88, h * 0.4), Offset(w * 0.88, h * 0.75), strokePaint);
        break;

      case BrutalistIconType.transfer:
        // Exchange Loop
        canvas.drawArc(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.7, h * 0.7), -0.4, 2.5, false, strokePaint);
        canvas.drawArc(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.7, h * 0.7), 2.7, 2.5, false, strokePaint);
        break;

      case BrutalistIconType.law:
        // Gavel Block
        canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.3, w * 0.6, h * 0.3), fillPaint);
        canvas.drawLine(Offset(w * 0.5, h * 0.45), Offset(w * 0.5, h * 0.85), strokePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.85, w * 0.7, h * 0.08), fillPaint);
        break;

      case BrutalistIconType.bribe:
        // Secret Envelope / Safe
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.25, w * 0.7, h * 0.5), strokePaint);
        canvas.drawLine(Offset(w * 0.15, h * 0.25), Offset(w * 0.5, h * 0.55), strokePaint);
        canvas.drawLine(Offset(w * 0.85, h * 0.25), Offset(w * 0.5, h * 0.55), strokePaint);
        break;

      case BrutalistIconType.statue:
        // Monument / Pedestal
        canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.2, w * 0.3, h * 0.4), strokePaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.15), w * 0.08, fillPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.65, w * 0.6, h * 0.25), fillPaint);
        break;

      case BrutalistIconType.bus:
        // Victory Bus Silhouette
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * 0.25, w * 0.8, h * 0.45), const Radius.circular(3)), strokePaint);
        canvas.drawLine(Offset(w * 0.1, h * 0.45), Offset(w * 0.9, h * 0.45), strokePaint);
        canvas.drawCircle(Offset(w * 0.28, h * 0.72), w * 0.09, fillPaint);
        canvas.drawCircle(Offset(w * 0.72, h * 0.72), w * 0.09, fillPaint);
        break;

      case BrutalistIconType.audit:
        // Document / Magnifier Inspection
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.5, h * 0.7), strokePaint);
        canvas.drawLine(Offset(w * 0.25, h * 0.3), Offset(w * 0.55, h * 0.3), strokePaint);
        canvas.drawLine(Offset(w * 0.25, h * 0.45), Offset(w * 0.55, h * 0.45), strokePaint);
        canvas.drawCircle(Offset(w * 0.65, h * 0.65), w * 0.18, strokePaint..color = AppColors.neonPink);
        canvas.drawLine(Offset(w * 0.78, h * 0.78), Offset(w * 0.9, h * 0.9), strokePaint..color = AppColors.neonPink);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BrutalistIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
