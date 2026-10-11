import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bookings_providers.dart';

/// Os reembolsos, para achar os que falharam e tentar de novo.
class RefundsPage extends ConsumerWidget {
  const RefundsPage({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onOpenBooking,
  });

  final RefundQuery query;
  final ValueChanged<RefundQuery> onQueryChanged;
  final ValueChanged<int> onOpenBooking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(refundsProvider(query));
    final page = result.value;

    return Padding(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.refundsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: DbookSpacing.lg),
          Wrap(
            spacing: DbookSpacing.sm,
            children: [
              ChoiceChip(
                label: Text(l10n.refundsFilterAll),
                selected: query.status == null,
                onSelected: (_) =>
                    onQueryChanged((status: null, page: 0, size: query.size)),
              ),
              for (final status in const [
                RefundStatus.failed,
                RefundStatus.requested,
                RefundStatus.completed,
              ])
                ChoiceChip(
                  label: Text(refundStatusLabel(l10n, status)),
                  selected: query.status == status,
                  onSelected: (_) => onQueryChanged((
                    status: status,
                    page: 0,
                    size: query.size,
                  )),
                ),
            ],
          ),
          const SizedBox(height: DbookSpacing.md),
          Expanded(
            child: DbookDataTable<Refund>(
              semanticLabel: l10n.refundsTitle,
              columns: [
                DbookColumn(
                  id: 'id',
                  label: l10n.refundColId,
                  width: 110,
                  cellBuilder: (r) => Text('#${r.id}'),
                ),
                DbookColumn(
                  id: 'booking',
                  label: l10n.refundColBooking,
                  width: 130,
                  cellBuilder: (r) => TextButton(
                    onPressed: () => onOpenBooking(r.bookingId),
                    child: Text('#${r.bookingId}'),
                  ),
                ),
                DbookColumn(
                  id: 'amount',
                  label: l10n.refundColAmount,
                  width: 140,
                  numeric: true,
                  cellBuilder: (r) => Text(PortalFormats.money(r.amount)),
                ),
                DbookColumn(
                  id: 'status',
                  label: l10n.refundColStatus,
                  width: 140,
                  cellBuilder: (r) => DbookStatusBadge(
                    status: switch (r.status) {
                      RefundStatus.completed => DbookStatus.confirmed,
                      RefundStatus.requested => DbookStatus.pending,
                      RefundStatus.failed => DbookStatus.cancelled,
                      RefundStatus.unknown => DbookStatus.unknown,
                    },
                    label: refundStatusLabel(l10n, r.status),
                    showIcon: true,
                  ),
                ),
                DbookColumn(
                  id: 'reason',
                  label: l10n.refundColReason,
                  width: 180,
                  cellBuilder: (r) => Text(refundReasonLabel(l10n, r.reason)),
                ),
                DbookColumn(
                  id: 'date',
                  label: l10n.refundColDate,
                  width: 160,
                  cellBuilder: (r) => Text(
                    r.createdAt == null
                        ? l10n.commonNone
                        : PortalFormats.dateTime(r.createdAt!),
                  ),
                ),
                DbookColumn(
                  id: 'actions',
                  label: l10n.teamColActions,
                  width: 150,
                  canHide: false,
                  cellBuilder: (r) => r.canRetry
                      ? TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(adminBookingsApiProvider)
                                  .retryRefund(r.id);
                              ref.invalidate(refundsProvider(query));
                            } on Object catch (error) {
                              if (context.mounted) {
                                showDbookToast(
                                  context,
                                  portalErrorMessage(l10n, error),
                                  tone: DbookToastTone.danger,
                                );
                              }
                            }
                          },
                          child: Text(l10n.refundRetry),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
              rows: page?.items ?? const [],
              rowKey: (r) => r.id,
              isLoading: result.isLoading && !result.hasValue,
              errorMessage: result.hasError
                  ? portalErrorMessage(l10n, result.error!)
                  : null,
              onRetry: () => ref.invalidate(refundsProvider(query)),
              emptyTitle: l10n.refundsEmpty,
              emptyMessage: l10n.refundsEmptyMessage,
              pagination: DbookPagination(
                page: page?.page ?? query.page,
                pageSize: query.size,
                total: page?.totalElements ?? 0,
                onPageChanged: (p) => onQueryChanged((
                  status: query.status,
                  page: p,
                  size: query.size,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
