import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

void main() {
  test(
    'given two bookings with the same fields when compared then they are equal',
    () {
      const a = Booking(
        id: 1,
        bookableId: 10,
        seatId: 100,
        customerId: 5,
        status: BookingStatus.pending,
      );
      const b = Booking(
        id: 1,
        bookableId: 10,
        seatId: 100,
        customerId: 5,
        status: BookingStatus.pending,
      );

      expect(a, b);
    },
  );

  test(
    'given a pending booking when copyWith confirms it then status updates',
    () {
      const pending = Booking(
        id: 1,
        bookableId: 10,
        seatId: 100,
        customerId: 5,
        status: BookingStatus.pending,
      );

      final confirmed = pending.copyWith(status: BookingStatus.confirmed);

      expect(confirmed.status, BookingStatus.confirmed);
      expect(confirmed.id, pending.id);
    },
  );
}
