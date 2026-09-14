import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

class _FakeBookingRepository implements BookingRepository {
  int? capturedBookableId;
  int? capturedSeatId;
  int? cancelledBookingId;

  @override
  Future<Booking> create({required int bookableId, required int seatId}) async {
    capturedBookableId = bookableId;
    capturedSeatId = seatId;
    return Booking(
      id: 1,
      bookableId: bookableId,
      seatId: seatId,
      customerId: 5,
      status: BookingStatus.pending,
    );
  }

  @override
  Future<Booking> cancel(int bookingId) async {
    cancelledBookingId = bookingId;
    return Booking(
      id: bookingId,
      bookableId: 10,
      seatId: 100,
      customerId: 5,
      status: BookingStatus.cancelled,
    );
  }

  @override
  Future<List<MyBooking>> listMine() async => [];
}

void main() {
  test('given a seat when registering a booking then forwards params and '
      'returns a pending booking', () async {
    final repository = _FakeBookingRepository();
    final useCase = RegisterBookingUseCase(repository);

    final booking = await useCase(bookableId: 10, seatId: 100);

    expect(repository.capturedBookableId, 10);
    expect(repository.capturedSeatId, 100);
    expect(booking.status, BookingStatus.pending);
  });

  test('given a booking id when cancelling then forwards it and returns it '
      'cancelled', () async {
    final repository = _FakeBookingRepository();
    final useCase = CancelBookingUseCase(repository);

    final booking = await useCase(1);

    expect(repository.cancelledBookingId, 1);
    expect(booking.status, BookingStatus.cancelled);
  });
}
