import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';
import 'booking_record.dart';

/// Reservas feitas nesta sessão (veja o porquê em [BookingRecord]) —
/// populada por `SeatSelectionNotifier.confirmBooking` e atualizada por
/// [cancel].
class MyBookingsNotifier extends Notifier<List<BookingRecord>> {
  @override
  List<BookingRecord> build() => const [];

  void add(BookingRecord record) => state = [...state, record];

  /// Deixa o `DbookNetworkException` (403/404/409...) passar pra quem
  /// chamou tratar — é uma ação pontual disparada por um toque de botão,
  /// não um fluxo com estado próprio.
  Future<void> cancel(BookingRecord record) async {
    final updated = await ref
        .read(bookingRepositoryProvider)
        .cancel(record.booking.id);

    state = [
      for (final existing in state)
        if (existing.booking.id == record.booking.id)
          existing.copyWith(booking: updated)
        else
          existing,
    ];
  }
}
