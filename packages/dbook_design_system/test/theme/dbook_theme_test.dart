import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given DbookTheme.light when built then cardTheme uses the design system radius and elevation', () {
    final cardTheme = DbookTheme.light.cardTheme;
    final shape = cardTheme.shape! as RoundedRectangleBorder;

    expect(shape.borderRadius, BorderRadius.circular(DbookRadius.lg));
    expect(cardTheme.elevation, DbookElevation.sm);
  });

  test('given DbookTheme.light when built then listTileTheme uses the design system radius', () {
    final listTileTheme = DbookTheme.light.listTileTheme;
    final shape = listTileTheme.shape! as RoundedRectangleBorder;

    expect(shape.borderRadius, BorderRadius.circular(DbookRadius.md));
  });

  test('given DbookTheme.light when built then a selected checkbox fills with primary', () {
    final checkboxTheme = DbookTheme.light.checkboxTheme;
    final fillColor = checkboxTheme.fillColor!.resolve({WidgetState.selected});

    expect(fillColor, DbookColorScheme.light.primary);
  });

  test(
    'given DbookTheme.light when built then sliderTheme uses the primary color',
    () {
      final sliderTheme = DbookTheme.light.sliderTheme;

      expect(sliderTheme.activeTrackColor, DbookColorScheme.light.primary);
      expect(sliderTheme.thumbColor, DbookColorScheme.light.primary);
    },
  );
}
