import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_flights/dbook_feature_flights.dart';
import 'package:dbook_feature_flights/src/state/destination_reviews_notifier.dart'
    show destinationReviewRepositoryProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/mock_network_image.dart';

const _destination = Destination(
  iataCode: 'GIG',
  city: 'Rio de Janeiro',
  country: 'Brasil',
  photoUrl: 'https://example.com/gig.jpg',
  region: 'América do Sul',
  isPopular: true,
);

PublicReview _review(int id, int rating, String comment) => PublicReview(
  id: id,
  rating: rating,
  comment: comment,
  author: 'Marina',
  edited: false,
);

class _FakeReviews implements DestinationReviewRepository {
  var items = [
    _review(1, 5, 'Cidade incrível'),
    _review(2, 3, 'Trânsito pesado'),
  ];
  final sorts = <ReviewSort>[];
  final deleted = <int>[];
  final edited = <(int, int?, String?)>[];
  final reported = <(int, String)>[];
  Object? deleteError;

  @override
  Future<DestinationReviews> list(
    String iataCode, {
    ReviewSort sort = ReviewSort.recent,
    int page = 0,
    int size = 10,
  }) async {
    sorts.add(sort);
    return DestinationReviews(
      summary: ReviewSummary(
        average: 4,
        total: items.length,
        distribution: const {1: 0, 2: 0, 3: 1, 4: 0, 5: 1},
      ),
      page: PublicReviewPage(
        items: items,
        page: 0,
        totalPages: 1,
        totalElements: items.length,
      ),
    );
  }

  @override
  Future<void> edit(int reviewId, {int? rating, String? comment}) async {
    edited.add((reviewId, rating, comment));
  }

  @override
  Future<void> delete(int reviewId) async {
    if (deleteError != null) throw deleteError!;
    deleted.add(reviewId);
    items = items.where((r) => r.id != reviewId).toList();
  }

  @override
  Future<void> report(int reviewId, String reason) async {
    reported.add((reviewId, reason));
  }
}

Widget _app(_FakeReviews fake, {bool loggedIn = false, Set<int>? own}) =>
    ProviderScope(
      overrides: [
        destinationReviewRepositoryProvider.overrideWithValue(fake),
        isLoggedInProvider.overrideWithValue(loggedIn),
        ownReviewIdsProvider.overrideWithValue(own ?? const {}),
      ],
      child: MaterialApp(
        theme: DbookTheme.light,
        home: const DestinationDetailPage(destination: _destination),
      ),
    );

void main() {
  testWidgetsWithMockImages(
    'given public reviews when the page builds then lists the comments',
    (tester) async {
      await tester.pumpWidget(_app(_FakeReviews()));
      await tester.pumpAndSettle();

      expect(find.text('Cidade incrível'), findsOneWidget);
      expect(find.text('Trânsito pesado'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given the sort chips when choosing best rated then reloads with that '
    'sort',
    (tester) async {
      final fake = _FakeReviews();
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Melhores notas'));
      await tester.pumpAndSettle();

      expect(fake.sorts.last, isNot(ReviewSort.recent));
    },
  );

  testWidgetsWithMockImages(
    'given no reviews when the page builds then shows the empty state',
    (tester) async {
      final fake = _FakeReviews()..items = [];
      await tester.pumpWidget(_app(fake));
      await tester.pumpAndSettle();

      expect(find.text('Ainda sem avaliações'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given my own review when deleting it after confirming then the server '
    'is told and it leaves the list',
    (tester) async {
      final fake = _FakeReviews();
      await tester.pumpWidget(_app(fake, loggedIn: true, own: {1}));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mais ações').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apagar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apagar').last);
      await tester.pumpAndSettle();
      // a janela de "Desfazer" passa antes de apagar no servidor
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      expect(fake.deleted, [1]);
      expect(find.text('Cidade incrível'), findsNothing);
    },
  );

  testWidgetsWithMockImages(
    'given my own review when editing the comment then sends only what '
    'changed',
    (tester) async {
      final fake = _FakeReviews();
      await tester.pumpWidget(_app(fake, loggedIn: true, own: {1}));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mais ações').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Cidade incrível, voltarei',
      );
      await tester.pump();
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(fake.edited, hasLength(1));
      expect(fake.edited.single.$1, 1);
      expect(fake.edited.single.$3, 'Cidade incrível, voltarei');
    },
  );

  testWidgetsWithMockImages(
    "given someone else's review when reporting with a reason then sends "
    'the report',
    (tester) async {
      final fake = _FakeReviews();
      await tester.pumpWidget(_app(fake, loggedIn: true, own: {1}));
      await tester.pumpAndSettle();

      // a 2ª avaliação é de outra pessoa
      await tester.tap(find.byTooltip('Mais ações').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Denunciar'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Conteúdo ofensivo');
      await tester.pump();
      await tester.tap(find.widgetWithText(DbookButton, 'Denunciar'));
      await tester.pumpAndSettle();

      expect(fake.reported, [(2, 'Conteúdo ofensivo')]);
    },
  );
}
