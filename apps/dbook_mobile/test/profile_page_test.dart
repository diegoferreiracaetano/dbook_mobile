import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_auth/dbook_feature_auth.dart';
import 'package:dbook_mobile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Já nasce `loggedIn` com [email]/[name] fixos — pula bootstrap/getMe(),
/// que bateriam na rede de verdade.
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier({this.email, this.name});

  final String? email;
  final String? name;

  @override
  AuthState build() => AuthState.loggedIn(
    tokens: const AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    email: email,
    name: name,
  );

  @override
  Future<void> bootstrap() async {}
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.updateNameError});

  final DbookNetworkException? updateNameError;
  String? capturedName;

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) => throw UnimplementedError();

  @override
  Future<AuthTokens> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<AuthTokens> refresh(String refreshToken) => throw UnimplementedError();

  @override
  Future<User> getMe() => throw UnimplementedError();

  @override
  Future<User> updateName(String name) async {
    capturedName = name;
    if (updateNameError != null) throw updateNameError!;
    return User(id: 1, email: 'diego@dbook.com', name: name, role: Role.client);
  }
}

Widget _wrap(AuthRepository authRepository, {String? email, String? name}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      authNotifierProvider.overrideWith(
        () => _FakeAuthNotifier(email: email, name: name),
      ),
    ],
    child: MaterialApp(theme: DbookTheme.light, home: const ProfilePage()),
  );
}

void main() {
  testWidgets(
    'given a user with a real name when Profile builds then shows the name '
    'and e-mail',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          _FakeAuthRepository(),
          email: 'diego@dbook.com',
          name: 'Diego Ferreira',
        ),
      );

      expect(find.text('Diego Ferreira'), findsOneWidget);
      expect(find.text('diego@dbook.com'), findsOneWidget);
    },
  );

  testWidgets(
    'given a user with no name yet when Profile builds then shows a decent '
    'fallback instead of blank',
    (tester) async {
      await tester.pumpWidget(
        _wrap(_FakeAuthRepository(), email: 'diego@dbook.com', name: null),
      );

      expect(find.text('Sessão sem nome salvo'), findsOneWidget);
    },
  );

  testWidgets(
    'given Editar Perfil tapped when a new name is submitted then it saves '
    'and the header updates',
    (tester) async {
      final authRepository = _FakeAuthRepository();

      await tester.pumpWidget(
        _wrap(authRepository, email: 'diego@dbook.com', name: 'Diego'),
      );

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Diego Ferreira',
      );
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(authRepository.capturedName, 'Diego Ferreira');
      expect(find.text('Diego Ferreira'), findsOneWidget);
      expect(find.text('Perfil atualizado'), findsOneWidget);
    },
  );

  testWidgets(
    'given the update failing when submitted then shows the error inline '
    'and keeps the dialog open',
    (tester) async {
      final authRepository = _FakeAuthRepository(
        updateNameError: const DbookValidationException('Nome inválido'),
      );

      await tester.pumpWidget(
        _wrap(authRepository, email: 'diego@dbook.com', name: 'Diego'),
      );

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Novo Nome',
      );
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(find.text('Nome inválido'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(authRepository.capturedName, 'Novo Nome');
    },
  );
}
