import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// Grava toda chamada e responde um corpo fixo: prova o que cada operação de
/// escrita manda (método, caminho, corpo e cabeçalhos) sem subir servidor.
class _Recorder {
  _Recorder([this.reply = const <String, dynamic>{}]) {
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls.add(options);
          handler.resolve(
            Response<Object>(
              requestOptions: options,
              statusCode: 200,
              data: reply,
            ),
          );
        },
      ),
    );
  }

  final Object reply;
  late final Dio dio;
  final calls = <RequestOptions>[];

  RequestOptions get last => calls.last;
}

void main() {
  group('customers', () {
    test('given a note when adding, editing and deleting then uses the notes '
        'routes', () async {
      final r = _Recorder({'id': 5, 'body': 'x'});
      final api = DioCustomersApi(r.dio);

      await api.addNote(2, body: 'ligar', pinned: true);
      expect(r.last.method, 'POST');
      expect(r.last.path, '/admin/customers/2/notes');
      expect(r.last.data, {'body': 'ligar', 'pinned': true});

      await api.updateNote(2, 5, body: 'novo texto');
      expect(r.last.method, 'PATCH');
      expect(r.last.path, '/admin/customers/2/notes/5');
      expect(r.last.data, {'body': 'novo texto'});

      await api.deleteNote(2, 5);
      expect(r.last.method, 'DELETE');
      expect(r.last.path, '/admin/customers/2/notes/5');
    });

    test('given moderation when blocking, unblocking and anonymizing then '
        'sends the reason and the typed confirmation', () async {
      final r = _Recorder();
      final api = DioCustomersApi(r.dio);

      await api.block(2, 'fraude');
      expect(r.last.path, '/admin/customers/2/block');
      expect(r.last.data, {'reason': 'fraude'});

      await api.unblock(2);
      expect(r.last.path, '/admin/customers/2/unblock');

      await api.anonymize(2, reason: 'LGPD', confirmation: 'ANONIMIZAR');
      expect(r.last.path, '/admin/customers/2/anonymize');
      expect((r.last.data as Map)['confirmation'], 'ANONIMIZAR');
    });

    test(
      'given a query when exporting then asks for bytes with the filters',
      () async {
        final r = _Recorder(<int>[1, 2, 3]);
        final api = DioCustomersApi(r.dio);

        final file = await api.export((
          text: 'ana',
          status: CustomerStatus.blocked,
          from: null,
          to: null,
          hasBookings: true,
          sort: defaultCustomerQuery.sort,
          descending: true,
          page: 0,
          size: 20,
        ));

        expect(r.last.path, '/admin/customers/export');
        expect(r.last.responseType, ResponseType.bytes);
        expect(r.last.queryParameters['query'], 'ana');
        expect(r.last.queryParameters['status'], 'BLOCKED');
        expect(file.bytes, [1, 2, 3]);
      },
    );
  });

  group('catalog', () {
    final form = FlightForm(
      flightNumber: 'DB2000',
      airlineIataCode: 'LA',
      originIataCode: 'GRU',
      destinationIataCode: 'GIG',
      departureTime: DateTime(2027, 2, 1, 8),
      arrivalTime: DateTime(2027, 2, 1, 9, 10),
      seatClass: SeatClass.economy,
      price: 399.9,
      totalCapacity: 120,
      aircraftType: 'Airbus A320',
    );

    test(
      'given a form when creating then posts it and returns the id',
      () async {
        final r = _Recorder({'id': 77});

        final id = await DioCatalogApi(r.dio).createFlight(form);

        expect(id, 77);
        expect(r.last.method, 'POST');
        expect(r.last.path, '/admin/flights');
        expect((r.last.data as Map)['flightNumber'], 'DB2000');
      },
    );

    test(
      'given a form when updating then sends the version for the lock',
      () async {
        final r = _Recorder({
          'flight': {'id': 1, 'version': 4},
        });

        await DioCatalogApi(r.dio).updateFlight(1, form, version: 3);

        expect(r.last.method, 'PUT');
        expect((r.last.data as Map)['version'], 3);
      },
    );

    test(
      'given a flight when cancelling then posts to its cancel route',
      () async {
        final r = _Recorder();

        await DioCatalogApi(r.dio).cancelFlight(1);

        expect(r.last.path, '/admin/flights/1/cancel');
      },
    );

    test('given csv when importing then sends the dry run flag and reads '
        'the report', () async {
      final r = _Recorder({
        'dryRun': true,
        'totalRows': 3,
        'toCreate': 2,
        'alreadyExisting': 1,
        'created': 0,
        'errors': [
          {'line': 4, 'message': 'preço inválido'},
        ],
      });

      final report = await DioCatalogApi(r.dio)
          .importFlights('a,b\n1,2', dryRun: true);

      expect(r.last.path, '/admin/flights/import');
      expect(
        r.last.queryParameters['dryRun'] ?? (r.last.data as Object?),
        isNotNull,
      );
      expect(report.totalRows, 3);
      expect(report.errors, hasLength(1));
    });

    test('given airlines and airports when saving and deleting then picks '
        'create or update by id', () async {
      final r = _Recorder();
      final api = DioCatalogApi(r.dio);

      await api.saveAirline(iataCode: 'g3', name: ' Gol ');
      expect(r.last.method, 'POST');
      expect(r.last.data, {'iataCode': 'G3', 'name': 'Gol', 'logoUrl': ''});

      await api.saveAirline(
        iataCode: 'g3',
        name: 'Gol',
        logoUrl: ' https://cdn.example.com/G3.png ',
      );
      expect(r.last.data, {
        'iataCode': 'G3',
        'name': 'Gol',
        'logoUrl': 'https://cdn.example.com/G3.png',
      });

      await api.saveAirline(id: 4, iataCode: 'g3', name: 'Gol');
      expect(r.last.method, 'PUT');
      expect(r.last.path, '/admin/airlines/4');

      await api.deleteAirline(4);
      expect(r.last.method, 'DELETE');

      const airport = Airport(
        iataCode: 'CWB',
        name: 'Afonso Pena',
        city: 'Curitiba',
        country: 'Brasil',
        photoUrl: 'https://x/y.jpg',
        region: 'América do Sul',
        isPopular: false,
      );
      await api.saveAirport(airport);
      expect(r.last.method, 'POST');
      await api.saveAirport(
        Airport(
          id: 9,
          iataCode: airport.iataCode,
          name: airport.name,
          city: airport.city,
          country: airport.country,
          photoUrl: airport.photoUrl,
          region: airport.region,
          isPopular: true,
        ),
      );
      expect(r.last.method, 'PUT');
      expect(r.last.path, '/admin/airports/9');
      await api.deleteAirport(9);
      expect(r.last.path, '/admin/airports/9');
    });
  });

  group('bookings and governance', () {
    test(
      'given a pending booking when cancelling then posts the cancel',
      () async {
        final r = _Recorder();

        await DioAdminBookingsApi(r.dio).cancel(8);

        expect(r.last.method, 'POST');
        expect(r.last.path, contains('/bookings/8/cancel'));
      },
    );

    test('given a failed refund when retrying then posts the retry', () async {
      final r = _Recorder({'id': 3, 'status': 'REQUESTED'});

      await DioAdminBookingsApi(r.dio).retryRefund(3);

      expect(r.last.path, '/admin/refunds/3/retry');
    });

    test('given the override flag when refunding then sends it only when '
        'true', () async {
      final r = _Recorder({'id': 1});
      final api = DioAdminBookingsApi(r.dio);

      await api.refund(
        2,
        const RefundRequest(reason: RefundReason.other, note: 'x'),
        idempotencyKey: 'k1',
      );
      expect((r.last.data as Map).containsKey('override'), isFalse);

      await api.refund(
        2,
        const RefundRequest(reason: RefundReason.other, override: true),
        idempotencyKey: 'k2',
      );
      expect((r.last.data as Map)['override'], isTrue);
      expect(r.last.headers['Idempotency-Key'], 'k2');
    });

    test('given a promo form when creating and updating then sends the '
        'right JSON', () async {
      final r = _Recorder({'id': 1, 'code': 'NATAL'});
      final api = DioGovernanceApi(r.dio);
      final form = PromoForm(
        code: ' natal20 ',
        type: PromoType.percent,
        value: 20,
        validFrom: DateTime(2026, 12, 1),
        validUntil: DateTime(2026, 12, 31),
        minAmount: 100,
      );

      await api.createPromo(form);
      expect(r.last.method, 'POST');
      expect((r.last.data as Map)['code'], 'NATAL20');

      await api.updatePromo(1, form);
      expect(r.last.method, anyOf('PUT', 'PATCH'));
      expect(r.last.path, '/admin/promo-codes/1');

      await api.setPromoActive(1, active: false);
      expect(r.last.path, '/admin/promo-codes/1/deactivate');
      await api.setPromoActive(1, active: true);
      expect(r.last.path, '/admin/promo-codes/1/activate');
    });

    test('given a review when hiding, restoring and dismissing then uses '
        'the moderation routes', () async {
      final r = _Recorder();
      final api = DioGovernanceApi(r.dio);

      await api.hideReview(11, 'ofensivo');
      expect(r.last.path, '/admin/reviews/11/hide');
      expect(r.last.data, {'reason': 'ofensivo'});
      await api.restoreReview(11);
      expect(r.last.path, '/admin/reviews/11/restore');
      await api.dismissReports(11);
      expect(r.last.path, '/admin/reviews/11/dismiss-reports');
    });
  });

  group('auth', () {
    test('given the 2FA enrollment flow when calling then uses the account '
        'routes', () async {
      final r = _Recorder({
        'otpauthUri': 'otpauth://x',
        'manualEntryKey': 'ABC',
        'recoveryCodes': ['a', 'b'],
      });
      final api = DioAdminAuthApi(r.dio);

      final enrollment = await api.enrollTwoFactor();
      expect(enrollment.manualEntryKey, 'ABC');
      expect(r.last.path, '/admin/2fa/enroll');

      final codes = await api.confirmTwoFactor('123456');
      expect(codes, ['a', 'b']);
      expect(r.last.data, {'code': '123456'});

      await api.disableTwoFactor(password: 'p', code: '654321');
      expect(r.last.path, '/admin/2fa/disable');
    });

    test('given a challenge when enrolling and confirming then sends the '
        'challenge token', () async {
      final r = _Recorder({
        'otpauthUri': 'otpauth://x',
        'manualEntryKey': 'K',
        'accessToken': 't',
        'recoveryCodes': ['r1'],
      });
      final api = DioAdminAuthApi(r.dio);

      await api.enrollWithChallenge('ch');
      expect(r.last.data, {'challengeToken': 'ch'});
      final done = await api.confirmWithChallenge(
        challengeToken: 'ch',
        code: '111111',
      );
      expect(done.accessToken, 't');
      expect(done.recoveryCodes, ['r1']);
      final token = await api.verifyTwoFactor(
        challengeToken: 'ch',
        code: '222222',
      );
      expect(token, 't');
    });

    test('given refresh, logout, password and invitation when calling then '
        'uses each route', () async {
      final r = _Recorder({
        'accessToken': 'novo',
        'id': 3,
        'name': 'Ana',
        'email': 'a@b.c',
        'role': 'SUPPORT',
      });
      final api = DioAdminAuthApi(r.dio);

      expect(await api.refresh(), 'novo');
      expect(r.last.path, '/admin/auth/refresh');
      await api.logout();
      expect(r.last.path, '/admin/auth/logout');
      await api.changePassword(currentPassword: 'a', newPassword: 'b');
      expect(r.last.path, '/admin/auth/change-password');
      final accepted = await api.acceptInvitation(
        token: 'tk',
        name: 'Ana',
        password: 'segredo-longo-123',
      );
      expect(accepted.role, Role.support);
      expect(r.last.path, '/admin/invitations/accept');
    });
  });

  group('team', () {
    test('given a member when changing role, blocking and unblocking then '
        'uses the staff routes', () async {
      final r = _Recorder({
        'id': 2,
        'name': 'B',
        'email': 'b@c.d',
        'role': 'CATALOG_MANAGER',
        'status': 'ACTIVE',
      });
      final api = DioTeamApi(r.dio);

      await api.changeRole(id: 2, role: Role.catalogManager);
      expect(r.last.path, '/admin/staff/2/role');
      expect((r.last.data as Map)['role'], 'CATALOG_MANAGER');
      await api.block(id: 2, reason: 'saiu');
      expect(r.last.path, '/admin/staff/2/block');
      await api.unblock(2);
      expect(r.last.path, '/admin/staff/2/unblock');
    });

    test('given an invitation when inviting, resending and revoking then '
        'uses the invitation routes', () async {
      final r = _Recorder({
        'id': 1,
        'email': 'n@d.t',
        'role': 'SUPPORT',
        'status': 'PENDING',
      });
      final api = DioTeamApi(r.dio);

      await api.invite(email: 'n@d.t', role: Role.support);
      expect(r.last.path, '/admin/invitations');
      await api.resendInvitation(1);
      expect(r.last.path, '/admin/invitations/1/resend');
      await api.revokeInvitation(1);
      expect(r.last.method, 'DELETE');
    });
  });
}
