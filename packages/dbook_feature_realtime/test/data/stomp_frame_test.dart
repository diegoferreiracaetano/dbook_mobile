import 'package:dbook_feature_realtime/dbook_feature_realtime.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given a frame with headers and body when serialized then matches the '
      'STOMP wire format', () {
    const frame = StompFrame('SUBSCRIBE', {
      'id': 'sub-0',
      'destination': '/topic/bookables/1/availability',
    }, '');

    expect(
      frame.serialize(),
      'SUBSCRIBE\n'
      'id:sub-0\n'
      'destination:/topic/bookables/1/availability\n'
      '\n'
      '\x00',
    );
  });

  test(
    'given a raw CONNECTED frame when parsed then extracts command and headers',
    () {
      const raw = 'CONNECTED\nversion:1.2\n\n\x00';

      final frame = StompFrame.parse(raw);

      expect(frame.command, 'CONNECTED');
      expect(frame.headers, {'version': '1.2'});
      expect(frame.body, isEmpty);
    },
  );

  test('given a raw MESSAGE frame with a JSON body when parsed then keeps the body intact', () {
    const raw =
        'MESSAGE\n'
        'destination:/topic/bookables/1/availability\n'
        'content-type:application/json\n'
        '\n'
        '{"bookableId":1,"availableCapacity":4}\x00';

    final frame = StompFrame.parse(raw);

    expect(frame.command, 'MESSAGE');
    expect(frame.headers['destination'], '/topic/bookables/1/availability');
    expect(frame.body, '{"bookableId":1,"availableCapacity":4}');
  });

  test('given a raw frame without a trailing null byte when parsed then still works', () {
    const raw = 'ERROR\nmessage:bad token\n\ninvalid credentials';

    final frame = StompFrame.parse(raw);

    expect(frame.command, 'ERROR');
    expect(frame.headers['message'], 'bad token');
    expect(frame.body, 'invalid credentials');
  });

  test('given a frame round-tripped through serialize and parse then survives intact', () {
    const original = StompFrame('CONNECT', {
      'accept-version': '1.2',
      'heart-beat': '0,0',
      'Authorization': 'Bearer access-token',
    }, '');

    final parsed = StompFrame.parse(original.serialize());

    expect(parsed.command, original.command);
    expect(parsed.headers, original.headers);
    expect(parsed.body, original.body);
  });
}
