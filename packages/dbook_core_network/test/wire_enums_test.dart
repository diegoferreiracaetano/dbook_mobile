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

  test(
    'given an unknown value when parsed then it is unknown and is reported',
    () {
      final reported = <String>[];
      onUnknownWireValue = (enumName, value) =>
          reported.add('$enumName:$value');

      expect(seatClassFromWire('ECONOMY_PLUS'), SeatClass.unknown);
      expect(bookingStatusFromWire('REFUNDED'), BookingStatus.unknown);
      expect(reported, ['SeatClass:ECONOMY_PLUS', 'BookingStatus:REFUNDED']);

      onUnknownWireValue = (_, _) {};
    },
  );

  test('given every backend Role value when parsed then all decode', () {
    expect(roleFromWire('CLIENT'), Role.client);
    expect(roleFromWire('SUPPORT'), Role.support);
    expect(roleFromWire('CATALOG_MANAGER'), Role.catalogManager);
    expect(roleFromWire('SUPER_ADMIN'), Role.superAdmin);
  });

  test('given permissions with an unknown one when parsed then it is dropped '
      'and reported', () {
    final reported = <String>[];
    onUnknownWireValue = (enumName, value) => reported.add('$enumName:$value');

    final permissions = permissionsFromWire([
      'FLIGHT_WRITE',
      'AUDIT_READ',
      'TIME_TRAVEL',
    ]);

    expect(permissions, {Permission.flightWrite, Permission.auditRead});
    expect(reported, ['Permission:TIME_TRAVEL']);

    onUnknownWireValue = (_, _) {};
  });
}
