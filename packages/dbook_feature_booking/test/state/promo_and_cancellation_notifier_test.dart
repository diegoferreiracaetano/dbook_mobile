import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_booking/dbook_feature_booking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePromos implements PromoRepository {
  Object? error;
  List<int>? lastIds;

  @override
  Future<PromoPreview> validate({
    required String code,
    required List<int> bookingIds,
  }) async {
    lastIds = bookingIds;
    if (error != null) throw error!;
    return PromoPreview(code: code, subtotal: 1000, discount: 100, total: 900);
  }
}

class _FakeRefunds implements RefundRepository {
  CancellationPolicy policyToReturn = const CancellationPolicy(
    bookingId: 5,
    action: CancellationAction.refundRequest,
    refundAmount: 900,
  );
  final keys = <String>[];
  final results = <RefundRequestResult>[];
  Object? requestError;

  @override
  Future<CancellationPolicy> policy(int bookingId) async => policyToReturn;

  @override
  Future<RefundRequestResult> request(
    int bookingId, {
    required String idempotencyKey,
  }) async {
    keys.add(idempotencyKey);
    if (requestError != null) throw requestError!;
    return results.removeAt(0);
  }
}

void main() {
  group('promo', () {
    ProviderContainer containerWith(_FakePromos promos) {
      final container = ProviderContainer(
        overrides: [promoRepositoryProvider.overrideWithValue(promos)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('given a valid code when validating then applies the preview the '
        'server computed', () async {
      final promos = _FakePromos();
      final container = containerWith(promos);

      await container.read(promoNotifierProvider.notifier).validate(
        '  BEMVINDO ',
        [1, 2],
      );

      final state = container.read(promoNotifierProvider);
      expect(state, isA<PromoApplied>());
      expect((state as PromoApplied).preview.total, 900);
      expect(promos.lastIds, [1, 2]);
    });

    test('given a blank code when validating then goes back to none without '
        'calling the server', () async {
      final promos = _FakePromos();
      final container = containerWith(promos);

      await container.read(promoNotifierProvider.notifier).validate('   ', [1]);

      expect(container.read(promoNotifierProvider), isA<PromoNone>());
      expect(promos.lastIds, isNull);
    });

    test('given an unknown code when validating then explains it does not '
        'exist', () async {
      final promos = _FakePromos()
        ..error = const DbookNotFoundException('nope');
      final container = containerWith(promos);

      await container.read(promoNotifierProvider.notifier).validate('X', [1]);

      final state = container.read(promoNotifierProvider) as PromoRejected;
      expect(state.reason, contains('não existe'));
    });
  });

  group('cancellation', () {
    ProviderContainer containerWith(_FakeRefunds refunds) {
      var n = 0;
      final container = ProviderContainer(
        overrides: [
          refundRepositoryProvider.overrideWithValue(refunds),
          idempotencyKeyGeneratorProvider.overrideWithValue(() => 'key-${++n}'),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    Future<CancellationNotifier> loaded(ProviderContainer c) async {
      c.listen(cancellationNotifierProvider(5), (_, _) {});
      final notifier = c.read(cancellationNotifierProvider(5).notifier);
      await notifier.load();
      return notifier;
    }

    test('given a lost response when retrying then the same idempotency key '
        'is sent again', () async {
      final refunds = _FakeRefunds()
        ..requestError = const DbookUnknownNetworkException('timeout');
      final container = containerWith(refunds);
      final notifier = await loaded(container);

      await notifier.confirm();
      await notifier.confirm();

      expect(refunds.keys, ['key-1', 'key-1']);
      expect(
        container.read(cancellationNotifierProvider(5)),
        isA<CancellationReady>(),
      );
    });

    test(
      'given a refund that failed when retrying then a new key is used',
      () async {
        final refunds = _FakeRefunds()
          ..results.addAll([
            const RefundRequestResult(
              bookingId: 5,
              amount: 900,
              status: RefundProgress.failed,
            ),
            const RefundRequestResult(
              bookingId: 5,
              amount: 900,
              status: RefundProgress.completed,
            ),
          ]);
        final container = containerWith(refunds);
        final notifier = await loaded(container);

        await notifier.confirm();
        await notifier.confirm();

        expect(refunds.keys, ['key-1', 'key-2']);
        final state = container.read(cancellationNotifierProvider(5));
        expect(state, isA<RefundFinished>());
        expect(
          (state as RefundFinished).result.status,
          RefundProgress.completed,
        );
      },
    );

    test('given a closed refund window when confirming then shows the '
        'support message', () async {
      final refunds = _FakeRefunds()
        ..requestError = const DbookConflictException(
          'x',
          code: 'REFUND_WINDOW_CLOSED',
        );
      final container = containerWith(refunds);
      final notifier = await loaded(container);

      await notifier.confirm();

      final state =
          container.read(cancellationNotifierProvider(5)) as CancellationReady;
      expect(state.error, contains('24 horas'));
    });
  });
}
