import 'package:dbook_core_storage/dbook_core_storage.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test(
    'given no saved session when reading tokens then returns null',
    () async {
      final storage = SecureTokenStorage();

      expect(await storage.readTokens(), isNull);
    },
  );

  test(
    'given saved tokens when read back then returns the same pair',
    () async {
      final storage = SecureTokenStorage();
      const tokens = AuthTokens(accessToken: 'access', refreshToken: 'refresh');

      await storage.saveTokens(tokens);
      final read = await storage.readTokens();

      expect(read, tokens);
    },
  );

  test(
    'given saved tokens when cleared then reading tokens returns null again',
    () async {
      final storage = SecureTokenStorage();
      await storage.saveTokens(
        const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
      );

      await storage.clear();

      expect(await storage.readTokens(), isNull);
    },
  );
}
