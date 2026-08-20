// presentation/widgets/club_emblem_widget.dart
// Dynasty XI - Dynamic Retro-Cyber Neo-Brutalist Club Crest & Badge Engine

import 'dart:math';
import 'package:flutter/material.dart';

enum EmblemShape {
  classicShield,  // Klasik Sivri Kalkan
  roundedHeater,  // Yuvarlak Tabanlı Kalkan
  diamond,        // Elmas / Baklava
  hexagon,        // Sekizgen / Heksagon
  circle,         // Dairesel Madalyon
}

enum EmblemPattern {
  verticalSplit,  // Dikey İki Renk
  horizontalSplit,// Yatay İki Renk
  diagonalSash,   // Çapraz Kuşak
  striped,        // 3 Çizgili Şerit
  quartered,      // 4 Parçalı Dama
  solidWithBorder,// Tek Renk & Vurgu Çerçevesi
}

class ClubEmblemWidget extends StatelessWidget {
  final String clubId;
  final String clubName;
  final String? badgeIcon;
  final Color? primaryColor;
  final Color? secondaryColor;
  final double size;
  final bool showShadow;

  const ClubEmblemWidget({
    super.key,
    required this.clubName,
    this.clubId = '',
    this.badgeIcon,
    this.primaryColor,
    this.secondaryColor,
    this.size = 36.0,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    // Kulüp ID veya İsimden deterministik tohum üret
    final seedString = clubId.isNotEmpty ? clubId : clubName;
    final hash = _computeHash(seedString);
    final rng = Random(hash);

    final shape = EmblemShape.values[rng.nextInt(EmblemShape.values.length)];
    final pattern = EmblemPattern.values[rng.nextInt(EmblemPattern.values.length)];

    final colors = _getClubColors(rng, primaryColor, secondaryColor);
    final primary = colors.primary;
    final secondary = colors.secondary;

    final symbol = _resolveEmblemSymbol(badgeIcon, rng);

    return Container(
      width: size,
      height: size,
      decoration: showShadow
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  offset: Offset(size * 0.08, size * 0.08),
                  blurRadius: 0,
                ),
              ],
            )
          : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _ClubEmblemPainter(
          shape: shape,
          pattern: pattern,
          primaryColor: primary,
          secondaryColor: secondary,
          symbol: symbol,
        ),
      ),
    );
  }

  int _computeHash(String str) {
    var h = 0;
    for (var i = 0; i < str.length; i++) {
      h = 31 * h + str.codeUnitAt(i);
    }
    return h.abs();
  }

  ({Color primary, Color secondary}) _getClubColors(
    Random rng,
    Color? customPrimary,
    Color? customSecondary,
  ) {
    if (customPrimary != null && customSecondary != null) {
      return (primary: customPrimary, secondary: customSecondary);
    }

    const palette = [
      (primary: Color(0xFF0F172A), secondary: Color(0xFF38BDF8)), // Slate & Sky
      (primary: Color(0xFF991B1B), secondary: Color(0xFFFBBF24)), // Crimson & Gold
      (primary: Color(0xFF0B2E20), secondary: Color(0xFF22C55E)), // Forest & Neon Lime
      (primary: Color(0xFF1E3A8A), secondary: Color(0xFFF472B6)), // Navy & Hot Pink
      (primary: Color(0xFF4C1D95), secondary: Color(0xFFA78BFA)), // Purple & Lavender
      (primary: Color(0xFF7C2D12), secondary: Color(0xFFFB923C)), // Burnt Orange & Amber
      (primary: Color(0xFF164E63), secondary: Color(0xFF2DD4BF)), // Deep Teal & Mint
      (primary: Color(0xFF831843), secondary: Color(0xFFFDE047)), // Ruby & Yellow
      (primary: Color(0xFF1E293B), secondary: Color(0xFFFF0055)), // Dark Charcoal & Cyber Pink
      (primary: Color(0xFF064E3B), secondary: Color(0xFFFFD700)), // Emerald & Pure Gold
    ];

    final pair = palette[rng.nextInt(palette.length)];
    return (
      primary: customPrimary ?? pair.primary,
      secondary: customSecondary ?? pair.secondary,
    );
  }

  String _resolveEmblemSymbol(String? badgeIcon, Random rng) {
    if (badgeIcon != null && badgeIcon.trim().isNotEmpty && badgeIcon != '🛡️') {
      return badgeIcon.trim();
    }

    const symbols = [
      '🦅', '🦁', '🐺', '⚡', '⚓', '⚔️', '🏰', '👑', '🔥', '🌊', '🏆', '⭐', '🛡️', '🐅', '🐉', '🏹'
    ];
    return symbols[rng.nextInt(symbols.length)];
  }
}

