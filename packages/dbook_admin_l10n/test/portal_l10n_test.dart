import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await PortalFormats.init();
    l10n = await AppLocalizations.delegate.load(const Locale('pt'));
  });

  group('PortalFormats', () {
    test('given a date when formatted then it is dd/MM/yyyy', () {
      expect(PortalFormats.date(DateTime(2026, 10, 7)), '07/10/2026');
    });

    test('given a date and time when formatted then it has HH:mm', () {
      expect(
        PortalFormats.dateTime(DateTime(2026, 10, 7, 9, 5)),
        '07/10/2026 09:05',
      );
    });

    test('given a value when formatted as money then it uses R\$ and pt-BR '
        'separators', () {
      expect(PortalFormats.money(1234.5).replaceAll(' ', ' '), r'R$ 1.234,50');
    });

    test('given ratios when formatted then they are percentages with a sign '
        'when asked', () {
      expect(PortalFormats.percent(0.125), contains('12,5'));
      expect(PortalFormats.signedPercent(0.125), startsWith('+'));
      expect(PortalFormats.signedPercent(-0.03), startsWith('-'));
    });

    test('given instants when asked how long ago then it reads naturally', () {
      final now = DateTime(2026, 10, 7, 12);
      expect(
        PortalFormats.ago(now.subtract(const Duration(seconds: 5)), now),
        'agora',
      );
      expect(
        PortalFormats.ago(now.subtract(const Duration(minutes: 5)), now),
        'há 5 min',
      );
      expect(
        PortalFormats.ago(now.subtract(const Duration(hours: 2)), now),
        'há 2 h',
      );
      expect(
        PortalFormats.ago(now.subtract(const Duration(days: 3)), now),
        'há 3 dias',
      );
    });
  });

  group('portalErrorMessage', () {
    test('given a known code when mapped then the message is by code, not the '
        "server's text", () {
      const error = DbookUnauthorizedException(
        'texto cru do servidor',
        code: 'INVALID_CREDENTIALS',
      );

      final message = portalErrorMessage(l10n, error);

      expect(message, l10n.errInvalidCredentials);
      expect(message, isNot(contains('cru')));
    });

    test('given TOO_MANY_ATTEMPTS when mapped then it carries the seconds', () {
      const error = DbookRateLimitException(
        'x',
        code: 'TOO_MANY_ATTEMPTS',
        retryAfter: 30,
      );

      expect(portalErrorMessage(l10n, error), contains('30'));
    });

    test('given an unknown code when mapped then it falls back to the HTTP '
        'status', () {
      const error = DbookForbiddenException('x', code: 'NOVO_CODIGO');

      expect(portalErrorMessage(l10n, error), l10n.errForbidden);
    });

    test('given a network failure when mapped then it says there is no '
        'connection', () {
      const error = DbookUnknownNetworkException('timeout');

      expect(portalErrorMessage(l10n, error), l10n.errNetwork);
    });

    test('given something that is not a network error when mapped then it is '
        'generic', () {
      expect(portalErrorMessage(l10n, StateError('x')), l10n.errGeneric);
    });
  });
}
