import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';
import '../tokens/dbook_typography.dart';

/// `ThemeData` do DBook — o que o `MaterialApp` (`theme`/`darkTheme`) de
/// fato consome. Monta os tokens de cor e tipografia num tema completo;
/// nenhuma feature deve montar `ThemeData` própria.
abstract final class DbookTheme {
  static ThemeData get light => _theme(
    colorScheme: DbookColorScheme.light,
    statusColors: DbookStatusColors.light,
  );

  static ThemeData get dark => _theme(
    colorScheme: DbookColorScheme.dark,
    statusColors: DbookStatusColors.dark,
  );

  static ThemeData _theme({
    required ColorScheme colorScheme,
    required DbookStatusColors statusColors,
  }) {
    final textTheme = DbookTypography.textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [statusColors],
    );
  }
}
