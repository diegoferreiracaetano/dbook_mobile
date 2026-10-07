import 'package:flutter/material.dart';

/// Anel de foco do teclado — o portal é usado com Tab, então todo controle
/// focável precisa mostrar onde está o foco, com contraste de 3:1 ou mais
/// contra a superfície (WCAG 1.4.11).
abstract final class DbookFocus {
  static const double ringWidth = 2;
  static const double ringOffset = 2;

  static BorderSide ring(ColorScheme scheme) =>
      BorderSide(color: scheme.primary, width: ringWidth);
}
