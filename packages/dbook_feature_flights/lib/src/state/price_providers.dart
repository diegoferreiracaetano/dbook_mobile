import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final priceRepositoryProvider = Provider<PriceRepository>(
  (ref) => PriceRepositoryImpl(ref.watch(dioProvider)),
);

/// O histórico de preço de um voo (público).
final priceHistoryProvider = FutureProvider.autoDispose
    .family<PriceHistory, int>(
      (ref, flightId) => ref.watch(priceRepositoryProvider).history(flightId),
    );

/// Os alertas de preço do usuário. Ligar, desligar, mudar o alvo e apagar
/// aparecem na hora e **voltam atrás** se o servidor recusar (o erro sobe
/// para a tela explicar).
class PriceAlertsNotifier extends AsyncNotifier<List<PriceAlert>> {
  @override
  Future<List<PriceAlert>> build() =>
      ref.read(priceRepositoryProvider).alerts();

  PriceRepository get _repository => ref.read(priceRepositoryProvider);

  Future<void> create({
    required String origin,
    required String destination,
    required DateTime date,
    required double targetPrice,
  }) async {
    final created = await _repository.createAlert(
      origin: origin,
      destination: destination,
      date: date,
      targetPrice: targetPrice,
    );
    state = AsyncData([created, ...?state.value]);
  }

  Future<void> _change(
    int id,
    PriceAlert Function(PriceAlert) optimistic,
    Future<PriceAlert> Function() call,
  ) async {
    final before = state.value;
    if (before == null) return;
    state = AsyncData([for (final a in before) a.id == id ? optimistic(a) : a]);
    try {
      final confirmed = await call();
      state = AsyncData([
        for (final a in state.value ?? before) a.id == id ? confirmed : a,
      ]);
    } on Object {
      state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> setActive(PriceAlert alert, {required bool active}) => _change(
    alert.id,
    (a) => a.copyWith(active: active),
    () => _repository.updateAlert(alert.id, active: active),
  );

  Future<void> setTarget(PriceAlert alert, double targetPrice) => _change(
    alert.id,
    (a) => a.copyWith(targetPrice: targetPrice),
    () => _repository.updateAlert(alert.id, targetPrice: targetPrice),
  );

  Future<void> delete(PriceAlert alert) async {
    final before = state.value;
    if (before == null) return;
    state = AsyncData([
      for (final a in before)
        if (a.id != alert.id) a,
    ]);
    try {
      await _repository.deleteAlert(alert.id);
    } on Object {
      state = AsyncData(before);
      rethrow;
    }
  }
}

final priceAlertsNotifierProvider =
    AsyncNotifierProvider.autoDispose<PriceAlertsNotifier, List<PriceAlert>>(
      PriceAlertsNotifier.new,
    );

/// A mensagem para o cliente de um erro ao mexer em alertas.
String priceAlertErrorMessage(Object error) {
  if (error is DbookNetworkException) {
    return switch (error.code) {
      'PRICE_ALERTS_LIMIT' => 'Você já tem 20 alertas ativos. Desligue ou apague algum para criar outro.',
      _ when error is DbookConflictException => 'Você já tem um alerta para esta rota e data. Mude o valor dele em "Alertas de preço".',
      _ when error is DbookUnknownNetworkException =>
        'Sem conexão. Tente de novo quando a rede voltar.',
      _ =>
        'Não foi possível salvar o alerta. Confira os dados e tente de novo.',
    };
  }
  return 'Não foi possível salvar o alerta. Tente de novo.';
}
