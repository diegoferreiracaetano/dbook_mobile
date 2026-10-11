/// Dimensões fixas recorrentes que não são espaçamento: a altura de um bloco
/// reservado enquanto o conteúdo carrega, a largura de uma coluna de rótulo.
/// Existem para que "200 aqui, 240 ali" não vire número solto na feature.
abstract final class DbookSizes {
  /// Altura mínima de todo botão: alvo de toque confortável (48 dp).
  static const double controlHeight = 48;

  /// Diálogo ou folha pequena em carregamento.
  static const double loadingXs = 72;
  static const double loadingSm = 96;

  /// Seção de uma página em carregamento (preços, séries, detalhes).
  static const double loadingMd = 160;
  static const double loadingLg = 240;

  /// Largura de um cartão de indicador (KPI) numa grade.
  static const double kpiCard = 260;

  /// Largura de uma coluna curta de rótulo (nota 1-5, contadores).
  static const double labelColumn = 18;

  /// Largura máxima de um texto explicativo dentro de uma tooltip.
  static const double tooltipText = 260;
}
