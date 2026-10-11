import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'governance_providers.dart';

/// Os filtros da trilha na URL (o cursor não vai: é só da rolagem).
class AuditQueryCodec {
  const AuditQueryCodec._();

  static AuditQuery decode(Map<String, String> params) => (
    actorId: int.tryParse(params['actor'] ?? ''),
    action: params['action'],
    targetType: params['type'],
    targetId: params['target'],
    outcome: params['outcome'],
    from: DateTime.tryParse(params['from'] ?? ''),
    to: DateTime.tryParse(params['to'] ?? ''),
    cursor: null,
    size: 50,
  );

  static Map<String, String> encode(AuditQuery q) {
    String day(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return {
      if (q.actorId != null) 'actor': '${q.actorId}',
      if (q.action != null && q.action!.isNotEmpty) 'action': q.action!,
      if (q.targetType != null && q.targetType!.isNotEmpty)
        'type': q.targetType!,
      if (q.targetId != null && q.targetId!.isNotEmpty) 'target': q.targetId!,
      if (q.outcome != null && q.outcome!.isNotEmpty) 'outcome': q.outcome!,
      if (q.from != null) 'from': day(q.from!),
      if (q.to != null) 'to': day(q.to!),
    };
  }
}

AuditQuery _with(
  AuditQuery q, {
  Object? actorId = _keep,
  Object? action = _keep,
  Object? targetType = _keep,
  Object? targetId = _keep,
  Object? outcome = _keep,
  Object? from = _keep,
  Object? to = _keep,
}) => (
  actorId: identical(actorId, _keep) ? q.actorId : actorId as int?,
  action: identical(action, _keep) ? q.action : action as String?,
  targetType: identical(targetType, _keep)
      ? q.targetType
      : targetType as String?,
  targetId: identical(targetId, _keep) ? q.targetId : targetId as String?,
  outcome: identical(outcome, _keep) ? q.outcome : outcome as String?,
  from: identical(from, _keep) ? q.from : from as DateTime?,
  to: identical(to, _keep) ? q.to : to as DateTime?,
  cursor: null,
  size: q.size,
);

const Object _keep = Object();

/// O visualizador da trilha de auditoria, **por cursor**: carrega mais ao
/// chegar no fim da lista. Cada linha abre e mostra o "antes e depois" campo
/// a campo, e leva ao cliente, reserva ou voo afetado.
class AuditPage extends ConsumerStatefulWidget {
  const AuditPage({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onOpenTarget,
  });

  final AuditQuery query;
  final ValueChanged<AuditQuery> onQueryChanged;

  /// Abre o alvo de um registro (`CUSTOMER`, `BOOKING`, `FLIGHT`...).
  final void Function(String targetType, String targetId) onOpenTarget;

  @override
  ConsumerState<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends ConsumerState<AuditPage> {
  final _scroll = ScrollController();
  final _items = <AuditEntry>[];
  String? _cursor;
  bool _loading = false;
  Object? _error;
  bool _loadedOnce = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void didUpdateWidget(AuditPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _load(reset: true);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 &&
        _cursor != null &&
        !_loading) {
      _load(reset: false);
    }
  }

