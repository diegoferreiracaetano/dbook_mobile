import 'package:freezed_annotation/freezed_annotation.dart';

import 'role.dart';

part 'user.freezed.dart';

/// Usuário — espelha `UserResponse` do backend (sem `passwordHash`, que
/// nunca sai do servidor).
@freezed
abstract class User with _$User {
  const factory User({
    required int? id,
    required String email,
    required String name,
    required Role role,
  }) = _User;
}
