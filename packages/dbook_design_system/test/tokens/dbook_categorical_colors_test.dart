import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/contrast.dart';

void main() {
  test(
    'given a known airline when asking its color then returns the fixed one',
    () {
      expect(
        DbookCategoricalColors.forKey('LA'),
        DbookCategoricalColors.airlines['LA'],
      );
    },
  );

  test('given an unknown key when asking twice then returns the same color '
      'from the series', () {
    final first = DbookCategoricalColors.forKey('ZZ');

    expect(DbookCategoricalColors.forKey('ZZ'), first);
    expect(DbookCategoricalColors.series, contains(first));
  });

  test('given every categorical color when drawn under white text then it '
      'meets AA', () {
    for (final color in DbookCategoricalColors.series) {
      expect(
        contrastRatio(DbookPalette.white, color),
        greaterThanOrEqualTo(4.5),
        reason: '$color',
      );
    }
  });
}
