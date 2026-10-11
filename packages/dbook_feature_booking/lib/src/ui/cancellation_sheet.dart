import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/cancellation_notifier.dart';
import '../state/cancellation_state.dart';

final _money = NumberFormat.currency(symbol: r'$');
final _when = DateFormat('dd/MM/yyyy HH:mm');

/// A folha de "Cancelar / reembolsar" de uma reserva. Mostra **o que
/// acontece, quanto volta e até quando, antes** de a pessoa confirmar, e o
/// resultado depois (concluído, em andamento ou falhou).
class CancellationSheet extends ConsumerWidget {
  const CancellationSheet({super.key, required this.booking});

  final MyBooking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = cancellationNotifierProvider(booking.id);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${booking.flight.originIataCode} → ${booking.flight.destinationIataCode}'
              ' · assento ${booking.seat.label}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: DbookSpacing.md),
            ..._body(context, state, notifier),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    CancellationState state,
    CancellationNotifier notifier,
  ) {
    switch (state) {
      case CancellationLoading():
        return const [
          SizedBox(
            height: DbookSizes.loadingSm,
            child: DbookLoadingIndicator(),
          ),
        ];
      case CancellationLoadFailed(:final message):
        return [
          Text(message),
          const SizedBox(height: DbookSpacing.md),
          DbookButton(label: 'Tentar de novo', onPressed: notifier.load),
        ];
      case CancellationReady(:final policy, :final error):
        return _ready(context, policy, error, notifier);
      case CancellationSubmitting(:final policy):
        return [
          Text(_explanation(policy)),
          const SizedBox(height: DbookSpacing.lg),
          const DbookButton(
            label: 'Processando…',
            onPressed: null,
            isLoading: true,
          ),
        ];
      case CancellationDone():
        return [
          const DbookInlineStatusBanner(
            tone: DbookBannerTone.success,
            message: 'Reserva cancelada. O assento foi liberado.',
          ),
          const SizedBox(height: DbookSpacing.md),
          DbookButton(
            label: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ];
      case RefundFinished(:final result, :final policy):
        return _finished(context, result, policy, notifier);
    }
  }

  List<Widget> _ready(
    BuildContext context,
    CancellationPolicy policy,
    String? error,
    CancellationNotifier notifier,
  ) {
    final can = policy.action != CancellationAction.none;
    return [
      Text(_explanation(policy)),
      if (policy.action == CancellationAction.refundRequest &&
          policy.refundableUntil != null) ...[
        const SizedBox(height: DbookSpacing.xs),
        Text(
          'Você pode pedir até ${_when.format(policy.refundableUntil!)}.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      if (error != null) ...[
        const SizedBox(height: DbookSpacing.md),
        DbookInlineStatusBanner(message: error, tone: DbookBannerTone.warning),
      ],
      const SizedBox(height: DbookSpacing.lg),
      if (can)
        DbookButton(
          label: switch (policy.action) {
            CancellationAction.cancel => 'Cancelar reserva',
            _ => error == null ? 'Pedir reembolso' : 'Tentar de novo',
          },
          onPressed: notifier.confirm,
        ),
      const SizedBox(height: DbookSpacing.sm),
      DbookButton(
        label: can ? 'Manter reserva' : 'Fechar',
        variant: DbookButtonVariant.text,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ];
  }

  List<Widget> _finished(
    BuildContext context,
    RefundRequestResult result,
    CancellationPolicy policy,
    CancellationNotifier notifier,
  ) {
    final amount = _money.format(result.amount);
    final (tone, message) = switch (result.status) {
      RefundProgress.completed => (
        DbookBannerTone.success,
        'Reembolso concluído: $amount de volta no seu cartão.',
      ),
      RefundProgress.requested => (
        DbookBannerTone.info,
        'Pedido registrado. O reembolso de $amount está em andamento.',
      ),
      RefundProgress.failed => (
        DbookBannerTone.warning,
        'Não conseguimos devolver agora e o dinheiro não saiu da sua reserva. '
            'Você pode tentar de novo.',
      ),
      RefundProgress.unknown => (
        DbookBannerTone.info,
        'Pedido registrado. Acompanhe pela lista de viagens.',
      ),
    };

    return [
      DbookInlineStatusBanner(tone: tone, message: message),
      const SizedBox(height: DbookSpacing.md),
      if (result.status == RefundProgress.failed) ...[
        DbookButton(label: 'Tentar de novo', onPressed: notifier.confirm),
        const SizedBox(height: DbookSpacing.sm),
      ],
      DbookButton(
        label: 'Fechar',
        variant: result.status == RefundProgress.failed
            ? DbookButtonVariant.text
            : DbookButtonVariant.primary,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ];
  }

  String _explanation(CancellationPolicy policy) => switch (policy.action) {
    CancellationAction.cancel => 'Esta reserva ainda não foi paga. Cancelar libera o assento e não há nada a devolver.',
    CancellationAction.refundRequest =>
      'Você será reembolsado em ${_money.format(policy.refundAmount ?? 0)}, '
          'o valor que você pagou. Depois do reembolso a reserva é cancelada.',
    CancellationAction.none => switch (policy.blockedBy) {
      CancellationBlock.windowClosed =>
        'Faltam menos de 24 horas para a partida, então o reembolso não é mais '
            'possível pelo app. Fale com o suporte.',
      CancellationBlock.refundInProgress =>
        'Já existe um reembolso em andamento para esta reserva.',
      CancellationBlock.alreadyRefunded => 'Esta reserva já foi reembolsada.',
      CancellationBlock.alreadyCancelled => 'Esta reserva já foi cancelada.',
      _ => 'Esta reserva não pode ser cancelada agora.',
    },
  };
}
