import 'package:dbook_feature_admin_team/dbook_feature_admin_team.dart';
import 'package:dbook_domain/dbook_domain.dart' show Role;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/portal_harness.dart';

const _staff = [
  {
    'id': 1,
    'name': 'Admin',
    'email': 'admin@dbook.test',
    'role': 'SUPER_ADMIN',
    'status': 'ACTIVE',
  },
  {
    'id': 2,
    'name': 'Bianca Souza',
    'email': 'bianca@dbook.test',
    'role': 'SUPPORT',
    'status': 'ACTIVE',
  },
];

void main() {
  testWidgets('given the staff when inviting then posts the e-mail and role', (
    tester,
  ) async {
    final recorder = RecordingDio(
      replies: {'/admin/staff': _staff, '/admin/invitations': <Object>[]},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const TeamPage());

    await tester.tap(find.byIcon(Icons.person_add_alt));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'novo@dbook.test',
    );
    await tester.tap(find.text('Enviar convite'));
    await tester.pumpAndSettle();

    final posts = recorder.to('POST', '/admin/invitations').toList();
    expect(posts, hasLength(1));
    expect((posts.single.data as Map)['email'], 'novo@dbook.test');
  });

  testWidgets('given an e-mail with an account when inviting then explains '
      'it and keeps the dialog', (tester) async {
    final recorder = RecordingDio(
      replies: {'/admin/staff': _staff, '/admin/invitations': <Object>[]},
      failures: {
        'POST /admin/invitations': (status: 409, body: {'error': 'dup'}),
      },
    );
    await pumpPortal(tester, dio: recorder.dio, child: const TeamPage());

    await tester.tap(find.byIcon(Icons.person_add_alt));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'bianca@dbook.test',
    );
    await tester.tap(find.text('Enviar convite'));
    await tester.pumpAndSettle();

    expect(find.text('Já existe uma conta com este e-mail.'), findsOneWidget);
  });

  testWidgets('given a rejected block when confirming then shows the error '
      'in the dialog', (tester) async {
    final recorder = RecordingDio(
      replies: {'/admin/staff': _staff, '/admin/invitations': <Object>[]},
      failures: {
        'POST /admin/staff/2/block': (
          status: 409,
          body: {'error': 'Último super admin'},
        ),
      },
    );
    await pumpPortal(tester, dio: recorder.dio, child: const TeamPage());

    await tester.tap(find.byTooltip('Ações para Bianca Souza').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloquear'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Motivo');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Bloquear'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('given a member when blocking with a reason then posts the '
      'block', (tester) async {
    final recorder = RecordingDio(
      replies: {'/admin/staff': _staff, '/admin/invitations': <Object>[]},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const TeamPage());

    await tester.tap(find.byTooltip('Ações para Bianca Souza').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloquear'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Saiu da empresa');
    await tester.pump();

    expect(find.text('Saiu da empresa'), findsOneWidget);
  });

  testWidgets('given the staff when the invitations tab opens then it is '
      'empty without errors', (tester) async {
    final recorder = RecordingDio(
      replies: {'/admin/staff': _staff, '/admin/invitations': <Object>[]},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const TeamPage());

    await tester.tap(find.text('Convites'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('given a member when changing the role then sends the new '
      'role', (tester) async {
    final recorder = RecordingDio(
      replies: {'/admin/staff': _staff, '/admin/invitations': <Object>[]},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const TeamPage());

    await tester.tap(find.byTooltip('Ações para Bianca Souza').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alterar papel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(RadioListTile<Role>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Alterar papel'));
    await tester.pumpAndSettle();

    final calls = recorder.calls.where((c) => c.path == '/admin/staff/2/role');
    expect(calls, hasLength(1));
  });

  const invitations = [
    {
      'id': 9,
      'email': 'novo@dbook.test',
      'role': 'SUPPORT',
      'status': 'PENDING',
      'invitedBy': 1,
      'createdAt': '2026-10-09T20:00:00Z',
      'expiresAt': '2026-10-16T20:00:00Z',
    },
  ];

  Future<RecordingDio> openInvitations(WidgetTester tester) async {
    final recorder = RecordingDio(
      replies: {'/admin/staff': _staff, '/admin/invitations': invitations},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const TeamPage());
    await tester.tap(find.text('Convites'));
    await tester.pumpAndSettle();
    return recorder;
  }

  testWidgets('given a pending invitation when resending then posts the '
      'resend', (tester) async {
    final recorder = await openInvitations(tester);

    expect(find.text('novo@dbook.test'), findsWidgets);
    await tester.tap(find.byTooltip('Ações para novo@dbook.test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reenviar'));
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/invitations/9/resend'), hasLength(1));
  });

  testWidgets('given a pending invitation when revoking after confirming '
      'then deletes it', (tester) async {
    final recorder = await openInvitations(tester);

    await tester.tap(find.byTooltip('Ações para novo@dbook.test'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar convite'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar convite').last);
    await tester.pumpAndSettle();

    expect(recorder.to('DELETE', '/admin/invitations/9'), hasLength(1));
  });

  testWidgets('given a blocked member when unblocking after confirming then '
      'posts the unblock', (tester) async {
    final blocked = [
      _staff.first,
      {
        'id': 3,
        'name': 'Carla Dias',
        'email': 'carla@dbook.test',
        'role': 'SUPPORT',
        'status': 'BLOCKED',
        'blockedReason': 'Saiu da empresa',
      },
    ];
    final recorder = RecordingDio(
      replies: {'/admin/staff': blocked, '/admin/invitations': <Object>[]},
    );
    await pumpPortal(tester, dio: recorder.dio, child: const TeamPage());

    await tester.tap(find.byTooltip('Ações para Carla Dias').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desbloquear'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desbloquear').last);
    await tester.pumpAndSettle();

    expect(recorder.to('POST', '/admin/staff/3/unblock'), hasLength(1));
  });

  testWidgets('given the only active super admin when opening his actions '
      'then blocking is explained instead of offered', (tester) async {
    final recorder = RecordingDio(
      replies: {
        '/admin/staff': [_staff.first],
        '/admin/invitations': <Object>[],
      },
    );
    await pumpPortal(tester, dio: recorder.dio, child: const TeamPage());

    await tester.tap(find.byTooltip('Ações para Admin').first);
    await tester.pumpAndSettle();

    expect(find.text('Bloquear'), findsOneWidget);
    final item = tester.widget<PopupMenuItem<String>>(
      find.widgetWithText(PopupMenuItem<String>, 'Bloquear'),
    );
    expect(item.enabled, isFalse);
  });
}
