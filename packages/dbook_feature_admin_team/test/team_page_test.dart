import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_admin_team/dbook_feature_admin_team.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTeamApi implements TeamApi {
  _FakeTeamApi(this.staff);

  final List<StaffMember> staff;

  @override
  Future<List<StaffMember>> listStaff() async => staff;

  @override
  Future<List<Invitation>> listInvitations() async => const [];

  @override
  Future<Invitation> invite({required String email, required Role role}) =>
      throw UnimplementedError();

  @override
  Future<void> resendInvitation(int id) => throw UnimplementedError();

  @override
  Future<void> revokeInvitation(int id) => throw UnimplementedError();

  @override
  Future<StaffMember> changeRole({required int id, required Role role}) =>
      throw UnimplementedError();

  @override
  Future<StaffMember> block({required int id, required String reason}) =>
      throw UnimplementedError();

  @override
  Future<StaffMember> unblock(int id) => throw UnimplementedError();
}

const _me = StaffProfile(
  id: 1,
  name: 'Diego Ferreira',
  email: 'diego@dbook.test',
  role: Role.superAdmin,
  permissions: {Permission.adminPortalAccess, Permission.adminManage},
);

Widget _app(_FakeTeamApi api) => ProviderScope(
  overrides: [
    teamApiProvider.overrideWithValue(api),
    staffProfileProvider.overrideWithValue(_me),
  ],
  child: MaterialApp(
    theme: DbookTheme.light,
    locale: const Locale('pt'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: TeamPage()),
  ),
);

void main() {
  setUpAll(() async {
    await PortalFormats.init();
  });

  testWidgets('given staff from the server when built then lists the members '
      'and offers to invite', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(
        _FakeTeamApi(const [
          StaffMember(
            id: 1,
            name: 'Diego Ferreira',
            email: 'diego@dbook.test',
            role: Role.superAdmin,
            status: StaffStatus.active,
          ),
          StaffMember(
            id: 2,
            name: 'Bianca Souza',
            email: 'bianca@dbook.test',
            role: Role.support,
            status: StaffStatus.active,
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Diego Ferreira'), findsWidgets);
    expect(find.text('Bianca Souza'), findsOneWidget);
    expect(find.byIcon(Icons.person_add_alt), findsOneWidget);
  });
}
