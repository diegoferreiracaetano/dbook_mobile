import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';

/// Bloco visual que sugere um código QR/barcode, usado no bilhete.
///
/// É um padrão fixo desenhado na mão, não um QR de verdade — quando o
/// bilhete for ligado a uma reserva real (M5/M7), troca por uma lib de
/// geração de QR de verdade codificando o id da reserva.
class DbookQrPlaceholder extends StatelessWidget {
  const DbookQrPlaceholder({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DbookRadius.xs),
      child: CustomPaint(
        size: Size.square(size),
        painter: const _QrPatternPainter(),
      ),
    );
  }
}

class _QrPatternPainter extends CustomPainter {
  const _QrPatternPainter();

  static const _gridSize = 6;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final foreground = Paint()..color = const Color(0xFF1D2124);
    final cellSize = size.width / _gridSize;

    for (var row = 0; row < _gridSize; row++) {
      for (var col = 0; col < _gridSize; col++) {
        final filled = (row * 7 + col * 3 + row * col) % 5 < 2;
        if (!filled) continue;

        canvas.drawRect(
          Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
          foreground,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
