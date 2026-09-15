import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';
import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Tela cheia de sucesso (ex. confirmação de reserva) — fundo em gradiente,
/// ícone de check com sparkles decorativos, bloco de referência opcional
/// (com botão de copiar) e até duas ações, com uma silhueta de skyline no
/// rodapé. Usa branco literal porque todo o conteúdo é "sobre cor", mesmo
/// padrão já usado no texto do `DbookDestinationCard` sobre a foto.
class DbookSuccessScreen extends StatelessWidget {
  const DbookSuccessScreen({
    super.key,
    required this.title,
    required this.message,
    this.referenceLabel,
    this.referenceValue,
    this.onCopyReference,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final String title;
  final String message;
  final String? referenceLabel;
  final String? referenceValue;
  final VoidCallback? onCopyReference;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DbookPalette.primaryPressed, DbookPalette.primary],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _Sparkles()),
          const Positioned(left: 0, right: 0, bottom: 0, child: _SkylineArt()),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DbookSpacing.xl,
              vertical: DbookSpacing.xxxl,
            ),
            // `primaryActionLabel` pode ser bem mais longo que "View My
            // Bookings" (ex. "Search Next Flight: Rio de Janeiro (GIG) →
            // São Paulo (GRU)" da jornada ida-e-volta/Multi-city) — sem
            // scroll, um título+mensagem+botão longos o bastante juntos
            // estouram a altura da tela (RenderFlex overflow). O
            // `LayoutBuilder`+`ConstrainedBox` mantém o conteúdo
            // centralizado quando cabe (caso comum) e deixa rolar quando
            // não cabe, em vez de vazar.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: DbookSpacing.xl),
                      Text(
                        title,
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: DbookSpacing.sm),
                      Text(
                        message,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (referenceLabel != null && referenceValue != null) ...[
                        const SizedBox(height: DbookSpacing.xl),
                        _ReferenceCard(
                          label: referenceLabel!,
                          value: referenceValue!,
                          onCopy: onCopyReference,
                        ),
                      ],
                      if (primaryActionLabel != null &&
                          onPrimaryAction != null) ...[
                        const SizedBox(height: DbookSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onPrimaryAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: DbookPalette.primary,
                            ),
                            child: Text(primaryActionLabel!),
                          ),
                        ),
                      ],
                      if (secondaryActionLabel != null &&
                          onSecondaryAction != null) ...[
                        const SizedBox(height: DbookSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: onSecondaryAction,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: Text(secondaryActionLabel!),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard({required this.label, required this.value, this.onCopy});

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DbookSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(DbookRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: DbookSpacing.xs),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _Sparkles extends StatelessWidget {
  const _Sparkles();

  static const _positions = [
    (0.18, 0.14, 14.0),
    (0.78, 0.10, 10.0),
    (0.82, 0.24, 16.0),
    (0.14, 0.28, 10.0),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            for (final (dx, dy, size) in _positions)
              Positioned(
                left: constraints.maxWidth * dx,
                top: constraints.maxHeight * dy,
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withValues(alpha: 0.55),
                  size: size,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SkylineArt extends StatelessWidget {
  const _SkylineArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _SkylinePainter())),
          const Positioned(
            right: 24,
            top: 4,
            child: Icon(Icons.flight, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  static const _buildingWidths = [
    0.08,
    0.06,
    0.1,
    0.05,
    0.09,
    0.07,
    0.11,
    0.06,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    var x = 0.0;

    for (var i = 0; i < _buildingWidths.length; i++) {
      final width = size.width * _buildingWidths[i];
      final height = size.height * (0.4 + (i % 3) * 0.2);
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - height, width, height),
        paint,
      );
      x += width + size.width * 0.01;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
