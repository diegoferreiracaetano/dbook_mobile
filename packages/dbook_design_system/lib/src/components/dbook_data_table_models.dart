import 'package:flutter/widgets.dart';

/// Sentido da ordenação de uma coluna.
enum DbookSortDirection { ascending, descending }

/// Ordenação pedida pelo usuário. A tabela **não ordena nada**: quem ordena é
/// o servidor; a tabela só mostra a seta e avisa que o usuário quer outra.
@immutable
class DbookSort {
  const DbookSort(this.columnId, this.direction);

  final String columnId;
  final DbookSortDirection direction;

  /// Ciclo ao tocar no cabeçalho: sem ordem, crescente, decrescente, sem ordem.
  static DbookSort? next(DbookSort? current, String columnId) {
    if (current == null || current.columnId != columnId) {
      return DbookSort(columnId, DbookSortDirection.ascending);
    }
    return switch (current.direction) {
      DbookSortDirection.ascending => DbookSort(
        columnId,
        DbookSortDirection.descending,
      ),
      DbookSortDirection.descending => null,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is DbookSort &&
      other.columnId == columnId &&
      other.direction == direction;

  @override
  int get hashCode => Object.hash(columnId, direction);
}

/// Uma coluna tipada da tabela. [width] é a largura mínima em dp: sobrando
/// espaço, as colunas crescem na mesma proporção; faltando, a tabela rola na
/// horizontal. [numeric] alinha à direita (números em coluna).
class DbookColumn<T> {
  const DbookColumn({
    required this.id,
    required this.label,
    required this.cellBuilder,
    this.width = 160,
    this.sortable = false,
    this.numeric = false,
    this.canHide = true,
  });

  final String id;
  final String label;
  final Widget Function(T row) cellBuilder;
  final double width;
  final bool sortable;
  final bool numeric;
  final bool canHide;
}

/// Paginação **do servidor**: [page] começa em 0 e [total] é o total de
/// itens que o servidor diz ter (não o tamanho da página carregada).
@immutable
class DbookPagination {
  const DbookPagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.onPageChanged,
    this.pageSizes = const [10, 25, 50],
    this.onPageSizeChanged,
  });

  final int page;
  final int pageSize;
  final int total;
  final ValueChanged<int> onPageChanged;
  final List<int> pageSizes;
  final ValueChanged<int>? onPageSizeChanged;

  int get firstItem => total == 0 ? 0 : page * pageSize + 1;
  int get lastItem => total == 0 ? 0 : ((page + 1) * pageSize).clamp(1, total);
  bool get hasPrevious => page > 0;
  bool get hasNext => (page + 1) * pageSize < total;
}
