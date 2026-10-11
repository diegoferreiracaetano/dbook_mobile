import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_notifications/dbook_feature_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AppNotification _n(int id, {bool read = false}) => AppNotification(
  id: id,
  type: NotificationType.bookingConfirmed,
  title: 't$id',
  body: 'b$id',
  read: read,
  createdAt: DateTime(2026, 10, 9),
);

class _FakeNotifications implements NotificationRepository {
  List<NotificationPage> pages = [
    NotificationPage(items: [_n(1), _n(2)], nextCursor: 'c1'),
    NotificationPage(items: [_n(3)]),
  ];
  Object? markReadError;
  final markedRead = <int>[];
  final registered = <String>[];
  final unregistered = <String>[];
  var listCalls = 0;
  Object? registerError;

  @override
  Future<NotificationPage> list({
    String? cursor,
    int size = 20,
    bool unreadOnly = false,
  }) async {
    listCalls++;
    return cursor == null ? pages[0] : pages[1];
  }

  @override
  Future<int> unreadCount() async => 2;

  @override
  Future<void> markRead(int id) async {
    if (markReadError != null) throw markReadError!;
    markedRead.add(id);
  }

  @override
  Future<void> markAllRead() async {
    if (markReadError != null) throw markReadError!;
  }

  @override
  Future<List<NotificationPreference>> preferences() async => const [];

  @override
  Future<List<NotificationPreference>> updatePreferences(
    List<NotificationPreference> changes,
  ) async => changes;

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {
    if (registerError != null) throw registerError!;
    registered.add(token);
  }

  @override
  Future<void> unregisterDevice(String token) async => unregistered.add(token);
}

class _FixedToken implements PushTokenSource {
  @override
  Future<String?> token() async => 'tok-1';
}

ProviderContainer _container(_FakeNotifications fake) {
  final container = ProviderContainer(
    overrides: [
      notificationRepositoryProvider.overrideWithValue(fake),
      pushTokenSourceProvider.overrideWithValue(_FixedToken()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// O `build` agenda o primeiro carregamento sozinho; espera ele terminar.
Future<void> _settle(ProviderContainer container) async {
  for (var i = 0; i < 50; i++) {
    await Future<void>.delayed(Duration.zero);
    if (!container.read(inboxNotifierProvider).isLoading) return;
  }
}

void main() {
  test('given a first page when the inbox loads then it shows the items and '
      'the cursor', () async {
    final container = _container(_FakeNotifications());
    container.listen(inboxNotifierProvider, (_, _) {});

    await _settle(container);

    final state = container.read(inboxNotifierProvider);
    expect(state.items.map((n) => n.id), [1, 2]);
    expect(state.hasMore, isTrue);
    expect(state.isLoading, isFalse);
  });

  test('given more pages when loading more then appends them and clears the '
      'cursor', () async {
    final container = _container(_FakeNotifications());
    container.listen(inboxNotifierProvider, (_, _) {});
    final notifier = container.read(inboxNotifierProvider.notifier);
    await _settle(container);

    await notifier.loadMore();

    final state = container.read(inboxNotifierProvider);
    expect(state.items.map((n) => n.id), [1, 2, 3]);
    expect(state.hasMore, isFalse);
  });

  test('given the server refuses when marking read then the item goes back '
      'to unread', () async {
    final fake = _FakeNotifications()..markReadError = StateError('no');
    final container = _container(fake);
    container.listen(inboxNotifierProvider, (_, _) {});
    final notifier = container.read(inboxNotifierProvider.notifier);
    await _settle(container);

    await notifier.markRead(_n(1));

    expect(container.read(inboxNotifierProvider).items.first.read, isFalse);
  });

  test(
    'given the server accepts when marking read then the item stays read',
    () async {
      final fake = _FakeNotifications();
      final container = _container(fake);
      container.listen(inboxNotifierProvider, (_, _) {});
      final notifier = container.read(inboxNotifierProvider.notifier);
      await _settle(container);

      await notifier.markRead(_n(1));

      expect(container.read(inboxNotifierProvider).items.first.read, isTrue);
      expect(fake.markedRead, [1]);
    },
  );

  test('given a token when registering twice then registers the device '
      'once', () async {
    final fake = _FakeNotifications();
    final container = _container(fake);
    final registrar = container.read(deviceRegistrarProvider);

    await registrar.register();
    await registrar.register();

    expect(fake.registered, ['tok-1']);
  });

  test(
    'given the server fails when registering then it does not throw',
    () async {
      final fake = _FakeNotifications()..registerError = StateError('down');
      final container = _container(fake);

      await container.read(deviceRegistrarProvider).register();

      expect(fake.registered, isEmpty);
    },
  );

  test('given a registered device when signing out then unregisters its '
      'token', () async {
    final fake = _FakeNotifications();
    final container = _container(fake);
    final registrar = container.read(deviceRegistrarProvider);
    await registrar.register();

    await registrar.unregister();

    expect(fake.unregistered, ['tok-1']);
  });

  test('given a price alert notification when asking its target then goes '
      'to price alerts', () {
    final alert = AppNotification(
      id: 9,
      type: NotificationType.priceAlert,
      title: '',
      body: '',
      read: false,
      createdAt: DateTime(2026),
    );

    expect(alert.target, NotificationTarget.priceAlerts);
    expect(_n(1).target, NotificationTarget.trips);
  });
}
