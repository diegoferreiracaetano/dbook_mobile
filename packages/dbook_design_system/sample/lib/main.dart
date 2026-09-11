import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DbookDesignSystemShowcase());
}

class DbookDesignSystemShowcase extends StatefulWidget {
  const DbookDesignSystemShowcase({super.key});

  @override
  State<DbookDesignSystemShowcase> createState() =>
      _DbookDesignSystemShowcaseState();
}

class _DbookDesignSystemShowcaseState extends State<DbookDesignSystemShowcase> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DBook Design System',
      theme: DbookTheme.light,
      darkTheme: DbookTheme.dark,
      themeMode: _themeMode,
      home: ShowcasePage(onToggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}

class ShowcasePage extends StatelessWidget {
  const ShowcasePage({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DBook Design System'),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: onToggleTheme,
            icon: Icon(
              themeMode == ThemeMode.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ColorsSection(),
            _TypographySection(),
            _ButtonsSection(),
            _FormSection(),
            _AvatarSection(),
            _StatusBadgeSection(),
            _CardsSection(),
            _SeatMapSection(),
            _QrSection(),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DbookSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: DbookSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<DbookStatusColors>()!;
    final swatches = <(String, Color)>[
      ('primary', colorScheme.primary),
      ('secondary', colorScheme.secondary),
      ('surface', colorScheme.surface),
      ('outline', colorScheme.outline),
      ('success', statusColors.success),
      ('warning', statusColors.warning),
      ('error', colorScheme.error),
    ];

    return _Section(
      title: 'Cores',
      child: Wrap(
        spacing: DbookSpacing.md,
        runSpacing: DbookSpacing.md,
        children: [
          for (final (label, color) in swatches)
            Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(DbookRadius.sm),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                ),
                const SizedBox(height: DbookSpacing.xs),
                Text(label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
        ],
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _Section(
      title: 'Tipografia',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Headline large', style: textTheme.headlineLarge),
          Text('Title large', style: textTheme.titleLarge),
          Text('Body large', style: textTheme.bodyLarge),
          Text('Label medium', style: textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Botões',
      child: Wrap(
        spacing: DbookSpacing.md,
        runSpacing: DbookSpacing.md,
        children: [
          DbookButton(label: 'Primário', onPressed: () {}),
          DbookButton(
            label: 'Secundário',
            variant: DbookButtonVariant.secondary,
            onPressed: () {},
          ),
          DbookButton(
            label: 'Texto',
            variant: DbookButtonVariant.text,
            onPressed: () {},
          ),
          DbookButton(
            label: 'Com ícone',
            icon: Icons.flight_takeoff,
            onPressed: () {},
          ),
          const DbookButton(
            label: 'Carregando',
            onPressed: null,
            isLoading: true,
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatefulWidget {
  const _FormSection();

  @override
  State<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Formulário',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DbookSearchField(
            controller: _controller,
            hintText: 'Para onde você vai?',
            onSubmitted: (_) {},
          ),
          const SizedBox(height: DbookSpacing.md),
          const Wrap(
            spacing: DbookSpacing.lg,
            children: [
              DbookLegendItem(label: 'Selecionado', color: Colors.blue),
              DbookLegendItem(
                label: 'Disponível',
                color: Colors.blue,
                outlined: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Avatar',
      child: Row(
        children: [
          DbookAvatar(initials: 'D', size: DbookAvatarSize.small),
          SizedBox(width: DbookSpacing.md),
          DbookAvatar(initials: 'DB', size: DbookAvatarSize.medium),
          SizedBox(width: DbookSpacing.md),
          DbookAvatar(initials: 'DBK', size: DbookAvatarSize.large),
        ],
      ),
    );
  }
}

class _StatusBadgeSection extends StatelessWidget {
  const _StatusBadgeSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Status',
      child: Wrap(
        spacing: DbookSpacing.md,
        children: [
          DbookStatusBadge(status: DbookStatus.confirmed, label: 'Confirmado'),
          DbookStatusBadge(status: DbookStatus.pending, label: 'Pendente'),
          DbookStatusBadge(status: DbookStatus.cancelled, label: 'Cancelado'),
        ],
      ),
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Cards',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: 220,
            child: DbookDestinationCard(
              title: 'Madri, Espanha',
              subtitle: 'a partir de R\$480',
              background: const BoxDecoration(color: Color(0xFF0085FF)),
              onTap: () {},
            ),
          ),
          const SizedBox(height: DbookSpacing.md),
          DbookFlightResultTile(
            timeRange: '08:00 — 10:35',
            durationLabel: '2h 35m direto',
            price: 'R\$ 612',
            selected: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SeatMapSection extends StatelessWidget {
  const _SeatMapSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Mapa de assento',
      child: Wrap(
        spacing: DbookSpacing.sm,
        children: [
          DbookSeatCell(state: DbookSeatState.available),
          DbookSeatCell(state: DbookSeatState.selected),
          DbookSeatCell(state: DbookSeatState.occupied),
        ],
      ),
    );
  }
}

class _QrSection extends StatelessWidget {
  const _QrSection();

  @override
  Widget build(BuildContext context) {
    return const _Section(
      title: 'Código QR (placeholder)',
      child: DbookQrPlaceholder(size: 80),
    );
  }
}
