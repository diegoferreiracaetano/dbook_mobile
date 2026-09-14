// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserResponseDto _$UserResponseDtoFromJson(Map<String, dynamic> json) =>
    _UserResponseDto(
      id: (json['id'] as num?)?.toInt(),
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$UserResponseDtoToJson(_UserResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': instance.role,
    };
