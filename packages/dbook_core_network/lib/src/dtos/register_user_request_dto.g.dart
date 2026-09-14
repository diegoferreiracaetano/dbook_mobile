// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_user_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterUserRequestDto _$RegisterUserRequestDtoFromJson(
  Map<String, dynamic> json,
) => _RegisterUserRequestDto(
  email: json['email'] as String,
  password: json['password'] as String,
  name: json['name'] as String,
);

Map<String, dynamic> _$RegisterUserRequestDtoToJson(
  _RegisterUserRequestDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'name': instance.name,
};
