import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_providers.dart';

/// A caixa de entrada: a primeira página, mais as seguintes por cursor.
class InboxState {
  const InboxState({
    this.items = const [],
    this.nextCursor,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
    this.loadMoreError,
  });

  final List<AppNotification> items;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;

  /// Falha ao carregar a primeira página (a tela mostra "tentar de novo").
  final Object? error;

  /// Falha ao carregar mais (a lista fica; só o rodapé mostra o erro).
  final Object? loadMoreError;

  bool get hasMore => nextCursor != null;
  bool get hasUnread => items.any((n) => !n.read);

  InboxState copyWith({
    List<AppNotification>? items,
    String? Function()? nextCursor,
    bool? isLoading,
    bool? isLoadingMore,
    Object? Function()? error,
    Object? Function()? loadMoreError,
  }) => InboxState(
    items: items ?? this.items,
    nextCursor: nextCursor == null ? this.nextCursor : nextCursor(),
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error == null ? this.error : error(),
    loadMoreError: loadMoreError == null ? this.loadMoreError : loadMoreError(),
  );
}

class InboxNotifier extends Notifier<InboxState> {
  @override
  InboxState build() {
    Future<void>.microtask(refresh);
    return const InboxState();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final page = await ref.read(notificationRepositoryProvider).list();
      state = InboxState(
        items: page.items,
        nextCursor: page.nextCursor,
        isLoading: false,
      );
    } on Object catch (error) {
      state = state.copyWith(isLoading: false, error: () => error);
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.isLoadingMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true, loadMoreError: () => null);
    try {
      final page = await ref
          .read(notificationRepositoryProvider)
          .list(cursor: cursor);
      state = state.copyWith(
        items: [...state.items, ...page.items],
        nextCursor: () => page.nextCursor,
        isLoadingMore: false,
      );
    } on Object catch (error) {
      state = state.copyWith(isLoadingMore: false, loadMoreError: () => error);
    }
  }

  /// Marca como lida ao abrir. Na tela vira lida na hora; se o servidor
  /// recusa, volta a ser não lida (o estado real é o do servidor).
  Future<void> markRead(AppNotification notification) async {
    if (notification.read) return;
    _replace(notification.id, (n) => n.asRead());
    try {
      await ref.read(notificationRepositoryProvider).markRead(notification.id);
      ref.invalidate(unreadCountProvider);
    } on Object {
      _replace(notification.id, (_) => notification);
    }
  }

  /// "Marcar todas como lidas". Deixa o erro subir para a tela avisar.
  Future<void> markAllRead() async {
    final before = state.items;
    state = state.copyWith(items: [for (final n in before) n.asRead()]);
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      ref.invalidate(unreadCountProvider);
    } on Object {
      state = state.copyWith(items: before);
      rethrow;
    }
  }

  void _replace(int id, AppNotification Function(AppNotification) change) {
    state = state.copyWith(
      items: [for (final n in state.items) n.id == id ? change(n) : n],
    );
  }
}
