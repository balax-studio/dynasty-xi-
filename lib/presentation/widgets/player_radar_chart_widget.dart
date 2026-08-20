// presentation/widgets/player_radar_chart_widget.dart
// Custom painted 6-Axis Hexagonal Cyber-Radar Chart for Player Attributes.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../domain/entities/player.dart';

class PlayerRadarChartWidget extends StatelessWidget {
  final Player player;
  final double size;

  const PlayerRadarChartWidget({
    super.key,
    required this.player,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: AppColors.win95DarkGrey, width: 1.5),
      ),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RadarChartPainter(
              attributes: [
                _RadarAttr('HIZ', player.pace),
                _RadarAttr('TEK', player.technique),
                _RadarAttr('ŞUT', player.shooting),
                _RadarAttr('PAS', player.passing),
                _RadarAttr('DEF', player.defending),
                _RadarAttr('FİZ', player.physical),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarAttr {
  final String label;
  final int value;
  const _RadarAttr(this.label, this.value);
}

class _RadarChartPainter extends CustomPainter {
  final List<_RadarAttr> attributes;

  _RadarChartPainter({required this.attributes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 28;
    final count = attributes.length;
    final angleStep = (math.pi * 2) / count;

    final gridPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = Colors.white38
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final polyFillPaint = Paint()
      ..color = AppColors.neonLime.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final polyStrokePaint = Paint()
      ..color = AppColors.neonLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 1. Konsantrik Izgara Halkaları (25, 50, 75, 100)
    for (var step = 1; step <= 4; step++) {
      final r = radius * (step / 4);
      final path = Path();
      for (var i = 0; i < count; i++) {
        final angle = (i * angleStep) - (math.pi / 2);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 2. Eksen Çizgileri & Etiketler
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < count; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), axisPaint);

      // Etiket ve Değer
      final labelOffset = Offset(
        center.dx + (radius + 18) * math.cos(angle),
        center.dy + (radius + 18) * math.sin(angle),
      );

      final attr = attributes[i];
      final labelSpan = TextSpan(
        children: [
          TextSpan(
            text: '${attr.label}\n',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: '${attr.value}',
            style: TextStyle(
              color: attr.value >= 75 ? AppColors.neonCyan : (attr.value >= 60 ? AppColors.accentGold : Colors.white),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );

      textPainter.text = labelSpan;
      textPainter.textAlign = TextAlign.center;
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelOffset.dx - (textPainter.width / 2), labelOffset.dy - (textPainter.height / 2)),
      );
    }

    // 3. Oyuncunun Nitelik Poligonu
    final polyPath = Path();
    for (var i = 0; i < count; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final val = (attributes[i].value / 100.0).clamp(0.1, 1.0);
      final r = radius * val;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        polyPath.moveTo(x, y);
      } else {
        polyPath.lineTo(x, y);
      }
    }
    polyPath.close();

    canvas.drawPath(polyPath, polyFillPaint);
    canvas.drawPath(polyPath, polyStrokePaint);

    // Noktalar
    final dotPaint = Paint()
      ..color = AppColors.neonCyan
      ..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final angle = (i * angleStep) - (math.pi / 2);
      final val = (attributes[i].value / 100.0).clamp(0.1, 1.0);
      final r = radius * val;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) => true;
}
