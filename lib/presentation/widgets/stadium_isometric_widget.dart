// presentation/widgets/stadium_isometric_widget.dart
// Dynamic Isometric Pixel-Art Stadium & Facility Grounds Canvas (§21.3, §8.1)

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class StadiumIsometricWidget extends StatelessWidget {
  final int stadiumLevel;
  final int trainingLevel;
  final int youthLevel;
  final String clubName;

  const StadiumIsometricWidget({
    super.key,
    required this.stadiumLevel,
    required this.trainingLevel,
    required this.youthLevel,
    required this.clubName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF041810),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 120),
            painter: _StadiumPainter(
              stadiumLevel: stadiumLevel,
              trainingLevel: trainingLevel,
              youthLevel: youthLevel,
            ),
          ),
          Positioned(
            top: 6,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.black.withValues(alpha: 0.8),
              child: Text(
                '🏟️ ${clubName.toUpperCase()} ARENA (SEVİYE $stadiumLevel)',
                style: const TextStyle(color: AppColors.neonLime, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.black.withValues(alpha: 0.8),
              child: Text(
                'Tesisler: Antrenman Sv.$trainingLevel • Akademi Sv.$youthLevel',
                style: const TextStyle(color: AppColors.neonCyan, fontSize: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StadiumPainter extends CustomPainter {
  final int stadiumLevel;
  final int trainingLevel;
  final int youthLevel;

  _StadiumPainter({
    required this.stadiumLevel,
    required this.trainingLevel,
    required this.youthLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final grassPaint = Paint()..color = const Color(0xFF0D5C35);
    final pitchPaint = Paint()..color = const Color(0xFF15803D);
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final standPaint = Paint()
      ..color = stadiumLevel >= 4
          ? const Color(0xFF1E3A8A)
          : (stadiumLevel >= 2 ? const Color(0xFF475569) : const Color(0xFF334155));

    final floodlightPaint = Paint()..color = stadiumLevel >= 3 ? AppColors.accentGold : Colors.grey;

    // 1. Draw outer grass ground
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), grassPaint);

    // 2. Isometric Pitch
    final pitchPath = Path()
      ..moveTo(w * 0.5, h * 0.25)
      ..lineTo(w * 0.78, h * 0.55)
      ..lineTo(w * 0.5, h * 0.85)
      ..lineTo(w * 0.22, h * 0.55)
      ..close();
    canvas.drawPath(pitchPath, pitchPaint);
    canvas.drawPath(pitchPath, linePaint);

    // Center Line
    canvas.drawLine(Offset(w * 0.36, h * 0.4), Offset(w * 0.64, h * 0.7), linePaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.55), 10, linePaint);

    // 3. Stands (Tiered according to stadium level)
    final standHeight = 6.0 * stadiumLevel;

    // Top Stand
    final topStand = Path()
      ..moveTo(w * 0.48, h * 0.22 - standHeight)
      ..lineTo(w * 0.76, h * 0.52 - standHeight)
      ..lineTo(w * 0.78, h * 0.55)
      ..lineTo(w * 0.5, h * 0.25)
      ..close();
    canvas.drawPath(topStand, standPaint);

    // Left Stand
    final leftStand = Path()
      ..moveTo(w * 0.20, h * 0.52 - standHeight)
      ..lineTo(w * 0.48, h * 0.22 - standHeight)
      ..lineTo(w * 0.5, h * 0.25)
      ..lineTo(w * 0.22, h * 0.55)
      ..close();
    canvas.drawPath(leftStand, standPaint..color = standPaint.color.withValues(alpha: 0.9));

    // 4. Floodlights (Stadyum ışıkları)
    if (stadiumLevel >= 2) {
      canvas.drawLine(Offset(w * 0.16, h * 0.45), Offset(w * 0.16, h * 0.25), Paint()..color = Colors.grey..strokeWidth = 2);
      canvas.drawCircle(Offset(w * 0.16, h * 0.25), 3.5, floodlightPaint);

      canvas.drawLine(Offset(w * 0.84, h * 0.45), Offset(w * 0.84, h * 0.25), Paint()..color = Colors.grey..strokeWidth = 2);
      canvas.drawCircle(Offset(w * 0.84, h * 0.25), 3.5, floodlightPaint);
    }

    // 5. Training pitch miniature (Left corner)
    if (trainingLevel >= 1) {
      final tPitch = Rect.fromLTWH(8, h * 0.65, 36, 24);
      canvas.drawRect(tPitch, Paint()..color = const Color(0xFF166534));
      canvas.drawRect(tPitch, linePaint);
    }

    // 6. Youth academy building miniature (Right corner)
    if (youthLevel >= 1) {
      final yBuilding = Rect.fromLTWH(w - 44, h * 0.65, 36, 22);
      canvas.drawRect(yBuilding, Paint()..color = const Color(0xFF64748B));
      canvas.drawRect(Rect.fromLTWH(w - 38, h * 0.70, 8, 8), Paint()..color = AppColors.neonCyan);
    }
  }

  @override
  bool shouldRepaint(covariant _StadiumPainter oldDelegate) =>
      oldDelegate.stadiumLevel != stadiumLevel ||
      oldDelegate.trainingLevel != trainingLevel ||
      oldDelegate.youthLevel != youthLevel;
}
