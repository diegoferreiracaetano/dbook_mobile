import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_feature_admin_catalog/dbook_feature_admin_catalog.dart';
import 'package:dbook_feature_admin_catalog/src/csv_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given filters when encoding and decoding a flight query then they '
      'round trip', () {
    final query = (
      origin: 'GRU',
      destination: 'LIS',
      airline: 'LA',
      departureFrom: DateTime(2026, 11, 1),
      departureTo: DateTime(2026, 11, 30),
      status: FlightStatus.scheduled,
      page: 2,
      size: 50,
    );

    expect(FlightQueryCodec.decode(FlightQueryCodec.encode(query)), query);
  });

  test('given the default flight query when encoding then the URL stays '
      'clean', () {
    expect(FlightQueryCodec.encode(defaultFlightQuery), isEmpty);
  });

  test('given a quoted cell with a comma and an escaped quote when parsing '
      'a csv then keeps it as one cell', () {
    final rows = parseCsv('a,"b,c","d ""e"""\r\n1,2,3\n');

    expect(rows, [
      ['a', 'b,c', 'd "e"'],
      ['1', '2', '3'],
    ]);
  });

  test('given blank lines and no trailing newline when parsing a csv then '
      'skips the blanks and keeps the last row', () {
    expect(parseCsv('x,y\n\nz,w'), [
      ['x', 'y'],
      ['z', 'w'],
    ]);
  });
}
