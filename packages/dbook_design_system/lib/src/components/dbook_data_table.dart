import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/dbook_density.dart';
import '../tokens/dbook_focus.dart';
import '../tokens/dbook_spacing.dart';
import 'dbook_data_table_models.dart';
import 'dbook_empty_state.dart';
import 'dbook_error_state.dart';
import 'dbook_pagination_bar.dart';
import 'dbook_skeleton.dart';

/// Tabela de dados do portal. **Controlada por fora**: a tabela mostra o que
/// recebe e avisa o que o usuário quer (ordenar, mudar de página, selecionar,
/// esconder coluna); quem busca, ordena e pagina é o servidor.
///
/// Estados: carregando (esqueleto, [isLoading]), erro ([errorMessage] com
/// "Tentar de novo"), vazio e pronto. Cabeçalho fixo na vertical; rola na
/// horizontal quando as colunas não cabem. Teclado: Tab entra, setas
/// cima/baixo mudam de linha, Enter ou Espaço abrem a linha ([onRowTap]).
///
/// Precisa de **altura limitada** (a lista de linhas é `Expanded`): ponha-a
/// dentro de um `Expanded` ou `SizedBox` com altura.
class DbookDataTable<T> extends StatefulWidget {
  const DbookDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowKey,
    this.semanticLabel = 'Tabela de dados',
    this.sort,
    this.onSort,
    this.pagination,
    this.selectedKeys,
    this.onSelectionChanged,
    this.selectionActions,
    this.hiddenColumnIds = const {},
    this.onHiddenColumnsChanged,
    this.onRowTap,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.emptyTitle = 'Nenhum resultado',
    this.emptyMessage = 'Ajuste os filtros e tente de novo.',
  });

  final List<DbookColumn<T>> columns;
  final List<T> rows;
  final Object Function(T row) rowKey;
  final String semanticLabel;
  final DbookSort? sort;
  final ValueChanged<DbookSort?>? onSort;
  final DbookPagination? pagination;

  /// Com [onSelectionChanged] a tabela ganha a coluna de caixas de seleção.
  final Set<Object>? selectedKeys;
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// Botões que aparecem quando há linhas selecionadas ("Bloquear"...).
  final Widget? selectionActions;
  final Set<String> hiddenColumnIds;
  final ValueChanged<Set<String>>? onHiddenColumnsChanged;
  final ValueChanged<T>? onRowTap;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String emptyTitle;
  final String emptyMessage;

  @override
  State<DbookDataTable<T>> createState() => _DbookDataTableState<T>();
}

class _DbookDataTableState<T> extends State<DbookDataTable<T>> {
  static const double _selectionWidth = 48;
  static const int _skeletonRows = 8;

  final _horizontal = ScrollController();

  bool get _selectable => widget.onSelectionChanged != null;
  Set<Object> get _selected => widget.selectedKeys ?? const {};

