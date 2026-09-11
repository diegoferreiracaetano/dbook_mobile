import '../entities/ai_suggestion.dart';

/// Porta pras sugestões de voo por IA. O backend limita a 5 chamadas/min
/// por usuário (429) e audita toda chamada, com sucesso ou falha.
abstract interface class AiSuggestionRepository {
  /// `POST /ai/suggestions`
  Future<List<AiSuggestion>> suggest(String query);
}
