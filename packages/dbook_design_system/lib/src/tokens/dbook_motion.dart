import 'package:flutter/animation.dart';

/// Durações e curvas padrão de transição/animação do design system.
abstract final class DbookMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// Transições comuns (fade, troca de conteúdo).
  static const Curve standard = Curves.easeInOutCubic;

  /// Elementos que entram/saem de tela (bottom sheet, dialog, drawer).
  static const Curve emphasized = Curves.easeOutCubic;
}
