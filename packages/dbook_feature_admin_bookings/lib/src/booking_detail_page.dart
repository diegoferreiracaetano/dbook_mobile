import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_status_ui.dart';
import 'bookings_providers.dart';
import 'refund_dialog.dart';

/// O detalhe de uma reserva: dados, linha do tempo (criada, paga, cancelada,
/// expirada, reembolsada, com quem fez), pagamento e reembolso, e as ações
/// que a permissão de quem olha permite.
class BookingDetailPage extends ConsumerWidget {
  const BookingDetailPage({
    super.key,
    required this.id,
    required this.onBack,
    required this.onOpenCustomer,
  });

  final int id;
  final VoidCallback onBack;
  final ValueChanged<int> onOpenCustomer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(adminBookingDetailProvider(id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: detail.when(
        loading: () => const SizedBox(
          height: DbookSizes.loadingLg,
          child: DbookLoadingIndicator(),
        ),
        error: (error, _) => SizedBox(
          height: 320,
          child: DbookErrorState(
            message: portalErrorMessage(l10n, error),
            onRetry: () => ref.invalidate(adminBookingDetailProvider(id)),
          ),
        ),
        data: (data) => _Content(
          detail: data,
          onBack: onBack,
          onOpenCustomer: onOpenCustomer,
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({
    required this.detail,
    required this.onBack,
    required this.onOpenCustomer,
  });

  final AdminBookingDetail detail;
  final VoidCallback onBack;
  final ValueChanged<int> onOpenCustomer;

  AdminBooking get booking => detail.booking;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDbookConfirmationDialog(
      context,
      title: l10n.bookingCancelTitle(booking.id),
      message: l10n.bookingCancelMessage,
      confirmLabel: l10n.bookingCancel,
      cancelLabel: l10n.commonCancel,
      level: DbookConfirmLevel.destructive,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(adminBookingsApiProvider).cancel(booking.id);
      ref.invalidate(adminBookingDetailProvider(booking.id));
      if (context.mounted) {
        showDbookToast(
          context,
          l10n.bookingCancelDone,
          tone: DbookToastTone.success,
        );
      }
    } on Object catch (error) {
      ref.invalidate(adminBookingDetailProvider(booking.id));
      if (context.mounted) {
        showDbookToast(
          context,
          portalErrorMessage(l10n, error),
          tone: DbookToastTone.danger,
        );
      }
    }
  }

  Future<void> _refund(BuildContext context, WidgetRef ref) async {
    final done = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RefundDialog(detail: detail),
    );
    if ((done ?? false) && context.mounted) {
      ref.invalidate(adminBookingDetailProvider(booking.id));
      showDbookToast(
        context,
        context.l10n.refundDone,
        tone: DbookToastTone.success,
      );
    }
  }

  Future<void> _retry(
    BuildContext context,
    WidgetRef ref,
    Refund refund,
  ) async {
    final l10n = context.l10n;
    try {
      await ref.read(adminBookingsApiProvider).retryRefund(refund.id);
      ref.invalidate(adminBookingDetailProvider(booking.id));
    } on Object catch (error) {
      if (context.mounted) {
        showDbookToast(
          context,
          portalErrorMessage(l10n, error),
          tone: DbookToastTone.danger,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final refund = detail.refund;
    final payment = detail.payment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DbookBreadcrumbs(
          items: [
            DbookBreadcrumbItem(label: l10n.bookingsBackToList, onTap: onBack),
            DbookBreadcrumbItem(label: '#${booking.id}'),
          ],
        ),
        const SizedBox(height: DbookSpacing.md),
        Wrap(
          spacing: DbookSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.bookingDetailTitle(booking.id),
              style: theme.textTheme.headlineSmall,
            ),
            BookingStatusBadge(booking.status),
          ],
        ),
        const SizedBox(height: DbookSpacing.lg),
        DbookDefinitionList(
          items: [
            DbookDefinition(label: l10n.bookingItem, value: booking.title),
            if (booking.route != null)
              DbookDefinition(label: l10n.bookingRoute, value: booking.route),
            if (booking.seatLabel != null)
              DbookDefinition(
                label: l10n.bookingSeat,
                value: booking.seatLabel,
              ),
            DbookDefinition(
              label: l10n.bookingColDeparture,
              value: booking.departureTime == null
                  ? null
                  : PortalFormats.dateTime(booking.departureTime!),
            ),
            DbookDefinition(
              label: l10n.bookingFrozenPrice,
              value: PortalFormats.money(booking.price),
            ),
            if (booking.discount != null && booking.discount! > 0)
              DbookDefinition(
                label: l10n.bookingDiscount,
                value: PortalFormats.money(booking.discount!),
              ),
            if (booking.paidAmount != null)
              DbookDefinition(
                label: l10n.bookingPaidAmount,
                value: PortalFormats.money(booking.paidAmount!),
              ),
            DbookDefinition(
              label: l10n.bookingCustomer,
              child: TextButton(
                onPressed: () => onOpenCustomer(booking.customerId),
                child: Text(
                  '${booking.customerName} · ${l10n.bookingCustomerLink}',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DbookSpacing.lg),
        Wrap(
          spacing: DbookSpacing.sm,
          runSpacing: DbookSpacing.sm,
          children: [
            if (booking.status == BookingStatus.pending)
              PermissionGate(
                permission: Permission.bookingCancelAny,
                child: DbookButton(
                  label: l10n.bookingCancel,
                  icon: Icons.cancel_outlined,
                  variant: DbookButtonVariant.secondary,
                  onPressed: () => _cancel(context, ref),
                ),
              ),
            if (booking.status == BookingStatus.confirmed && refund == null)
              PermissionGate(
                permission: Permission.paymentRefund,
                child: DbookButton(
                  label: l10n.bookingRefund,
                  icon: Icons.currency_exchange,
                  onPressed: () => _refund(context, ref),
                ),
              ),
            if (refund != null && refund.canRetry)
              PermissionGate(
                permission: Permission.paymentRefund,
                child: DbookButton(
                  label: l10n.refundRetry,
                  icon: Icons.refresh,
                  onPressed: () => _retry(context, ref, refund),
                ),
              ),
          ],
        ),
        const SizedBox(height: DbookSpacing.xl),
        Text(l10n.bookingPaymentTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: DbookSpacing.sm),
        payment == null
            ? Text(l10n.bookingNoPayment)
            : DbookDefinitionList(
                items: [
                  DbookDefinition(
                    label: '#${payment.id}',
                    value: PortalFormats.money(payment.amount),
                  ),
                  DbookDefinition(
                    label: l10n.bookingCard,
                    value: '•••• ${payment.cardLast4}',
                  ),
                  DbookDefinition(
                    label: l10n.paymentColDate,
                    value: payment.createdAt == null
                        ? null
                        : PortalFormats.dateTime(payment.createdAt!),
                  ),
                ],
              ),
        const SizedBox(height: DbookSpacing.xl),
        Text(l10n.bookingRefundTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: DbookSpacing.sm),
        refund == null
            ? Text(l10n.bookingNoRefund)
            : DbookDefinitionList(
                items: [
                  DbookDefinition(
                    label: l10n.refundColStatus,
                    child: DbookStatusBadge(
                      status: switch (refund.status) {
                        RefundStatus.completed => DbookStatus.confirmed,
                        RefundStatus.requested => DbookStatus.pending,
                        RefundStatus.failed => DbookStatus.cancelled,
                        RefundStatus.unknown => DbookStatus.unknown,
                      },
                      label: refundStatusLabel(l10n, refund.status),
                      showIcon: true,
                    ),
                  ),
                  DbookDefinition(
                    label: l10n.refundColAmount,
                    value: PortalFormats.money(refund.amount),
                  ),
                  DbookDefinition(
                    label: l10n.refundColReason,
                    value: refundReasonLabel(l10n, refund.reason),
                  ),
                  if (refund.status == RefundStatus.failed)
                    DbookDefinition(
                      label: l10n.refundFailedTitle,
                      value: l10n.refundFailedMessage,
                    ),
                ],
              ),
        const SizedBox(height: DbookSpacing.xl),
        Text(l10n.bookingTimelineTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: DbookSpacing.sm),
        _Timeline(entries: detail.timeline),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.entries});

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DbookSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    top: DbookSpacing.xxs,
                    right: DbookSpacing.sm,
                  ),
                  child: Icon(Icons.circle, size: 10),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.from == null
                            ? l10n.bookingTimelineCreated
                            : l10n.bookingTimelineChanged(
                                bookingStatusLabel(l10n, entry.from!),
                                bookingStatusLabel(
                                  l10n,
                                  entry.to ?? BookingStatus.unknown,
                                ),
                              ),
                      ),
                      Text(
                        [
                          if (entry.occurredAt != null)
                            PortalFormats.dateTime(entry.occurredAt!.toLocal()),
                          entry.actorId == null
                              ? l10n.bookingTimelineBySystem
                              : l10n.bookingTimelineBy(entry.actorId!),
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
