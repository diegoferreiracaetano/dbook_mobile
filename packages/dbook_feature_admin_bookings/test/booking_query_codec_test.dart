import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_admin_bookings/dbook_feature_admin_bookings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given an empty query string when decoding then returns the default '
      'query', () {
    expect(BookingQueryCodec.decode({}), defaultBookingQuery);
  });

  test(
    'given the default query when encoding then adds nothing to the URL',
    () {
      expect(BookingQueryCodec.encode(defaultBookingQuery), isEmpty);
    },
  );

  test('given filters when encoding and decoding then they round trip', () {
    final query = (
      status: BookingStatus.confirmed,
      bookableId: 12,
      customerId: 7,
      from: DateTime(2026, 10, 1),
      to: DateTime(2026, 10, 31),
      paid: true,
      page: 3,
      size: 50,
    );

    final params = BookingQueryCodec.encode(query);

    expect(params['status'], 'confirmed');
    expect(params['paid'], 'yes');
    expect(params['from'], '2026-10-01');
    expect(BookingQueryCodec.decode(params), query);
  });

  test('given garbage values when decoding then falls back instead of '
      'throwing', () {
    final query = BookingQueryCodec.decode({
      'status': 'nope',
      'flight': 'abc',
      'page': '-5',
      'size': '9999',
      'paid': 'maybe',
    });

    expect(query.status, isNull);
    expect(query.bookableId, isNull);
    expect(query.paid, isNull);
    expect(query.page, 0);
    expect(query.size, 100);
  });

  test('given a filter change when editing then goes back to page zero', () {
    final onPageFour = BookingQueryEdit.page(defaultBookingQuery, 4);

    final edited = BookingQueryEdit.status(onPageFour, BookingStatus.pending);

    expect(edited.page, 0);
    expect(edited.status, BookingStatus.pending);
    expect(BookingQueryEdit.page(edited, 2).page, 2);
  });
}
