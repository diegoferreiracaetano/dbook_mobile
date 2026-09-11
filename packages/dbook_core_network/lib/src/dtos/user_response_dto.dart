import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../wire_enums.dart';

part 'user_response_dto.freezed.dart';
part 'user_response_dto.g.dart';

/// Resposta de `POST /auth/register`.
@freezed
abstract class UserResponseDto with _$UserResponseDto {
  const UserResponseDto._();

  const factory UserResponseDto({
    required int? id,
    required String email,
    required String role,
  }) = _UserResponseDto;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);

  User toDomain() {
    return User(id: id, email: email, role: roleFromWire(role));
  }
}
