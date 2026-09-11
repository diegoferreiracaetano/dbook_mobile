/// Níveis de elevação do Material 3, em dp — usar direto na propriedade
/// `elevation` dos widgets (`Card`, `AppBar`, `NavigationBar` etc.). O
/// próprio widget Material monta a sombra/tonalidade a partir disso; nunca
/// desenhar sombra na mão com `BoxShadow`.
abstract final class DbookElevation {
  static const double none = 0;
  static const double sm = 1;
  static const double md = 3;
  static const double lg = 6;
}
