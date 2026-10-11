import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/inbox_notifier.dart';
import '../state/notification_providers.dart';

/// A caixa de entrada de notificações. Tocar numa abre a tela certa pelo tipo
/// ([onOpen], decidido pelo app: features não se importam) e a marca como
/// lida. Lista por cursor (carrega mais ao chegar no fim) e puxa para
/// atualizar.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({
    super.key,
    required this.onOpen,
    required this.onOpenPreferences,
  });

  final ValueChanged<AppNotification> onOpen;
  final VoidCallback onOpenPreferences;

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 240) {
        ref.read(inboxNotifierProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _markAll() async {
    try {
      await ref.read(inboxNotifierProvider.notifier).markAllRead();
    } on DbookNetworkException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(inboxNotifierProvider);
    final notifier = ref.read(inboxNotifierProvider.notifier);

    return Scaffold(
      appBar: DbookAppBar(
        title: 'Notificações',
        actions: [
          if (inbox.hasUnread)
            TextButton(onPressed: _markAll, child: const Text('Marcar todas')),
          IconButton(
            tooltip: 'Preferências',
            icon: const Icon(Icons.tune),
            onPressed: widget.onOpenPreferences,
          ),
        ],
      ),
      body: _body(inbox, notifier),
    );
  }

  Widget _body(InboxState inbox, InboxNotifier notifier) {
    if (inbox.isLoading && inbox.items.isEmpty) {
      return const DbookLoadingIndicator();
    }
    if (inbox.error != null && inbox.items.isEmpty) {
      final error = inbox.error;
      return DbookStatusPlaceholder(
        icon: Icons.error_outline,
        title: 'Não deu para carregar',
        message: error is DbookNetworkException
            ? error.message
            : 'Tente de novo em instantes.',
        actionLabel: 'Tentar de novo',
        onAction: notifier.refresh,
      );
    }
    if (inbox.items.isEmpty) {
      return const DbookStatusPlaceholder(
        icon: Icons.notifications_none,
        title: 'Nenhuma notificação ainda',
        message:
            'Você será avisado aqui quando uma reserva for confirmada ou '
            'expirar, quando um reembolso terminar e quando um voo mudar.',
      );
    }

    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: inbox.items.length + 1,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == inbox.items.length) return _footer(inbox, notifier);
          final item = inbox.items[index];
          return ListTile(
            leading: Icon(
              item.read ? Icons.notifications_none : Icons.notifications_active,
              color: item.read ? null : theme.colorScheme.primary,
              semanticLabel: item.read ? 'Lida' : 'Não lida',
            ),
            title: Text(
              item.title,
              style: item.read
                  ? null
                  : const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(item.body),
            onTap: () {
              notifier.markRead(item);
              widget.onOpen(item);
            },
          );
        },
      ),
    );
  }

  Widget _footer(InboxState inbox, InboxNotifier notifier) {
    if (inbox.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(DbookSpacing.lg),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (inbox.loadMoreError != null) {
      return TextButton(
        onPressed: notifier.loadMore,
        child: const Text('Não deu para carregar mais. Tentar de novo'),
      );
    }
    return const SizedBox(height: DbookSpacing.lg);
  }
}
