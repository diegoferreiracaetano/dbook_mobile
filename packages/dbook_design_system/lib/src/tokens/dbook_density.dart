import 'dbook_spacing.dart';

/// Medidas das telas densas do portal (tabelas e filtros de operador). O app
/// de clientes não usa isto: lá a escala é a de [DbookSpacing] com alvos de
/// toque de 48dp.
abstract final class DbookDensity {
  static const double rowHeight = 40;
  static const double headerRowHeight = 36;
  static const double cellPaddingH = DbookSpacing.md;
  static const double cellPaddingV = DbookSpacing.sm;
  static const double controlGap = DbookSpacing.sm;
}
