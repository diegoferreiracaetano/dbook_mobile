import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('given the app identity when the session clients are built then both '
      'carry it', () {
    final container = ProviderContainer(
      overrides: [
        baseUrlProvider.overrideWithValue('http://localhost:8080/v1'),
        appClientProvider.overrideWithValue(
          const AppClientInfo(version: '1.0.0+1', platform: 'android'),
        ),
      ],
    );
    addTearDown(container.dispose);

    for (final dio in [
      container.read(dioProvider),
      container.read(authOnlyDioProvider),
    ]) {
      expect(dio.options.headers['X-App-Version'], '1.0.0+1');
      expect(dio.options.headers['X-App-Platform'], 'android');
    }
  });
}
