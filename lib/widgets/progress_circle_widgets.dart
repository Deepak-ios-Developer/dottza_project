
import 'dart:math' as math;

import 'package:dotzza_project/main.dart';
import 'package:flutter/material.dart';

class OasisProgressCirclePainter extends CustomPainter {
  final double progress;

  OasisProgressCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle with subtle gradient effect
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFAF8FF),
          const Color(0xFFF3F0FF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, bgPaint);

    // Background ring (unfilled portion)
    final bgRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 2, bgRingPaint);

    // Progress ring with gradient
    final progressRect = Rect.fromCircle(center: center, radius: radius - 2);
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF9B87E8),
          const Color(0xFF9B87E8),
        ],
      ).createShader(progressRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = math.pi * progress;
    
    canvas.drawArc(
      progressRect,
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant OasisProgressCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class PriorityCirclePainter extends CustomPainter {
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final int total;

  PriorityCirclePainter({
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawCircle(center, radius - 8, bgPaint);

    if (total == 0) return;

    double startAngle = -math.pi / 2;

    // High priority with gradient
    if (highCount > 0) {
      final highRect = Rect.fromCircle(center: center, radius: radius - 8);
      final highPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF9B87E8),
            const Color(0xFF8A73D6),
          ],
        ).createShader(highRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      final highSweep = (highCount / total) * 2 * math.pi;
      canvas.drawArc(
        highRect,
        startAngle,
        highSweep,
        false,
        highPaint,
      );
      startAngle += highSweep;
    }

    // Medium priority
    if (mediumCount > 0) {
      final mediumPaint = Paint()
        ..color = const Color(0xFFB39DFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      final mediumSweep = (mediumCount / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        startAngle,
        mediumSweep,
        false,
        mediumPaint,
      );
      startAngle += mediumSweep;
    }

    // Low priority
    if (lowCount > 0) {
      final lowPaint = Paint()
        ..color = const Color(0xFFD4C5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      final lowSweep = (lowCount / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        startAngle,
        lowSweep,
        false,
        lowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CompletionCirclePainter extends CustomPainter {
  final double progress;

  CompletionCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 6, bgPaint);

    // Progress arc with gradient
    final progressRect = Rect.fromCircle(center: center, radius: radius - 6);
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white,
        ],
      ).createShader(progressRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      progressRect,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}class MultiRingProgress extends StatelessWidget {
  final double high;     // 0–1
  final double medium;   // 0–1
  final double low;      // 0–1
  final double least;    // 0–1

  const MultiRingProgress({
    super.key,
    required this.high,
    required this.medium,
    required this.low,
    required this.least,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: CustomPaint(
        painter: _MultiRingPainter(
          high: high,
          medium: medium,
          low: low,
          least: least,
        ),
      ),
    );
  }
}

class _MultiRingPainter extends CustomPainter {
  final double high;
  final double medium;
  final double low;
  final double least;

  _MultiRingPainter({
    required this.high,
    required this.medium,
    required this.low,
    required this.least,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 10;

    final center = Offset(size.width / 2, size.height / 2);

    // 🔥 Define 4 radii for 4 rings
    final double r1 = size.width * 0.40; // outermost
    final double r2 = size.width * 0.32;
    final double r3 = size.width * 0.24;
    final double r4 = size.width * 0.16; // innermost

    Paint bg = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final rect1 = Rect.fromCircle(center: center, radius: r1);
    final rect2 = Rect.fromCircle(center: center, radius: r2);
    final rect3 = Rect.fromCircle(center: center, radius: r3);
    final rect4 = Rect.fromCircle(center: center, radius: r4);

    // ---------- Background Base Circles ----------
    canvas.drawArc(rect1, 0, 6.283, false, bg);
    canvas.drawArc(rect2, 0, 6.283, false, bg);
    canvas.drawArc(rect3, 0, 6.283, false, bg);
    canvas.drawArc(rect4, 0, 6.283, false, bg);

    // ---------- Colored Progress Arcs (Outer → Inner) ----------

    // OUTER – Low (Blue)
    _drawArc(canvas, rect1, stroke, 6.283 * low, blue500);

    // MID 1 – Medium (Yellow)
    _drawArc(canvas, rect2, stroke, 6.283 * medium, yellow500);

    // MID 2 – High (Red)
    _drawArc(canvas, rect3, stroke, 6.283 * high, red500);

    // INNER – Least (Purple or any color)
    _drawArc(canvas, rect4, stroke, 6.283 * least, primary500);
  }

  void _drawArc(Canvas canvas, Rect rect, double stroke, double sweep, Color c) {
    Paint p = Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    canvas.drawArc(
      rect,
      -90 * 0.0174533, // Start angle (top)
      sweep,
      false,
      p,
    );
  }

  @override
  bool shouldRepaint(_) => true;
}


class SleepGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = Colors.blue.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.5,
      size.width * 0.4, size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.8,
      size.width, size.height * 0.5,
    );

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}
