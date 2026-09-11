import 'package:dbook_domain/dbook_domain.dart';
import 'package:test/test.dart';

class _FakeAiSuggestionRepository implements AiSuggestionRepository {
  String? capturedQuery;

  @override
  Future<List<AiSuggestion>> suggest(String query) async {
    capturedQuery = query;
    return const [AiSuggestion(flightId: 1, reason: 'Cheapest nonstop option')];
  }
}

void main() {
  test('given a natural language query when called then forwards it and '
      'returns suggestions', () async {
    final repository = _FakeAiSuggestionRepository();
    final useCase = SuggestFlightsUseCase(repository);

    final suggestions = await useCase('voos baratos pro Rio mês que vem');

    expect(repository.capturedQuery, 'voos baratos pro Rio mês que vem');
    expect(suggestions.single.flightId, 1);
  });
}
