import 'package:dbook_admin/src/router.dart';
import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_test/flutter_test.dart';

StaffProfile _profile(Set<Permission> permissions, {bool mustChange = false}) =>
    StaffProfile(
      id: 1,
      name: 'Ana',
      email: 'ana@dbook.test',
      role: Role.support,
      permissions: permissions,
      mustChangePassword: mustChange,
    );

void main() {
  group('safeReturnTo', () {
    test('given an internal path when checking then keeps it', () {
      expect(safeReturnTo('/customers?q=ana'), '/customers?q=ana');
    });

    test('given external or protocol-relative addresses when checking then '
        'rejects them', () {
      expect(safeReturnTo('https://evil.example'), isNull);
      expect(safeReturnTo('//evil.example'), isNull);
      expect(safeReturnTo(r'/\evil.example'), isNull);
      expect(safeReturnTo('javascript:alert(1)'), isNull);
    });

    test(
      'given the login screens when checking then rejects them (no loop)',
      () {
        expect(safeReturnTo('/login'), isNull);
        expect(safeReturnTo('/accept-invite?token=x'), isNull);
      },
    );

    test('given nothing when checking then there is no destination', () {
      expect(safeReturnTo(null), isNull);
      expect(safeReturnTo(''), isNull);
    });
  });

  group('portalRedirect', () {
    test('given no session when opening a page then goes to login keeping '
        'where it wanted to go', () {
      expect(
        portalRedirect(const SessionSignedOut(), Uri.parse('/customers')),
        '/login?returnTo=%2Fcustomers',
      );
    });

    test('given no session when opening login then stays', () {
      expect(
        portalRedirect(const SessionSignedOut(), Uri.parse('/login')),
        isNull,
      );
    });

    test(
      'given a restoring session when opening a page then waits at login',
      () {
        expect(
          portalRedirect(const SessionRestoring(), Uri.parse('/team')),
          startsWith('/login'),
        );
      },
    );

    test('given a signed in user when opening login then goes to the safe '
        'return address or home', () {
      final session = SessionSignedIn(_profile({Permission.adminPortalAccess}));

      expect(
        portalRedirect(session, Uri.parse('/login?returnTo=%2Fbookings')),
        '/bookings',
      );
      expect(
        portalRedirect(
          session,
          Uri.parse('/login?returnTo=https%3A%2F%2Fevil.example'),
        ),
        '/',
      );
    });

    test('given a user without the permission when opening an area then goes '
        'to forbidden', () {
      final session = SessionSignedIn(_profile({Permission.adminPortalAccess}));

      expect(portalRedirect(session, Uri.parse('/team')), '/forbidden');
    });

    test(
      'given a user with the permission when opening an area then stays',
      () {
        final session = SessionSignedIn(
          _profile({Permission.adminPortalAccess, Permission.adminManage}),
        );

        expect(portalRedirect(session, Uri.parse('/team')), isNull);
      },
    );

    test('given a user who must change the password when opening any page '
        'then is taken to change it', () {
      final session = SessionSignedIn(
        _profile({Permission.adminPortalAccess}, mustChange: true),
      );

      expect(portalRedirect(session, Uri.parse('/')), '/change-password');
      expect(portalRedirect(session, Uri.parse('/change-password')), isNull);
    });
  });
}
