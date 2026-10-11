import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_feature_admin_customers/src/customer_query_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given the default query when encoding then the URL stays clean', () {
    expect(CustomerQueryCodec.encode(defaultCustomerQuery), isEmpty);
  });

  test('given search, filters and sort when encoding and decoding then they '
      'round trip', () {
    final query = (
      text: 'ana',
      status: CustomerStatus.blocked,
      from: DateTime(2026, 1, 1),
      to: DateTime(2026, 6, 30),
      hasBookings: false,
      sort: CustomerSort.values.last,
      descending: !defaultCustomerQuery.descending,
      page: 4,
      size: 10,
    );

    expect(CustomerQueryCodec.decode(CustomerQueryCodec.encode(query)), query);
  });

  test('given an unknown status and out of range paging when decoding then '
      'uses safe values', () {
    final query = CustomerQueryCodec.decode({
      'status': 'zzz',
      'page': '-1',
      'size': '0',
    });

    expect(query.status, isNull);
    expect(query.page, 0);
    expect(query.size, 1);
  });
}
