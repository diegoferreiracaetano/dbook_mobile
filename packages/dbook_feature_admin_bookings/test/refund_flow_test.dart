import 'dart:convert';
import 'dart:io';

import 'package:dbook_feature_admin_bookings/dbook_feature_admin_bookings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

Object _fx(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as Object;

void main() {
  refundQueueFlows();

  testWidgets('given a paid booking when refunding then posts with an '
      'Idempotency-Key header', (tester) async {
    final recorder = RecordingDio(
      replies: {
        '/admin/bookings/2': _fx('booking_detail'),
        'POST /admin/bookings/2/refund': {
          'id': 5,
          'bookingId': 2,
          'amount': 1050,
          'status': 'COMPLETED',
        },
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: BookingDetailPage(id: 2, onBack: () {}, onOpenCustomer: (_) {}),
    );

    await tester.tap(find.text('Reembolsar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reembolsar').last);
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/bookings/2/refund').toList();
    expect(posts, hasLength(1));
    expect(posts.single.headers['Idempotency-Key'], isNotEmpty);
    expect((posts.single.data as Map)['reason'], isNotEmpty);
  });
}

void refundQueueFlows() {
  Map<String, Object> failedRefund(String status) => {
    'items': [
      {
        'id': 3,
        'bookingId': 2,
        'amount': 1050,
        'status': status,
        'paymentId': 1,
        'reason': 'CUSTOMER_REQUEST',
        'failureReason': 'Gateway fora do ar',
        'createdAt': '2026-10-09T20:00:00Z',
      },
    ],
    'page': 0,
    'size': 20,
    'totalElements': 1,
    'totalPages': 1,
  };

  testWidgets('given a failed refund when retrying then posts the retry', (
    tester,
  ) async {
    final recorder = RecordingDio(
      replies: {'GET /admin/refunds': failedRefund('FAILED')},
    );
    var opened = 0;
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: RefundsPage(
        query: (status: null, page: 0, size: 20),
        onQueryChanged: (_) {},
        onOpenBooking: (id) => opened = id,
      ),
    );

    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/refunds/3/retry'), hasLength(1));
    expect(opened, 0);
  });

  testWidgets('given a refund when opening its booking then navigates', (
    tester,
  ) async {
    final recorder = RecordingDio(
      replies: {'GET /admin/refunds': failedRefund('COMPLETED')},
    );
    var opened = 0;
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: RefundsPage(
        query: (status: null, page: 0, size: 20),
        onQueryChanged: (_) {},
        onOpenBooking: (id) => opened = id,
      ),
    );

    expect(find.text('Tentar de novo'), findsNothing);
    await tester.tap(find.text('#2').first);
    await tester.pumpAndSettle();

    expect(opened, 2);
  });

  testWidgets('given the window closed when refunding then shows the policy '
      'conflict and offers no second charge', (tester) async {
    final recorder = RecordingDio(
      replies: {'/admin/bookings/2': _fx('booking_detail')},
      failures: {
        'POST /admin/bookings/2/refund': (
          status: 409,
          body: {'error': 'closed', 'code': 'REFUND_WINDOW_CLOSED'},
        ),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: BookingDetailPage(id: 2, onBack: () {}, onOpenCustomer: (_) {}),
    );

    await tester.tap(find.text('Reembolsar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reembolsar').last);
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/bookings/2/refund'), hasLength(1));
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
