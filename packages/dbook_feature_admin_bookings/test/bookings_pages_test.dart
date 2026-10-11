import 'dart:convert';
import 'dart:io';

import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_feature_admin_bookings/dbook_feature_admin_bookings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

void main() {
  testWidgets('given real bookings when the list builds then shows flight '
      'and hotel with the customer', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/bookings': 'bookings'}),
      child: BookingsPage(
        query: defaultBookingQuery,
        onQueryChanged: (_) {},
        onOpen: (_) {},
      ),
    );

    expect(find.text('Hotel Copacabana'), findsWidgets);
    expect(find.text('Marina Alves'), findsWidgets);
  });

  testWidgets('given a real booking when the detail builds then shows the '
      'stay, payment and timeline', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/bookings/2': 'booking_detail'}),
      child: BookingDetailPage(id: 2, onBack: () {}, onOpenCustomer: (_) {}),
    );

    expect(find.text('Hotel Copacabana'), findsWidgets);
    expect(find.textContaining('4242'), findsWidgets);
  });

  testWidgets('given no refunds when the queue builds then it is empty '
      'without errors', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/refunds': 'refunds'}),
      child: RefundsPage(
        query: (status: null, page: 0, size: 20),
        onQueryChanged: (_) {},
        onOpenBooking: (_) {},
      ),
    );

    expect(find.byType(RefundsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('given the list when choosing paid only then reports the '
      'filter', (tester) async {
    AdminBookingQuery? reported;
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/bookings': 'bookings'}),
      child: BookingsPage(
        query: defaultBookingQuery,
        onQueryChanged: (q) => reported = q,
        onOpen: (_) {},
      ),
    );

    await tester.tap(find.text('Pagas'));
    await tester.pumpAndSettle();

    expect(reported?.paid, isTrue);
  });

  testWidgets('given a booking row when tapping it then opens it', (
    tester,
  ) async {
    int? opened;
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/bookings': 'bookings'}),
      child: BookingsPage(
        query: defaultBookingQuery,
        onQueryChanged: (_) {},
        onOpen: (id) => opened = id,
      ),
    );

    await tester.tap(find.text('Hotel Copacabana').first);
    await tester.pumpAndSettle();

    expect(opened, 2);
  });

  testWidgets('given a pending booking when cancelling after confirming then '
      'posts the cancel', (tester) async {
    final detail = jsonDecode(
      File('test/fixtures/booking_detail.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    (detail['booking'] as Map<String, dynamic>)['status'] = 'PENDING';
    detail['payment'] = null;
    final recorder = RecordingDio(replies: {'GET /admin/bookings/2': detail});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: BookingDetailPage(id: 2, onBack: () {}, onOpenCustomer: (_) {}),
    );

    await tester.tap(find.text('Cancelar reserva').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar reserva').last);
    await tester.pumpAndSettle();

    final posts = recorder.calls
        .where((c) => c.method == 'POST' && c.path.contains('/cancel'))
        .toList();
    expect(posts, hasLength(1));
  });

  testWidgets('given a booking when opening its customer then navigates', (
    tester,
  ) async {
    int? opened;
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/bookings/2': 'booking_detail'}),
      child: BookingDetailPage(
        id: 2,
        onBack: () {},
        onOpenCustomer: (id) => opened = id,
      ),
    );

    await tester.ensureVisible(find.byType(TextButton).first);
    await tester.tap(find.byType(TextButton).first);
    await tester.pumpAndSettle();

    expect(opened, 2);
  });

  Map<String, dynamic> detailWith({
    String status = 'CONFIRMED',
    Map<String, dynamic>? refund,
  }) {
    final detail = jsonDecode(
      File('test/fixtures/booking_detail.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    (detail['booking'] as Map<String, dynamic>)['status'] = status;
    detail['refund'] = refund;
    return detail;
  }

  Map<String, dynamic> refundJson(String status) => {
    'id': 5,
    'bookingId': 2,
    'paymentId': 1,
    'amount': 1050.0,
    'status': status,
    'reason': 'CUSTOMER_REQUEST',
    'failureReason': status == 'FAILED' ? 'gateway' : null,
    'requestedBy': 1,
    'createdAt': '2026-10-09T23:40:00Z',
    'completedAt': status == 'COMPLETED' ? '2026-10-09T23:41:00Z' : null,
  };

  testWidgets('given a failed refund when retrying then posts the retry', (
    tester,
  ) async {
    final recorder = RecordingDio(
      replies: {
        'GET /admin/bookings/2': detailWith(refund: refundJson('FAILED')),
        'POST /admin/refunds/5/retry': refundJson('COMPLETED'),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: BookingDetailPage(id: 2, onBack: () {}, onOpenCustomer: (_) {}),
    );

    await tester.ensureVisible(find.text('Tentar de novo'));
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(
      recorder.calls.where((c) => c.method == 'POST'),
      hasLength(1),
    );
  });

  testWidgets('given a failed retry when tapping it then shows the error '
      'and keeps the page', (tester) async {
    final recorder = RecordingDio(
      replies: {
        'GET /admin/bookings/2': detailWith(refund: refundJson('FAILED')),
      },
      failures: {
        'POST /admin/refunds/5/retry': (
          status: 409,
          body: {'error': 'Já reembolsado'},
        ),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: BookingDetailPage(id: 2, onBack: () {}, onOpenCustomer: (_) {}),
    );

    await tester.ensureVisible(find.text('Tentar de novo'));
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(find.text('O reembolso falhou'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('given a refunded booking when it builds then shows the refund '
      'block', (tester) async {
    final recorder = RecordingDio(
      replies: {
        'GET /admin/bookings/2': detailWith(
          status: 'CANCELLED',
          refund: refundJson('COMPLETED'),
        ),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: BookingDetailPage(id: 2, onBack: () {}, onOpenCustomer: (_) {}),
    );

    expect(find.text('Tentar de novo'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('given a rejected cancel when confirming then shows the error', (
    tester,
  ) async {
    final recorder = RecordingDio(
      replies: {
        'GET /admin/bookings/2': detailWith(status: 'PENDING')
          ..['payment'] = null,
      },
      failures: {
        'POST /admin/bookings/2/cancel': (
          status: 409,
          body: {'error': 'Reserva já paga'},
        ),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: BookingDetailPage(id: 2, onBack: () {}, onOpenCustomer: (_) {}),
    );

    await tester.tap(find.text('Cancelar reserva').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar reserva').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
