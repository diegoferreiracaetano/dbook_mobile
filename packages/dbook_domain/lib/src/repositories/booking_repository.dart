import '../entities/booking.dart';
import '../entities/my_booking.dart';

/// Porta pro ciclo de vida de uma reserva.
abstract interface class BookingRepository {
  /// `POST /bookings` — `customerId` vem do JWT no backend, não é passado
  /// aqui.
  Future<Booking> create({required int bookableId, required int seatId});

  /// `POST /bookings/{id}/cancel` — só o dono ou um ADMIN pode cancelar
  /// (o backend retorna 403 caso contrário).
  Future<Booking> cancel(int bookingId);

  /// `GET /bookings` — todas as reservas do usuário autenticado
  /// ("minhas viagens"), cada uma já com o `Flight`/`Seat` completos.
  Future<List<MyBooking>> listMine();
}
