import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'customer_dialogs.dart';
import 'customers_providers.dart';

DbookStatus _badgeFor(BookingStatus status) => switch (status) {
  BookingStatus.pending => DbookStatus.pending,
  BookingStatus.confirmed => DbookStatus.confirmed,
  BookingStatus.cancelled || BookingStatus.refunded => DbookStatus.cancelled,
  BookingStatus.expired || BookingStatus.unknown => DbookStatus.unknown,
};

/// Uma aba da visão 360º: só é construída (e só busca) quando aberta.
class BookingsTab extends ConsumerWidget {
  const BookingsTab({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(customerBookingsProvider(customerId));

    return DbookDataTable<CustomerBooking>(
      semanticLabel: l10n.tabBookings,
      columns: [
        DbookColumn(
          id: 'id',
          label: l10n.bookingColId,
          width: 100,
          cellBuilder: (b) => Text('#${b.id}'),
        ),
        DbookColumn(
          id: 'item',
          label: l10n.bookingColItem,
          width: 280,
          cellBuilder: (b) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (b.origin != null && b.destination != null)
                Text(
                  '${b.origin} → ${b.destination}'
                  '${b.seatLabel == null ? '' : ' · ${b.seatLabel}'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        DbookColumn(
          id: 'status',
          label: l10n.bookingColStatus,
          width: 150,
          cellBuilder: (b) => DbookStatusBadge(
            status: _badgeFor(b.status),
            label: bookingStatusLabel(l10n, b.status),
            showIcon: true,
          ),
        ),
        DbookColumn(
          id: 'price',
          label: l10n.bookingColPrice,
          width: 130,
          numeric: true,
          cellBuilder: (b) => Text(PortalFormats.money(b.price)),
        ),
        DbookColumn(
          id: 'departure',
          label: l10n.bookingColDeparture,
          width: 160,
          cellBuilder: (b) => Text(
            b.departureTime == null
                ? l10n.commonNone
                : PortalFormats.dateTime(b.departureTime!),
          ),
        ),
      ],
      rows: result.value ?? const [],
      rowKey: (b) => b.id,
      isLoading: result.isLoading && !result.hasValue,
      errorMessage: result.hasError
          ? portalErrorMessage(l10n, result.error!)
          : null,
      onRetry: () => ref.invalidate(customerBookingsProvider(customerId)),
      emptyTitle: l10n.tabEmptyBookings,
      emptyMessage: l10n.tabEmptyHint,
    );
  }
}

class PaymentsTab extends ConsumerWidget {
  const PaymentsTab({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(customerPaymentsProvider(customerId));

    return DbookDataTable<CustomerPayment>(
      semanticLabel: l10n.tabPayments,
      columns: [
        DbookColumn(
          id: 'id',
          label: l10n.paymentColId,
          width: 120,
          cellBuilder: (p) => Text('#${p.id}'),
        ),
        DbookColumn(
          id: 'amount',
          label: l10n.paymentColAmount,
          width: 150,
          numeric: true,
          cellBuilder: (p) => Text(PortalFormats.money(p.amount)),
        ),
        DbookColumn(
          id: 'card',
          label: l10n.paymentColCard,
          width: 140,
          cellBuilder: (p) => Text('•••• ${p.cardLast4}'),
        ),
        DbookColumn(
          id: 'date',
          label: l10n.paymentColDate,
          width: 170,
          cellBuilder: (p) => Text(
            p.createdAt == null
                ? l10n.commonNone
                : PortalFormats.dateTime(p.createdAt!),
          ),
        ),
      ],
      rows: result.value ?? const [],
      rowKey: (p) => p.id,
      isLoading: result.isLoading && !result.hasValue,
      errorMessage: result.hasError
          ? portalErrorMessage(l10n, result.error!)
          : null,
      onRetry: () => ref.invalidate(customerPaymentsProvider(customerId)),
      emptyTitle: l10n.tabEmptyPayments,
      emptyMessage: l10n.tabEmptyHint,
    );
  }
}

class ReviewsTab extends ConsumerWidget {
  const ReviewsTab({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(customerReviewsProvider(customerId));

    return DbookDataTable<CustomerReview>(
      semanticLabel: l10n.tabReviews,
      columns: [
        DbookColumn(
          id: 'rating',
          label: l10n.reviewColRating,
          width: 140,
          cellBuilder: (r) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 16),
              const SizedBox(width: DbookSpacing.xs),
              Text('${r.rating}/5'),
            ],
          ),
        ),
        DbookColumn(
          id: 'comment',
          label: l10n.reviewColComment,
          width: 420,
          cellBuilder: (r) =>
              Text(r.comment, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        DbookColumn(
          id: 'date',
          label: l10n.reviewColDate,
          width: 150,
          cellBuilder: (r) => Text(
            r.createdAt == null
                ? l10n.commonNone
                : PortalFormats.date(r.createdAt!),
          ),
        ),
      ],
      rows: result.value ?? const [],
      rowKey: (r) => r.id,
      isLoading: result.isLoading && !result.hasValue,
      errorMessage: result.hasError
          ? portalErrorMessage(l10n, result.error!)
          : null,
      onRetry: () => ref.invalidate(customerReviewsProvider(customerId)),
      emptyTitle: l10n.tabEmptyReviews,
      emptyMessage: l10n.tabEmptyHint,
    );
  }
}

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(customerHistoryProvider(customerId));

    return DbookDataTable<AuditEntry>(
      semanticLabel: l10n.tabHistory,
      columns: [
        DbookColumn(
          id: 'when',
          label: l10n.auditColWhen,
          width: 170,
          cellBuilder: (e) =>
              Text(PortalFormats.dateTime(e.occurredAt.toLocal())),
        ),
        DbookColumn(
          id: 'action',
          label: l10n.auditColAction,
          width: 280,
          cellBuilder: (e) => Text(auditActionLabel(l10n, e.action)),
        ),
        DbookColumn(
          id: 'actor',
          label: l10n.auditColActor,
          width: 200,
          cellBuilder: (e) =>
              Text('#${e.actorId} · ${roleLabel(l10n, e.actorRole)}'),
        ),
        DbookColumn(
          id: 'outcome',
          label: l10n.auditColOutcome,
          width: 120,
          cellBuilder: (e) => DbookStatusBadge(
            status: e.denied ? DbookStatus.cancelled : DbookStatus.confirmed,
            label: e.denied
                ? l10n.auditOutcomeDenied
                : l10n.auditOutcomeSuccess,
            showIcon: true,
          ),
        ),
      ],
      rows: result.value?.items ?? const [],
      rowKey: (e) => e.id,
      isLoading: result.isLoading && !result.hasValue,
      errorMessage: result.hasError
          ? portalErrorMessage(l10n, result.error!)
          : null,
      onRetry: () => ref.invalidate(customerHistoryProvider(customerId)),
      emptyTitle: l10n.tabEmptyHistory,
      emptyMessage: l10n.tabEmptyHint,
    );
  }
}

/// Notas internas: criar, editar, fixar e apagar. O servidor decide quem pode
/// mexer em quê (só o autor edita; o autor ou um administrador apaga): a tela
/// só mostra as ações a quem tem a chance de poder.
class NotesTab extends ConsumerWidget {
  const NotesTab({super.key, required this.customerId, required this.canWrite});

