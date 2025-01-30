import 'package:flutter/material.dart';

class RectangularProgressBorderPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  RectangularProgressBorderPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Calculate the total perimeter of the rectangle
    final double perimeter = 2 * (size.width + size.height);

    // Calculate the length of the progress border
    final double progressLength = perimeter * progress;

    // Draw the progress border
    _drawProgressBorder(canvas, rect, progressLength, paint);
  }

  void _drawProgressBorder(Canvas canvas, Rect rect, double progressLength, Paint paint) {
    double currentLength = 0;

    // Top edge
    if (currentLength + rect.width <= progressLength) {
      canvas.drawLine(rect.topLeft, rect.topRight, paint);
      currentLength += rect.width;
    } else {
      final double remaining = progressLength - currentLength;
      canvas.drawLine(rect.topLeft, rect.topLeft + Offset(remaining, 0), paint);
      return;
    }

    // Right edge
    if (currentLength + rect.height <= progressLength) {
      canvas.drawLine(rect.topRight, rect.bottomRight, paint);
      currentLength += rect.height;
    } else {
      final double remaining = progressLength - currentLength;
      canvas.drawLine(rect.topRight, rect.topRight + Offset(0, remaining), paint);
      return;
    }

    // Bottom edge
    if (currentLength + rect.width <= progressLength) {
      canvas.drawLine(rect.bottomRight, rect.bottomLeft, paint);
      currentLength += rect.width;
    } else {
      final double remaining = progressLength - currentLength;
      canvas.drawLine(rect.bottomRight, rect.bottomRight - Offset(remaining, 0), paint);
      return;
    }

    // Left edge
    if (currentLength + rect.height <= progressLength) {
      canvas.drawLine(rect.bottomLeft, rect.topLeft, paint);
    } else {
      final double remaining = progressLength - currentLength;
      canvas.drawLine(rect.bottomLeft, rect.bottomLeft - Offset(0, remaining), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}