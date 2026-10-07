import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'given widths around each limit when classified then picks the window size',
    () {
      expect(DbookBreakpoints.fromWidth(599.9), DbookWindowSize.compact);
      expect(DbookBreakpoints.fromWidth(600), DbookWindowSize.medium);
      expect(DbookBreakpoints.fromWidth(1023.9), DbookWindowSize.medium);
      expect(DbookBreakpoints.fromWidth(1024), DbookWindowSize.expanded);
    },
  );

  testWidgets(
    'given a 1200dp wide window when read from context then it is expanded',
    (tester) async {
      late DbookWindowSize size;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1200, 800)),
          child: Builder(
            builder: (context) {
              size = DbookBreakpoints.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(size, DbookWindowSize.expanded);
    },
  );
}
