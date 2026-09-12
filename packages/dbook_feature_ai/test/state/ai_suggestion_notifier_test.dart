import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_ai/dbook_feature_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAiSuggestionRepository implements AiSuggestionRepository {
  _FakeAiSuggestionRepository({this.suggestions = const [], this.error});

  final List<AiSuggestion> suggestions;
  final DbookNetworkException? error;
  String? capturedQuery;

  @override
  Future<List<AiSuggestion>> suggest(String query) async {
    capturedQuery = query;
    if (error != null) throw error!;
    return suggestions;
  }
}

ProviderContainer _buildContainer(AiSuggestionRepository repository) {
  final container = ProviderContainer(
    overrides: [aiSuggestionRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('given fresh state when built then starts idle', () {
    final container = _buildContainer(_FakeAiSuggestionRepository());

    expect(
      container.read(aiSuggestionNotifierProvider),
      const AiSuggestionState.idle(),
    );
  });

  test('given matching suggestions when suggesting then forwards the query and '
      'ends up in success', () async {
    const suggestion = AiSuggestion(
      flightId: 1,
      reason: 'Cheapest fare to a beach destination in January',
    );
    final repository = _FakeAiSuggestionRepository(
      suggestions: const [suggestion],
    );
    final container = _buildContainer(repository);

    await container
        .read(aiSuggestionNotifierProvider.notifier)
        .suggest('cheap beach trip in january');

    final state = container.read(aiSuggestionNotifierProvider);
    expect(state, isA<AiSuggestionSuccess>());
    expect((state as AiSuggestionSuccess).suggestions, [suggestion]);
    expect(repository.capturedQuery, 'cheap beach trip in january');
  });

  test('given the backend rate-limits the request then ends up in error with '
      'the backend message', () async {
    final repository = _FakeAiSuggestionRepository(
      error: const DbookRateLimitException('Too many requests, slow down'),
    );
    final container = _buildContainer(repository);

    await container
        .read(aiSuggestionNotifierProvider.notifier)
        .suggest('anything');

    final state = container.read(aiSuggestionNotifierProvider);
    expect(state, isA<AiSuggestionError>());
    expect(
      (state as AiSuggestionError).message,
      'Too many requests, slow down',
    );
  });

  test('given the AI model is unavailable then ends up in error with the '
      'backend message', () async {
    final repository = _FakeAiSuggestionRepository(
      error: const DbookServiceUnavailableException('Model unavailable'),
    );
    final container = _buildContainer(repository);

    await container
        .read(aiSuggestionNotifierProvider.notifier)
        .suggest('anything');

    final state = container.read(aiSuggestionNotifierProvider);
    expect(state, isA<AiSuggestionError>());
    expect((state as AiSuggestionError).message, 'Model unavailable');
  });
}
