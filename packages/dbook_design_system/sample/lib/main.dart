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
            _DataDisplaySection(),
            _TripSummaryCardSection(),
            _CardsSection(),
            _FareDateStripSection(),
            _SeatMapSection(),
            _QrSection(),
            _FeedbackSection(),
            _SuccessScreenSection(),
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
  bool _agreedToTerms = false;
  String _cabinClass = 'Economy';
  RangeValues _priceRange = const RangeValues(200, 1200);

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
          const SizedBox(height: DbookSpacing.md),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _agreedToTerms,
            onChanged: (value) =>
                setState(() => _agreedToTerms = value ?? false),
            title: const Text('Aceito os Termos de Serviço'),
          ),
          const SizedBox(height: DbookSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _cabinClass,
            decoration: const InputDecoration(labelText: 'Classe'),
            items: const [
              DropdownMenuItem(value: 'Economy', child: Text('Econômica')),
              DropdownMenuItem(value: 'Business', child: Text('Executiva')),
            ],
            onChanged: (value) =>
                setState(() => _cabinClass = value ?? _cabinClass),
          ),
          const SizedBox(height: DbookSpacing.lg),
          Text('Faixa de preço', style: Theme.of(context).textTheme.labelLarge),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 2000,
            divisions: 20,
            labels: RangeLabels(
              'R\$${_priceRange.start.round()}',
              'R\$${_priceRange.end.round()}',
            ),
            onChanged: (values) => setState(() => _priceRange = values),
          ),
          const SizedBox(height: DbookSpacing.md),
          DbookSocialLoginRow(
            buttons: [
              DbookSocialLoginButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                onPressed: () {},
              ),
              DbookSocialLoginButton(
                icon: Icons.apple,
                label: 'Apple',
                onPressed: () {},
              ),
              DbookSocialLoginButton(
                icon: Icons.facebook,
                label: 'Facebook',
                onPressed: () {},
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

class _DataDisplaySection extends StatelessWidget {
  const _DataDisplaySection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Preço, badges e resumo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DbookPriceDisplay(amount: 'R\$ 612', caption: 'por pessoa'),
          const SizedBox(height: DbookSpacing.lg),
          const Row(
            children: [
              DbookNotificationBadge(
                count: 3,
                child: Icon(Icons.notifications_outlined),
              ),
              SizedBox(width: DbookSpacing.xl),
              DbookNotificationBadge(
                count: 0,
                child: Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          Card(
            child: Column(
              children: [
                DbookPricedListItem(
                  icon: Icons.event_seat_outlined,
                  title: 'Seat Selection',
                  subtitle: 'Choose your seat',
                  price: '\$15',
                  onTap: () {},
                ),
                DbookPricedListItem(
                  icon: Icons.luggage_outlined,
                  title: 'Extra Baggage',
                  subtitle: 'Add a checked bag',
                  price: '\$60',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: DbookSpacing.lg),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: DbookSpacing.sm),
            child: Column(
              children: [
                DbookSummaryRow(label: 'Flight (1 adult)', value: '\$450'),
                DbookSummaryRow(label: 'Taxes & Fees', value: '\$120'),
                DbookSummaryRow(label: 'Seat Selection', value: '\$15'),
                Divider(),
                DbookSummaryRow(
                  label: 'Total',
                  value: '\$585',
                  emphasize: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripSummaryCardSection extends StatelessWidget {
  const _TripSummaryCardSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Resumo de busca',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DbookTripSummaryCard(
            origin: 'São Paulo (GRU)',
            destination: 'Madrid (MAD)',
            dateRangeLabel: 'Jan 13 - Jan 30, 2026',
            passengersLabel: '1 Adult, Economy',
            onSwap: () {},
            onTapRoute: () {},
            onTapDates: () {},
            onTapPassengers: () {},
          ),
          const SizedBox(height: DbookSpacing.md),
          DbookTripSummaryCard(
            origin: 'GRU',
            destination: 'MAD',
            dateRangeLabel: 'Jan 13 - Jan 30',
            passengersLabel: '1 Adult',
            compact: true,
            onTapRoute: () {},
          ),
        ],
      ),
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  // Gradientes decorativos que substituem a foto real do destino — até o
  // dado vier da API (M4/M5) com a foto de verdade, isso evita depender de
  // uma imagem de terceiro embutida no repo ou de rede nos testes.
  static const _madridSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B3D91), Color(0xFF0085FF), Color(0xFFFF9D6C)],
  );

  static const _romeSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A1E5C), Color(0xFFB1456B), Color(0xFFFFC26B)],
  );

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Cards',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: DbookDestinationCard(
                    title: 'Madri, Espanha',
                    subtitle: 'a partir de R\$480',
                    background: const BoxDecoration(gradient: _madridSky),
                    onTap: () {},
                  ),
                ),
              ),
              const SizedBox(width: DbookSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 140,
                  child: DbookDestinationCard(
                    title: 'Roma, Itália',
                    subtitle: 'a partir de R\$520',
                    background: const BoxDecoration(gradient: _romeSky),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.md),
          DbookFlightResultTile(
            airlineName: 'Iberia',
            flightNumber: 'IB 6821',
            departureTime: '10:30',
            departureAirport: 'GRU',
            arrivalTime: '06:45',
            arrivalAirport: 'MAD',
            durationLabel: '2h 15m',
            price: '\$450',
            selected: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _FareDateStripSection extends StatefulWidget {
  const _FareDateStripSection();

  @override
  State<_FareDateStripSection> createState() => _FareDateStripSectionState();
}

class _FareDateStripSectionState extends State<_FareDateStripSection> {
  static const _options = [
    DbookFareDateOption(dayLabel: 'Sun', dateLabel: '11', price: '\$529'),
    DbookFareDateOption(dayLabel: 'Mon', dateLabel: '12', price: '\$499'),
    DbookFareDateOption(dayLabel: 'Tue', dateLabel: '13', price: '\$450'),
    DbookFareDateOption(dayLabel: 'Wed', dateLabel: '14', price: '\$520'),
    DbookFareDateOption(dayLabel: 'Thu', dateLabel: '15', price: '\$510'),
  ];

  var _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Faixa de data e preço',
      child: DbookFareDateStrip(
        options: _options,
        selectedIndex: _selectedIndex,
        onSelected: (index) => setState(() => _selectedIndex = index),
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

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<DbookStatusColors>()!;

    return _Section(
      title: 'Feedback',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DbookLoadingIndicator(message: 'Buscando voos...'),
          const SizedBox(height: DbookSpacing.xl),
          DbookStatusPlaceholder(
            icon: Icons.search_off,
            title: 'Nenhum voo encontrado',
            message: 'Tente outra data ou destino.',
          ),
          const SizedBox(height: DbookSpacing.xl),
          DbookStatusPlaceholder(
            icon: Icons.error_outline,
            iconColor: colorScheme.error,
            title: 'Algo deu errado',
            message: 'Não foi possível carregar os dados.',
            actionLabel: 'Tentar de novo',
            onAction: () {},
          ),
          const SizedBox(height: DbookSpacing.xl),
          DbookStatusPlaceholder(
            icon: Icons.check_circle,
            iconColor: statusColors.success,
            circleSize: 96,
            iconSize: 44,
            title: 'Reserva confirmada!',
            message: 'Seu voo para Madri está garantido.',
          ),
          const SizedBox(height: DbookSpacing.xl),
          const Wrap(
            spacing: DbookSpacing.md,
            runSpacing: DbookSpacing.md,
            children: [
              DbookInlineStatusBanner(message: 'Disponibilidade em tempo real'),
              DbookInlineStatusBanner(
                message: 'Reserva confirmada',
                tone: DbookBannerTone.success,
              ),
              DbookInlineStatusBanner(
                message: 'Poucos assentos restantes',
                tone: DbookBannerTone.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuccessScreenSection extends StatelessWidget {
  const _SuccessScreenSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Tela de sucesso',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DbookRadius.lg),
        child: SizedBox(
          height: 520,
          child: DbookSuccessScreen(
            title: 'Booking Confirmed!',
            message:
                'Your flight to Madrid is all set. A confirmation email '
                'has been sent to you@email.com',
            referenceLabel: 'Booking Reference',
            referenceValue: 'HF123456',
            onCopyReference: () {},
            primaryActionLabel: 'View My Trip',
            onPrimaryAction: () {},
            secondaryActionLabel: 'Back to Home',
            onSecondaryAction: () {},
          ),
        ),
      ),
    );
  }
}
