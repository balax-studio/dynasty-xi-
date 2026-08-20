// presentation/widgets/face_avatar_widget.dart
// Procedural Pixel & Retro Avatar Renderer using CustomPainter (§23.1)

import 'package:flutter/material.dart';
import '../../domain/visuals/face_generator.dart';

class FaceAvatarWidget extends StatelessWidget {
  final dynamic seed;
  final double size;
  final bool showBorder;

  const FaceAvatarWidget({
    super.key,
    required this.seed,
    this.size = 48.0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final int numericSeed = seed is int ? seed : (int.tryParse(seed.toString()) ?? seed.toString().hashCode);
    final face = ProceduralFaceData.fromSeed(numericSeed);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: showBorder ? Border.all(color: Colors.black, width: 2) : null,
        boxShadow: showBorder
            ? const [
                BoxShadow(color: Colors.black, offset: Offset(2, 2)),
              ]
            : null,
      ),
      child: ClipRect(
        child: CustomPaint(
          size: Size(size, size),
          painter: _FacePainter(face),
        ),
      ),
    );
  }
}

class _FacePainter extends CustomPainter {
  final ProceduralFaceData face;

  _FacePainter(this.face);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final unit = w / 16.0;

    final skinPaint = Paint()..color = face.skinColor;
    final hairPaint = Paint()..color = face.hairColor;
    final eyePaint = Paint()..color = face.eyeColor;
    final pupilPaint = Paint()..color = Colors.black;
    final mouthPaint = Paint()..color = const Color(0xFF881337);
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.15);

    // 1. Neck
    canvas.drawRect(Rect.fromLTWH(6 * unit, 11 * unit, 4 * unit, 4 * unit), shadowPaint);
    canvas.drawRect(Rect.fromLTWH(6.5 * unit, 11 * unit, 3 * unit, 4 * unit), skinPaint);

    // 2. Base Head (Pixel Rect)
    final headRect = Rect.fromLTWH(3.5 * unit, 3 * unit, 9 * unit, 9 * unit);
    canvas.drawRect(headRect, skinPaint);

    // Jaw shading
    canvas.drawRect(Rect.fromLTWH(3.5 * unit, 11 * unit, 9 * unit, 1 * unit), shadowPaint);

    // 3. Hair Base & Style
    switch (face.hairStyle % 6) {
      case 0: // Buzzcut / Short
        canvas.drawRect(Rect.fromLTWH(3 * unit, 2 * unit, 10 * unit, 2.5 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(2.5 * unit, 3 * unit, 1.5 * unit, 4 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(12 * unit, 3 * unit, 1.5 * unit, 4 * unit), hairPaint);
        break;
      case 1: // Afro / Curly
        canvas.drawRect(Rect.fromLTWH(2 * unit, 1 * unit, 12 * unit, 4 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(1.5 * unit, 2 * unit, 2 * unit, 6 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(12.5 * unit, 2 * unit, 2 * unit, 6 * unit), hairPaint);
        break;
      case 2: // Side Part / Slick
        canvas.drawRect(Rect.fromLTWH(3 * unit, 1.5 * unit, 10 * unit, 3 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(2 * unit, 2.5 * unit, 2.5 * unit, 5 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(12 * unit, 3.5 * unit, 1.5 * unit, 3 * unit), hairPaint);
        break;
      case 3: // Spiky
        canvas.drawRect(Rect.fromLTWH(3 * unit, 2 * unit, 10 * unit, 2.5 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(4 * unit, 0.5 * unit, 2 * unit, 2 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(7 * unit, 0.5 * unit, 2 * unit, 2 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(10 * unit, 0.5 * unit, 2 * unit, 2 * unit), hairPaint);
        break;
      case 4: // Ponytail / Long
        canvas.drawRect(Rect.fromLTWH(3 * unit, 2 * unit, 10 * unit, 3 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(2 * unit, 4 * unit, 2 * unit, 8 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(12 * unit, 4 * unit, 2 * unit, 8 * unit), hairPaint);
        break;
      default: // Dreadlocks / Fringe
        canvas.drawRect(Rect.fromLTWH(3 * unit, 1.5 * unit, 10 * unit, 4 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(4 * unit, 4.5 * unit, 1.5 * unit, 2 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(7 * unit, 4.5 * unit, 1.5 * unit, 2 * unit), hairPaint);
        canvas.drawRect(Rect.fromLTWH(10 * unit, 4.5 * unit, 1.5 * unit, 2 * unit), hairPaint);
    }

    // 4. Eyes & Brows
    // Brows
    canvas.drawRect(Rect.fromLTWH(4.5 * unit, 5 * unit, 2.5 * unit, 0.7 * unit), hairPaint);
    canvas.drawRect(Rect.fromLTWH(9 * unit, 5 * unit, 2.5 * unit, 0.7 * unit), hairPaint);

    // Left Eye
    canvas.drawRect(Rect.fromLTWH(5 * unit, 6 * unit, 2 * unit, 1.5 * unit), Colors.white as dynamic);
    canvas.drawRect(Rect.fromLTWH(5.5 * unit, 6.2 * unit, 1.2 * unit, 1.2 * unit), eyePaint);
    canvas.drawRect(Rect.fromLTWH(5.8 * unit, 6.5 * unit, 0.6 * unit, 0.6 * unit), pupilPaint);

    // Right Eye
    canvas.drawRect(Rect.fromLTWH(9 * unit, 6 * unit, 2 * unit, 1.5 * unit), Colors.white as dynamic);
    canvas.drawRect(Rect.fromLTWH(9.3 * unit, 6.2 * unit, 1.2 * unit, 1.2 * unit), eyePaint);
    canvas.drawRect(Rect.fromLTWH(9.6 * unit, 6.5 * unit, 0.6 * unit, 0.6 * unit), pupilPaint);

    // 5. Nose
    canvas.drawRect(Rect.fromLTWH(7.5 * unit, 7.5 * unit, 1 * unit, 1.5 * unit), shadowPaint);

    // 6. Mouth
    if (face.mouthShape == 0) {
      // Smile
      canvas.drawRect(Rect.fromLTWH(6.5 * unit, 10 * unit, 3 * unit, 0.8 * unit), mouthPaint);
    } else if (face.mouthShape == 1) {
      // Focused / Straight
      canvas.drawRect(Rect.fromLTWH(6.8 * unit, 10 * unit, 2.4 * unit, 0.6 * unit), mouthPaint);
    } else {
      // Open / Shouting
      canvas.drawRect(Rect.fromLTWH(6.5 * unit, 9.7 * unit, 3 * unit, 1.4 * unit), mouthPaint);
    }

    // 7. Beard / Mustache
    if (face.beardStyle == 1) {
      // Stubble
      canvas.drawRect(Rect.fromLTWH(5.5 * unit, 9 * unit, 5 * unit, 2.5 * unit), hairPaint..color = face.hairColor.withValues(alpha: 0.4));
    } else if (face.beardStyle == 2) {
      // Goatee
      canvas.drawRect(Rect.fromLTWH(6.5 * unit, 10.8 * unit, 3 * unit, 1.5 * unit), hairPaint);
    } else if (face.beardStyle == 3) {
      // Full Beard
      canvas.drawRect(Rect.fromLTWH(4 * unit, 8 * unit, 8 * unit, 4 * unit), hairPaint..color = face.hairColor.withValues(alpha: 0.85));
    }

    // 8. Accessories
    if (face.accessory == 1) {
      // Headband
      final bandPaint = Paint()..color = const Color(0xFFEF4444);
      canvas.drawRect(Rect.fromLTWH(2.5 * unit, 4 * unit, 11 * unit, 1 * unit), bandPaint);
    } else if (face.accessory == 2) {
      // Sports Glasses
      final glassPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * 0.4;
      canvas.drawRect(Rect.fromLTWH(4.5 * unit, 5.8 * unit, 2.8 * unit, 2 * unit), glassPaint);
      canvas.drawRect(Rect.fromLTWH(8.7 * unit, 5.8 * unit, 2.8 * unit, 2 * unit), glassPaint);
      canvas.drawLine(Offset(7.3 * unit, 6.8 * unit), Offset(8.7 * unit, 6.8 * unit), glassPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) => oldDelegate.face.seed != face.seed;
}
