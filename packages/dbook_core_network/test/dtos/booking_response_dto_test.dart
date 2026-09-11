import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

void main() {
  test('given a confirmed booking JSON when mapped then status decodes', () {
    final dto = BookingResponseDto.fromJson({
      'id': 1,
      'bookableId': 10,
      'seatId': 100,
      'customerId': 5,
      'status': 'CONFIRMED',
    });

    final booking = dto.toDomain();

    expect(booking.status, BookingStatus.confirmed);
    expect(booking.bookableId, 10);
  });

  test(
    'given a null bookableId when mapped to domain then throws StateError',
    () {
      final dto = BookingResponseDto.fromJson({
        'id': 1,
        'bookableId': null,
        'seatId': 100,
        'customerId': 5,
        'status': 'PENDING',
      });

      expect(dto.toDomain, throwsStateError);
    },
  );
}
