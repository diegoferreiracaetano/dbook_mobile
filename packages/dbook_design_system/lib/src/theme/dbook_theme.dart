import 'package:flutter/material.dart';

import '../tokens/dbook_colors.dart';
import '../tokens/dbook_elevation.dart';
import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';
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

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DbookRadius.full),
    );
    final buttonPadding = const EdgeInsets.symmetric(
      horizontal: DbookSpacing.xl,
      vertical: DbookSpacing.md,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: [statusColors],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          textStyle: textTheme.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DbookRadius.full),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DbookSpacing.lg,
          vertical: DbookSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DbookRadius.xs),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DbookRadius.xs),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DbookRadius.xs),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DbookRadius.xs),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DbookRadius.xs),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DbookRadius.xs),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DbookRadius.lg),
        ),
        headerBackgroundColor: colorScheme.primary,
        headerForegroundColor: colorScheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: DbookElevation.sm,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DbookRadius.lg),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onPrimaryContainer,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: DbookSpacing.sm,
          vertical: DbookSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DbookRadius.sm),
        ),
        side: BorderSide.none,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DbookRadius.md),
        ),
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DbookSpacing.lg,
          vertical: DbookSpacing.xs,
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.error,
        textColor: colorScheme.onError,
        textStyle: textTheme.labelSmall,
      ),
    );
  }
}
