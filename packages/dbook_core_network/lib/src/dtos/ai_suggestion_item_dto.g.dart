// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_suggestion_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiSuggestionItemDto _$AiSuggestionItemDtoFromJson(Map<String, dynamic> json) =>
    _AiSuggestionItemDto(
      flightId: (json['flightId'] as num).toInt(),
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$AiSuggestionItemDtoToJson(
  _AiSuggestionItemDto instance,
) => <String, dynamic>{
  'flightId': instance.flightId,
  'reason': instance.reason,
};
