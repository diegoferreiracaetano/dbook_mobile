import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given buttons and a tap when built then the divider label renders and '
    'onPressed fires',
    (tester) async {
      var googleTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: DbookSocialLoginRow(
              buttons: [
                DbookSocialLoginButton(
                  icon: Icons.g_mobiledata,
                  label: 'Google',
                  onPressed: () => googleTapCount++,
                ),
                const DbookSocialLoginButton(icon: Icons.apple, label: 'Apple'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('ou continue com'), findsOneWidget);
      expect(find.byTooltip('Google'), findsOneWidget);
      expect(find.byTooltip('Apple'), findsOneWidget);

      await tester.tap(find.byTooltip('Google'));
      expect(googleTapCount, 1);
    },
  );
}