  @override
  void dispose() {
    _horizontal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final column in widget.columns)
        if (!widget.hiddenColumnIds.contains(column.id)) column,
    ];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: Column(
        children: [
          if (_hasToolbar) _toolbar(context),
          Expanded(child: _content(context, visible)),
          if (widget.pagination != null)
            DbookPaginationBar(pagination: widget.pagination!),
        ],
      ),
    );
  }

  bool get _hasToolbar =>
      widget.onHiddenColumnsChanged != null ||
      (_selectable && _selected.isNotEmpty);

  Widget _toolbar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DbookSpacing.md,
        vertical: DbookSpacing.xs,
      ),
      child: Row(
        children: [
          if (_selectable && _selected.isNotEmpty) ...[
            Semantics(
              liveRegion: true,
              child: Text(
                _selected.length == 1
                    ? '1 selecionada'
                    : '${_selected.length} selecionadas',
                style: theme.textTheme.labelLarge,
              ),
            ),
            if (widget.selectionActions != null) ...[
              const SizedBox(width: DbookSpacing.md),
              widget.selectionActions!,
            ],
          ],
          const Spacer(),
          if (widget.onHiddenColumnsChanged != null) _columnsMenu(),
        ],
      ),
    );
  }

  Widget _columnsMenu() {
    final hideable = [
      for (final column in widget.columns)
        if (column.canHide) column,
    ];

    return PopupMenuButton<String>(
      tooltip: 'Colunas visíveis',
      icon: const Icon(Icons.view_column_outlined),
      onSelected: (id) {
        final next = {...widget.hiddenColumnIds};
        if (!next.remove(id)) next.add(id);
        widget.onHiddenColumnsChanged!(next);
      },
      itemBuilder: (context) => [
        for (final column in hideable)
          CheckedPopupMenuItem<String>(
            value: column.id,
            checked: !widget.hiddenColumnIds.contains(column.id),
            child: Text(column.label),
          ),
      ],
    );
  }

  Widget _content(BuildContext context, List<DbookColumn<T>> visible) {
    if (widget.errorMessage != null) {
      return DbookErrorState(
        message: widget.errorMessage!,
        onRetry: widget.onRetry,
      );
    }
    if (!widget.isLoading && widget.rows.isEmpty) {
      return DbookEmptyState(
        title: widget.emptyTitle,
        message: widget.emptyMessage,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) =>
          _grid(context, visible, constraints.maxWidth, constraints.maxHeight),
    );
  }

  Widget _grid(
    BuildContext context,
    List<DbookColumn<T>> visible,
    double availableWidth,
    double availableHeight,
  ) {
    final columnsWidth = visible.fold<double>(0, (sum, c) => sum + c.width);
    final extra = _selectable ? _selectionWidth : 0;
    final scale = columnsWidth == 0
        ? 1.0
        : math.max(1.0, (availableWidth - extra) / columnsWidth);
    final contentWidth = math.max(availableWidth, columnsWidth + extra);

    return Scrollbar(
      controller: _horizontal,
      child: SingleChildScrollView(
        controller: _horizontal,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: contentWidth,
          height: availableHeight,
          child: Column(
            children: [
              _header(context, visible, scale),
              Expanded(child: _body(context, visible, scale)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    List<DbookColumn<T>> visible,
    double scale,
  ) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: SizedBox(
          height: DbookDensity.headerRowHeight,
          child: Row(
            children: [
              if (_selectable)
                SizedBox(
                  width: _selectionWidth,
                  child: Checkbox(
                    tristate: true,
                    value: _headerCheckboxValue(),
                    onChanged: (_) => _toggleAllOnPage(),
                  ),
                ),
              for (final column in visible)
                SizedBox(
                  width: column.width * scale,
                  child: _headerCell(context, column),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(BuildContext context, DbookColumn<T> column) {
    final theme = Theme.of(context);
    final current = widget.sort?.columnId == column.id ? widget.sort : null;
    final style = theme.textTheme.labelLarge;
    final label = Text(column.label, style: style);
    final alignment = column.numeric
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DbookDensity.cellPaddingH,
      ),
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          Flexible(child: label),
          if (current != null) ...[
            const SizedBox(width: DbookSpacing.xxs),
            Icon(
              current.direction == DbookSortDirection.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              size: 14,
            ),
          ],
        ],
      ),
    );

    if (!column.sortable || widget.onSort == null) {
      return content;
    }

    final description = switch (current?.direction) {
      DbookSortDirection.ascending => ', ordenado de forma crescente',
      DbookSortDirection.descending => ', ordenado de forma decrescente',
      null => ', ordenável',
    };

    return Semantics(
      label: '${column.label}$description',
      excludeSemantics: true,
      button: true,
      onTap: () => widget.onSort!(DbookSort.next(widget.sort, column.id)),
      child: InkWell(
        onTap: () => widget.onSort!(DbookSort.next(widget.sort, column.id)),
        child: content,
      ),
    );
  }

  Widget _body(
    BuildContext context,
    List<DbookColumn<T>> visible,
    double scale,
  ) {
    if (widget.isLoading) {
      return Semantics(
        liveRegion: true,
        label: 'Carregando dados',
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _skeletonRows,
          itemExtent: DbookDensity.rowHeight,
          itemBuilder: (context, index) => _skeletonRow(visible, scale),
        ),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            FocusScope.of(context).focusInDirection(TraversalDirection.down),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            FocusScope.of(context).focusInDirection(TraversalDirection.up),
      },
      child: ListView.builder(
        itemCount: widget.rows.length,
        itemExtent: DbookDensity.rowHeight,
        itemBuilder: (context, index) =>
            _row(context, widget.rows[index], visible, scale),
      ),
    );
  }

  Widget _skeletonRow(List<DbookColumn<T>> visible, double scale) {
    return Row(
      children: [
        if (_selectable) const SizedBox(width: _selectionWidth),
        for (final column in visible)
          SizedBox(
            width: column.width * scale,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: DbookDensity.cellPaddingH,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DbookSkeleton(width: 80),
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(
    BuildContext context,
    T row,
    List<DbookColumn<T>> visible,
    double scale,
  ) {
    final theme = Theme.of(context);
    final key = widget.rowKey(row);
    final isSelected = _selected.contains(key);

    final cells = Row(
      children: [
        if (_selectable)
          SizedBox(
            width: _selectionWidth,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => _toggle(key, value ?? false),
            ),
          ),
        for (final column in visible)
          SizedBox(
            width: column.width * scale,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DbookDensity.cellPaddingH,
              ),
              child: Align(
                alignment: column.numeric
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: column.cellBuilder(row),
              ),
            ),
          ),
      ],
    );

    return Semantics(
      container: true,
      selected: isSelected,
      child: _FocusRing(
        child: Material(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
              : Colors.transparent,
          shape: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: InkWell(
            onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(row),
            child: cells,
          ),
        ),
      ),
    );
  }

  bool? _headerCheckboxValue() {
    final keys = widget.rows.map(widget.rowKey).toSet();
    final selectedOnPage = keys.where(_selected.contains).length;
    if (selectedOnPage == 0) return false;
    return selectedOnPage == keys.length ? true : null;
  }

  void _toggleAllOnPage() {
    final keys = widget.rows.map(widget.rowKey).toSet();
    final next = {..._selected};
    if (keys.every(_selected.contains)) {
      next.removeAll(keys);
    } else {
      next.addAll(keys);
    }
    widget.onSelectionChanged!(next);
  }

  void _toggle(Object key, bool selected) {
    final next = {..._selected};
    if (selected) {
      next.add(key);
    } else {
      next.remove(key);
    }
    widget.onSelectionChanged!(next);
  }
}

/// Contorno de foco de teclado em volta da linha inteira (WCAG 2.4.7): o
/// realce padrão do `InkWell` é sutil demais numa linha de tabela.
class _FocusRing extends StatefulWidget {
  const _FocusRing({required this.child});

  final Widget child;

  @override
  State<_FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<_FocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: _focused
              ? Border.all(color: color, width: DbookFocus.ringWidth)
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}
