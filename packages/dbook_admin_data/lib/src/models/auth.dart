import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';

import '../json.dart';

/// Quem está logado no portal e o que pode fazer (`GET /v1/admin/auth/me`).
/// O menu e os botões saem de [permissions]; quem autoriza de verdade é o
/// servidor (front burro).
class StaffProfile {
  const StaffProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    this.twoFactorEnabled = false,
    this.twoFactorRequired = false,
    this.mustChangePassword = false,
  });

  factory StaffProfile.fromJson(Json json) => StaffProfile(
    id: json.count('id'),
    name: json.text('name'),
    email: json.text('email'),
    role: roleFromWire(json.text('role')),
    permissions: permissionsFromWire(json.strings('permissions')),
    twoFactorEnabled: json.flag('twoFactorEnabled'),
    twoFactorRequired: json.flag('twoFactorRequired'),
    // O backend ainda não manda este campo (M28 do backend o deixou fora);
    // se passar a mandar, a troca de senha vira obrigatória sem mudar o app.
    mustChangePassword: json.flag('mustChangePassword'),
  );

  final int id;
  final String name;
  final String email;
  final Role role;
  final Set<Permission> permissions;
  final bool twoFactorEnabled;
  final bool twoFactorRequired;
  final bool mustChangePassword;

  bool can(Permission permission) => permissions.contains(permission);

  /// Verdadeiro se tem **todas** as permissões pedidas.
  bool canAll(Iterable<Permission> required) => required.every(can);
}

/// Resultado do primeiro passo do login: entrou, ou falta o segundo fator.
sealed class LoginOutcome {
  const LoginOutcome();
}

class LoginSucceeded extends LoginOutcome {
  const LoginSucceeded(this.accessToken);

  final String accessToken;
}

/// `202`: a conta precisa do segundo fator. [enrollmentRequired] diz que ela
/// ainda não cadastrou o autenticador.
class LoginNeedsSecondFactor extends LoginOutcome {
  const LoginNeedsSecondFactor({
    required this.challengeToken,
    required this.enrollmentRequired,
  });

  final String challengeToken;
  final bool enrollmentRequired;
}

/// Cadastro do autenticador: a URI para o QR e a chave para digitar à mão.
class TwoFactorEnrollment {
  const TwoFactorEnrollment({
    required this.otpauthUri,
    required this.manualEntryKey,
  });

  factory TwoFactorEnrollment.fromJson(Json json) => TwoFactorEnrollment(
    otpauthUri: json.text('otpauthUri'),
    manualEntryKey: json.text('manualEntryKey'),
  );

  final String otpauthUri;
  final String manualEntryKey;
}

/// Fim do cadastro feito durante o login: a sessão e os códigos de
/// recuperação, que **só aparecem aqui**.
class TwoFactorEnrolled {
  const TwoFactorEnrolled({
    required this.accessToken,
    required this.recoveryCodes,
  });

  factory TwoFactorEnrolled.fromJson(Json json) => TwoFactorEnrolled(
    accessToken: json.text('accessToken'),
    recoveryCodes: json.strings('recoveryCodes'),
  );

  final String accessToken;
  final List<String> recoveryCodes;
}

/// Resposta do aceite de convite.
class AcceptedInvitation {
  const AcceptedInvitation({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AcceptedInvitation.fromJson(Json json) => AcceptedInvitation(
    id: json.count('id'),
    name: json.text('name'),
    email: json.text('email'),
    role: roleFromWire(json.text('role')),
  );

  final int id;
  final String name;
  final String email;
  final Role role;
}
