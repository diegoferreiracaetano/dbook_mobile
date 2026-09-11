import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_suggestion.freezed.dart';

/// Sugestão de voo da IA — espelha `AiSuggestionItem` do backend. Só
/// consultiva: nunca reserva sozinha.
@freezed
abstract class AiSuggestion with _$AiSuggestion {
  const factory AiSuggestion({required int flightId, required String reason}) =
      _AiSuggestion;
}
