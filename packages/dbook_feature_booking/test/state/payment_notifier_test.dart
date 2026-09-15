import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingRepository implements BookingRepository {
  var listMineCallCount = 0;

  @override
  Future<Booking> create({
    required int bookableId,
    required int seatId,
  }) async => throw UnimplementedError();

  @override
  Future<Booking> cancel(int bookingId) async => throw UnimplementedError();

  @override
  Future<List<MyBooking>> listMine() async {
    listMineCallCount++;
    return const [];
  }
}

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

ProviderContainer _buildContainer({
  required PaymentRepository paymentRepository,
  required BookingRepository bookingRepository,
}) {
  final container = ProviderContainer(
    overrides: [
      paymentRepositoryProvider.overrideWithValue(paymentRepository),
      bookingRepositoryProvider.overrideWithValue(bookingRepository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('given fresh state when built then starts idle', () {
    final container = _buildContainer(
      paymentRepository: _FakePaymentRepository(),
      bookingRepository: _FakeBookingRepository(),
    );

    expect(container.read(paymentNotifierProvider), const PaymentState.idle());
  });

  test('given booking ids and card data when paying then calls the repository '
      'with only cardLast4/cardholderName, ends up paid and invalidates the '
      'bookings list', () async {
    final paymentRepository = _FakePaymentRepository();
    final bookingRepository = _FakeBookingRepository();
    final container = _buildContainer(
      paymentRepository: paymentRepository,
      bookingRepository: bookingRepository,
    );
    await container.read(myBookingsNotifierProvider.future);
    expect(bookingRepository.listMineCallCount, 1);

    await container
        .read(paymentNotifierProvider.notifier)
        .pay(bookingIds: [1, 2], cardLast4: '4242', cardholderName: 'Jane Doe');

    expect(paymentRepository.capturedBookingIds, [1, 2]);
    expect(paymentRepository.capturedCardLast4, '4242');
    expect(paymentRepository.capturedCardholderName, 'Jane Doe');
    final state = container.read(paymentNotifierProvider);
    expect(state, isA<PaymentPaid>());
    expect((state as PaymentPaid).payment.id, 55);

    await container.read(myBookingsNotifierProvider.future);
    expect(bookingRepository.listMineCallCount, 2);
  });

  test(
    'given the backend rejects the payment then surfaces the error',
    () async {
      final container = _buildContainer(
        paymentRepository: _FakePaymentRepository(
          error: const DbookConflictException('Booking is no longer PENDING'),
        ),
        bookingRepository: _FakeBookingRepository(),
      );

      await container
          .read(paymentNotifierProvider.notifier)
          .pay(bookingIds: [1], cardLast4: '4242', cardholderName: 'Jane Doe');

      final state = container.read(paymentNotifierProvider);
      expect(state, isA<PaymentError>());
      expect((state as PaymentError).message, 'Booking is no longer PENDING');
    },
  );
}
