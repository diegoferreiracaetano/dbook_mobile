import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_ai/dbook_feature_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAiSuggestionRepository implements AiSuggestionRepository {
  _FakeAiSuggestionRepository({this.suggestions = const [], this.error});

  final List<AiSuggestion> suggestions;
  final DbookNetworkException? error;

  @override
  Future<List<AiSuggestion>> suggest(String query) async {
    if (error != null) throw error!;
    return suggestions;
  }
}

Widget _wrap(Widget child, {required AiSuggestionRepository repository}) {
  return ProviderScope(
    overrides: [aiSuggestionRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: DbookTheme.light, home: child),
  );
}

void main() {
  testWidgets('given idle state when built then invites the user to type', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AiSuggestionPage(),
        repository: _FakeAiSuggestionRepository(),
      ),
    );

    expect(find.text('Descreva sua viagem'), findsOneWidget);
  });

  testWidgets(
    'given matching suggestions when a query is submitted then lists each '
    'one',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AiSuggestionPage(),
          repository: _FakeAiSuggestionRepository(
            suggestions: const [
              AiSuggestion(flightId: 42, reason: 'Best fare for your dates'),
            ],
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField),
        'cheap beach trip in january',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Flight #42'), findsOneWidget);
      expect(find.text('Best fare for your dates'), findsOneWidget);
    },
  );

  testWidgets(
    'given no suggestions when a query is submitted then shows the empty '
    'state',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AiSuggestionPage(),
          repository: _FakeAiSuggestionRepository(),
        ),
      );

      await tester.enterText(find.byType(TextField), 'anything');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma sugestão'), findsOneWidget);
    },
  );

  testWidgets(
    'given the backend rejects the request then shows the error with a '
    'retry that resubmits the same query',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AiSuggestionPage(),
          repository: _FakeAiSuggestionRepository(
            error: const DbookRateLimitException('Too many requests'),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'anything');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Too many requests'), findsOneWidget);

      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(find.text('Too many requests'), findsOneWidget);
    },
  );
}
