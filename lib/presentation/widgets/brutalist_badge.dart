// lib/presentation/widgets/brutalist_badge.dart
// Brutalist Club Crest & Heraldry Renderer — Replaces all emoji badge icons with geometric vector crests.

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class BrutalistBadge extends StatelessWidget {
  final String badgeIcon;
  final String? clubName;
  final String? primaryColorHex;
  final String? secondaryColorHex;
  final double size;

  const BrutalistBadge({
    super.key,
    required this.badgeIcon,
    this.clubName,
    this.primaryColorHex,
    this.secondaryColorHex,
    this.size = 32.0,
  });

  Color _parseHex(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      final val = int.tryParse('FF$clean', radix: 16);
      if (val != null) return Color(val);
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final primary = _parseHex(primaryColorHex, AppColors.neonLime);
    final secondary = _parseHex(secondaryColorHex, AppColors.accentGold);
    final initial = (clubName != null && clubName!.isNotEmpty) ? clubName![0].toUpperCase() : 'X';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.neoPitchBlack,
        border: Border.all(color: primary, width: 1.5),
        borderRadius: BorderRadius.circular(size * 0.18),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.15),
        child: CustomPaint(
          size: Size(size, size),
          painter: _BrutalistBadgePainter(
            badgeKey: badgeIcon,
            initial: initial,
            primaryColor: primary,
            secondaryColor: secondary,
          ),
        ),
      ),
    );
  }
}

class _BrutalistBadgePainter extends CustomPainter {
  final String badgeKey;
  final String initial;
  final Color primaryColor;
  final Color secondaryColor;

  _BrutalistBadgePainter({
    required this.badgeKey,
    required this.initial,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Diagonal Background Stripes in Secondary Color
    final stripePaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.15)
      ..strokeWidth = 2.0;
    for (var i = -w; i < w * 2; i += 8) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset((i + h).toDouble(), h), stripePaint);
    }

    // Outer Geometric Shield Outline
    final shield = Path()
      ..moveTo(w * 0.18, h * 0.15)
      ..lineTo(w * 0.82, h * 0.15)
      ..lineTo(w * 0.82, h * 0.58)
      ..quadraticBezierTo(w * 0.5, h * 0.88, w * 0.5, h * 0.88)
      ..quadraticBezierTo(w * 0.18, h * 0.58, w * 0.18, h * 0.58)
      ..close();

    canvas.drawPath(
      shield,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      shield,
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final key = badgeKey.toUpperCase();

    if (key.contains('BOLT') || key.contains('BOLT') || key.contains('LIGHTNING')) {
      final bolt = Path()
        ..moveTo(w * 0.55, h * 0.22)
        ..lineTo(w * 0.35, h * 0.5)
        ..lineTo(w * 0.52, h * 0.5)
        ..lineTo(w * 0.45, h * 0.78)
        ..lineTo(w * 0.68, h * 0.44)
        ..lineTo(w * 0.52, h * 0.44)
        ..close();
      canvas.drawPath(bolt, Paint()..color = secondaryColor);
    } else if (key.contains('STAR') || key.contains('STAR') || key.contains('STAR')) {
      final star = Path()
        ..moveTo(w * 0.5, h * 0.22)
        ..lineTo(w * 0.58, h * 0.42)
        ..lineTo(w * 0.78, h * 0.5)
        ..lineTo(w * 0.58, h * 0.58)
        ..lineTo(w * 0.5, h * 0.78)
        ..lineTo(w * 0.42, h * 0.58)
        ..lineTo(w * 0.22, h * 0.5)
        ..lineTo(w * 0.42, h * 0.42)
        ..close();
      canvas.drawPath(star, Paint()..color = secondaryColor);
    } else if (key.contains('CROWN') || key.contains('CROWN') || key.contains('KING')) {
      final crown = Path()
        ..moveTo(w * 0.28, h * 0.65)
        ..lineTo(w * 0.28, h * 0.38)
        ..lineTo(w * 0.42, h * 0.5)
        ..lineTo(w * 0.5, h * 0.3)
        ..lineTo(w * 0.58, h * 0.5)
        ..lineTo(w * 0.72, h * 0.38)
        ..lineTo(w * 0.72, h * 0.65)
        ..close();
      canvas.drawPath(crown, Paint()..color = secondaryColor);
    } else if (key.contains('FLAME') || key.contains('[FORM]') || key.contains('FIRE')) {
      final flame = Path()
        ..moveTo(w * 0.5, h * 0.24)
        ..quadraticBezierTo(w * 0.75, h * 0.48, w * 0.75, h * 0.65)
        ..arcToPoint(Offset(w * 0.25, h * 0.65), radius: Radius.circular(w * 0.25))
        ..quadraticBezierTo(w * 0.25, h * 0.48, w * 0.5, h * 0.24)
        ..close();
      canvas.drawPath(flame, Paint()..color = secondaryColor);
    } else {
      // Default: High-impact Geometric Monogram Letter
      final tp = TextPainter(
        text: TextSpan(
          text: initial,
          style: TextStyle(
            color: secondaryColor,
            fontSize: size.width * 0.42,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2 - h * 0.04));
    }
  }

  @override
  bool shouldRepaint(covariant _BrutalistBadgePainter oldDelegate) {
    return oldDelegate.badgeKey != badgeKey ||
        oldDelegate.initial != initial ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
