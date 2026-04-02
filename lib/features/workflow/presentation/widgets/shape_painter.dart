import 'package:flutter/material.dart';
import '../../domain/entities/node_shape.dart';

class ShapePainter extends CustomPainter {
  final NodeShape shape;
  final Color color;
  final Color borderColor;

  ShapePainter({
    required this.shape,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path path;
    switch (shape) {
      case NodeShape.rectangle:
        path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        break;
      case NodeShape.roundedRectangle:
        path = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(0, 0, size.width, size.height),
              const Radius.circular(12),
            ),
          );
        break;
      case NodeShape.stadium:
        path = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(0, 0, size.width, size.height),
              Radius.circular(size.height / 2),
            ),
          );
        break;
      case NodeShape.diamond:
        path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();
        break;
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
