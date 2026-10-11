import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _booking = MyBooking(
  id: 5,
  status: BookingStatus.confirmed,
  flight: Flight(
    id: 1,
    flightNumber: 'DB1001',
    airlineIataCode: 'LA',
    airlineName: 'LATAM',
    originIataCode: 'GRU',
    destinationIataCode: 'GIG',
    departureTime: DateTime(2027, 1, 15, 8),
    arrivalTime: DateTime(2027, 1, 15, 9, 10),
    seatClass: SeatClass.economy,
    price: 900,
    availableCapacity: 30,
    aircraftType: 'Airbus A320',
    seatLayout: const [3, 3],
  ),
  seat: const Seat(
    id: 1,
    bookableId: 1,
    label: '3A',
    status: SeatStatus.available,
  ),
);

class _Refunds implements RefundRepository {
  _Refunds(this.policyToReturn, {this.result});

  final CancellationPolicy policyToReturn;
  final RefundRequestResult? result;

  @override
  Future<CancellationPolicy> policy(int bookingId) async => policyToReturn;

  @override
  Future<RefundRequestResult> request(
    int bookingId, {
    required String idempotencyKey,
  }) async => result!;
}

Widget _app(_Refunds fake) => ProviderScope(
  overrides: [refundRepositoryProvider.overrideWithValue(fake)],
  child: MaterialApp(
    theme: DbookTheme.light,
    home: Scaffold(body: CancellationSheet(booking: _booking)),
  ),
);

CancellationPolicy _refundable() => CancellationPolicy(
  bookingId: 5,
  action: CancellationAction.refundRequest,
  refundAmount: 900,
  refundableUntil: DateTime(2027, 1, 14, 8),
);

void main() {
  testWidgets('given a paid booking when the sheet opens then shows the '
      'amount and the deadline from the server', (tester) async {
    await tester.pumpWidget(_app(_Refunds(_refundable())));
    await tester.pumpAndSettle();

    expect(find.textContaining('reembolsado em'), findsOneWidget);
    expect(find.textContaining('Você pode pedir até'), findsOneWidget);
    expect(find.text('Pedir reembolso'), findsOneWidget);
  });

  testWidgets('given a completed refund when confirming then says the money '
      'went back', (tester) async {
    await tester.pumpWidget(
      _app(
        _Refunds(
          _refundable(),
          result: const RefundRequestResult(
            bookingId: 5,
            amount: 900,
            status: RefundProgress.completed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pedir reembolso'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Reembolso concluído'), findsOneWidget);
  });

  testWidgets('given a refund that failed when confirming then says the '
      'money did not leave and offers retry', (tester) async {
    await tester.pumpWidget(
      _app(
        _Refunds(
          _refundable(),
          result: const RefundRequestResult(
            bookingId: 5,
            amount: 900,
            status: RefundProgress.failed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pedir reembolso'));
    await tester.pumpAndSettle();

    expect(find.textContaining('o dinheiro não saiu'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('given a refund in progress when confirming then says it is '
      'on its way', (tester) async {
    await tester.pumpWidget(
      _app(
        _Refunds(
          _refundable(),
          result: const RefundRequestResult(
            bookingId: 5,
            amount: 900,
            status: RefundProgress.requested,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pedir reembolso'));
    await tester.pumpAndSettle();

    expect(find.textContaining('em andamento'), findsOneWidget);
  });

  testWidgets('given a closed window when the sheet opens then explains it '
      'and offers only to close', (tester) async {
    await tester.pumpWidget(
      _app(
        _Refunds(
          const CancellationPolicy(
            bookingId: 5,
            action: CancellationAction.none,
            blockedBy: CancellationBlock.windowClosed,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('menos de 24 horas'), findsOneWidget);
    expect(find.text('Pedir reembolso'), findsNothing);
    expect(find.text('Fechar'), findsOneWidget);
  });

  testWidgets('given a refund already done when the sheet opens then says '
      'so', (tester) async {
    await tester.pumpWidget(
      _app(
        _Refunds(
          const CancellationPolicy(
            bookingId: 5,
            action: CancellationAction.none,
            blockedBy: CancellationBlock.alreadyRefunded,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('já foi reembolsada'), findsOneWidget);
  });
}
