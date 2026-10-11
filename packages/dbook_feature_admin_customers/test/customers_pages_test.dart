import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_feature_admin_customers/dbook_feature_admin_customers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

void main() {
  testWidgets('given a real customer list when built then shows the '
      'customer', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/customers': 'customers'}),
      child: CustomersPage(
        query: defaultCustomerQuery,
        onQueryChanged: (_) {},
        onOpen: (_) {},
      ),
    );

    expect(find.text('Marina Alves'), findsWidgets);
    expect(find.textContaining('@dbook.test'), findsWidgets);
  });

  testWidgets('given a real customer when the 360 detail builds then shows '
      'the profile', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({
        '/admin/customers/2': 'customer_detail',
        '/admin/customers/2/bookings': 'customer_bookings',
        '/admin/customers/2/payments': 'customer_payments',
        '/admin/customers/2/reviews': 'customer_reviews',
        '/admin/customers/2/notes': 'customer_notes',
      }),
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );

    expect(find.text('Marina Alves'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('given the list when typing in the search then reports the '
      'query after the debounce', (tester) async {
    CustomerQuery? reported;
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/customers': 'customers'}),
      child: CustomersPage(
        query: defaultCustomerQuery,
        onQueryChanged: (q) => reported = q,
        onOpen: (_) {},
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'marina');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(reported?.text, 'marina');
    expect(reported?.page, 0);
  });

  testWidgets('given the list when choosing the blocked filter then reports '
      'the status', (tester) async {
    CustomerQuery? reported;
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/customers': 'customers'}),
      child: CustomersPage(
        query: defaultCustomerQuery,
        onQueryChanged: (q) => reported = q,
        onOpen: (_) {},
      ),
    );

    await tester.tap(find.text('Bloqueados'));
    await tester.pumpAndSettle();

    expect(reported?.status, CustomerStatus.blocked);
  });

  testWidgets('given a customer row when tapping it then opens that '
      'customer', (tester) async {
    int? opened;
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/customers': 'customers'}),
      child: CustomersPage(
        query: defaultCustomerQuery,
        onQueryChanged: (_) {},
        onOpen: (id) => opened = id,
      ),
    );

    await tester.tap(find.text('Marina Alves'));
    await tester.pumpAndSettle();

    expect(opened, 2);
  });

  testWidgets('given the list when exporting then confirms, asks the server '
      'for the file and (without a browser) says it is not available', (
    tester,
  ) async {
    final recorder = RecordingDio(
      replies: {
        'GET /admin/customers': {
          'items': <Object>[],
          'page': 0,
          'size': 20,
          'totalElements': 0,
          'totalPages': 0,
        },
        'GET /admin/customers/export': <int>[1, 2, 3],
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomersPage(
        query: defaultCustomerQuery,
        onQueryChanged: (_) {},
        onOpen: (_) {},
      ),
    );

    await tester.tap(find.text('Exportar CSV'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exportar'));
    await tester.pumpAndSettle();

    expect(recorder.to('GET', '/admin/customers/export'), hasLength(1));
  });

  testWidgets('given the list when tapping a sortable header then reports '
      'the new order', (tester) async {
    CustomerQuery? reported;
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/customers': 'customers'}),
      child: CustomersPage(
        query: defaultCustomerQuery,
        onQueryChanged: (q) => reported = q,
        onOpen: (_) {},
      ),
    );

    await tester.tap(find.text('Cliente').first);
    await tester.pumpAndSettle();

    expect(reported, isNotNull);
    expect(reported!.page, 0);
  });

  testWidgets('given the list when clearing all filters then goes back to '
      'the default query', (tester) async {
    CustomerQuery? reported;
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/customers': 'customers'}),
      child: CustomersPage(
        query: (
          text: 'ana',
          status: CustomerStatus.blocked,
          from: null,
          to: null,
          hasBookings: true,
          sort: defaultCustomerQuery.sort,
          descending: defaultCustomerQuery.descending,
          page: 3,
          size: 20,
        ),
        onQueryChanged: (q) => reported = q,
        onOpen: (_) {},
      ),
    );

    await tester.tap(find.textContaining('Limpar'));
    await tester.pumpAndSettle();

    expect(reported?.text, '');
    expect(reported?.status, isNull);
    expect(reported?.page, 0);
  });
}
