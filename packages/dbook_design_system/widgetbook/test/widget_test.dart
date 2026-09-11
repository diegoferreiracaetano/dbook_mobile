import 'package:dbook_design_system_widgetbook/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given the widgetbook app when built then it renders without errors',
    (tester) async {
      await tester.pumpWidget(const DbookWidgetbook());
      await tester.pumpAndSettle();

      expect(find.byType(DbookWidgetbook), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
