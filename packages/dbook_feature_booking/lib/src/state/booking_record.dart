import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_record.freezed.dart';

/// Uma reserva feita nesta sessão do app, já enriquecida com o [Flight] e o
/// [Seat] escolhidos — o backend não expõe um "GET /bookings" (só
/// criar/cancelar), então não há como buscar essa lista de novo depois que
/// o app fecha; [BookingRecord] existe só em memória, populado conforme o
/// usuário reserva.
@freezed
abstract class BookingRecord with _$BookingRecord {
  const factory BookingRecord({
    required Booking booking,
    required Flight flight,
    required Seat seat,
  }) = _BookingRecord;
}
