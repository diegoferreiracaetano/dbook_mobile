import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('given only initials when built then renders the initials text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: const Scaffold(body: DbookAvatar(initials: 'DC')),
      ),
    );

    expect(find.text('DC'), findsOneWidget);
  });

  testWidgets(
    'given large size when built then renders a bigger CircleAvatar than small',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: const Scaffold(
            body: Row(
              children: [
                DbookAvatar(initials: 'A', size: DbookAvatarSize.small),
                DbookAvatar(initials: 'B', size: DbookAvatarSize.large),
              ],
            ),
          ),
        ),
      );

      final avatars = tester
          .widgetList<CircleAvatar>(find.byType(CircleAvatar))
          .toList();

      expect(avatars[0].radius, lessThan(avatars[1].radius!));
    },
  );

  testWidgets('given custom colors when built then uses them instead of the '
      'theme container colors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.dark,
        home: const Scaffold(
          body: DbookAvatar(
            initials: 'MA',
            backgroundColor: Color(0xFFFFFFFF),
            foregroundColor: Color(0xFF074599),
          ),
        ),
      ),
    );

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundColor, const Color(0xFFFFFFFF));
    expect(avatar.foregroundColor, const Color(0xFF074599));
  });
}
