import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_suggestion_providers.dart';
import 'ai_suggestion_state.dart';

class AiSuggestionNotifier extends Notifier<AiSuggestionState> {
  @override
  AiSuggestionState build() => const AiSuggestionState.idle();

  Future<void> suggest(String query) async {
    state = const AiSuggestionState.loading();
    try {
      final suggestions = await ref
          .read(aiSuggestionRepositoryProvider)
          .suggest(query);
      state = AiSuggestionState.success(suggestions);
    } on DbookNetworkException catch (error) {
      state = AiSuggestionState.error(error.message);
    }
  }
}