class _ClubEmblemPainter extends CustomPainter {
  final EmblemShape shape;
  final EmblemPattern pattern;
  final Color primaryColor;
  final Color secondaryColor;
  final String symbol;

  _ClubEmblemPainter({
    required this.shape,
    required this.pattern,
    required this.primaryColor,
    required this.secondaryColor,
    required this.symbol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = _createShapePath(shape, w, h);

    // Kalkan Arka Planı Kırpma
    canvas.save();
    canvas.clipPath(path);

    // 1. Zemin Deseni Çizimi
    _drawPattern(canvas, w, h);

    canvas.restore();

    // 2. Kalkan Dış Çerçevesi (Neo-Brutalist Kalın Çizgi)
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.0, w * 0.075);
    canvas.drawPath(path, borderPaint);

    // 3. İç İnce Vurgu Çerçevesi (Neon Accent)
    final innerBorderPath = _createShapePath(shape, w * 0.88, h * 0.88);
    final innerPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.0, w * 0.035);

    canvas.save();
    canvas.translate(w * 0.06, h * 0.06);
    canvas.drawPath(innerBorderPath, innerPaint);
    canvas.restore();

    // 4. Merkez Hanedanlık Sembolü / İkonu
    _drawSymbol(canvas, w, h);
  }

  Path _createShapePath(EmblemShape shape, double w, double h) {
    final path = Path();
    switch (shape) {
      case EmblemShape.classicShield:
        path.moveTo(0, 0);
        path.lineTo(w, 0);
        path.lineTo(w, h * 0.65);
        path.lineTo(w * 0.5, h);
        path.lineTo(0, h * 0.65);
        path.close();
        break;

      case EmblemShape.roundedHeater:
        path.moveTo(w * 0.1, 0);
        path.lineTo(w * 0.9, 0);
        path.quadraticBezierTo(w, 0, w, h * 0.2);
        path.quadraticBezierTo(w, h * 0.7, w * 0.5, h);
        path.quadraticBezierTo(0, h * 0.7, 0, h * 0.2);
        path.quadraticBezierTo(0, 0, w * 0.1, 0);
        path.close();
        break;

      case EmblemShape.diamond:
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, h * 0.5);
        path.lineTo(w * 0.5, h);
        path.lineTo(0, h * 0.5);
        path.close();
        break;

      case EmblemShape.hexagon:
        path.moveTo(w * 0.5, 0);
        path.lineTo(w, h * 0.25);
        path.lineTo(w, h * 0.75);
        path.lineTo(w * 0.5, h);
        path.lineTo(0, h * 0.75);
        path.lineTo(0, h * 0.25);
        path.close();
        break;

      case EmblemShape.circle:
        path.addOval(Rect.fromLTWH(0, 0, w, h));
        break;
    }
    return path;
  }

  void _drawPattern(Canvas canvas, double w, double h) {
    final pPaint = Paint()..color = primaryColor;
    final sPaint = Paint()..color = secondaryColor;

    // Arka planı primary ile kapla
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), pPaint);

    switch (pattern) {
      case EmblemPattern.verticalSplit:
        canvas.drawRect(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h), sPaint);
        break;

      case EmblemPattern.horizontalSplit:
        canvas.drawRect(Rect.fromLTWH(0, h * 0.5, w, h * 0.5), sPaint);
        break;

      case EmblemPattern.diagonalSash:
        final sashPath = Path()
          ..moveTo(0, 0)
          ..lineTo(w * 0.45, 0)
          ..lineTo(w, h * 0.55)
          ..lineTo(w, h)
          ..lineTo(w * 0.55, h)
          ..lineTo(0, h * 0.45)
          ..close();
        canvas.drawPath(sashPath, sPaint);
        break;

      case EmblemPattern.striped:
        final barWidth = w / 5;
        canvas.drawRect(Rect.fromLTWH(barWidth, 0, barWidth, h), sPaint);
        canvas.drawRect(Rect.fromLTWH(barWidth * 3, 0, barWidth, h), sPaint);
        break;

      case EmblemPattern.quartered:
        canvas.drawRect(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h * 0.5), sPaint);
        canvas.drawRect(Rect.fromLTWH(0, h * 0.5, w * 0.5, h * 0.5), sPaint);
        break;

      case EmblemPattern.solidWithBorder:
        // İç dolgu
        final centerCircle = Paint()
          ..color = secondaryColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.35, centerCircle);
        break;
    }
  }

  void _drawSymbol(Canvas canvas, double w, double h) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: w * 0.46,
          shadows: const [
            Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 1),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final offset = Offset(
      (w - textPainter.width) / 2,
      (h - textPainter.height) / 2 - (shape == EmblemShape.classicShield ? h * 0.05 : 0),
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ClubEmblemPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.pattern != pattern ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.symbol != symbol;
  }
}
