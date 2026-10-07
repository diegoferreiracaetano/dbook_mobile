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
  static const warning = Color(0xFF855A0E);
  static const warningBg = Color(0xFFFBEEDA);
  static const error = Color(0xFFB23A2E);
  static const errorBg = Color(0xFFF8E6E3);

  static const info = Color(0xFF0B5FA5);
  static const infoBg = Color(0xFFE6F3FF);

  static const successBorder = Color(0xFFB5DDBE);
  static const warningBorder = Color(0xFFEBCF9E);
  static const errorBorder = Color(0xFFE9B7B1);
  static const infoBorder = Color(0xFFB3D9FF);

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
        onPrimary: DbookPalette.white,
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

/// Tons semânticos que o `ColorScheme` do Material não cobre (sucesso, aviso,
/// perigo, informação) — como [ThemeExtension], em
/// `Theme.of(context).extension<DbookStatusColors>()`. Cada tom é um trio:
/// texto/ícone saturado, fundo claro e borda; texto sobre fundo cumpre AA (4,5:1),
/// o que `dbook_status_colors_test.dart` garante.
@immutable
class DbookStatusColors extends ThemeExtension<DbookStatusColors> {
  const DbookStatusColors({
    required this.success,
    required this.successContainer,
    required this.successBorder,
    required this.warning,
    required this.warningContainer,
    required this.warningBorder,
    required this.danger,
    required this.dangerContainer,
    required this.dangerBorder,
    required this.info,
    required this.infoContainer,
    required this.infoBorder,
  });

  final Color success;
  final Color successContainer;
  final Color successBorder;

  final Color warning;
  final Color warningContainer;
  final Color warningBorder;

  final Color danger;
  final Color dangerContainer;
  final Color dangerBorder;

  final Color info;
  final Color infoContainer;
  final Color infoBorder;

  static const light = DbookStatusColors(
    success: DbookPalette.success,
    successContainer: DbookPalette.successBg,
    successBorder: DbookPalette.successBorder,
    warning: DbookPalette.warning,
    warningContainer: DbookPalette.warningBg,
    warningBorder: DbookPalette.warningBorder,
    danger: DbookPalette.error,
    dangerContainer: DbookPalette.errorBg,
    dangerBorder: DbookPalette.errorBorder,
    info: DbookPalette.info,
    infoContainer: DbookPalette.infoBg,
    infoBorder: DbookPalette.infoBorder,
  );

  /// Pílulas autocontidas (fundo claro com texto escuro) funcionam nos dois
  /// temas; pares escuros de verdade entram quando o tema escuro do portal
  /// for decidido.
  static const dark = light;

  @override
  DbookStatusColors copyWith({
    Color? success,
    Color? successContainer,
    Color? successBorder,
    Color? warning,
    Color? warningContainer,
    Color? warningBorder,
    Color? danger,
    Color? dangerContainer,
    Color? dangerBorder,
    Color? info,
    Color? infoContainer,
    Color? infoBorder,
  }) {
    return DbookStatusColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      successBorder: successBorder ?? this.successBorder,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      warningBorder: warningBorder ?? this.warningBorder,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      infoBorder: infoBorder ?? this.infoBorder,
    );
  }

  @override
  DbookStatusColors lerp(ThemeExtension<DbookStatusColors>? other, double t) {
    if (other is! DbookStatusColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return DbookStatusColors(
      success: mix(success, other.success),
      successContainer: mix(successContainer, other.successContainer),
      successBorder: mix(successBorder, other.successBorder),
      warning: mix(warning, other.warning),
      warningContainer: mix(warningContainer, other.warningContainer),
      warningBorder: mix(warningBorder, other.warningBorder),
      danger: mix(danger, other.danger),
      dangerContainer: mix(dangerContainer, other.dangerContainer),
      dangerBorder: mix(dangerBorder, other.dangerBorder),
      info: mix(info, other.info),
      infoContainer: mix(infoContainer, other.infoContainer),
      infoBorder: mix(infoBorder, other.infoBorder),
    );
  }
}
