import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/contrast.dart';

void main() {
  const colors = DbookStatusColors.light;
  final pairs = <String, (Color, Color)>{
    'success': (colors.success, colors.successContainer),
    'warning': (colors.warning, colors.warningContainer),
    'danger': (colors.danger, colors.dangerContainer),
    'info': (colors.info, colors.infoContainer),
  };

  for (final entry in pairs.entries) {
    test(
      'given the ${entry.key} tone when text is drawn on its background then it meets AA (4.5:1)',
      () {
        final (foreground, background) = entry.value;

        expect(
          contrastRatio(foreground, background),
          greaterThanOrEqualTo(4.5),
        );
      },
    );
  }

  test('given two status color sets when interpolated halfway then each field is blended', () {
    final halfway = DbookStatusColors.light.lerp(
      DbookStatusColors.light.copyWith(info: const Color(0xFF000000)),
      0.5,
    );

    expect(
      halfway.info,
      Color.lerp(DbookStatusColors.light.info, const Color(0xFF000000), 0.5),
    );
  });
}
