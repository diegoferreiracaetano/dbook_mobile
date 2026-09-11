import 'package:dbook_mobile/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given the app when built then the first onboarding slide renders',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: DbookMobileApp()));
      await tester.pump();

      expect(find.text('Discover New Horizons'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    },
  );

  testWidgets(
    'given Next tapped three times when settled then Get Started shows',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: DbookMobileApp()));
      await tester.pump();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Travel Your Way'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
    },
  );
}
