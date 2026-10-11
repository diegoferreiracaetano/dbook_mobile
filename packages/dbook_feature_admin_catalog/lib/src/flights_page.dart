import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_providers.dart';
import 'flight_query_codec.dart';

/// A lista de voos do catálogo, com filtros e página na URL.
class FlightsPage extends ConsumerWidget {
  const FlightsPage({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onOpen,
    required this.onCreate,
    required this.onImport,
  });

  final FlightQuery query;
  final ValueChanged<FlightQuery> onQueryChanged;
  final ValueChanged<int> onOpen;
  final VoidCallback onCreate;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(flightsProvider(query));
    final page = result.value;

    Widget codeField(
      String label,
      String value,
      ValueChanged<String> onChanged,
    ) => SizedBox(
      width: 150,
      child: TextFormField(
        key: ValueKey('$label-$value'),
        initialValue: value,
        decoration: InputDecoration(labelText: label, isDense: true),
        textCapitalization: TextCapitalization.characters,
        maxLength: 3,
        buildCounter: (
          _, {
          required currentLength,
          required isFocused,
          maxLength,
        }) => null,
        onFieldSubmitted: onChanged,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.flightsTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              PermissionGate(
                permission: Permission.flightWrite,
                child: Wrap(
                  spacing: DbookSpacing.sm,
                  children: [
                    DbookButton(
                      label: l10n.flightsImport,
                      icon: Icons.upload_file,
                      variant: DbookButtonVariant.secondary,
                      onPressed: onImport,
                    ),
                    DbookButton(
                      label: l10n.flightsNew,
                      icon: Icons.add,
                      onPressed: onCreate,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          Wrap(
            spacing: DbookSpacing.md,
            runSpacing: DbookSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              codeField(
                l10n.flightsFilterOrigin,
                query.origin,
                (v) => onQueryChanged(
                  FlightQueryEdit.origin(query, v.trim().toUpperCase()),
                ),
              ),
              codeField(
                l10n.flightsFilterDestination,
                query.destination,
                (v) => onQueryChanged(
                  FlightQueryEdit.destination(query, v.trim().toUpperCase()),
                ),
              ),
              codeField(
                l10n.flightsFilterAirline,
                query.airline,
                (v) => onQueryChanged(
                  FlightQueryEdit.airline(query, v.trim().toUpperCase()),
                ),
              ),
              DropdownButton<FlightStatus?>(
                value: query.status,
                hint: Text(l10n.flightsFilterStatus),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(l10n.flightsFilterStatusAll),
                  ),
                  DropdownMenuItem(
                    value: FlightStatus.scheduled,
                    child: Text(l10n.flightStatusScheduled),
                  ),
                  DropdownMenuItem(
                    value: FlightStatus.cancelled,
                    child: Text(l10n.flightStatusCancelled),
                  ),
                ],
                onChanged: (v) =>
                    onQueryChanged(FlightQueryEdit.status(query, v)),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.sm),
          DbookFilterBar(
            onClearAll: () => onQueryChanged(FlightQueryEdit.cleared(query)),
            period: query.departureFrom != null && query.departureTo != null
                ? DateTimeRange(
                    start: query.departureFrom!,
                    end: query.departureTo!,
                  )
                : null,
            onPeriodChanged: (range) => onQueryChanged(
              FlightQueryEdit.period(query, range?.start, range?.end),
            ),
          ),
          const SizedBox(height: DbookSpacing.md),
          Expanded(
            child: DbookDataTable<AdminFlight>(
              semanticLabel: l10n.flightsTitle,
              columns: [
                DbookColumn(
                  id: 'number',
                  label: l10n.flightColNumber,
                  width: 150,
                  cellBuilder: (f) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.flightNumber),
                      Text(
                        f.airlineName ?? f.airlineIataCode,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DbookColumn(
                  id: 'route',
                  label: l10n.flightColRoute,
                  width: 130,
                  cellBuilder: (f) => Text('${f.origin} → ${f.destination}'),
                ),
                DbookColumn(
                  id: 'departure',
                  label: l10n.flightColDeparture,
                  width: 160,
                  cellBuilder: (f) => Text(
                    f.departureTime == null
                        ? l10n.commonNone
                        : PortalFormats.dateTime(f.departureTime!),
                  ),
                ),
                DbookColumn(
                  id: 'class',
                  label: l10n.flightColClass,
                  width: 150,
                  cellBuilder: (f) => Text(seatClassLabel(l10n, f.seatClass)),
                ),
                DbookColumn(
                  id: 'price',
                  label: l10n.flightColPrice,
                  width: 120,
                  numeric: true,
                  cellBuilder: (f) => Text(PortalFormats.money(f.price)),
                ),
                DbookColumn(
                  id: 'seats',
                  label: l10n.flightColSeats,
                  width: 200,
                  cellBuilder: (f) => Text(
                    '${f.availableSeats} ${l10n.flightSeatsFree} · '
                    '${f.reservedSeats} ${l10n.flightSeatsReserved}',
                  ),
                ),
                DbookColumn(
                  id: 'status',
                  label: l10n.flightColStatus,
                  width: 140,
                  cellBuilder: (f) => DbookStatusBadge(
                    status: switch (f.status) {
                      FlightStatus.scheduled => DbookStatus.confirmed,
                      FlightStatus.cancelled => DbookStatus.cancelled,
                      FlightStatus.unknown => DbookStatus.unknown,
                    },
                    label: flightStatusLabel(l10n, f.status),
                    showIcon: true,
                  ),
                ),
              ],
              rows: page?.items ?? const [],
              rowKey: (f) => f.id,
              isLoading: result.isLoading && !result.hasValue,
              errorMessage: result.hasError
                  ? portalErrorMessage(l10n, result.error!)
                  : null,
              onRetry: () => ref.invalidate(flightsProvider(query)),
              emptyTitle: l10n.flightsEmpty,
              emptyMessage: l10n.flightsEmptyMessage,
              onRowTap: (f) => onOpen(f.id),
              pagination: DbookPagination(
                page: page?.page ?? query.page,
                pageSize: query.size,
                total: page?.totalElements ?? 0,
                onPageChanged: (p) =>
                    onQueryChanged(FlightQueryEdit.page(query, p)),
                onPageSizeChanged: (s) =>
                    onQueryChanged(FlightQueryEdit.size(query, s)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
