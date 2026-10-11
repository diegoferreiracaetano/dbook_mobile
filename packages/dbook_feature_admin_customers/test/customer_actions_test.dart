import 'dart:convert';
import 'dart:io';

import 'package:dbook_feature_admin_customers/dbook_feature_admin_customers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

Object _fx(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync()) as Object;

void main() {
  testWidgets('given a customer when blocking with a reason then posts the '
      'reason to the server', (tester) async {
    final recorder = RecordingDio(
      replies: {
        '/admin/customers/2': _fx('customer_detail'),
        '/admin/customers/2/bookings': _fx('customer_bookings'),
        '/admin/customers/2/payments': _fx('customer_payments'),
        '/admin/customers/2/reviews': _fx('customer_reviews'),
        '/admin/customers/2/notes': _fx('customer_notes'),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );

    await tester.tap(find.text('Bloquear cliente'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Motivo (obrigatório)'),
      'Chargeback suspeito',
    );
    await tester.pump();
    await tester.tap(find.text('Bloquear').last);
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/customers/2/block').toList();
    expect(posts, hasLength(1));
    expect((posts.single.data as Map)['reason'], 'Chargeback suspeito');
  });

  testWidgets('given a customer when blocking without a reason then does '
      'not call the server', (tester) async {
    final recorder = RecordingDio(
      replies: {
        '/admin/customers/2': _fx('customer_detail'),
        '/admin/customers/2/bookings': _fx('customer_bookings'),
        '/admin/customers/2/payments': _fx('customer_payments'),
        '/admin/customers/2/reviews': _fx('customer_reviews'),
        '/admin/customers/2/notes': _fx('customer_notes'),
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );

    await tester.tap(find.text('Bloquear cliente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloquear').last);
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/customers/2/block'), isEmpty);
  });

  RecordingDio fullRecorder() => RecordingDio(
    replies: {
      '/admin/customers/2': _fx('customer_detail'),
      '/admin/customers/2/bookings': _fx('customer_bookings'),
      '/admin/customers/2/payments': _fx('customer_payments'),
      '/admin/customers/2/reviews': _fx('customer_reviews'),
      '/admin/customers/2/notes': _fx('customer_notes'),
    },
  );

  testWidgets('given the customer when opening each tab then the real '
      'lists render without errors', (tester) async {
    final recorder = fullRecorder();
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );

    for (final tab in ['Pagamentos', 'Avaliações', 'Notas', 'Reservas']) {
      await tester.tap(
        find.descendant(of: find.byType(TabBar), matching: find.text(tab)),
      );
      await tester.pumpAndSettle();
    }

    expect(find.text('Hotel Copacabana'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('given the notes tab when adding a note then posts it', (
    tester,
  ) async {
    final recorder = fullRecorder();
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );

    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('Notas')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar nota'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      ),
      'Pediu 2ª via da nota fiscal',
    );
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/customers/2/notes').toList();
    expect(posts, hasLength(1));
    expect((posts.single.data as Map)['body'], 'Pediu 2ª via da nota fiscal');
  });

  Map<String, Object> repliesWithNote({bool blocked = false}) {
    final detail = Map<String, Object?>.from(
      _fx('customer_detail') as Map<String, dynamic>,
    );
    if (blocked) detail['status'] = 'BLOCKED';
    return {
      '/admin/customers/2': detail as Object,
      '/admin/customers/2/bookings': _fx('customer_bookings'),
      '/admin/customers/2/payments': _fx('customer_payments'),
      '/admin/customers/2/reviews': _fx('customer_reviews'),
      '/admin/customers/2/notes': {
        'items': [
          {
            'id': 5,
            'authorId': 1,
            'body': 'Cliente pediu segunda via',
            'pinned': false,
            'createdAt': '2026-10-09T20:00:00Z',
          },
        ],
        'page': 0,
        'size': 20,
        'totalElements': 1,
        'totalPages': 1,
      },
    };
  }

  Future<RecordingDio> openNotes(WidgetTester tester) async {
    final recorder = RecordingDio(replies: repliesWithNote());
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );
    await tester.tap(
      find.descendant(of: find.byType(TabBar), matching: find.text('Notas')),
    );
    await tester.pumpAndSettle();
    return recorder;
  }

  testWidgets('given my note when pinning then patches pinned', (tester) async {
    final recorder = await openNotes(tester);

    await tester.tap(find.byTooltip('Editar nota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fixar'));
    await tester.pumpAndSettle();

    final patches = recorder.to('PATCH', '/admin/customers/2/notes/5');
    expect(patches, hasLength(1));
    expect((patches.single.data as Map)['pinned'], isTrue);
  });

  testWidgets('given my note when deleting after confirming then deletes it', (
    tester,
  ) async {
    final recorder = await openNotes(tester);

    await tester.tap(find.byTooltip('Editar nota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar nota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar nota').last);
    await tester.pumpAndSettle();

    expect(recorder.to('DELETE', '/admin/customers/2/notes/5'), hasLength(1));
  });

  testWidgets('given my note when editing the text then patches the body', (
    tester,
  ) async {
    final recorder = await openNotes(tester);

    await tester.tap(find.byTooltip('Editar nota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar nota').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      ),
      'Segunda via enviada por e-mail',
    );
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final patches = recorder.to('PATCH', '/admin/customers/2/notes/5').toList();
    expect(patches, hasLength(1));
    expect(
      (patches.single.data as Map)['body'],
      'Segunda via enviada por e-mail',
    );
  });

  testWidgets('given a blocked customer when unblocking after confirming '
      'then posts the unblock', (tester) async {
    final recorder = RecordingDio(replies: repliesWithNote(blocked: true));
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );

    await tester.tap(find.text('Desbloquear cliente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desbloquear cliente').last);
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/customers/2/unblock'), hasLength(1));
  });

  testWidgets('given the anonymize dialog when the phrase is typed then '
      'posts the erasure with the confirmation', (tester) async {
    final recorder = RecordingDio(replies: repliesWithNote());
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );

    await tester.ensureVisible(find.text('Anonimizar dados'));
    await tester.tap(find.text('Anonimizar dados'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Motivo (obrigatório)'),
      'Pedido do titular pela LGPD',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'ANONYMIZE 2'),
      'ANONYMIZE 2',
    );
    await tester.pump();
    await tester.tap(find.text('Anonimizar para sempre'));
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/customers/2/anonymize').toList();
    expect(posts, hasLength(1));
    expect((posts.single.data as Map)['confirmation'], 'ANONYMIZE 2');
  });

  testWidgets('given the customer when opening the history tab then lists '
      'the audit entries about them', (tester) async {
    final audit = _fx('audit');
    final recorder = RecordingDio(
      replies: {...repliesWithNote(), '/admin/audit': audit},
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Histórico'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cliente consultado'), findsWidgets);
  });

  testWidgets('given reviews in the customer when opening that tab then '
      'shows the rating and comment', (tester) async {
    final recorder = RecordingDio(
      replies: {
        ...repliesWithNote(),
        '/admin/customers/2/reviews': {
          'items': [
            {
              'id': 4,
              'bookingId': 2,
              'rating': 4,
              'comment': 'Hotel limpo e bem localizado',
              'createdAt': '2026-10-09T20:00:00Z',
            },
          ],
          'page': 0,
          'size': 20,
          'totalElements': 1,
          'totalPages': 1,
        },
      },
    );
    await pumpPortal(
      tester,
      dio: recorder.dio,
      child: CustomerDetailPage(id: 2, onBack: () {}),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(TabBar),
        matching: find.text('Avaliações'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hotel limpo e bem localizado'), findsOneWidget);
  });
}
