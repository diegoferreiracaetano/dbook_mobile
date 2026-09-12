import 'package:dbook_domain/dbook_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_suggestion_state.freezed.dart';

@freezed
sealed class AiSuggestionState with _$AiSuggestionState {
  const factory AiSuggestionState.idle() = AiSuggestionIdle;
  const factory AiSuggestionState.loading() = AiSuggestionLoading;
  const factory AiSuggestionState.success(List<AiSuggestion> suggestions) =
      AiSuggestionSuccess;
  const factory AiSuggestionState.error(String message) = AiSuggestionError;
}
