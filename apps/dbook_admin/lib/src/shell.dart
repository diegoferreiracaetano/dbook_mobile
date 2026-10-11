import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'connectivity.dart';
import 'destinations.dart';

/// A moldura do portal depois do login. O layout muda com a largura da
/// janela: barra lateral fixa (1024dp ou mais), trilho de ícones (600 a 1023)
/// ou gaveta (abaixo de 600). O menu sai das permissões de quem está logado:
/// o que o papel não alcança nem aparece.
class PortalShell extends ConsumerWidget {
  const PortalShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(staffProfileProvider);
    final items = visibleDestinations(profile);
    final current = destinationFor(location);
    final selected = items.indexWhere((d) => d.path == current?.path);
    final size = DbookBreakpoints.of(context);

    final body = Column(
      children: [
        const _Banners(),
        Expanded(child: IdleGuard(child: child)),
      ],
    );

    void open(PortalDestination destination) => context.go(destination.path);

    return switch (size) {
      DbookWindowSize.expanded => Scaffold(
        appBar: _appBar(context, ref, withMenu: false),
        body: Row(
          children: [
            SizedBox(
              width: 248,
              child: _SideMenu(items: items, selected: selected, onOpen: open),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      ),
      DbookWindowSize.medium => Scaffold(
        appBar: _appBar(context, ref, withMenu: false),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selected < 0 ? null : selected,
              onDestinationSelected: (index) => open(items[index]),
              destinations: [
                for (final item in items)
                  NavigationRailDestination(
                    icon: Tooltip(
                      message: item.label(l10n),
                      child: Icon(item.icon),
                    ),
                    label: Text(item.label(l10n)),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      ),
      DbookWindowSize.compact => Scaffold(
        appBar: _appBar(context, ref, withMenu: true),
        drawer: Drawer(
          child: SafeArea(
            child: _SideMenu(
              items: items,
              selected: selected,
              onOpen: (destination) {
                Navigator.of(context).pop();
                open(destination);
              },
            ),
          ),
        ),
        body: body,
      ),
    };
  }

  PreferredSizeWidget _appBar(
    BuildContext context,
    WidgetRef ref, {
    required bool withMenu,
  }) {
    final l10n = context.l10n;
    final profile = ref.watch(staffProfileProvider);

    return AppBar(
      automaticallyImplyLeading: withMenu,
      title: Text(l10n.appTitle),
      actions: [
        if (profile != null)
          PopupMenuButton<String>(
            tooltip: profile.name,
            icon: CircleAvatar(
              radius: 14,
              child: Text(
                profile.name.isEmpty ? '?' : profile.name[0].toUpperCase(),
              ),
            ),
            onSelected: (value) {
              if (value == 'account') context.go('/account');
              if (value == 'logout') {
                ref.read(adminSessionProvider.notifier).logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text('${profile.name}\n${profile.email}'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'account', child: Text(l10n.navAccount)),
              PopupMenuItem(value: 'logout', child: Text(l10n.navLogout)),
            ],
          ),
        const SizedBox(width: DbookSpacing.sm),
      ],
    );
  }
}

class _SideMenu extends StatelessWidget {
  const _SideMenu({
    required this.items,
    required this.selected,
    required this.onOpen,
  });

  final List<PortalDestination> items;
  final int selected;
  final ValueChanged<PortalDestination> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: l10n.navMenu,
      child: ListView(
        padding: const EdgeInsets.all(DbookSpacing.sm),
        children: [
          for (var i = 0; i < items.length; i++)
            ListTile(
              dense: true,
              leading: Icon(items[i].icon),
              title: Text(items[i].label(l10n)),
              selected: i == selected,
              selectedTileColor: theme.colorScheme.primaryContainer,
              onTap: () => onOpen(items[i]),
            ),
        ],
      ),
    );
  }
}

class _Banners extends ConsumerWidget {
  const _Banners();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final config = ref.watch(appConfigProvider);
    final reachable = ref.watch(apiReachableProvider).value ?? true;
    final environment = switch (config.environment) {
      'local' => l10n.envNameLocal,
      'staging' => l10n.envNameStaging,
      final other => other,
    };

    return Column(
      children: [
        if (!config.isProduction)
          SizedBox(
            width: double.infinity,
            child: DbookInlineStatusBanner(
              message: l10n.envBanner(environment),
              tone: DbookBannerTone.warning,
              icon: Icons.science_outlined,
            ),
          ),
        if (!reachable)
          SizedBox(
            width: double.infinity,
            child: DbookInlineStatusBanner(
              message: l10n.offlineBanner,
              tone: DbookBannerTone.warning,
              icon: Icons.cloud_off,
            ),
          ),
      ],
    );
  }
}
