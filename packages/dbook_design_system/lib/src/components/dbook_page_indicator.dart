import 'package:flutter/material.dart';

import '../tokens/dbook_motion.dart';
import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Indicador de página (dots) — usado no onboarding. Cores default são
/// brancas porque o uso típico é sobre uma foto; passe [color]/
/// [inactiveColor] pra usar em outro contexto.
class DbookPageIndicator extends StatelessWidget {
  const DbookPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentIndex,
    this.color = Colors.white,
    this.inactiveColor = Colors.white38,
  });

  final int pageCount;
  final int currentIndex;
  final Color color;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < pageCount; i++) ...[
          if (i > 0) const SizedBox(width: DbookSpacing.xs),
          AnimatedContainer(
            duration: DbookMotion.fast,
            curve: DbookMotion.standard,
            width: i == currentIndex ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == currentIndex ? color : inactiveColor,
              borderRadius: BorderRadius.circular(DbookRadius.full),
            ),
          ),
        ],
      ],
    );
  }
}
