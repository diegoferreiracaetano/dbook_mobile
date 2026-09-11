import 'package:flutter/material.dart';

/// Ilustrações de fundo dos slides de onboarding — desenho vetorial flat
/// (não fotorrealista, de propósito: nenhuma tentativa de imitar uma foto
/// de verdade à mão, só uma cena estilizada), específicas dessa sequência
/// de telas — por isso vivem no app, não no `dbook_design_system`.

/// "Discover New Horizons" — vista de nuvens e asa do avião ao entardecer.
class CloudsAndWingArt extends StatelessWidget {
  const CloudsAndWingArt({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CloudsAndWingPainter(), size: Size.infinite);
  }
}

class _CloudsAndWingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B3D91), Color(0xFF3E7BD6), Color(0xFFFF9D6C)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sky);

    final sun = Paint()
      ..color = const Color(0x55FFE1B3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.55),
      size.width * 0.22,
      sun,
    );

    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.65);
    _drawCloud(canvas, cloud, Offset(size.width * 0.22, size.height * 0.5), 34);
    _drawCloud(
      canvas,
      cloud,
      Offset(size.width * 0.58, size.height * 0.62),
      26,
    );
    _drawCloud(canvas, cloud, Offset(size.width * 0.8, size.height * 0.42), 20);

    final wing = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.55, size.height)
      ..lineTo(size.width * 0.2, size.height * 0.78)
      ..lineTo(0, size.height * 0.82)
      ..close();
    canvas.drawPath(wing, Paint()..color = const Color(0xFF14171C));

    final wingHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.18, size.height * 0.79),
      wingHighlight,
    );
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double scale) {
    canvas.drawCircle(center, scale * 0.6, paint);
    canvas.drawCircle(
      center + Offset(scale * 0.7, scale * 0.1),
      scale * 0.5,
      paint,
    );
    canvas.drawCircle(
      center + Offset(-scale * 0.6, scale * 0.15),
      scale * 0.45,
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, scale * 0.3),
        width: scale * 2.6,
        height: scale * 0.9,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "Best Prices Everytime" — vila colorida à beira de um lago.
class LakesideVillageArt extends StatelessWidget {
  const LakesideVillageArt({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LakesideVillagePainter(), size: Size.infinite);
  }
}

class _LakesideVillagePainter extends CustomPainter {
  static const _houseColors = [
    Color(0xFFF4C453),
    Color(0xFFE8724C),
    Color(0xFF3FA7A0),
    Color(0xFFE0668A),
    Color(0xFFF4C453),
    Color(0xFF3FA7A0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF00566B), Color(0xFF5AB4C4)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.7));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.7), sky);

    final water = Paint()
      ..shader =
          const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5AB4C4), Color(0xFF00899A)],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.62,
              size.width,
              size.height * 0.38,
            ),
          );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38),
      water,
    );

    final ripple = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;
    for (var i = 0; i < 4; i++) {
      final y = size.height * 0.72 + i * size.height * 0.055;
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.9, y),
        ripple,
      );
    }

    final hillside = Path()
      ..moveTo(0, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.4,
        size.width,
        size.height * 0.62,
      )
      ..lineTo(size.width, size.height * 0.66)
      ..close();
    canvas.drawPath(hillside, Paint()..color = const Color(0xFF1E4A52));

    for (var i = 0; i < _houseColors.length; i++) {
      // Espalha as casas entre 12% e 88% da largura (não nas bordas
      // exatas), pra sempre caírem sobre a curva da colina.
      final progress = 0.12 + 0.76 * (i + 0.5) / _houseColors.length;
      final baseX = size.width * progress;
      final riseFactor = (0.25 - (progress - 0.5).abs()).clamp(0.0, 0.25);
      final baseY = size.height * 0.66 - riseFactor * size.height * 0.55;
      final width = size.width * 0.09;
      final height = size.width * 0.08;

      final body = Paint()..color = _houseColors[i];
      canvas.drawRect(
        Rect.fromLTWH(baseX - width / 2, baseY - height, width, height),
        body,
      );

      final roof = Path()
        ..moveTo(baseX - width / 2 - 3, baseY - height)
        ..lineTo(baseX, baseY - height - width * 0.6)
        ..lineTo(baseX + width / 2 + 3, baseY - height)
        ..close();
      canvas.drawPath(roof, Paint()..color = const Color(0xFF14313A));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "Travel Your Way" — montanhas e uma pessoa com mochila no topo.
class MountainHikerArt extends StatelessWidget {
  const MountainHikerArt({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MountainHikerPainter(), size: Size.infinite);
  }
}

class _MountainHikerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4A1E5C), Color(0xFFB1456B)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sky);

    _drawPeak(
      canvas,
      size,
      baseY: size.height * 0.72,
      peakX: size.width * 0.25,
      peakY: size.height * 0.38,
      width: size.width * 0.55,
      color: const Color(0xFF8A5A82),
    );
    _drawPeak(
      canvas,
      size,
      baseY: size.height * 0.78,
      peakX: size.width * 0.78,
      peakY: size.height * 0.3,
      width: size.width * 0.65,
      color: const Color(0xFF6C3F6B),
    );
    _drawPeak(
      canvas,
      size,
      baseY: size.height * 0.82,
      peakX: size.width * 0.5,
      peakY: size.height * 0.55,
      width: size.width * 0.7,
      color: const Color(0xFF4A2A4F),
    );

    final person = Paint()..color = const Color(0xFF1B1024);
    final hipX = size.width * 0.5;
    final hipY = size.height * 0.53;

    canvas.drawCircle(Offset(hipX, hipY - 16), 5, person);
    canvas.drawLine(
      Offset(hipX, hipY - 11),
      Offset(hipX, hipY + 6),
      person..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(hipX, hipY - 6),
      Offset(hipX - 8, hipY - 16),
      person,
    );
    canvas.drawLine(
      Offset(hipX, hipY - 6),
      Offset(hipX + 8, hipY - 16),
      person,
    );
    canvas.drawLine(
      Offset(hipX, hipY + 6),
      Offset(hipX - 6, hipY + 18),
      person,
    );
    canvas.drawLine(
      Offset(hipX, hipY + 6),
      Offset(hipX + 6, hipY + 18),
      person,
    );
  }

  void _drawPeak(
    Canvas canvas,
    Size size, {
    required double baseY,
    required double peakX,
    required double peakY,
    required double width,
    required Color color,
  }) {
    final path = Path()
      ..moveTo(peakX - width / 2, baseY)
      ..lineTo(peakX, peakY)
      ..lineTo(peakX + width / 2, baseY)
      ..close();
    canvas.drawPath(path, Paint()..color = color);

    final snow = Path()
      ..moveTo(peakX - width * 0.08, peakY + width * 0.12)
      ..lineTo(peakX, peakY)
      ..lineTo(peakX + width * 0.08, peakY + width * 0.12)
      ..lineTo(peakX + width * 0.04, peakY + width * 0.1)
      ..lineTo(peakX, peakY + width * 0.16)
      ..lineTo(peakX - width * 0.04, peakY + width * 0.1)
      ..close();
    canvas.drawPath(
      snow,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
