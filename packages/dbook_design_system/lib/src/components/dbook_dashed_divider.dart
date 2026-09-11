import 'package:flutter/material.dart';

/// Divisor tracejado — Flutter não tem um nativo (o `Divider`/
/// `dividerTheme` cobre só o sólido), então este é um `CustomPaint` fino
/// que só desenha um traço, sem lógica além disso.
class DbookDashedDivider extends StatelessWidget {
  const DbookDashedDivider({
    super.key,
    this.dashWidth = 6,
    this.dashGap = 4,
    this.thickness = 1,
  });

  final double dashWidth;
  final double dashGap;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;

    return SizedBox(
      height: thickness,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: color,
          dashWidth: dashWidth,
          dashGap: dashGap,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    var x = 0.0;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashWidth, size.height / 2),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      dashWidth != oldDelegate.dashWidth ||
      dashGap != oldDelegate.dashGap;
}