  Future<void> _load({required bool reset}) async {
    final generation = reset ? ++_generation : _generation;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _items.clear();
        _cursor = null;
      }
    });
    try {
      final page = await ref.read(auditApiProvider).search((
        actorId: widget.query.actorId,
        action: widget.query.action,
        targetType: widget.query.targetType,
        targetId: widget.query.targetId,
        outcome: widget.query.outcome,
        from: widget.query.from,
        to: widget.query.to,
        cursor: reset ? null : _cursor,
        size: widget.query.size,
      ));
      if (!mounted || generation != _generation) return;
      setState(() {
        _items.addAll(page.items);
        _cursor = page.nextCursor;
        _loadedOnce = true;
      });
    } on Object catch (error) {
      if (mounted && generation == _generation) setState(() => _error = error);
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = widget.query;

    return Padding(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.auditTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: DbookSpacing.lg),
          Wrap(
            spacing: DbookSpacing.md,
            runSpacing: DbookSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<String?>(
                value: query.action,
                hint: Text(l10n.auditFilterAction),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.auditFilterActionAll),
                  ),
                  for (final action in knownAuditActions)
                    DropdownMenuItem(
                      value: action,
                      child: Text(auditActionLabel(l10n, action)),
                    ),
                ],
                onChanged: (v) =>
                    widget.onQueryChanged(_with(query, action: v)),
              ),
              DropdownButton<String?>(
                value: query.outcome,
                hint: Text(l10n.auditFilterOutcome),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.auditFilterOutcomeAll),
                  ),
                  DropdownMenuItem(
                    value: 'SUCCESS',
                    child: Text(l10n.auditOutcomeSuccess),
                  ),
                  DropdownMenuItem(
                    value: 'DENIED',
                    child: Text(l10n.auditOutcomeDenied),
                  ),
                ],
                onChanged: (v) =>
                    widget.onQueryChanged(_with(query, outcome: v)),
              ),
              _textFilter(
                l10n.auditFilterActor,
                query.actorId?.toString() ?? '',
                (v) {
                  widget.onQueryChanged(
                    _with(query, actorId: int.tryParse(v.trim())),
                  );
                },
              ),
              _textFilter(l10n.auditFilterTargetType, query.targetType ?? '', (
                v,
              ) {
                widget.onQueryChanged(
                  _with(
                    query,
                    targetType: v.trim().isEmpty
                        ? null
                        : v.trim().toUpperCase(),
                  ),
                );
              }),
              _textFilter(l10n.auditFilterTargetId, query.targetId ?? '', (v) {
                widget.onQueryChanged(
                  _with(query, targetId: v.trim().isEmpty ? null : v.trim()),
                );
              }),
            ],
          ),
          const SizedBox(height: DbookSpacing.sm),
          DbookFilterBar(
            onClearAll: () =>
                widget.onQueryChanged(AuditQueryCodec.decode(const {})),
            period: query.from != null && query.to != null
                ? DateTimeRange(start: query.from!, end: query.to!)
                : null,
            onPeriodChanged: (range) => widget.onQueryChanged(
              _with(
                query,
                from: range?.start,
                to: range?.end.add(const Duration(days: 1)),
              ),
            ),
          ),
          const SizedBox(height: DbookSpacing.md),
          Expanded(child: _list(context)),
        ],
      ),
    );
  }

  Widget _textFilter(
    String label,
    String value,
    ValueChanged<String> onSubmit,
  ) => SizedBox(
    width: 150,
    child: TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: value,
      decoration: InputDecoration(labelText: label, isDense: true),
      onFieldSubmitted: onSubmit,
    ),
  );

  Widget _list(BuildContext context) {
    final l10n = context.l10n;
    if (_error != null && _items.isEmpty) {
      return DbookErrorState(
        message: portalErrorMessage(l10n, _error!),
        onRetry: () => _load(reset: true),
      );
    }
    if (!_loadedOnce && _loading) return const DbookLoadingIndicator();
    if (_loadedOnce && _items.isEmpty) {
      return DbookEmptyState(
        title: l10n.auditEmpty,
        message: l10n.auditEmptyMessage,
      );
    }

    return ListView.builder(
      controller: _scroll,
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) {
          if (_error != null) {
            return Center(
              child: TextButton(
                onPressed: () => _load(reset: false),
                child: Text(l10n.commonRetry),
              ),
            );
          }
          if (_loading) {
            return Padding(
              padding: const EdgeInsets.all(DbookSpacing.lg),
              child: Center(child: Text(l10n.auditLoadingMore)),
            );
          }
          return _cursor == null
              ? const SizedBox.shrink()
              : Center(
                  child: TextButton(
                    onPressed: () => _load(reset: false),
                    child: Text(l10n.auditLoadMore),
                  ),
                );
        }
        return _AuditTile(
          entry: _items[index],
          onOpenTarget: widget.onOpenTarget,
        );
      },
    );
  }
}

class _AuditTile extends StatefulWidget {
  const _AuditTile({required this.entry, required this.onOpenTarget});

