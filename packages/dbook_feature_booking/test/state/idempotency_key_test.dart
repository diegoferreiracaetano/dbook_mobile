import 'package:dbook_feature_booking/src/state/idempotency_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given a generated key then it is a valid UUID v4', () {
    final uuidV4 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    expect(generateIdempotencyKey(), matches(uuidV4));
  });

  test('given two generated keys then they are different', () {
    expect(generateIdempotencyKey(), isNot(generateIdempotencyKey()));
  });
}
