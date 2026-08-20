// presentation/widgets/player_growth_chart_widget.dart
// Historical Season-by-Season OVR Progression Line Chart (§21.4)

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class PlayerGrowthChartWidget extends StatelessWidget {
  final List<int> seasonRatings;
  final int currentOvr;

  const PlayerGrowthChartWidget({
    super.key,
    required this.seasonRatings,
    required this.currentOvr,
  });

  @override
  Widget build(BuildContext context) {
    final points = seasonRatings.isEmpty ? [currentOvr - 2, currentOvr - 1, currentOvr] : [...seasonRatings, currentOvr];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📈 SEZONLUK GELİŞİM GRAFİĞİ (OVR)',
                style: TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'Şu An: $currentOvr OVR',
                style: const TextStyle(color: AppColors.neonLime, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: CustomPaint(
              painter: _GrowthChartPainter(points),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(points.length, (i) {
              return Text(
                'S${i + 1}: ${points[i]}',
                style: const TextStyle(color: Colors.white54, fontSize: 9),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<int> points;

  _GrowthChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final minVal = (points.reduce((a, b) => a < b ? a : b) - 5).clamp(40, 99);
    final maxVal = (points.reduce((a, b) => a > b ? a : b) + 5).clamp(minVal + 1, 100);

    final linePaint = Paint()
      ..color = AppColors.neonLime
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.0;

    final dotPaint = Paint()..color = AppColors.accentGold;

    // Draw grid lines
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), gridPaint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), gridPaint);

    final path = Path();
    final stepX = points.length > 1 ? size.width / (points.length - 1) : size.width;

    for (int i = 0; i < points.length; i++) {
      final normY = 1.0 - ((points[i] - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);
      final x = i * stepX;
      final y = normY * (size.height - 10) + 5;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw dot
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) => true;
}
