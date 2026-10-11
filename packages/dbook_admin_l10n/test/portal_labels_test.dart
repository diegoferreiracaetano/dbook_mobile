import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await PortalFormats.init();
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  group('portalErrorMessage', () {
    test('given each known backend code when translating then never shows '
        'the raw server text', () {
      const codes = [
        'INVALID_CREDENTIALS',
        'ACCOUNT_BLOCKED',
        'INVALID_TWO_FACTOR_CODE',
        'INVALID_INVITATION',
        'STALE_VERSION',
        'IDEMPOTENCY_KEY_REUSED',
        'REFUND_WINDOW_CLOSED',
        'PAYLOAD_TOO_LARGE',
        'TOO_MANY_ATTEMPTS',
        'RATE_LIMITED',
      ];
      final seen = <String>{};
      for (final code in codes) {
        final text = portalErrorMessage(
          l10n,
          DbookConflictException('texto cru do servidor', code: code),
        );
        expect(text, isNot(contains('texto cru')), reason: code);
        expect(text, isNotEmpty, reason: code);
        seen.add(text);
      }
      expect(seen, hasLength(codes.length), reason: 'cada código, sua frase');
    });

    test('given the retry-after when rate limited then the message carries '
        'the wait', () {
      final text = portalErrorMessage(
        l10n,
        const DbookRateLimitException('x', retryAfter: 42),
      );

      expect(text, contains('42'));
    });

    test('given each error class without a code when translating then falls '
        'back by HTTP kind', () {
      final errors = <Object>[
        const DbookValidationException('x'),
        const DbookUnauthorizedException('x'),
        const DbookForbiddenException('x'),
        const DbookNotFoundException('x'),
        const DbookConflictException('x'),
        const DbookUnprocessableException('x'),
        const DbookBadGatewayException('x'),
        const DbookServiceUnavailableException('x'),
        const DbookUnknownNetworkException('x'),
      ];
      for (final error in errors) {
        final text = portalErrorMessage(l10n, error);
        expect(text, isNotEmpty, reason: '$error');
        expect(text, isNot('x'), reason: '$error');
      }
    });

    test('given a non network error when translating then is generic', () {
      expect(portalErrorMessage(l10n, StateError('x')), l10n.errGeneric);
    });
  });

  group('labels', () {
    test('given every role when labelling then each has a distinct text', () {
      final labels = {for (final r in Role.values) roleLabel(l10n, r)};

      expect(labels, hasLength(Role.values.length));
    });

    test('given roles when describing then staff roles have a description', () {
      expect(roleDescription(l10n, Role.support), isNotEmpty);
      expect(roleDescription(l10n, Role.client), isEmpty);
    });

    test('given an unknown audit action when labelling then shows the raw '
        'code', () {
      expect(auditActionLabel(l10n, 'NEW_ACTION_X'), 'NEW_ACTION_X');
      expect(auditActionLabel(l10n, 'STAFF_BLOCKED'), isNot('STAFF_BLOCKED'));
    });

    test('given every booking, refund and flight state when labelling then '
        'has a text', () {
      for (final s in BookingStatus.values) {
        expect(bookingStatusLabel(l10n, s), isNotEmpty, reason: '$s');
      }
      for (final s in RefundStatus.values) {
        expect(refundStatusLabel(l10n, s), isNotEmpty, reason: '$s');
      }
      for (final s in FlightStatus.values) {
        expect(flightStatusLabel(l10n, s), isNotEmpty, reason: '$s');
      }
      for (final s in SeatClass.values) {
        expect(seatClassLabel(l10n, s), isNotEmpty, reason: '$s');
      }
      for (final r in RefundReason.values) {
        expect(refundReasonLabel(l10n, r), isNotEmpty, reason: '$r');
      }
    });

    test('given every action the audit list knows when labelling then none '
        'falls back to the raw code', () {
      for (final action in knownAuditActions) {
        expect(
          auditActionLabel(l10n, action),
          isNot(action),
          reason: 'sem rótulo para $action',
        );
      }
    });
  });
}
