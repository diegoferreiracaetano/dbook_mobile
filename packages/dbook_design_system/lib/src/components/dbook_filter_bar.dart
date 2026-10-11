import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens/dbook_radius.dart';
import '../tokens/dbook_spacing.dart';

/// Filtro ativo, mostrado como chip removível ("Status: Ativo").
class DbookActiveFilter {
  const DbookActiveFilter({
    required this.id,
    required this.label,
    required this.onRemove,
  });

  final String id;
  final String label;
  final VoidCallback onRemove;
}

/// Atalho de período ("Últimos 7 dias"). [resolve] recebe o "hoje" e devolve
/// o intervalo, inclusive nas duas pontas.
class DbookPeriodPreset {
  const DbookPeriodPreset({required this.label, required this.resolve});

  final String label;
  final DateTimeRange Function(DateTime today) resolve;

  static final today = DbookPeriodPreset(
    label: 'Hoje',
    resolve: (now) => DateTimeRange(start: now, end: now),
  );

  static final last7Days = DbookPeriodPreset(
    label: 'Últimos 7 dias',
    resolve: (now) =>
        DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
  );

  static final last30Days = DbookPeriodPreset(
    label: 'Últimos 30 dias',
    resolve: (now) =>
        DateTimeRange(start: now.subtract(const Duration(days: 29)), end: now),
  );

  static final defaults = [today, last7Days, last30Days];
}

/// Barra de filtros de uma tabela: busca com *debounce*, período com atalhos,
/// chips de filtro ativo removíveis e "Limpar tudo".
///
/// **Controlada**: o texto, o período e os chips vêm de fora (assim o portal
/// pode guardá-los na URL e restaurá-los). A busca só avisa [onSearchChanged]
/// [debounce] depois da última tecla; digitar de novo cancela o aviso
/// pendente; Enter avisa na hora.
class DbookFilterBar extends StatefulWidget {
  const DbookFilterBar({
    super.key,
    required this.onClearAll,
    this.searchText = '',
    this.onSearchChanged,
    this.searchHint = 'Buscar',
    this.debounce = const Duration(milliseconds: 300),
    this.period,
    this.onPeriodChanged,
    this.presets,
    this.activeFilters = const [],
    this.today,
    this.searchFocusNode,
  });

  final String searchText;

  /// Sem ela, a barra não mostra o campo de busca (listas que o servidor não
  /// busca por texto não prometem uma busca).
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback onClearAll;
  final String searchHint;
  final Duration debounce;
  final DateTimeRange? period;

  /// Sem [onPeriodChanged] o seletor de período não aparece.
  final ValueChanged<DateTimeRange?>? onPeriodChanged;
  final List<DbookPeriodPreset>? presets;
  final List<DbookActiveFilter> activeFilters;

  /// "Hoje" para os atalhos; em teste, uma data fixa.
  final DateTime Function()? today;

  /// Para focar a busca de fora (o atalho `/` das listas).
  final FocusNode? searchFocusNode;

  @override
  State<DbookFilterBar> createState() => _DbookFilterBarState();
}

class _DbookFilterBarState extends State<DbookFilterBar> {
  static const double _searchWidth = 280;
  static const String _custom = '__custom__';

  late final TextEditingController _controller = TextEditingController(
    text: widget.searchText,
  );
  Timer? _pending;

  bool get _hasAnyFilter =>
      widget.searchText.isNotEmpty ||
      widget.period != null ||
      widget.activeFilters.isNotEmpty;

  @override
  void didUpdateWidget(DbookFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchText != _controller.text &&
        widget.searchText != oldWidget.searchText) {
      _pending?.cancel();
      _controller.text = widget.searchText;
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTyped(String text) {
    _pending?.cancel();
    _pending = Timer(widget.debounce, () => widget.onSearchChanged?.call(text));
    setState(() {});
  }

  void _submit(String text) {
    _pending?.cancel();
    widget.onSearchChanged?.call(text);
  }

  void _clearSearch() {
    _pending?.cancel();
    _controller.clear();
    widget.onSearchChanged?.call('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DbookSpacing.sm,
      runSpacing: DbookSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.onSearchChanged != null)
          SizedBox(width: _searchWidth, child: _searchField()),
        if (widget.onPeriodChanged != null) _periodMenu(context),
        for (final filter in widget.activeFilters)
          InputChip(
            label: Text(filter.label),
            onDeleted: filter.onRemove,
            deleteButtonTooltipMessage: 'Remover filtro ${filter.label}',
          ),
        if (_hasAnyFilter)
          TextButton(
            onPressed: () {
              _pending?.cancel();
              _controller.clear();
              widget.onClearAll();
            },
            child: const Text('Limpar tudo'),
          ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _controller,
      focusNode: widget.searchFocusNode,
      onChanged: _onTyped,
      onSubmitted: _submit,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.searchHint,
        isDense: true,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Limpar busca',
                onPressed: _clearSearch,
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DbookRadius.sm),
        ),
      ),
    );
  }

  Widget _periodMenu(BuildContext context) {
    final presets = widget.presets ?? DbookPeriodPreset.defaults;

    return PopupMenuButton<String>(
      tooltip: 'Escolher período',
      onSelected: (value) => _pick(context, value, presets),
      itemBuilder: (context) => [
        for (final preset in presets)
          PopupMenuItem(value: preset.label, child: Text(preset.label)),
        const PopupMenuItem(value: _custom, child: Text('Personalizado…')),
        if (widget.period != null)
          const PopupMenuItem(value: '', child: Text('Qualquer período')),
      ],
      child: Chip(
        avatar: const Icon(Icons.calendar_today_outlined, size: 16),
        label: Text(_periodLabel(widget.period)),
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    String value,
    List<DbookPeriodPreset> presets,
  ) async {
    final onChanged = widget.onPeriodChanged!;
    if (value.isEmpty) {
      onChanged(null);
      return;
    }
    if (value == _custom) {
      final today = DateUtils.dateOnly((widget.today ?? DateTime.now)());
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(today.year - 5),
        lastDate: today,
        initialDateRange: widget.period,
      );
      if (picked != null) onChanged(picked);
      return;
    }
    final today = DateUtils.dateOnly((widget.today ?? DateTime.now)());
    final preset = presets.firstWhere((p) => p.label == value);
    onChanged(preset.resolve(today));
  }

  static String _periodLabel(DateTimeRange? range) {
    if (range == null) return 'Qualquer período';
    String day(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
    return range.start == range.end
        ? day(range.start)
        : '${day(range.start)} – ${day(range.end)}';
  }
}
