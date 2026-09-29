import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'given a rating of 3 when built then 3 stars are filled and 2 are outlined',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DbookTheme.light,
          home: Scaffold(
            body: DbookRatingStars(rating: 3, onRatingSelected: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    },
  );

  testWidgets('given a tap on the 4th star then onRatingSelected receives 4', (
    tester,
  ) async {
    int? selectedRating;

    await tester.pumpWidget(
      MaterialApp(
        theme: DbookTheme.light,
        home: Scaffold(
          body: DbookRatingStars(
            rating: 0,
            onRatingSelected: (rating) => selectedRating = rating,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(IconButton).at(3));
    expect(selectedRating, 4);
  });
}
