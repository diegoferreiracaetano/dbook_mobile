import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:dbook_feature_notifications/dbook_feature_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AppNotification _n(int id, {bool read = false}) => AppNotification(
  id: id,
  type: NotificationType.bookingConfirmed,
  title: 'Reserva $id confirmada',
  body: 'Seu voo foi confirmado',
  read: read,
  createdAt: DateTime(2026, 10, 9),
);

class _FakeNotifications implements NotificationRepository {
  var unread = 3;
  var items = [_n(1), _n(2, read: true)];
  var prefs = const [
    NotificationPreference(
      type: NotificationType.bookingConfirmed,
      channel: NotificationChannel.email,
      enabled: true,
    ),
    NotificationPreference(
      type: NotificationType.bookingConfirmed,
      channel: NotificationChannel.push,
      enabled: false,
    ),
  ];
  final read = <int>[];

  @override
  Future<NotificationPage> list({
    String? cursor,
    int size = 20,
    bool unreadOnly = false,
  }) async => NotificationPage(items: items);

  @override
  Future<int> unreadCount() async => unread;

  @override
  Future<void> markRead(int id) async => read.add(id);

  @override
  Future<void> markAllRead() async => unread = 0;

  @override
  Future<List<NotificationPreference>> preferences() async => prefs;

  @override
  Future<List<NotificationPreference>> updatePreferences(
    List<NotificationPreference> changes,
  ) async {
    prefs = [
      for (final p in prefs)
        changes.firstWhere(
          (c) => c.type == p.type && c.channel == p.channel,
          orElse: () => p,
        ),
    ];
    return prefs;
  }

  @override
  Future<void> registerDevice({
    required String token,
    required String platform,
  }) async {}

  @override
  Future<void> unregisterDevice(String token) async {}
}

Widget _app(_FakeNotifications fake, Widget home) => ProviderScope(
  overrides: [notificationRepositoryProvider.overrideWithValue(fake)],
  child: MaterialApp(theme: DbookTheme.light, home: home),
);

void main() {
  testWidgets('given notifications when the inbox builds then lists them and '
      'opens the tapped one', (tester) async {
    AppNotification? opened;
    final fake = _FakeNotifications();
    await tester.pumpWidget(
      _app(
        fake,
        NotificationsPage(onOpen: (n) => opened = n, onOpenPreferences: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reserva 1 confirmada'), findsOneWidget);
    await tester.tap(find.text('Reserva 1 confirmada'));
    await tester.pumpAndSettle();

    expect(opened!.id, 1);
    expect(fake.read, [1]);
  });

  testWidgets('given an empty inbox when built then shows the empty state', (
    tester,
  ) async {
    final fake = _FakeNotifications()..items = [];
    await tester.pumpWidget(
      _app(fake, NotificationsPage(onOpen: (_) {}, onOpenPreferences: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma notificação ainda'), findsOneWidget);
  });

  testWidgets('given unread notifications when the bell builds then shows '
      'the count from the server', (tester) async {
    await tester.pumpWidget(
      _app(
        _FakeNotifications(),
        Scaffold(body: NotificationBell(onPressed: () {})),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.byTooltip('Notificações (3 não lidas)'), findsOneWidget);
  });

  testWidgets('given preferences when the page builds then lists the '
      'channel switches', (tester) async {
    await tester.pumpWidget(
      _app(_FakeNotifications(), const NotificationPreferencesPage()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsNWidgets(2));
  });

  testWidgets('given a switch when toggled then the new value is kept', (
    tester,
  ) async {
    final fake = _FakeNotifications();
    await tester.pumpWidget(_app(fake, const NotificationPreferencesPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    expect(
      fake.prefs
          .firstWhere((p) => p.channel == NotificationChannel.push)
          .enabled,
      isTrue,
    );
  });
}
