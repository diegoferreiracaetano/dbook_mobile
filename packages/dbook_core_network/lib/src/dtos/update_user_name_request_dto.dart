import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_user_name_request_dto.freezed.dart';
part 'update_user_name_request_dto.g.dart';

/// Corpo de `PATCH /users/me`.
@freezed
abstract class UpdateUserNameRequestDto with _$UpdateUserNameRequestDto {
  const factory UpdateUserNameRequestDto({required String name}) =
      _UpdateUserNameRequestDto;

  factory UpdateUserNameRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserNameRequestDtoFromJson(json);
}
