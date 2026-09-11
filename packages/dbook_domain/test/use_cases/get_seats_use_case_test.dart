import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

class _FakeFlightRepository implements FlightRepository {
  int? capturedBookableId;

  @override
  Future<List<Flight>> search({
    required String originIataCode,
    required String destinationIataCode,
    required DateTime date,
  }) async => [];

  @override
  Future<List<Seat>> getSeats(int bookableId) async {
    capturedBookableId = bookableId;
    return const [
      Seat(id: 1, bookableId: 10, label: '3A', status: SeatStatus.available),
    ];
  }
}

void main() {
  test(
    'given a bookable id when called then forwards it and returns its seats',
    () async {
      final repository = _FakeFlightRepository();
      final useCase = GetSeatsUseCase(repository);

      final seats = await useCase(10);

      expect(repository.capturedBookableId, 10);
      expect(seats.single.label, '3A');
    },
  );
}
