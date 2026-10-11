import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bookings_providers.dart';

/// Reembolsar uma reserva paga. Antes de confirmar mostra **o valor, a
/// política e o prazo**. A chave de idempotência é **por tentativa**: se a
/// resposta se perde ou o servidor falha, "Tentar de novo" reaproveita a mesma
/// chave e o servidor devolve o resultado original, sem devolver o dinheiro
/// duas vezes; mudar o motivo ou a observação é outra tentativa e leva outra
/// chave. Enquanto o pedido está em voo o botão fica em "Processando…".
class RefundDialog extends ConsumerStatefulWidget {
  const RefundDialog({super.key, required this.detail});

  final AdminBookingDetail detail;

  @override
  ConsumerState<RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends ConsumerState<RefundDialog> {
  final _attempt = IdempotentAttempt();
  final _note = TextEditingController();
  RefundReason _reason = RefundReason.customerRequest;
  bool _override = false;
  bool _busy = false;
  String? _error;
  Refund? _failed;

  AdminBooking get _booking => widget.detail.booking;

  double get _amount =>
      _booking.paidAmount ?? widget.detail.payment?.amount ?? _booking.price;

  RefundRequest get _request => RefundRequest(
    reason: _reason,
    note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    override: _override,
  );

  bool get _noteMissing => _override && _note.text.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    _note.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || _noteMissing) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(adminBookingsApiProvider);
    try {
      final failed = _failed;
      final refund = failed != null
          ? await api.retryRefund(failed.id)
          : await api.refund(
              _booking.id,
              _request,
              idempotencyKey: _attempt.keyFor(_request.fingerprint),
            );
      if (!mounted) return;
      if (refund.status == RefundStatus.completed) {
        _attempt.finish();
        Navigator.of(context).pop(true);
      } else {
        setState(() => _failed = refund);
      }
    } on DbookNetworkException catch (error) {
      if (!mounted) return;
      if (error is DbookConflictException &&
          error.code != 'REFUND_WINDOW_CLOSED') {
        // outra pessoa mexeu na reserva: recarrega o que a tela mostra
        ref.invalidate(adminBookingDetailProvider(_booking.id));
        setState(() => _error = context.l10n.refundConflict);
      } else {
        setState(() => _error = portalErrorMessage(context.l10n, error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isSuperAdmin =
        ref.watch(staffProfileProvider)?.role == Role.superAdmin;
    final departure = _booking.departureTime;
    final deadline = departure?.subtract(const Duration(hours: 24));
    final failed = _failed;

    return AlertDialog(
      title: Text(l10n.refundTitle(_booking.id)),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.refundSummaryAmount(PortalFormats.money(_amount)),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: DbookSpacing.xs),
              Text(
                deadline == null
                    ? l10n.refundPolicy
                    : l10n.refundPolicyDeadline(
                        PortalFormats.dateTime(deadline),
                      ),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: DbookSpacing.lg),
              if (failed != null) ...[
                DbookInlineStatusBanner(
                  tone: DbookBannerTone.warning,
                  icon: Icons.error_outline,
                  message: failed.status == RefundStatus.failed
                      ? '${l10n.refundFailedTitle}. ${l10n.refundFailedMessage}'
                      : l10n.refundRequestedNote,
                ),
              ] else ...[
                DropdownButtonFormField<RefundReason>(
                  initialValue: _reason,
                  decoration: InputDecoration(
                    labelText: l10n.refundReasonLabel,
                  ),
                  items: [
                    for (final reason in RefundReason.values)
                      DropdownMenuItem(
                        value: reason,
                        child: Text(refundReasonLabel(l10n, reason)),
                      ),
                  ],
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _reason = v ?? _reason),
                ),
                const SizedBox(height: DbookSpacing.md),
                DbookTextArea(
                  label: l10n.refundNoteLabel,
                  controller: _note,
                  maxLength: 300,
                  minLines: 2,
                  enabled: !_busy,
                ),
                if (isSuperAdmin) ...[
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _override,
                    title: Text(l10n.refundOverride),
                    subtitle: Text(l10n.refundOverrideHelp),
                    onChanged: _busy
                        ? null
                        : (v) => setState(() => _override = v ?? false),
                  ),
                  if (_noteMissing)
                    Text(
                      l10n.refundNoteRequired,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
              ],
              if (_error != null) ...[
                const SizedBox(height: DbookSpacing.md),
                Semantics(liveRegion: true, child: DbookFieldError(_error!)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _busy || _noteMissing ? null : _submit,
          child: _busy
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: DbookSpacing.sm),
                    Text(l10n.refundProcessing),
                  ],
                )
              : Text(failed != null ? l10n.refundRetry : l10n.refundSubmit),
        ),
      ],
    );
  }
}
