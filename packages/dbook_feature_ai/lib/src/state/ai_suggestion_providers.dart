import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_suggestion_notifier.dart';
import 'ai_suggestion_state.dart';

/// Usa o `dioProvider` compartilhado (`dbook_core_session`) — o mesmo Dio
/// autenticado de toda outra feature.
final aiSuggestionRepositoryProvider = Provider<AiSuggestionRepository>(
  (ref) => AiSuggestionRepositoryImpl(ref.watch(dioProvider)),
);

final aiSuggestionNotifierProvider =
    NotifierProvider<AiSuggestionNotifier, AiSuggestionState>(
      AiSuggestionNotifier.new,
    );
