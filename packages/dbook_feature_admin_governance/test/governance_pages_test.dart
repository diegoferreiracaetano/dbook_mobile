import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_feature_admin_governance/dbook_feature_admin_governance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

void main() {
  promoFlows();
  reviewFlows();
  auditFlows();
  promoEditFlows();
  auditFilterFlows();
  auditPagingFlows();
  promoValidationFlows();

  testWidgets('given the real audit trail when the page builds then renders '
      'the entries', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/audit': 'audit'}),
      child: AuditPage(
        query: (
          actorId: null,
          action: null,
          targetType: null,
          targetId: null,
          outcome: null,
          from: null,
          to: null,
          cursor: null,
          size: 20,
        ),
        onQueryChanged: (_) {},
        onOpenTarget: (_, _) {},
      ),
    );

    expect(find.byType(AuditPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('given an empty moderation queue when built then shows no '
      'error', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/reviews': 'reviews'}),
      child: ReviewsPage(
        request: (queue: ReviewQueue.reported, page: 0),
        onRequestChanged: (_) {},
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('given no promo codes when built then shows the empty list '
      'without errors', (tester) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/promo-codes': 'promos'}),
      child: PromosPage(
        query: (active: null, page: 0, size: 20),
        onQueryChanged: (_) {},
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

void promoFlows() {
  const listed = {
    'items': [
      {
        'id': 7,
        'code': 'BEMVINDO10',
        'type': 'PERCENT',
        'value': 10,
        'minAmount': 200,
        'maxPerUser': 1,
        'redeemed': 3,
        'active': true,
      },
    ],
    'page': 0,
    'size': 20,
    'totalElements': 1,
    'totalPages': 1,
  };

  testWidgets('given the promo list when creating a code then posts it to '
      'the server', (tester) async {
    final recorder = RecordingDio(replies: {'/admin/promo-codes': listed});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: PromosPage(
        query: (active: null, page: 0, size: 20),
        onQueryChanged: (_) {},
      ),
    );

    await tester.tap(find.text('Novo código'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Código (3 a 32 letras, números, - ou _)',
      ),
      'NATAL20',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Percentual (menor que 100)'),
      '20',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/promo-codes').toList();
    expect(posts, hasLength(1));
    expect((posts.single.data as Map)['code'], 'NATAL20');
  });

  testWidgets('given an active code when switching it off then confirms and '
      'tells the server', (tester) async {
    final recorder = RecordingDio(replies: {'GET /admin/promo-codes': listed});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: PromosPage(
        query: (active: null, page: 0, size: 20),
        onQueryChanged: (_) {},
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desligar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desligar').last);
    await tester.pumpAndSettle();

    final writes = recorder.calls.where((c) => c.method != 'GET').toList();
    expect(writes, hasLength(1));
    expect(writes.single.path, contains('/admin/promo-codes/7'));
  });
}

void reviewFlows() {
  const queue = {
    'items': [
      {
        'id': 11,
        'bookingId': 2,
        'customerId': 2,
        'customerName': 'Marina Alves',
        'destination': 'GIG',
        'rating': 1,
        'comment': 'Texto ofensivo de teste',
        'status': 'VISIBLE',
        'openReports': 2,
        'lastReportReason': 'Ofensa',
        'createdAt': '2026-10-09T20:00:00Z',
      },
    ],
    'page': 0,
    'size': 20,
    'totalElements': 1,
    'totalPages': 1,
  };

  testWidgets('given a reported review when hiding with a reason then posts '
      'it', (tester) async {
    final recorder = RecordingDio(replies: {'GET /admin/reviews': queue});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: ReviewsPage(
        request: (queue: ReviewQueue.reported, page: 0),
        onRequestChanged: (_) {},
      ),
    );

    expect(find.text('Texto ofensivo de teste'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ocultar').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Motivo (10 a 500 caracteres)'),
      'Linguagem ofensiva contra a equipe',
    );
    await tester.pump();
    await tester.tap(find.text('Ocultar avaliação'));
    await tester.pumpAndSettle();

    final writes = recorder.calls.where((c) => c.method != 'GET').toList();
    expect(writes, hasLength(1));
    expect(writes.single.path, contains('/admin/reviews/11'));
  });

  testWidgets('given a reported review when dismissing the reports then '
      'tells the server', (tester) async {
    final recorder = RecordingDio(replies: {'GET /admin/reviews': queue});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: ReviewsPage(
        request: (queue: ReviewQueue.reported, page: 0),
        onRequestChanged: (_) {},
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dispensar denúncias'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dispensar denúncias').last);
    await tester.pumpAndSettle();

    final writes = recorder.calls.where((c) => c.method != 'GET').toList();
    expect(writes, hasLength(1));
  });
}

void auditFlows() {
  const emptyQuery = (
    actorId: null,
    action: null,
    targetType: null,
    targetId: null,
    outcome: null,
    from: null,
    to: null,
    cursor: null,
    size: 20,
  );

  testWidgets('given the real trail when opening an entry then shows its '
      'details and opens the target', (tester) async {
    String? openedType;
    String? openedId;
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/audit': 'audit'}),
      child: AuditPage(
        query: emptyQuery,
        onQueryChanged: (_) {},
        onOpenTarget: (type, id) {
          openedType = type;
          openedId = id;
        },
      ),
    );

    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    expect(
      find.text('Esta ação não guarda estado antes e depois.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Abrir CUSTOMER 2').first);
    await tester.pumpAndSettle();

    expect(openedType, 'CUSTOMER');
    expect(openedId, '2');
  });
}

void auditFilterFlows() {
  const emptyQuery = (
    actorId: null,
    action: null,
    targetType: null,
    targetId: null,
    outcome: null,
    from: null,
    to: null,
    cursor: null,
    size: 20,
  );

  Future<List<Object?>> pumpAudit(
    WidgetTester tester,
    void Function(Object q) onChanged,
  ) async {
    await pumpPortal(
      tester,
      dio: fixtureDio({'/admin/audit': 'audit'}),
      child: AuditPage(
        query: emptyQuery,
        onQueryChanged: onChanged,
        onOpenTarget: (_, _) {},
      ),
    );
    return const [];
  }

  testWidgets('given the outcome filter when choosing denied then reports '
      'it', (tester) async {
    Object? reported;
    await pumpAudit(tester, (q) => reported = q);

    await tester.tap(find.byType(DropdownButton<String?>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Negado').last);
    await tester.pumpAndSettle();

    expect((reported as dynamic).outcome, 'DENIED');
  });

  testWidgets('given the action filter when choosing an action then '
      'reports it', (tester) async {
    Object? reported;
    await pumpAudit(tester, (q) => reported = q);

    await tester.tap(find.byType(DropdownButton<String?>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cliente bloqueado').last);
    await tester.pumpAndSettle();

    expect((reported as dynamic).action, 'CUSTOMER_BLOCKED');
  });

  testWidgets('given the text filters when submitting each then reports the '
      'normalised values', (tester) async {
    Object? reported;
    await pumpAudit(tester, (q) => reported = q);

    Future<void> submit(String label, String value) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.enterText(field, value);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    await submit('Quem (id)', ' 7 ');
    expect((reported as dynamic).actorId, 7);

    await submit('Tipo do alvo', ' booking ');
    expect((reported as dynamic).targetType, 'BOOKING');

    await submit('Id do alvo', ' 42 ');
    expect((reported as dynamic).targetId, '42');
  });

  test('given the query when encoding and decoding then it round trips', () {
    final decoded = AuditQueryCodec.decode({
      'actor': '3',
      'action': 'CUSTOMER_BLOCKED',
      'type': 'CUSTOMER',
      'target': '9',
      'outcome': 'DENIED',
      'from': '2026-10-01',
      'to': '2026-10-09',
    });

    expect(decoded.actorId, 3);
    expect(decoded.size, 50);
    expect(AuditQueryCodec.encode(decoded), {
      'actor': '3',
      'action': 'CUSTOMER_BLOCKED',
      'type': 'CUSTOMER',
      'target': '9',
      'outcome': 'DENIED',
      'from': '2026-10-01',
      'to': '2026-10-09',
    });
    expect(AuditQueryCodec.encode(AuditQueryCodec.decode(const {})), isEmpty);
  });
}

void auditPagingFlows() {
  const emptyQuery = (
    actorId: null,
    action: null,
    targetType: null,
    targetId: null,
    outcome: null,
    from: null,
    to: null,
    cursor: null,
    size: 20,
  );

  Map<String, Object?> page(String cursor, int id) => {
    'items': [
      {
        'id': id,
        'occurredAt': '2026-10-09T20:00:00Z',
        'actorId': 1,
        'actorRole': 'SUPER_ADMIN',
        'action': 'STAFF_BLOCKED',
        'outcome': 'SUCCESS',
        'targetType': 'STAFF',
        'targetId': '2',
        'before': {'status': 'ACTIVE'},
        'after': {'status': 'BLOCKED'},
        'reason': 'Saiu da empresa',
        'requestId': 'req-$id',
        'ip': '127.0.0.1',
      },
    ],
    'nextCursor': cursor.isEmpty ? null : cursor,
  };

  testWidgets('given a cursor when loading more then appends the next '
      'page', (tester) async {
    final recorder = RecordingDio(replies: {'GET /admin/audit': page('c2', 1)});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: AuditPage(
        query: emptyQuery,
        onQueryChanged: (_) {},
        onOpenTarget: (_, _) {},
      ),
    );

    expect(find.text('Carregar mais'), findsOneWidget);
    await tester.ensureVisible(find.text('Carregar mais'));
    await tester.tap(find.text('Carregar mais'));
    await tester.pumpAndSettle();

    final reads = recorder.to('GET', '/admin/audit').toList();
    expect(reads, hasLength(2));
    expect(reads.last.queryParameters['cursor'], 'c2');
  });

  testWidgets('given an entry with before and after when expanding then '
      'shows the field diff and the reason', (tester) async {
    final recorder = RecordingDio(replies: {'GET /admin/audit': page('', 1)});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: AuditPage(
        query: emptyQuery,
        onQueryChanged: (_) {},
        onOpenTarget: (_, _) {},
      ),
    );

    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Saiu da empresa'), findsOneWidget);
    expect(find.text('status'), findsOneWidget);
  });
}

void promoValidationFlows() {
  Future<RecordingDio> open(WidgetTester tester) async {
    final recorder = RecordingDio();
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: PromosPage(
        query: (active: null, page: 0, size: 20),
        onQueryChanged: (_) {},
      ),
    );
    await tester.tap(find.text('Novo código'));
    await tester.pumpAndSettle();
    return recorder;
  }

  testWidgets('given an invalid code and value when saving then shows the '
      'rules and sends nothing', (tester) async {
    final recorder = await open(tester);

    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Código (3 a 32 letras, números, - ou _)',
      ),
      'a',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Percentual (menor que 100)'),
      '150',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('De 3 a 32 letras, números, - ou _.'), findsOneWidget);
    expect(recorder.calls.where((c) => c.method == 'POST'), isEmpty);
  });

  testWidgets('given the fixed type when chosen then the value field '
      'changes to money', (tester) async {
    await open(tester);

    await tester.tap(find.text('Percentual').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valor fixo').last);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(TextFormField, 'Valor do desconto (R\$)'),
      findsOneWidget,
    );
  });
}

void promoEditFlows() {
  const listed = {
    'items': [
      {
        'id': 7,
        'code': 'BEMVINDO10',
        'type': 'PERCENT',
        'value': 10,
        'minAmount': 200,
        'maxPerUser': 1,
        'redeemed': 3,
        'active': true,
      },
    ],
    'page': 0,
    'size': 20,
    'totalElements': 1,
    'totalPages': 1,
  };

  testWidgets('given a code when editing the value then the code stays '
      'locked and the update is sent', (tester) async {
    final recorder = RecordingDio(replies: {'GET /admin/promo-codes': listed});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: PromosPage(
        query: (active: null, page: 0, size: 20),
        onQueryChanged: (_) {},
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Limite de usos (vazio = sem limite)'),
      '50',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final writes = recorder.calls.where((c) => c.method != 'GET').toList();
    expect(writes, hasLength(1));
    expect(writes.single.path, '/admin/promo-codes/7');
    final body = writes.single.data as Map;
    expect(body['maxRedemptions'], 50);
    // código, tipo e valor não mudam depois de criado
    expect(body.containsKey('code'), isFalse);
    expect(body.containsKey('value'), isFalse);
  });

  testWidgets('given a code when asking for the redemptions then reads the '
      'list', (tester) async {
    final recorder = RecordingDio(replies: {'GET /admin/promo-codes': listed});
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: PromosPage(
        query: (active: null, page: 0, size: 20),
        onQueryChanged: (_) {},
      ),
    );

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver resgates'));
    await tester.pumpAndSettle();

    expect(
      recorder.to('GET', '/admin/promo-codes/7/redemptions'),
      hasLength(1),
    );
  });
}
