import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/mock_network_image.dart';

class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository({List<MyBooking> initial = const [], this.cancelError})
    : _bookings = {for (final booking in initial) booking.id: booking};

  final DbookNetworkException? cancelError;
  final Map<int, MyBooking> _bookings;

  @override
  Future<Booking> create({required int bookableId, required int seatId}) {
    throw UnimplementedError();
  }

  @override
  Future<Booking> cancel(int bookingId) async {
    if (cancelError != null) throw cancelError!;
    final current = _bookings[bookingId]!;
    _bookings[bookingId] = current.copyWith(status: BookingStatus.cancelled);
    return Booking(
      id: bookingId,
      bookableId: current.flight.id,
      seatId: current.seat.id,
      customerId: 7,
      status: BookingStatus.cancelled,
    );
  }

  @override
  Future<List<MyBooking>> listMine() async => _bookings.values.toList();
}

const _seat = Seat(
  id: 1,
  bookableId: 1,
  label: '3A',
  status: SeatStatus.available,
);

final _future = DateTime.now().add(const Duration(days: 30));
final _past = DateTime.now().subtract(const Duration(days: 30));

Flight _flight({DateTime? departureTime, String destinationIataCode = 'MAD'}) =>
    Flight(
      id: 1,
      flightNumber: 'IB 6821',
      airlineIataCode: 'IB',
      airlineName: 'Iberia',
      originIataCode: 'GRU',
      destinationIataCode: destinationIataCode,
      departureTime: departureTime ?? _future,
      arrivalTime: (departureTime ?? _future).add(const Duration(hours: 3)),
      seatClass: SeatClass.economy,
      price: 450,
      availableCapacity: 12,
      aircraftType: 'Airbus A320',
      seatLayout: const [3, 3],
    );

MyBooking _myBooking({
  int id = 99,
  BookingStatus status = BookingStatus.pending,
  DateTime? departureTime,
  String destinationIataCode = 'MAD',
}) => MyBooking(
  id: id,
  status: status,
  flight: _flight(
    departureTime: departureTime,
    destinationIataCode: destinationIataCode,
  ),
  seat: _seat,
);

/// Reserva ainda não paga: o servidor responde "é só cancelar".
class _FakeRefundRepository implements RefundRepository {
  @override
  Future<CancellationPolicy> policy(int bookingId) async => CancellationPolicy(
    bookingId: bookingId,
    action: CancellationAction.cancel,
  );

  @override
  Future<RefundRequestResult> request(
    int bookingId, {
    required String idempotencyKey,
  }) => throw UnimplementedError();
}

class _FakeReviews implements ReviewRepository {
  final created = <(int, int, String)>[];

  @override
  Future<Review> create({
    required int bookingId,
    required int rating,
    required String comment,
  }) async {
    created.add((bookingId, rating, comment));
    return Review(
      id: 1,
      bookingId: bookingId,
      customerId: 7,
      rating: rating,
      comment: comment,
      createdAt: DateTime(2026, 10, 9),
    );
  }
}

Widget _wrap(
  BookingRepository bookingRepository, {
  List<Destination> destinations = const [],
  void Function(PaidItem item)? onPay,
  ReviewRepository? reviews,
}) {
  return ProviderScope(
    overrides: [
      bookingRepositoryProvider.overrideWithValue(bookingRepository),
      refundRepositoryProvider.overrideWithValue(_FakeRefundRepository()),
      if (reviews != null) reviewRepositoryProvider.overrideWithValue(reviews),
    ],
    child: MaterialApp(
      theme: DbookTheme.light,
      home: MyBookingsPage(destinations: destinations, onPay: onPay),
    ),
  );
}

