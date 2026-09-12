import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/ai_suggestion_providers.dart';
import '../state/ai_suggestion_state.dart';

/// Busca em linguagem natural ("voo barato pra praia em janeiro") —
/// devolve `flightId` + motivo, não o [Flight] inteiro: o backend de
/// sugestão não embute os dados do voo na resposta, e não existe um
/// `GET /flights/{id}` pra completar depois. Mostra exatamente o que a API
/// devolve, sem fingir ter mais informação do que existe.
class AiSuggestionPage extends ConsumerStatefulWidget {
  const AiSuggestionPage({super.key});

  @override
  ConsumerState<AiSuggestionPage> createState() => _AiSuggestionPageState();
}

class _AiSuggestionPageState extends ConsumerState<AiSuggestionPage> {
  final _controller = TextEditingController();
  var _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String query) {
    if (query.trim().isEmpty) return;
    _lastQuery = query.trim();
    ref.read(aiSuggestionNotifierProvider.notifier).suggest(_lastQuery);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiSuggestionNotifierProvider);

    return Scaffold(
      appBar: const DbookAppBar(title: 'Ask DBook AI'),
      body: Padding(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DbookSearchField(
              controller: _controller,
              hintText: 'Ex.: voo barato pra praia em janeiro',
              onSubmitted: _submit,
            ),
            const SizedBox(height: DbookSpacing.lg),
            Expanded(
              child: _SuggestionsBody(
                state: state,
                onRetry: () => _submit(_lastQuery),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsBody extends StatelessWidget {
  const _SuggestionsBody({required this.state, required this.onRetry});

  final AiSuggestionState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AiSuggestionIdle() => const DbookStatusPlaceholder(
        icon: Icons.auto_awesome,
        title: 'Descreva sua viagem',
        message: 'Digite o que você procura e a IA sugere voos pra você.',
      ),
      AiSuggestionLoading() => const DbookLoadingIndicator(
        message: 'Pensando...',
      ),
      AiSuggestionError(:final message) => DbookStatusPlaceholder(
        icon: Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Não foi possível sugerir',
        message: message,
        actionLabel: 'Tentar de novo',
        onAction: onRetry,
      ),
      AiSuggestionSuccess(:final suggestions) when suggestions.isEmpty =>
        const DbookStatusPlaceholder(
          icon: Icons.search_off,
          title: 'Nenhuma sugestão',
          message: 'Tente descrever sua viagem de outro jeito.',
        ),
      AiSuggestionSuccess(:final suggestions) => _SuggestionList(
        suggestions: suggestions,
      ),
    };
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.suggestions});

  final List<AiSuggestion> suggestions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suggestions.length,
      separatorBuilder: (_, _) => const SizedBox(height: DbookSpacing.sm),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: Text('Flight #${suggestion.flightId}'),
            subtitle: Text(suggestion.reason),
          ),
        );
      },
    );
  }
}
