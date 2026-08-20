// presentation/widgets/pitch_painter.dart
// CustomPainter 2D football pitch view with stripes, penalty boxes, center circle and player nodes.

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../domain/entities/player.dart';

class PitchPainter extends CustomPainter {
  final List<Player> homePlayers;
  final List<Player> awayPlayers;
  final Offset? ballPosition;
  final String homeFormation;
  final String awayFormation;

  PitchPainter({
    required this.homePlayers,
    this.awayPlayers = const [],
    this.ballPosition,
    this.homeFormation = '4-3-3',
    this.awayFormation = '4-3-3',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Saha Çimi ve Retro Izgara Deseni (16-bit arcade grass & grid)
    const grassDark = Color(0xFF0F381E);
    const grassLight = Color(0xFF144D2A);

    const stripeCount = 10;
    final stripeHeight = h / stripeCount;
    for (var i = 0; i < stripeCount; i++) {
      final paint = Paint()..color = i % 2 == 0 ? grassDark : grassLight;
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, w, stripeHeight),
        paint,
      );
    }

    // Retro CRT Scanlines
    final scanlinePaint = Paint()..color = Colors.black.withValues(alpha: 0.15);
    for (var y = 0.0; y < h; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(w, y), scanlinePaint);
    }

    // 2. Neon Saha Çizgileri
    final linePaint = Paint()
      ..color = AppColors.neonLime.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const margin = 14.0;
    final pitchRect = Rect.fromLTRB(margin, margin, w - margin, h - margin);

    // Dış Çizgi & Köşe Bayrakları
    canvas.drawRect(pitchRect, linePaint);

    // Orta Çizgi
    canvas.drawLine(
      Offset(margin, h / 2),
      Offset(w - margin, h / 2),
      linePaint,
    );

    // Orta Daire
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.16, linePaint);
    canvas.drawCircle(Offset(w / 2, h / 2), 3.0, Paint()..color = AppColors.neonLime);

    // Ceza Sahaları (Üst ve Alt)
    final boxWidth = w * 0.55;
    final boxHeight = h * 0.16;
    final goalAreaWidth = w * 0.28;
    final goalAreaHeight = h * 0.06;

    // Üst Ceza Sahası
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w / 2, margin + boxHeight / 2),
        width: boxWidth,
        height: boxHeight,
      ),
      linePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w / 2, margin + goalAreaHeight / 2),
        width: goalAreaWidth,
        height: goalAreaHeight,
      ),
      linePaint,
    );

    // Alt Ceza Sahası
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w / 2, h - margin - boxHeight / 2),
        width: boxWidth,
        height: boxHeight,
      ),
      linePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(w / 2, h - margin - goalAreaHeight / 2),
        width: goalAreaWidth,
        height: goalAreaHeight,
      ),
      linePaint,
    );

    // 3. Oyuncu Düğümleri (Ev Sahibi Alt Yarıda, Deplasman Üst Yarıda)
    final homePositions = _getCoordinatesForFormation(homeFormation, w, h, isHome: true);
    for (var i = 0; i < homePlayers.take(11).length; i++) {
      final p = homePlayers[i];
      final coord = i < homePositions.length ? homePositions[i] : Offset(w / 2, h * 0.7);
      _drawPlayerNode(canvas, coord, p.position.code, p.lastName, isHome: true);
    }

    // Deplasman Oyuncuları (Üst Yarıda)
    final awayPositions = _getCoordinatesForFormation(awayFormation, w, h, isHome: false);
    for (var i = 0; i < 11; i++) {
      final posCode = _getPositionCodeForIndex(i);
      final lastName = i < awayPlayers.length ? awayPlayers[i].lastName : 'Rakip ${i + 1}';
      final coord = i < awayPositions.length ? awayPositions[i] : Offset(w / 2, h * 0.3);
      _drawPlayerNode(canvas, coord, posCode, lastName, isHome: false);
    }

    // 4. Canlı Retro Neon Top
    if (ballPosition != null) {
      final ballPixelOffset = Offset(
        ballPosition!.dx * w,
        ballPosition!.dy * h,
      );

      // Neon Top Parlaması
      final glowPaint = Paint()
        ..color = AppColors.neonPink.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(ballPixelOffset, 10.0, glowPaint);

      // Top Gövdesi
      final ballPaint = Paint()..color = Colors.white;
      canvas.drawCircle(ballPixelOffset, 6.0, ballPaint);

      // Top Çerçevesi
      final ballBorder = Paint()
        ..color = AppColors.neonPink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(ballPixelOffset, 6.0, ballBorder);
    }
  }

  void _drawPlayerNode(Canvas canvas, Offset offset, String positionCode, String lastName, {required bool isHome}) {
    final nodeColor = isHome ? AppColors.neonLime : AppColors.neonCyan;
    final nodePaint = Paint()..color = Colors.black;
    final borderPaint = Paint()
      ..color = nodeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Retro Arcade Beveled Node
    canvas.drawCircle(offset, 12.0, nodePaint);
    canvas.drawCircle(offset, 12.0, borderPaint);

    // Pozisyon Kodu
    final textPainter = TextPainter(
      text: TextSpan(
        text: positionCode,
        style: TextStyle(
          color: nodeColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      offset - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Oyuncu Soyadı
    final namePainter = TextPainter(
      text: TextSpan(
        text: lastName.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
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
      Offset(offset.dx - (namePainter.width / 2), offset.dy + (isHome ? 13 : -20)),
    );
  }

  String _getPositionCodeForIndex(int i) {
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

  List<Offset> _getCoordinatesForFormation(String formation, double w, double h, {required bool isHome}) {
    if (isHome) {
      // 1 GK, Defans, Orta Saha, Forvet koordinatları (Alt yarı saha: 0.54 - 0.92)
      return [
        Offset(w * 0.50, h * 0.92), // GK
        Offset(w * 0.15, h * 0.80), // LB
        Offset(w * 0.38, h * 0.82), // CB
        Offset(w * 0.62, h * 0.82), // CB
        Offset(w * 0.85, h * 0.80), // RB
        Offset(w * 0.25, h * 0.68), // CM
        Offset(w * 0.50, h * 0.70), // DM
        Offset(w * 0.75, h * 0.68), // CM
        Offset(w * 0.18, h * 0.55), // LW
        Offset(w * 0.50, h * 0.54), // ST
        Offset(w * 0.82, h * 0.55), // RW
      ];
    } else {
      // Deplasman koordinatları (Üst yarı saha: 0.08 - 0.46)
      return [
        Offset(w * 0.50, h * 0.08), // GK
        Offset(w * 0.85, h * 0.20), // RB
        Offset(w * 0.62, h * 0.18), // CB
        Offset(w * 0.38, h * 0.18), // CB
        Offset(w * 0.15, h * 0.20), // LB
        Offset(w * 0.75, h * 0.32), // CM
        Offset(w * 0.50, h * 0.30), // DM
        Offset(w * 0.25, h * 0.32), // CM
        Offset(w * 0.82, h * 0.45), // RW
        Offset(w * 0.50, h * 0.46), // ST
        Offset(w * 0.18, h * 0.45), // LW
      ];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
