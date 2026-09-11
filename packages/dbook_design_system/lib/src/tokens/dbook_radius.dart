/// Escala de raio de borda do design system.
abstract final class DbookRadius {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  /// Bem maior que qualquer widget real — força arredondamento total
  /// ("pill") independente da altura do widget.
  static const double full = 999;
}
