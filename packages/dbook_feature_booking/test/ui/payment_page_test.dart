import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePaymentRepository implements PaymentRepository {
  _FakePaymentRepository({this.error});

  final DbookNetworkException? error;
  List<int>? capturedBookingIds;
  String? capturedCardLast4;
  String? capturedCardholderName;

  @override
  Future<Payment> pay({
    required List<int> bookingIds,
    required String cardLast4,
    required String cardholderName,
    required String idempotencyKey,
    String? promoCode,
  }) async {
    capturedBookingIds = bookingIds;
    capturedCardLast4 = cardLast4;
    capturedCardholderName = cardholderName;
    if (error != null) throw error!;
    return Payment(
      id: 55,
      amount: 800,
      cardLast4: cardLast4,
      bookingIds: bookingIds,
      status: 'CONFIRMED',
    );
  }
}

Flight _flight({
  required String origin,
  required String destination,
  required double price,
}) => Flight(
  id: 1,
  flightNumber: 'IB 6821',
  airlineIataCode: 'IB',
  airlineName: 'Iberia',
  originIataCode: origin,
  destinationIataCode: destination,
  departureTime: DateTime(2026, 1, 13, 10, 30),
  arrivalTime: DateTime(2026, 1, 14, 6, 45),
  seatClass: SeatClass.economy,
  price: price,
  availableCapacity: 12,
  aircraftType: 'Airbus A320',
  seatLayout: const [3, 3],
);

const _outboundBooking = Booking(
  id: 1,
  bookableId: 1,
  seatId: 10,
  customerId: 7,
  status: BookingStatus.pending,
);
const _returnBooking = Booking(
  id: 2,
  bookableId: 2,
  seatId: 20,
  customerId: 7,
  status: BookingStatus.pending,
);
const _outboundSeat = Seat(
  id: 10,
  bookableId: 1,
  label: '12A',
  status: SeatStatus.reserved,
);
const _returnSeat = Seat(
  id: 20,
  bookableId: 2,
  label: '8C',
  status: SeatStatus.reserved,
);

List<BookedLeg> _twoLegs() => [
  (
    booking: _outboundBooking,
    flight: _flight(origin: 'GRU', destination: 'GIG', price: 500),
    seat: _outboundSeat,
  ),
  (
    booking: _returnBooking,
    flight: _flight(origin: 'GIG', destination: 'GRU', price: 300),
    seat: _returnSeat,
  ),
];

class _FakePromos implements PromoRepository {
  _FakePromos({this.error});

  final Object? error;
  List<int>? ids;

  @override
  Future<PromoPreview> validate({
    required String code,
    required List<int> bookingIds,
  }) async {
    ids = bookingIds;
    if (error != null) throw error!;
    return PromoPreview(code: code, subtotal: 800, discount: 80, total: 720);
  }
}

Widget _wrap(
  Widget child, {
  required PaymentRepository paymentRepository,
  PromoRepository? promos,
}) {
  return ProviderScope(
    overrides: [
      paymentRepositoryProvider.overrideWithValue(paymentRepository),
      if (promos != null) promoRepositoryProvider.overrideWithValue(promos),
    ],
    child: MaterialApp(theme: DbookTheme.light, home: child),
  );
}

Future<void> _fillValidCard(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Nome no cartão'),
    'Jane Doe',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Número do cartão'),
    '4242 4242 4242 4242',
  );
  await tester.enterText(find.widgetWithText(TextFormField, 'MM/YY'), '12/29');
  await tester.enterText(find.widgetWithText(TextFormField, 'CVV'), '123');
}

void main() {
  testWidgets(
    'given both legs when built then shows each as a detail line and the '
    'real total, with no fabricated fees',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          PaymentPage(bookedLegs: _twoLegs()),
          paymentRepository: _FakePaymentRepository(),
        ),
      );

      expect(find.text('GRU → GIG · Assento 12A'), findsOneWidget);
      expect(find.text('GIG → GRU · Assento 8C'), findsOneWidget);
      expect(find.text('Pagar \$800.00'), findsOneWidget);
      expect(find.textContaining('Tax'), findsNothing);
      expect(find.textContaining('Save card'), findsNothing);
    },
  );

  testWidgets('given valid card data when paying then sends only cardLast4/'
      'cardholderName, never the full card number', (tester) async {
    final paymentRepository = _FakePaymentRepository();
    await tester.pumpWidget(
      _wrap(
        PaymentPage(bookedLegs: _twoLegs()),
        paymentRepository: paymentRepository,
      ),
    );

    await _fillValidCard(tester);
    await tester.tap(find.text('Pagar \$800.00'));
    await tester.pumpAndSettle();

    expect(paymentRepository.capturedBookingIds, [1, 2]);
    expect(paymentRepository.capturedCardLast4, '4242');
    expect(paymentRepository.capturedCardholderName, 'Jane Doe');
  });

  testWidgets(
    'given the backend rejects the payment then shows the error inline',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          PaymentPage(bookedLegs: _twoLegs()),
          paymentRepository: _FakePaymentRepository(
            error: const DbookConflictException('Booking is no longer PENDING'),
          ),
        ),
      );

      await _fillValidCard(tester);
      await tester.tap(find.text('Pagar \$800.00'));
      await tester.pumpAndSettle();

      expect(find.text('Booking is no longer PENDING'), findsOneWidget);
    },
  );

  testWidgets(
    'given an empty card number when paying then validation blocks the '
    'submit and the repository is never called',
    (tester) async {
      final paymentRepository = _FakePaymentRepository();
      await tester.pumpWidget(
        _wrap(
          PaymentPage(bookedLegs: _twoLegs()),
          paymentRepository: paymentRepository,
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome no cartão'),
        'Jane Doe',
      );
      await tester.tap(find.text('Pagar \$800.00'));
      await tester.pumpAndSettle();

      expect(paymentRepository.capturedBookingIds, isNull);
      expect(find.text('Número de cartão inválido'), findsOneWidget);
    },
  );

  testWidgets('given a valid promo code when applying then shows the discount '
      'and the new total the server computed', (tester) async {
    final promos = _FakePromos();
    await tester.pumpWidget(
      _wrap(
        PaymentPage(bookedLegs: _twoLegs()),
        paymentRepository: _FakePaymentRepository(),
        promos: promos,
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Código promocional'),
      'BEMVINDO10',
    );
    await tester.ensureVisible(find.text('Aplicar'));
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(promos.ids, [1, 2]);
    expect(find.text('Pagar \$720.00'), findsOneWidget);
    expect(find.text('BEMVINDO10 aplicado'), findsOneWidget);
  });

  testWidgets('given an unknown promo code when applying then explains it '
      'and keeps the full total', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PaymentPage(bookedLegs: _twoLegs()),
        paymentRepository: _FakePaymentRepository(),
        promos: _FakePromos(error: const DbookNotFoundException('nope')),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Código promocional'),
      'XXXX',
    );
    await tester.ensureVisible(find.text('Aplicar'));
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('não existe'), findsOneWidget);
    expect(find.text('Pagar \$800.00'), findsOneWidget);
  });

  testWidgets('given a hotel item when paying together then the summary '
      'lists it and the total includes it', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PaymentPage(
          items: const [
            (bookingId: 9, label: 'Hotel Copacabana · 3 noites', price: 1050),
          ],
        ),
        paymentRepository: _FakePaymentRepository(),
      ),
    );

    expect(find.text('Hotel Copacabana · 3 noites'), findsOneWidget);
    expect(find.text('Pagar \$1,050.00'), findsOneWidget);
  });
}
