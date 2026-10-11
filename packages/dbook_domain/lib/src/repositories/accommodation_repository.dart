import '../entities/accommodation.dart';

/// Porta dos hotéis: busca e detalhe são públicos; reservar exige sessão.
abstract interface class AccommodationRepository {
  Future<List<AccommodationResult>> search(StaySearch search);

  Future<AccommodationDetail> detail(int id);

  /// Cria a reserva (`PENDING` por 15 min, como um assento) e devolve o id
  /// dela, que o pagamento usa. `409 ROOM_UNAVAILABLE` quando uma noite
  /// encheu entre a busca e o toque.
  Future<int> book({
    required int accommodationId,
    required int roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  });

  Future<List<StayBooking>> myStays();
}
