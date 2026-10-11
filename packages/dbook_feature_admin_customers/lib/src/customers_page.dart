import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer_dialogs.dart';
import 'customer_query_codec.dart';
import 'customers_providers.dart';

/// A lista de clientes. Busca, filtros, ordem e página vivem **na consulta**
/// ([query]) que o roteador guarda na URL: a página não tem estado próprio de
/// filtro, só avisa ([onQueryChanged]) o que a pessoa quer.
class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onOpen,
  });

  final CustomerQuery query;
  final ValueChanged<CustomerQuery> onQueryChanged;
  final ValueChanged<int> onOpen;

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final _search = FocusNode();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// `/` leva o foco à busca, a não ser que já se esteja digitando em algum
  /// campo (aí a barra é só um caractere).
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.slash) {
      return KeyEventResult.ignored;
    }
    final focused = FocusManager.instance.primaryFocus;
    final typing =
        focused?.context?.findAncestorWidgetOfExactType<EditableText>() != null;
    if (typing) return KeyEventResult.ignored;
    _search.requestFocus();
    return KeyEventResult.handled;
  }

  String _statusLabel(AppLocalizations l10n, CustomerStatus status) =>
      switch (status) {
        CustomerStatus.active => l10n.customerStatusActive,
        CustomerStatus.blocked => l10n.customerStatusBlocked,
        CustomerStatus.unknown => l10n.customerStatusUnknown,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = widget.query;
    final result = ref.watch(customersProvider(query));
    final page = result.value;

    CustomerSort? sortOf(String id) => switch (id) {
      'name' => CustomerSort.name,
      'email' => CustomerSort.email,
      'created' => CustomerSort.createdAt,
      'last' => CustomerSort.lastLoginAt,
      _ => null,
    };
    final currentSortId = switch (query.sort) {
      CustomerSort.name => 'name',
      CustomerSort.email => 'email',
      CustomerSort.createdAt => 'created',
      CustomerSort.lastLoginAt => 'last',
    };

    return Focus(
      onKeyEvent: _onKey,
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.customersTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                PermissionGate(
                  permission: Permission.customerExport,
                  child: DbookButton(
                    label: l10n.customerExport,
                    icon: Icons.download,
                    variant: DbookButtonVariant.secondary,
                    onPressed: () => exportCustomers(context, ref, query),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DbookSpacing.lg),
            DbookFilterBar(
              searchText: query.text,
              searchHint: l10n.customersSearchHint,
              searchFocusNode: _search,
              onSearchChanged: (text) =>
                  widget.onQueryChanged(CustomerQueryEdit.text(query, text)),
              onClearAll: () => widget.onQueryChanged((
                text: '',
                status: null,
                from: null,
                to: null,
                hasBookings: null,
                sort: query.sort,
                descending: query.descending,
                page: 0,
                size: query.size,
              )),
              period: query.from != null && query.to != null
                  ? DateTimeRange(start: query.from!, end: query.to!)
                  : null,
              onPeriodChanged: (range) => widget.onQueryChanged(
                CustomerQueryEdit.period(query, range?.start, range?.end),
              ),
              activeFilters: [
                if (query.status != null)
                  DbookActiveFilter(
                    id: 'status',
                    label: l10n.customersChipStatus(
                      _statusLabel(l10n, query.status!),
                    ),
                    onRemove: () => widget.onQueryChanged(
                      CustomerQueryEdit.status(query, null),
                    ),
                  ),
                if (query.hasBookings != null)
                  DbookActiveFilter(
                    id: 'bookings',
                    label: l10n.customersChipBookings(
                      query.hasBookings!
                          ? l10n.customersFilterWithBookings
                          : l10n.customersFilterWithoutBookings,
                    ),
                    onRemove: () => widget.onQueryChanged(
                      CustomerQueryEdit.hasBookings(query, null),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DbookSpacing.sm),
            Wrap(
              spacing: DbookSpacing.sm,
              children: [
                FilterChip(
                  label: Text(l10n.customersFilterActive),
                  selected: query.status == CustomerStatus.active,
                  onSelected: (on) => widget.onQueryChanged(
                    CustomerQueryEdit.status(
                      query,
                      on ? CustomerStatus.active : null,
                    ),
                  ),
                ),
                FilterChip(
                  label: Text(l10n.customersFilterBlocked),
                  selected: query.status == CustomerStatus.blocked,
                  onSelected: (on) => widget.onQueryChanged(
                    CustomerQueryEdit.status(
                      query,
                      on ? CustomerStatus.blocked : null,
                    ),
                  ),
                ),
                FilterChip(
                  label: Text(l10n.customersFilterWithBookings),
                  selected: query.hasBookings == true,
                  onSelected: (on) => widget.onQueryChanged(
                    CustomerQueryEdit.hasBookings(query, on ? true : null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DbookSpacing.md),
            Expanded(
              child: DbookDataTable<CustomerSummary>(
                semanticLabel: l10n.customersTitle,
                columns: [
                  DbookColumn(
                    id: 'name',
                    label: l10n.customersColName,
                    width: 280,
                    sortable: true,
                    cellBuilder: (c) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          c.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  DbookColumn(
                    id: 'status',
                    label: l10n.customersColStatus,
                    width: 130,
                    cellBuilder: (c) => DbookStatusBadge(
                      status: switch (c.status) {
                        CustomerStatus.active => DbookStatus.confirmed,
                        CustomerStatus.blocked => DbookStatus.cancelled,
                        CustomerStatus.unknown => DbookStatus.unknown,
                      },
                      label: _statusLabel(l10n, c.status),
                      showIcon: true,
                    ),
                  ),
                  DbookColumn(
                    id: 'bookings',
                    label: l10n.customersColBookings,
                    width: 110,
                    numeric: true,
                    cellBuilder: (c) =>
                        Text(PortalFormats.integer(c.bookingCount)),
                  ),
                  DbookColumn(
                    id: 'created',
                    label: l10n.customersColCreated,
                    width: 140,
                    sortable: true,
                    cellBuilder: (c) => Text(
                      c.createdAt == null
                          ? l10n.commonNone
                          : PortalFormats.date(c.createdAt!),
                    ),
                  ),
                  DbookColumn(
                    id: 'last',
                    label: l10n.customersColLastLogin,
                    width: 170,
                    sortable: true,
                    cellBuilder: (c) => Text(
                      c.lastLoginAt == null
                          ? l10n.customerNeverAccessed
                          : PortalFormats.dateTime(c.lastLoginAt!),
                    ),
                  ),
                ],
                rows: page?.items ?? const [],
                rowKey: (c) => c.id,
                isLoading: result.isLoading && !result.hasValue,
                errorMessage: result.hasError
                    ? portalErrorMessage(l10n, result.error!)
                    : null,
                onRetry: () => ref.invalidate(customersProvider(query)),
                emptyTitle: l10n.customersEmpty,
                emptyMessage: l10n.customersEmptyMessage,
                onRowTap: (c) => widget.onOpen(c.id),
                sort: DbookSort(
                  currentSortId,
                  query.descending
                      ? DbookSortDirection.descending
                      : DbookSortDirection.ascending,
                ),
                onSort: (next) {
                  final column = next == null ? null : sortOf(next.columnId);
                  // "sem ordem" volta ao padrão do servidor (mais novos primeiro)
                  widget.onQueryChanged(
                    column == null
                        ? CustomerQueryEdit.sort(
                            query,
                            defaultCustomerQuery.sort,
                            defaultCustomerQuery.descending,
                          )
                        : CustomerQueryEdit.sort(
                            query,
                            column,
                            next!.direction == DbookSortDirection.descending,
                          ),
                  );
                },
                pagination: DbookPagination(
                  page: page?.page ?? query.page,
                  pageSize: query.size,
                  total: page?.totalElements ?? 0,
                  onPageChanged: (p) =>
                      widget.onQueryChanged(CustomerQueryEdit.page(query, p)),
                  onPageSizeChanged: (s) =>
                      widget.onQueryChanged(CustomerQueryEdit.size(query, s)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
