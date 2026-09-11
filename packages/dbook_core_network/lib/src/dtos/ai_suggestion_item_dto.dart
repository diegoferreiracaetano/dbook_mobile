import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_suggestion_item_dto.freezed.dart';
part 'ai_suggestion_item_dto.g.dart';

/// Item de `suggestions` na resposta de `POST /ai/suggestions`.
@freezed
abstract class AiSuggestionItemDto with _$AiSuggestionItemDto {
  const AiSuggestionItemDto._();

  const factory AiSuggestionItemDto({
    required int flightId,
    required String reason,
  }) = _AiSuggestionItemDto;

  factory AiSuggestionItemDto.fromJson(Map<String, dynamic> json) =>
      _$AiSuggestionItemDtoFromJson(json);

  AiSuggestion toDomain() {
    return AiSuggestion(flightId: flightId, reason: reason);
  }
}
