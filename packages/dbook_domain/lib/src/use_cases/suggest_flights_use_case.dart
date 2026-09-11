import '../entities/ai_suggestion.dart';
import '../repositories/ai_suggestion_repository.dart';

class SuggestFlightsUseCase {
  const SuggestFlightsUseCase(this._repository);

  final AiSuggestionRepository _repository;

  Future<List<AiSuggestion>> call(String query) => _repository.suggest(query);
}
