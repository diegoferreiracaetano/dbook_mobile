import 'package:flutter/material.dart';

/// Paleta primitiva da marca DBook — valores brutos, sem significado
/// semântico. Só [DbookColorScheme] e [DbookStatusColors] deveriam
/// referenciar isto diretamente; features consomem cor só através do tema.
abstract final class DbookPalette {
  static const primary = Color(0xFF0085FF);
  static const primaryHover = Color(0xFF0071E0);
  static const primaryPressed = Color(0xFF005BBB);
  static const primaryLight = Color(0xFFE6F3FF);

  static const secondary = Color(0xFF00C2D6);
  static const secondaryHover = Color(0xFF00A7B8);
  static const secondaryLight = Color(0xFFE6F9FB);
  static const secondaryDark = Color(0xFF00899A);

  static const success = Color(0xFF1E7A34);
  static const successBg = Color(0xFFE3F3E6);
  static const warning = Color(0xFF9C6B12);
  static const warningBg = Color(0xFFFBEEDA);
  static const error = Color(0xFFB23A2E);
  static const errorBg = Color(0xFFF8E6E3);

  static const n900 = Color(0xFF141E27);
  static const n800 = Color(0xFF263640);
  static const n700 = Color(0xFF3D4F5A);
  static const n600 = Color(0xFF526876);
  static const n500 = Color(0xFF6C8390);
  static const n400 = Color(0xFF8CA0AA);
  static const n300 = Color(0xFFB4C4CC);
  static const n200 = Color(0xFFD3DEE3);
  static const n100 = Color(0xFFE6EDF1);
  static const n50 = Color(0xFFF4F7F9);
  static const white = Color(0xFFFFFFFF);
}

/// `ColorScheme` do Material 3, claro e escuro, montado a partir do
/// [DbookPalette]. `fromSeed` gera uma escala completa e acessível a partir
/// da cor de marca; só sobrescrevemos os papéis que já temos definidos no
/// design system pra manter a identidade visual exata nos lugares que
/// importam (primary/secondary/error) e deixamos o resto vir do algoritmo.
abstract final class DbookColorScheme {
  static final light =
      ColorScheme.fromSeed(
        seedColor: DbookPalette.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: DbookPalette.primary,
        onPrimary: DbookPalette.white,
        primaryContainer: DbookPalette.primaryLight,
        onPrimaryContainer: DbookPalette.primaryPressed,
        secondary: DbookPalette.secondary,
        onSecondary: DbookPalette.white,
        secondaryContainer: DbookPalette.secondaryLight,
        onSecondaryContainer: DbookPalette.secondaryDark,
        surface: DbookPalette.white,
        onSurface: DbookPalette.n900,
        surfaceContainerLow: DbookPalette.n50,
        outline: DbookPalette.n200,
        outlineVariant: DbookPalette.n100,
        error: DbookPalette.error,
        onError: DbookPalette.white,
        errorContainer: DbookPalette.errorBg,
        onErrorContainer: DbookPalette.error,
      );

  static final dark =
      ColorScheme.fromSeed(
        seedColor: DbookPalette.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: DbookPalette.primaryHover,
        onPrimary: DbookPalette.n900,
        primaryContainer: DbookPalette.primaryPressed,
        onPrimaryContainer: DbookPalette.primaryLight,
        secondary: DbookPalette.secondary,
        onSecondary: DbookPalette.n900,
        secondaryContainer: DbookPalette.secondaryDark,
        onSecondaryContainer: DbookPalette.secondaryLight,
        surface: DbookPalette.n900,
        onSurface: DbookPalette.n50,
        surfaceContainerLow: DbookPalette.n800,
        outline: DbookPalette.n600,
        outlineVariant: DbookPalette.n700,
        error: DbookPalette.error,
        onError: DbookPalette.white,
        errorContainer: DbookPalette.errorBg,
        onErrorContainer: DbookPalette.error,
      );
}

/// Cores de status que o `ColorScheme` do Material não cobre nativamente
/// (sucesso/aviso) — como [ThemeExtension], pra ficar disponível em
/// `Theme.of(context).extension<DbookStatusColors>()` igual qualquer outra
/// cor do tema.
@immutable
class DbookStatusColors extends ThemeExtension<DbookStatusColors> {
  const DbookStatusColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;

  static const light = DbookStatusColors(
    success: DbookPalette.success,
    onSuccess: DbookPalette.successBg,
    warning: DbookPalette.warning,
    onWarning: DbookPalette.warningBg,
  );

  static const dark = DbookStatusColors(
    success: DbookPalette.success,
    onSuccess: DbookPalette.successBg,
    warning: DbookPalette.warning,
    onWarning: DbookPalette.warningBg,
  );

  @override
  DbookStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
  }) {
    return DbookStatusColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
    );
  }

  @override
  DbookStatusColors lerp(ThemeExtension<DbookStatusColors>? other, double t) {
    if (other is! DbookStatusColors) return this;
    return DbookStatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
    );
  }
}
