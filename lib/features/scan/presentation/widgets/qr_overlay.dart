import 'package:flutter/material.dart';

class QrOverlay extends StatelessWidget {
  const QrOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const frameSize = 240.0;
    const cornerLen = 24.0;
    const strokeW = 3.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - frameSize / 2;
    final top = cy - frameSize / 2;
    final rect = Rect.fromLTWH(left, top, frameSize, frameSize);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          ),
      ),
      Paint()..color = Colors.black54,
    );

    final corner = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final r = left + frameSize;
    final b = top + frameSize;

    void line(Offset a, Offset c) => canvas.drawLine(a, c, corner);
    // Top-left
    line(Offset(left, top + cornerLen), Offset(left, top));
    line(Offset(left, top), Offset(left + cornerLen, top));
    // Top-right
    line(Offset(r - cornerLen, top), Offset(r, top));
    line(Offset(r, top), Offset(r, top + cornerLen));
    // Bottom-left
    line(Offset(left, b - cornerLen), Offset(left, b));
    line(Offset(left, b), Offset(left + cornerLen, b));
    // Bottom-right
    line(Offset(r - cornerLen, b), Offset(r, b));
    line(Offset(r, b), Offset(r, b - cornerLen));
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => false;
}
