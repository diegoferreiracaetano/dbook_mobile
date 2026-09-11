import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

void main() {
  test('given every backend SeatClass value when parsed then all decode', () {
    expect(seatClassFromWire('ECONOMY'), SeatClass.economy);
    expect(seatClassFromWire('PREMIUM_ECONOMY'), SeatClass.premiumEconomy);
    expect(seatClassFromWire('BUSINESS'), SeatClass.business);
    expect(seatClassFromWire('FIRST'), SeatClass.first);
  });

  test(
    'given every backend BookingStatus value when parsed then all decode',
    () {
      expect(bookingStatusFromWire('PENDING'), BookingStatus.pending);
      expect(bookingStatusFromWire('CONFIRMED'), BookingStatus.confirmed);
      expect(bookingStatusFromWire('CANCELLED'), BookingStatus.cancelled);
    },
  );

  test('given an unknown value when parsed then throws FormatException', () {
    expect(() => seatClassFromWire('ECONOMY_PLUS'), throwsFormatException);
  });
}