  final int customerId;
  final bool canWrite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final result = ref.watch(customerNotesProvider(customerId));
    final me = ref.watch(staffProfileProvider);

    Future<void> editor([CustomerNote? note]) async {
      final saved = await showDialog<bool>(
        context: context,
        builder: (_) => NoteEditorDialog(customerId: customerId, note: note),
      );
      if ((saved ?? false) && context.mounted) {
        ref.invalidate(customerNotesProvider(customerId));
        showDbookToast(context, l10n.noteSaved, tone: DbookToastTone.success);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canWrite)
          Padding(
            padding: const EdgeInsets.only(bottom: DbookSpacing.md),
            child: DbookButton(
              label: l10n.noteAdd,
              icon: Icons.add_comment_outlined,
              variant: DbookButtonVariant.secondary,
              onPressed: editor,
            ),
          ),
        Expanded(
          child: result.when(
            loading: () => const DbookLoadingIndicator(),
            error: (error, _) => DbookErrorState(
              message: portalErrorMessage(l10n, error),
              onRetry: () => ref.invalidate(customerNotesProvider(customerId)),
            ),
            data: (notes) => notes.isEmpty
                ? DbookEmptyState(
                    title: l10n.notesEmpty,
                    message: l10n.notesEmptyMessage,
                  )
                : ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final mine = note.authorId == me?.id;
                      return ListTile(
                        leading: note.pinned
                            ? Tooltip(
                                message: l10n.notePinned,
                                child: const Icon(Icons.push_pin),
                              )
                            : const Icon(Icons.sticky_note_2_outlined),
                        title: SelectableText(note.body),
                        subtitle: Text(
                          '${l10n.noteBy('#${note.authorId}', note.createdAt == null ? l10n.commonNone : PortalFormats.dateTime(note.createdAt!))}'
                          '${note.editedAt == null ? '' : ' · ${l10n.noteEdited}'}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing:
                            canWrite &&
                                (mine ||
                                    (me?.can(Permission.adminManage) ?? false))
                            ? _NoteMenu(
                                note: note,
                                customerId: customerId,
                                canEdit: mine,
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _NoteMenu extends ConsumerWidget {
  const _NoteMenu({
    required this.note,
    required this.customerId,
    required this.canEdit,
  });

  final CustomerNote note;
  final int customerId;
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final api = ref.read(customersApiProvider);

    Future<void> run(Future<void> Function() action, String success) async {
      try {
        await action();
        ref.invalidate(customerNotesProvider(customerId));
        if (context.mounted) {
          showDbookToast(context, success, tone: DbookToastTone.success);
        }
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

    return PopupMenuButton<String>(
      tooltip: l10n.noteEdit,
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            final saved = await showDialog<bool>(
              context: context,
              builder: (_) =>
                  NoteEditorDialog(customerId: customerId, note: note),
            );
            if ((saved ?? false) && context.mounted) {
              ref.invalidate(customerNotesProvider(customerId));
              showDbookToast(
                context,
                l10n.noteSaved,
                tone: DbookToastTone.success,
              );
            }
          case 'pin':
            await run(
              () => api.updateNote(customerId, note.id, pinned: !note.pinned),
              l10n.noteSaved,
            );
          case 'delete':
            final confirmed = await showDbookConfirmationDialog(
              context,
              title: l10n.noteDeleteTitle,
              message: l10n.noteDeleteMessage,
              confirmLabel: l10n.noteDelete,
              cancelLabel: l10n.commonCancel,
              level: DbookConfirmLevel.destructive,
            );
            if (confirmed) {
              await run(
                () => api.deleteNote(customerId, note.id),
                l10n.noteDeleted,
              );
            }
        }
      },
      itemBuilder: (context) => [
        if (canEdit) PopupMenuItem(value: 'edit', child: Text(l10n.noteEdit)),
        if (canEdit)
          PopupMenuItem(
            value: 'pin',
            child: Text(note.pinned ? l10n.noteUnpin : l10n.notePin),
          ),
        PopupMenuItem(value: 'delete', child: Text(l10n.noteDelete)),
      ],
    );
  }
}
