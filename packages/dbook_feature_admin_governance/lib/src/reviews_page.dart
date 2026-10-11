import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'governance_providers.dart';

/// A fila de moderação de avaliações: denunciadas, ocultas e visíveis. Ocultar
/// exige um motivo (10 a 500 caracteres) e fica na auditoria.
class ReviewsPage extends ConsumerWidget {
  const ReviewsPage({
    super.key,
    required this.request,
    required this.onRequestChanged,
  });

  final ReviewsRequest request;
  final ValueChanged<ReviewsRequest> onRequestChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final result = ref.watch(reviewsProvider(request));
    final page = result.value;

    String queueLabel(ReviewQueue q) => switch (q) {
      ReviewQueue.reported => l10n.reviewsQueueReported,
      ReviewQueue.hidden => l10n.reviewsQueueHidden,
      ReviewQueue.visible => l10n.reviewsQueueVisible,
    };

    Future<void> act(Future<void> Function() action, String success) async {
      try {
        await action();
        ref.invalidate(reviewsProvider);
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

    return Padding(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reviewsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: DbookSpacing.lg),
          Wrap(
            spacing: DbookSpacing.sm,
            children: [
              for (final queue in ReviewQueue.values)
                ChoiceChip(
                  label: Text(queueLabel(queue)),
                  selected: request.queue == queue,
                  onSelected: (_) => onRequestChanged((queue: queue, page: 0)),
                ),
            ],
          ),
          const SizedBox(height: DbookSpacing.md),
          Expanded(
            child: DbookDataTable<AdminReview>(
              semanticLabel: l10n.reviewsTitle,
              columns: [
                DbookColumn(
                  id: 'customer',
                  label: l10n.reviewColCustomer,
                  width: 180,
                  cellBuilder: (r) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        r.destination,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DbookColumn(
                  id: 'rating',
                  label: l10n.reviewColRating,
                  width: 90,
                  cellBuilder: (r) => Text('${r.rating}/5'),
                ),
                DbookColumn(
                  id: 'text',
                  label: l10n.reviewColText,
                  width: 420,
                  cellBuilder: (r) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.comment,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (r.lastReportReason != null)
                        Text(
                          l10n.reviewReportedReason(r.lastReportReason!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (r.hidden && r.hiddenReason != null)
                        Text(
                          l10n.reviewHiddenReason(r.hiddenReason!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                DbookColumn(
                  id: 'reports',
                  label: l10n.reviewColReports,
                  width: 110,
                  numeric: true,
                  cellBuilder: (r) => Text('${r.openReports}'),
                ),
                DbookColumn(
                  id: 'status',
                  label: l10n.reviewColStatus,
                  width: 120,
                  cellBuilder: (r) => DbookStatusBadge(
                    status: r.hidden
                        ? DbookStatus.cancelled
                        : DbookStatus.confirmed,
                    label: r.hidden
                        ? l10n.reviewStatusHidden
                        : l10n.reviewStatusVisible,
                    showIcon: true,
                  ),
                ),
                DbookColumn(
                  id: 'actions',
                  label: l10n.teamColActions,
                  width: 90,
                  canHide: false,
                  cellBuilder: (r) => PopupMenuButton<String>(
                    tooltip: l10n.teamActionsFor(r.customerName),
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      switch (value) {
                        case 'restore':
                          await act(
                            () => ref
                                .read(governanceApiProvider)
                                .restoreReview(r.id),
                            l10n.reviewRestoredDone,
                          );
                        case 'hide':
                          final done = await showDialog<bool>(
                            context: context,
                            builder: (_) => _HideReviewDialog(review: r),
                          );
                          if ((done ?? false) && context.mounted) {
                            ref.invalidate(reviewsProvider);
                            showDbookToast(
                              context,
                              l10n.reviewHiddenDone,
                              tone: DbookToastTone.success,
                            );
                          }
                        case 'dismiss':
                          final confirmed = await showDbookConfirmationDialog(
                            context,
                            title: l10n.reviewDismiss,
                            message: l10n.reviewDismissMessage,
                            confirmLabel: l10n.reviewDismiss,
                            cancelLabel: l10n.commonCancel,
                          );
                          if (confirmed) {
                            await act(
                              () => ref
                                  .read(governanceApiProvider)
                                  .dismissReports(r.id),
                              l10n.reviewDismissedDone,
                            );
                          }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: r.hidden ? 'restore' : 'hide',
                        child: Text(
                          r.hidden ? l10n.reviewRestore : l10n.reviewHide,
                        ),
                      ),
                      if (r.openReports > 0)
                        PopupMenuItem(
                          value: 'dismiss',
                          child: Text(l10n.reviewDismiss),
                        ),
                    ],
                  ),
                ),
              ],
              rows: page?.items ?? const [],
              rowKey: (r) => r.id,
              isLoading: result.isLoading && !result.hasValue,
              errorMessage: result.hasError
                  ? portalErrorMessage(l10n, result.error!)
                  : null,
              onRetry: () => ref.invalidate(reviewsProvider(request)),
              emptyTitle: l10n.reviewsEmpty,
              emptyMessage: l10n.reviewsEmptyMessage,
              pagination: DbookPagination(
                page: page?.page ?? request.page,
                pageSize: page?.size ?? 20,
                total: page?.totalElements ?? 0,
                onPageChanged: (p) =>
                    onRequestChanged((queue: request.queue, page: p)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HideReviewDialog extends ConsumerStatefulWidget {
  const _HideReviewDialog({required this.review});

  final AdminReview review;

  @override
  ConsumerState<_HideReviewDialog> createState() => _HideReviewDialogState();
}

class _HideReviewDialogState extends ConsumerState<_HideReviewDialog> {
  final _reason = TextEditingController();
  bool _busy = false;
  String? _error;

  String get _draftKey => 'review-hide-${widget.review.id}';

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(governanceApiProvider)
          .hideReview(widget.review.id, _reason.text.trim());
      ref.read(draftStoreProvider.notifier).clear(_draftKey);
      if (mounted) Navigator.of(context).pop(true);
    } on DbookNetworkException catch (error) {
      if (!mounted) return;
      setState(() => _error = portalErrorMessage(context.l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final length = _reason.text.trim().length;
    final valid = length >= 10 && length <= 500;

    return AlertDialog(
      title: Text(l10n.reviewHideTitle(widget.review.customerName)),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.reviewHideMessage),
              const SizedBox(height: DbookSpacing.md),
              if (_error != null) ...[
                DbookFieldError(_error!),
                const SizedBox(height: DbookSpacing.md),
              ],
              DraftGuard(
                draftKey: _draftKey,
                controller: _reason,
                child: DbookTextArea(
                  label: l10n.reviewHideReason,
                  controller: _reason,
                  maxLength: 500,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: _busy || !valid ? null : _submit,
          child: Text(l10n.reviewHideSubmit),
        ),
      ],
    );
  }
}
