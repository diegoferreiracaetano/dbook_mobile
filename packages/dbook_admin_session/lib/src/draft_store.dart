import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rascunhos de texto em **memória** (nota de cliente, motivo de bloqueio...).
/// Se a sessão cai por ociosidade com um formulário aberto, o texto escrito
/// não se perde: ao voltar, a tela o oferece. Só memória, de propósito: texto
/// de cliente não vai para `localStorage`; recarregar a página o descarta.
class DraftStore extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  String? read(String key) => state[key];

  void write(String key, String text) {
    if (text.isEmpty) {
      clear(key);
      return;
    }
    state = {...state, key: text};
  }

  void clear(String key) {
    if (!state.containsKey(key)) return;
    state = {...state}..remove(key);
  }
}

final draftStoreProvider = NotifierProvider<DraftStore, Map<String, String>>(
  DraftStore.new,
);

/// Liga um campo ao [DraftStore]: guarda o que se digita e, se já havia um
/// rascunho com o campo vazio, mostra a oferta de recuperá-lo. Apague o
/// rascunho (`draftStoreProvider.notifier.clear(key)`) quando o envio der
/// certo.
class DraftGuard extends ConsumerStatefulWidget {
  const DraftGuard({
    super.key,
    required this.draftKey,
    required this.controller,
    required this.child,
  });

  final String draftKey;
  final TextEditingController controller;
  final Widget child;

  @override
  ConsumerState<DraftGuard> createState() => _DraftGuardState();
}

class _DraftGuardState extends ConsumerState<DraftGuard> {
  String? _offered;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(draftStoreProvider)[widget.draftKey];
    if (saved != null && saved.isNotEmpty && widget.controller.text.isEmpty) {
      _offered = saved;
    }
    widget.controller.addListener(_save);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_save);
    super.dispose();
  }

  void _save() {
    if (_offered != null) return;
    ref
        .read(draftStoreProvider.notifier)
        .write(widget.draftKey, widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final offered = _offered;
    if (offered == null) return widget.child;

    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MaterialBanner(
          content: Text(l10n.draftRestoreTitle),
          actions: [
            TextButton(
              onPressed: () {
                widget.controller.text = offered;
                setState(() => _offered = null);
              },
              child: Text(l10n.draftRestore),
            ),
            TextButton(
              onPressed: () {
                ref.read(draftStoreProvider.notifier).clear(widget.draftKey);
                setState(() => _offered = null);
              },
              child: Text(l10n.draftDiscard),
            ),
          ],
        ),
        widget.child,
      ],
    );
  }
}
