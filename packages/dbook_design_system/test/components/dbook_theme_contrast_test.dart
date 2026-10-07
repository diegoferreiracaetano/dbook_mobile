import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/contrast.dart';

typedef _Pair = (Color foreground, Color background);

const _aaText = 4.5;

Map<String, _Pair> _pairs(ColorScheme c) => {
  'onSurface/surface': (c.onSurface, c.surface),
  'onSurfaceVariant/surface': (c.onSurfaceVariant, c.surface),
  'onSurfaceVariant/surfaceContainerLow': (
    c.onSurfaceVariant,
    c.surfaceContainerLow,
  ),
  'onError/error': (c.onError, c.error),
  'onErrorContainer/errorContainer': (c.onErrorContainer, c.errorContainer),
  'onPrimaryContainer/primaryContainer': (
    c.onPrimaryContainer,
    c.primaryContainer,
  ),
  'onPrimary/primary': (c.onPrimary, c.primary),
  'primary/surface': (c.primary, c.surface),
  'onSecondaryContainer/secondaryContainer': (
    c.onSecondaryContainer,
    c.secondaryContainer,
  ),
  'onSecondary/secondary': (c.onSecondary, c.secondary),
};

/// Pares da marca que hoje ficam **abaixo do AA** (texto normal, 4,5:1), com o
/// valor medido em 2026-10-07. Não são aprovados: são lacunas conhecidas, à
/// espera de uma decisão de design (a paleta é compartilhada com o app de
/// clientes). O teste impede que piorem; quando um par for corrigido, tire-o
/// daqui e ele passa a ser exigido como os demais.
const _knownBelowAa = <String, Map<String, double>>{
  'light': {
    'onPrimary/primary': 3.62,
    'primary/surface': 3.62,
    'onSecondaryContainer/secondaryContainer': 3.83,
    'onSecondary/secondary': 2.17,
  },
  'dark': {
    'primary/surface': 3.57,
    'onSecondaryContainer/secondaryContainer': 3.83,
  },
};

void main() {
  final schemes = {
    'light': DbookColorScheme.light,
    'dark': DbookColorScheme.dark,
  };

  for (final theme in schemes.entries) {
    final gaps = _knownBelowAa[theme.key] ?? const {};

    for (final pair in _pairs(theme.value).entries) {
      final ratio = contrastRatio(pair.value.$1, pair.value.$2);
      final floor = gaps[pair.key];

      if (floor == null) {
        test('given the ${theme.key} theme when ${pair.key} is drawn then it '
            'meets AA (4.5:1)', () {
          expect(ratio, greaterThanOrEqualTo(_aaText));
        });
      } else {
        test('given the ${theme.key} theme when ${pair.key} is drawn then it '
            'is no worse than the known gap ($floor:1)', () {
          expect(ratio, greaterThanOrEqualTo(floor - 0.01));
        });
      }
    }
  }

  test('given a known gap that was fixed when measured then it must leave '
      'the list (so it becomes mandatory)', () {
    for (final theme in schemes.entries) {
      final pairs = _pairs(theme.value);
      for (final gap in (_knownBelowAa[theme.key] ?? const {}).keys) {
        final pair = pairs[gap]!;
        expect(
          contrastRatio(pair.$1, pair.$2),
          lessThan(_aaText),
          reason:
              '$gap (${theme.key}) now meets AA: remove it from _knownBelowAa',
        );
      }
    }
  });
}
