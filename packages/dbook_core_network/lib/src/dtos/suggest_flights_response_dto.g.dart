// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggest_flights_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SuggestFlightsResponseDto _$SuggestFlightsResponseDtoFromJson(
  Map<String, dynamic> json,
) => _SuggestFlightsResponseDto(
  suggestions: (json['suggestions'] as List<dynamic>)
      .map((e) => AiSuggestionItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SuggestFlightsResponseDtoToJson(
  _SuggestFlightsResponseDto instance,
) => <String, dynamic>{'suggestions': instance.suggestions};
