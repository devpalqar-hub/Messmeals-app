import 'package:flutter/material.dart';

/// A traditional stacked tiffin/dabba-carrier glyph — a rounded, barrel-
/// shaped body split into three tiers, a domed lid, an arched carry handle,
/// and the little side clasps that hold the tiers together. Material's
/// bundled icon set has no literal tiffin shape, so this is hand-drawn to
/// match the weight of the other outlined bottom-bar icons.
class TiffinBoxIcon extends StatelessWidget {
  final double size;
  final Color color;

  const TiffinBoxIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TiffinBoxPainter(color: color),
    );
  }
}

class _TiffinBoxPainter extends CustomPainter {
  final Color color;

  _TiffinBoxPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.075
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Carry handle
    final handlePath =
        Path()
          ..moveTo(w * 0.37, h * 0.22)
          ..quadraticBezierTo(w * 0.37, h * 0.05, w * 0.5, h * 0.05)
          ..quadraticBezierTo(w * 0.63, h * 0.05, w * 0.63, h * 0.22);
    canvas.drawPath(handlePath, paint);

    // Rounded, barrel-shaped body with a domed lid
    final body =
        Path()
          ..moveTo(w * 0.27, h * 0.29)
          ..quadraticBezierTo(w * 0.18, h * 0.34, w * 0.18, h * 0.5)
          ..quadraticBezierTo(w * 0.18, h * 0.7, w * 0.24, h * 0.82)
          ..quadraticBezierTo(w * 0.27, h * 0.88, w * 0.35, h * 0.88)
          ..lineTo(w * 0.65, h * 0.88)
          ..quadraticBezierTo(w * 0.73, h * 0.88, w * 0.76, h * 0.82)
          ..quadraticBezierTo(w * 0.82, h * 0.7, w * 0.82, h * 0.5)
          ..quadraticBezierTo(w * 0.82, h * 0.34, w * 0.73, h * 0.29)
          ..quadraticBezierTo(w * 0.63, h * 0.19, w * 0.5, h * 0.19)
          ..quadraticBezierTo(w * 0.37, h * 0.19, w * 0.27, h * 0.29)
          ..close();
    canvas.drawPath(body, paint);

    // Tier dividers
    canvas.drawLine(
      Offset(w * 0.185, h * 0.48),
      Offset(w * 0.815, h * 0.48),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.2, h * 0.67),
      Offset(w * 0.8, h * 0.67),
      paint,
    );

    // Side clasps
    final claspPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.06
          ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.1, h * 0.42, w * 0.19, h * 0.58),
        Radius.circular(w * 0.02),
      ),
      claspPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.81, h * 0.42, w * 0.9, h * 0.58),
        Radius.circular(w * 0.02),
      ),
      claspPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TiffinBoxPainter oldDelegate) =>
      oldDelegate.color != color;
}
