import 'package:dbook_mobile/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'given a real device/emulator when the app launches then the first '
    'onboarding slide renders and Next advances to the second slide',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: DbookMobileApp()));
      await tester.pumpAndSettle();

      expect(find.text('Discover New Horizons'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Best Prices Everytime'), findsOneWidget);
    },
  );
}
