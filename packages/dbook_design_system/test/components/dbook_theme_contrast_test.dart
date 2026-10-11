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

void main() {
  final schemes = {
    'light': DbookColorScheme.light,
    'dark': DbookColorScheme.dark,
  };

  for (final theme in schemes.entries) {
    for (final pair in _pairs(theme.value).entries) {
      final ratio = contrastRatio(pair.value.$1, pair.value.$2);

      test('given the ${theme.key} theme when ${pair.key} is drawn then it '
          'meets AA (4.5:1)', () {
        expect(ratio, greaterThanOrEqualTo(_aaText));
      });
    }
  }

  final brands = {
    'light': DbookBrandColors.light,
    'dark': DbookBrandColors.dark,
  };
  for (final entry in brands.entries) {
    final b = entry.value;
    test('given the ${entry.key} brand surface when text is drawn on it then '
        'both the main and the muted text meet AA', () {
      expect(
        contrastRatio(b.onSurface, b.surface),
        greaterThanOrEqualTo(_aaText),
      );
      expect(
        contrastRatio(b.onSurfaceMuted, b.surface),
        greaterThanOrEqualTo(_aaText),
      );
    });
  }
}