void main() {
  testWidgetsWithMockImages(
    'given no bookings when built then shows the empty state',
    (tester) async {
      await tester.pumpWidget(_wrap(_FakeBookingRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma reserva ainda'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a pending upcoming booking when built then shows it under '
    'Próximas with a cancel action',
    (tester) async {
      await tester.pumpWidget(
        _wrap(_FakeBookingRepository(initial: [_myBooking()])),
      );
      await tester.pumpAndSettle();

      expect(find.text('GRU → MAD'), findsOneWidget);
      expect(find.text('Cancelar reserva'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a paid upcoming booking when built then offers the cancel/refund '
    'action (the sheet shows what the server allows)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(
            initial: [_myBooking(status: BookingStatus.confirmed)],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancelar reserva'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a past booking when built then it only shows under Anteriores, '
    'not Próximas',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(
            initial: [
              _myBooking(departureTime: _past, status: BookingStatus.confirmed),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma viagem futura'), findsOneWidget);
      expect(find.text('GRU → MAD'), findsNothing);

      await tester.tap(find.text('Anteriores'));
      await tester.pumpAndSettle();

      expect(find.text('GRU → MAD'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a cancelled booking with a future departure when built then it '
    'shows under Anteriores, not Próximas',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(
            initial: [
              _myBooking(
                departureTime: _future,
                status: BookingStatus.cancelled,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma viagem futura'), findsOneWidget);
      expect(find.text('GRU → MAD'), findsNothing);

      await tester.tap(find.text('Anteriores'));
      await tester.pumpAndSettle();

      expect(find.text('GRU → MAD'), findsOneWidget);
      expect(find.text('Cancelada'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given cancel confirmed when tapped then re-fetches, moves the booking '
    'to Anteriores and shows it cancelled',
    (tester) async {
      await tester.pumpWidget(
        _wrap(_FakeBookingRepository(initial: [_myBooking()])),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar reserva'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar reserva').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Reserva cancelada. O assento foi liberado.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();

      // Uma reserva cancelada não é mais uma viagem "a caminho" — some de
      // Próximas mesmo com data futura, só aparece em Anteriores.
      expect(find.text('Nenhuma viagem futura'), findsOneWidget);
      expect(find.text('Cancelada'), findsNothing);

      await tester.tap(find.text('Anteriores'));
      await tester.pumpAndSettle();

      expect(find.text('Cancelada'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given the backend rejects the cancellation then shows a snackbar and '
    'keeps the pending status',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(
            initial: [_myBooking()],
            cancelError: const DbookForbiddenException('Not your booking'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar reserva'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar reserva').last);
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível concluir agora. Tente de novo.'),
        findsOneWidget,
      );
      expect(find.text('Pendente'), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a destination in the catalog when built then shows its real '
    'photo instead of the fallback',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(initial: [_myBooking()]),
          destinations: const [
            Destination(
              iataCode: 'MAD',
              city: 'Madrid',
              country: 'Espanha',
              photoUrl: 'https://example.com/madrid.jpg',
              region: 'Europa',
              isPopular: true,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    },
  );

  testWidgetsWithMockImages(
    'given a pending booking when tapping Pagar agora then hands the booking '
    'to the payment flow with its frozen price',
    (tester) async {
      PaidItem? paid;
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(initial: [_myBooking()]),
          onPay: (item) => paid = item,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pagar agora'));

      expect(paid!.bookingId, 99);
      expect(paid!.label, contains('GRU'));
      expect(paid!.label, contains('3A'));
    },
  );

  testWidgetsWithMockImages(
    'given a confirmed booking when built then there is nothing to pay',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(
            initial: [_myBooking(status: BookingStatus.confirmed)],
          ),
          onPay: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pagar agora'), findsNothing);
    },
  );

  testWidgetsWithMockImages(
    'given a confirmed booking when reviewing with rating and comment then '
    'sends the review',
    (tester) async {
      final reviews = _FakeReviews();
      await tester.pumpWidget(
        _wrap(
          _FakeBookingRepository(
            initial: [_myBooking(status: BookingStatus.confirmed)],
          ),
          reviews: reviews,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Avaliar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.star_border).at(3));
      await tester.pump();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Voo pontual e atendimento ótimo',
      );
      await tester.pump();
      await tester.tap(find.text('Enviar'));
      await tester.pumpAndSettle();

      expect(reviews.created, hasLength(1));
      expect(reviews.created.single.$2, 4);
      expect(reviews.created.single.$3, 'Voo pontual e atendimento ótimo');
    },
  );

  testWidgetsWithMockImages(
    'given a stays view when choosing Hotéis then shows it instead of the '
    'flights',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(
              _FakeBookingRepository(),
            ),
          ],
          child: MaterialApp(
            theme: DbookTheme.light,
            home: const MyBookingsPage(staysView: Text('lista de estadias')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('lista de estadias'), findsNothing);
      await tester.tap(find.text('Hotéis'));
      await tester.pumpAndSettle();
      expect(find.text('lista de estadias'), findsOneWidget);
      await tester.tap(find.text('Voos'));
      await tester.pumpAndSettle();
      expect(find.text('lista de estadias'), findsNothing);
    },
  );
}
