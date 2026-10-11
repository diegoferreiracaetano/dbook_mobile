import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';
import 'cancellation_state.dart';

/// Cancelar uma reserva ou pedir o reembolso dela. A **chave de
/// idempotência é por tentativa**: se a resposta se perde (rede), "Tentar de
/// novo" repete a **mesma** chave e o servidor devolve o mesmo reembolso, sem
/// devolver o dinheiro duas vezes; depois de um reembolso que **falhou**, a
/// nova tentativa leva uma chave **nova** (a mesma repetiria a falha).
class CancellationNotifier extends Notifier<CancellationState> {
  CancellationNotifier(this.bookingId);

  final int bookingId;

  String? _attemptKey;

  @override
  CancellationState build() {
    Future<void>.microtask(load);
    return const CancellationLoading();
  }

  Future<void> load() async {
    state = const CancellationLoading();
    try {
      final policy = await ref.read(refundRepositoryProvider).policy(bookingId);
      state = CancellationReady(policy);
    } on DbookNetworkException catch (error) {
      state = CancellationLoadFailed(error.message);
    }
  }

  Future<void> confirm() async {
    final current = state;
    final policy = switch (current) {
      CancellationReady(:final policy) => policy,
      RefundFinished(:final policy) => policy,
      _ => null,
    };
    if (policy == null) return;

    state = CancellationSubmitting(policy);
    try {
      switch (policy.action) {
        case CancellationAction.cancel:
          await ref.read(myBookingsNotifierProvider.notifier).cancel(bookingId);
          state = const CancellationDone();
        case CancellationAction.refundRequest:
          final key = _attemptKey ??= ref.read(
            idempotencyKeyGeneratorProvider,
          )();
          final result = await ref
              .read(refundRepositoryProvider)
              .request(bookingId, idempotencyKey: key);
          // resposta recebida: a próxima tentativa (inclusive depois de um
          // FAILED, em que o dinheiro não saiu) é um pedido novo
          _attemptKey = null;
          if (result.status != RefundProgress.failed) {
            ref.invalidate(myBookingsNotifierProvider);
          }
          state = RefundFinished(result, policy);
        case CancellationAction.none:
          state = CancellationReady(policy);
      }
    } on DbookNetworkException catch (error) {
      // a chave fica: um novo "tentar de novo" repete o mesmo pedido
      state = CancellationReady(policy, error: _message(error));
    }
  }

  String _message(DbookNetworkException error) => switch (error.code) {
    'REFUND_WINDOW_CLOSED' => 'Faltam menos de 24 horas para a partida: o reembolso não é mais possível pelo app. Fale com o suporte.',
    _ when error is DbookUnknownNetworkException => 'Sem conexão. Toque em tentar de novo: o pedido não será feito duas vezes.',
    _ when error is DbookConflictException => 'Esta reserva já mudou (talvez já tenha reembolso em andamento). Atualize a lista.',
    _ => 'Não foi possível concluir agora. Tente de novo.',
  };
}

final cancellationNotifierProvider = NotifierProvider.autoDispose
    .family<CancellationNotifier, CancellationState, int>(
      CancellationNotifier.new,
    );
