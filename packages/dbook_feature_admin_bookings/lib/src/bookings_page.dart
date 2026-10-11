import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_query_codec.dart';
import 'booking_status_ui.dart';
import 'bookings_providers.dart';

/// A lista de reservas. Filtros, página e tamanho vivem na consulta que o
/// roteador guarda na URL (link direto e recarga preservam tudo).
class BookingsPage extends ConsumerWidget {
  const BookingsPage({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onOpen,
  });

  final AdminBookingQuery query;
  final ValueChanged<AdminBookingQuery> onQueryChanged;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(adminBookingsProvider(query));
    final page = result.value;

    return Padding(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bookingsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: DbookSpacing.lg),
          Wrap(
            spacing: DbookSpacing.md,
            runSpacing: DbookSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<BookingStatus?>(
                value: query.status,
                hint: Text(l10n.bookingsFilterStatus),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.bookingsFilterStatusAll),
                  ),
                  for (final status in BookingStatus.values)
                    if (status != BookingStatus.unknown)
                      DropdownMenuItem(
                        value: status,
                        child: Text(bookingStatusLabel(l10n, status)),
                      ),
                ],
                onChanged: (status) =>
                    onQueryChanged(BookingQueryEdit.status(query, status)),
              ),
              FilterChip(
                label: Text(l10n.bookingsFilterPaid),
                selected: query.paid == true,
                onSelected: (on) => onQueryChanged(
                  BookingQueryEdit.paid(query, on ? true : null),
                ),
              ),
              FilterChip(
                label: Text(l10n.bookingsFilterUnpaid),
                selected: query.paid == false,
                onSelected: (on) => onQueryChanged(
                  BookingQueryEdit.paid(query, on ? false : null),
                ),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.sm),
          DbookFilterBar(
            onClearAll: () => onQueryChanged(BookingQueryEdit.cleared(query)),
            period: query.from != null && query.to != null
                ? DateTimeRange(start: query.from!, end: query.to!)
                : null,
            onPeriodChanged: (range) => onQueryChanged(
              BookingQueryEdit.period(query, range?.start, range?.end),
            ),
            activeFilters: [
              if (query.customerId != null)
                DbookActiveFilter(
                  id: 'customer',
                  label: l10n.bookingsChipCustomer(query.customerId!),
                  onRemove: () =>
                      onQueryChanged(BookingQueryEdit.customer(query, null)),
                ),
              if (query.bookableId != null)
                DbookActiveFilter(
                  id: 'flight',
                  label: l10n.bookingsChipFlight(query.bookableId!),
                  onRemove: () =>
                      onQueryChanged(BookingQueryEdit.flight(query, null)),
                ),
            ],
          ),
          const SizedBox(height: DbookSpacing.md),
          Expanded(
            child: DbookDataTable<AdminBooking>(
              semanticLabel: l10n.bookingsTitle,
              columns: [
                DbookColumn(
                  id: 'id',
                  label: l10n.bookingColId,
                  width: 90,
                  cellBuilder: (b) => Text('#${b.id}'),
                ),
                DbookColumn(
                  id: 'customer',
                  label: l10n.bookingColCustomer,
                  width: 200,
                  cellBuilder: (b) => Text(
                    b.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DbookColumn(
                  id: 'item',
                  label: l10n.bookingColItem,
                  width: 260,
                  cellBuilder: (b) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (b.route != null)
                        Text(
                          b.route!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                DbookColumn(
                  id: 'status',
                  label: l10n.bookingColStatus,
                  width: 150,
                  cellBuilder: (b) => BookingStatusBadge(b.status),
                ),
                DbookColumn(
                  id: 'price',
                  label: l10n.bookingColPrice,
                  width: 130,
                  numeric: true,
                  cellBuilder: (b) => Text(PortalFormats.money(b.price)),
                ),
                DbookColumn(
                  id: 'paid',
                  label: l10n.bookingColPaid,
                  width: 120,
                  cellBuilder: (b) =>
                      Text(b.isPaid ? l10n.bookingPaidYes : l10n.bookingPaidNo),
                ),
                DbookColumn(
                  id: 'created',
                  label: l10n.bookingColCreated,
                  width: 160,
                  cellBuilder: (b) => Text(
                    b.createdAt == null
                        ? l10n.commonNone
                        : PortalFormats.dateTime(b.createdAt!),
                  ),
                ),
              ],
              rows: page?.items ?? const [],
              rowKey: (b) => b.id,
              isLoading: result.isLoading && !result.hasValue,
              errorMessage: result.hasError
                  ? portalErrorMessage(l10n, result.error!)
                  : null,
              onRetry: () => ref.invalidate(adminBookingsProvider(query)),
              emptyTitle: l10n.bookingsEmpty,
              emptyMessage: l10n.bookingsEmptyMessage,
              onRowTap: (b) => onOpen(b.id),
              pagination: DbookPagination(
                page: page?.page ?? query.page,
                pageSize: query.size,
                total: page?.totalElements ?? 0,
                onPageChanged: (p) =>
                    onQueryChanged(BookingQueryEdit.page(query, p)),
                onPageSizeChanged: (s) =>
                    onQueryChanged(BookingQueryEdit.size(query, s)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
