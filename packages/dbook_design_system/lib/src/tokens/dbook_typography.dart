import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Escala de tipografia do Material 3 em Roboto — os mesmos tamanhos, pesos
/// e alturas de linha do artifact de tokens do design system. Sem cor: a cor
/// do texto vem do `ColorScheme` quando o tema é montado (ver [DbookTheme]).
abstract final class DbookTypography {
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
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      height: lineHeight / fontSize,
      fontWeight: weight,
    );
  }
}
