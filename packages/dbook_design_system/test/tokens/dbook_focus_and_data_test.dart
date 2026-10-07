import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/contrast.dart';

void main() {
  test(
    'given any style when made tabular then it asks for fixed-width figures',
    () {
      final style = DbookTypography.tabular(const TextStyle(fontSize: 14));

      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    },
  );

  test('given the focus ring in each theme when drawn on the surface then it has 3:1 contrast', () {
    for (final scheme in [DbookColorScheme.light, DbookColorScheme.dark]) {
      final ring = DbookFocus.ring(scheme);

      expect(
        contrastRatio(ring.color, scheme.surface),
        greaterThanOrEqualTo(3),
      );
      expect(ring.width, DbookFocus.ringWidth);
    }
  });
}
