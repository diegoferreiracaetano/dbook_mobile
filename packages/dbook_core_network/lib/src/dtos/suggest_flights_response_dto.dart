import 'package:freezed_annotation/freezed_annotation.dart';

import 'ai_suggestion_item_dto.dart';

part 'suggest_flights_response_dto.freezed.dart';
part 'suggest_flights_response_dto.g.dart';

/// Resposta de `POST /ai/suggestions`.
@freezed
abstract class SuggestFlightsResponseDto with _$SuggestFlightsResponseDto {
  const factory SuggestFlightsResponseDto({
    required List<AiSuggestionItemDto> suggestions,
  }) = _SuggestFlightsResponseDto;

  factory SuggestFlightsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestFlightsResponseDtoFromJson(json);
}
