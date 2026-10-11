import 'package:flutter/material.dart';

/// Escala de tipografia do Material 3 em Roboto: tamanhos, pesos e alturas
/// de linha do Material. A fonte vai empacotada (`assets/fonts`), não vem de
/// um CDN. Roboto não tem peso 600: ele cai no Bold. Sem cor: a cor do texto
/// vem do `ColorScheme` quando o tema é montado (ver [DbookTheme]).
abstract final class DbookTypography {
  /// Família empacotada em `assets/fonts` (ver `pubspec.yaml`).
  static const family = 'Roboto';

  static TextTheme get textTheme => TextTheme(
    displayLarge: _style(fontSize: 57, lineHeight: 64, weight: FontWeight.w400),
    displayMedium: _style(
      fontSize: 45,
      lineHeight: 52,
      weight: FontWeight.w400,
    ),
    displaySmall: _style(fontSize: 36, lineHeight: 44, weight: FontWeight.w400),
    headlineLarge: _style(
      fontSize: 32,
      lineHeight: 40,
      weight: FontWeight.w700,
    ),
    headlineMedium: _style(
      fontSize: 28,
      lineHeight: 36,
      weight: FontWeight.w700,
    ),
    headlineSmall: _style(
      fontSize: 24,
      lineHeight: 32,
      weight: FontWeight.w600,
    ),
    titleLarge: _style(fontSize: 22, lineHeight: 28, weight: FontWeight.w600),
    titleMedium: _style(fontSize: 16, lineHeight: 24, weight: FontWeight.w600),
    titleSmall: _style(fontSize: 14, lineHeight: 20, weight: FontWeight.w600),
    bodyLarge: _style(fontSize: 16, lineHeight: 24, weight: FontWeight.w400),
    bodyMedium: _style(fontSize: 14, lineHeight: 20, weight: FontWeight.w400),
    bodySmall: _style(fontSize: 12, lineHeight: 16, weight: FontWeight.w400),
    labelLarge: _style(fontSize: 14, lineHeight: 20, weight: FontWeight.w500),
    labelMedium: _style(fontSize: 12, lineHeight: 16, weight: FontWeight.w500),
    labelSmall: _style(fontSize: 11, lineHeight: 16, weight: FontWeight.w500),
  );

  /// `TextStyle.height` no Flutter é um multiplicador do `fontSize`, não um
  /// valor absoluto — por isso a divisão, pra poder pensar em px como no
  /// design (ex.: Headline large = 32/40 vira fontSize 32, height 40/32).
  static TextStyle _style({
    required double fontSize,
    required double lineHeight,
    required FontWeight weight,
    double tracking = 0,
  }) {
    return TextStyle(
      fontFamily: family,
      package: 'dbook_design_system',
      fontSize: fontSize,
      height: lineHeight / fontSize,
      fontWeight: weight,
      letterSpacing: tracking,
    );
  }

  /// Texto de código, identificadores e valores copiáveis (códigos de
  /// reserva, `promo`, JSON de auditoria). Largura fixa, cor herdada.
  static TextStyle get mono => const TextStyle(
    fontFamily: 'Menlo',
    fontFamilyFallback: ['Consolas', 'Courier New', 'monospace'],
    fontSize: 13,
    height: 1.5,
  );

  /// Algarismos de largura fixa: em coluna de tabela, as casas decimais ficam
  /// alinhadas e o valor não "dança" quando muda.
  static TextStyle tabular(TextStyle base) =>
      base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle get dataMedium => tabular(textTheme.bodyMedium!);
  static TextStyle get dataSmall => tabular(textTheme.bodySmall!);
}