  final AuditEntry entry;
  final void Function(String targetType, String targetId) onOpenTarget;

  @override
  State<_AuditTile> createState() => _AuditTileState();
}

class _AuditTileState extends State<_AuditTile> {
  bool _showUnchanged = false;

  static const _openable = {'CUSTOMER', 'BOOKING', 'FLIGHT'};

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final entry = widget.entry;
    final changes = diffAudit(entry.before, entry.after)
        .where((c) => _showUnchanged || c.kind != AuditChangeKind.unchanged)
        .toList();

    return ExpansionTile(
      title: Text(auditActionLabel(l10n, entry.action)),
      subtitle: Text(
        '${PortalFormats.dateTime(entry.occurredAt.toLocal())} · '
        '#${entry.actorId} ${roleLabel(l10n, entry.actorRole)} · '
        '${entry.targetType} ${entry.targetId}',
        style: theme.textTheme.bodySmall,
      ),
      leading: DbookStatusBadge(
        status: entry.denied ? DbookStatus.cancelled : DbookStatus.confirmed,
        label: entry.denied
            ? l10n.auditOutcomeDenied
            : l10n.auditOutcomeSuccess,
        showIcon: true,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(
        DbookSpacing.xl,
        0,
        DbookSpacing.xl,
        DbookSpacing.lg,
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.reason != null)
          Padding(
            padding: const EdgeInsets.only(bottom: DbookSpacing.sm),
            child: Text('${l10n.auditReasonLabel}: ${entry.reason}'),
          ),
        if (!entry.hasDiff)
          Text(l10n.auditNoState, style: theme.textTheme.bodySmall)
        else ...[
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FixedColumnWidth(96),
            },
            children: [
              TableRow(
                children: [
                  Text(l10n.auditColField, style: theme.textTheme.labelLarge),
                  Text(l10n.auditColBefore, style: theme.textTheme.labelLarge),
                  Text(l10n.auditColAfter, style: theme.textTheme.labelLarge),
                  const SizedBox.shrink(),
                ],
              ),
              for (final change in changes)
                TableRow(
                  decoration: BoxDecoration(
                    color: switch (change.kind) {
                      AuditChangeKind.added =>
                        theme.extension<DbookStatusColors>()!.successContainer,
                      AuditChangeKind.removed =>
                        theme.extension<DbookStatusColors>()!.dangerContainer,
                      AuditChangeKind.changed =>
                        theme.extension<DbookStatusColors>()!.warningContainer,
                      AuditChangeKind.unchanged => null,
                    },
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(DbookSpacing.xs),
                      child: Text(change.field, style: DbookTypography.mono),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(DbookSpacing.xs),
                      child: Text('${change.before ?? '—'}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(DbookSpacing.xs),
                      child: Text('${change.after ?? '—'}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(DbookSpacing.xs),
                      child: Text(switch (change.kind) {
                        AuditChangeKind.added => l10n.auditChangeAdded,
                        AuditChangeKind.removed => l10n.auditChangeRemoved,
                        AuditChangeKind.changed => l10n.auditChangeChanged,
                        AuditChangeKind.unchanged => l10n.auditChangeUnchanged,
                      }),
                    ),
                  ],
                ),
            ],
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _showUnchanged,
            title: Text(l10n.auditShowUnchanged),
            onChanged: (v) => setState(() => _showUnchanged = v ?? false),
          ),
        ],
        Wrap(
          spacing: DbookSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (entry.requestId != null)
              SelectableText(
                '${l10n.auditRequestLabel}: ${entry.requestId}',
                style: theme.textTheme.bodySmall,
              ),
            if (entry.ip != null)
              SelectableText(
                '${l10n.auditIpLabel}: ${entry.ip}',
                style: theme.textTheme.bodySmall,
              ),
            if (_openable.contains(entry.targetType))
              TextButton(
                onPressed: () =>
                    widget.onOpenTarget(entry.targetType, entry.targetId),
                child: Text(
                  l10n.auditOpenTarget(entry.targetType, entry.targetId),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
