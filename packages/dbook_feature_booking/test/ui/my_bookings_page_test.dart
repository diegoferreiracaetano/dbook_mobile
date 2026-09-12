import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository({this.error});

  final DbookNetworkException? error;

  @override
  Future<Booking> create({required int bookableId, required int seatId}) {
    throw UnimplementedError();
  }

  @override
  Future<Booking> cancel(int bookingId) async {
    if (error != null) throw error!;
    return Booking(
      id: bookingId,
      bookableId: 1,
      seatId: 1,
      customerId: 7,
      status: BookingStatus.cancelled,
    );
  }
}

const _seat = Seat(
  id: 1,
  bookableId: 1,
  label: '3A',
  status: SeatStatus.available,
);

Flight _flight() => Flight(
  id: 1,
  flightNumber: 'IB 6821',
  originIataCode: 'GRU',
  destinationIataCode: 'MAD',
  departureTime: DateTime(2026, 1, 13, 10, 30),
  arrivalTime: DateTime(2026, 1, 14, 6, 45),
  seatClass: SeatClass.economy,
  price: 450,
  availableCapacity: 12,
);

BookingRecord _record({BookingStatus status = BookingStatus.pending}) =>
    BookingRecord(
      booking: Booking(
        id: 99,
        bookableId: 1,
        seatId: 1,
        customerId: 7,
        status: status,
      ),
      flight: _flight(),
      seat: _seat,
    );

void main() {
  testWidgets('given no bookings when built then shows the empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: DbookTheme.light,
          home: const MyBookingsPage(),
        ),
      ),
    );

    expect(find.text('Nenhuma reserva ainda'), findsOneWidget);
  });

  testWidgets(
    'given a pending booking when built then shows it with a cancel action',
    (tester) async {
      final record = _record();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: DbookTheme.light,
            home: const MyBookingsPage(),
          ),
        ),
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MyBookingsPage)),
      );
      container.read(myBookingsNotifierProvider.notifier).add(record);
      await tester.pump();

      expect(find.text('GRU → MAD'), findsOneWidget);
      expect(find.text('Cancel Booking'), findsOneWidget);
    },
  );

  testWidgets(
    'given a confirmed booking when built then shows no cancel action',
    (tester) async {
      final record = _record(status: BookingStatus.confirmed);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: DbookTheme.light,
            home: const MyBookingsPage(),
          ),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MyBookingsPage)),
      );
      container.read(myBookingsNotifierProvider.notifier).add(record);
      await tester.pump();

      expect(find.text('Cancel Booking'), findsNothing);
    },
  );

  testWidgets(
    'given cancel confirmed when tapped then updates the status shown',
    (tester) async {
      final record = _record();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(
              _FakeBookingRepository(),
            ),
          ],
          child: MaterialApp(
            theme: DbookTheme.light,
            home: const MyBookingsPage(),
          ),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MyBookingsPage)),
      );
      container.read(myBookingsNotifierProvider.notifier).add(record);
      await tester.pump();

      await tester.tap(find.text('Cancel Booking'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel Booking').last);
      await tester.pumpAndSettle();

      expect(find.text('Cancelada'), findsOneWidget);
    },
  );

  testWidgets(
    'given the backend rejects the cancellation then shows a snackbar and '
    'keeps the pending status',
    (tester) async {
      final record = _record();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(
              _FakeBookingRepository(
                error: const DbookForbiddenException('Not your booking'),
              ),
            ),
          ],
          child: MaterialApp(
            theme: DbookTheme.light,
            home: const MyBookingsPage(),
          ),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MyBookingsPage)),
      );
      container.read(myBookingsNotifierProvider.notifier).add(record);
      await tester.pump();

      await tester.tap(find.text('Cancel Booking'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel Booking').last);
      await tester.pumpAndSettle();

      expect(find.text('Not your booking'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
    },
  );
}
