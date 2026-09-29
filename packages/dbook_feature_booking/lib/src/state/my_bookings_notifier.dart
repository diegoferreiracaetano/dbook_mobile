import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';

/// Reservas do usuário autenticado — busca via `GET /bookings` (não é mais
/// só o que foi reservado nesta sessão). `build()` roda de novo sempre que
/// o provider for invalidado (depois de reservar, em [cancel], ou num
/// pull-to-refresh da tela).
class MyBookingsNotifier extends AsyncNotifier<List<MyBooking>> {
  @override
  Future<List<MyBooking>> build() {
    return ref.read(bookingRepositoryProvider).listMine();
  }

  /// Deixa o `DbookNetworkException` (403/404/409...) passar pra quem
  /// chamou tratar — é uma ação pontual disparada por um toque de botão,
  /// não um fluxo com estado próprio. Só re-busca a lista se o cancelamento
  /// realmente der certo.
  Future<void> cancel(int bookingId) async {
    await ref.read(bookingRepositoryProvider).cancel(bookingId);
    ref.invalidateSelf();
    await future;
  }

  /// Deixa o `DbookNetworkException` (400/403/404/409...) passar pra quem
  /// chamou tratar — mesma ideia do [cancel]. Não invalida a lista: o
  /// backend não devolve "já avaliada" no `GET /bookings`, então não tem
  /// nada novo pra re-buscar depois de avaliar.
  Future<void> review(
    int bookingId, {
    required int rating,
    required String comment,
  }) {
    return ref
        .read(reviewRepositoryProvider)
        .create(bookingId: bookingId, rating: rating, comment: comment);
  }
}
