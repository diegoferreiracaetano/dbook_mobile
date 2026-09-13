import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/flight_providers.dart';
import 'airport_picker_sheet.dart';
import 'destination_grid_card.dart';
import 'region_carousel.dart';

/// Dados de busca preenchidos — devolvidos por [onSearch] quando origem,
/// destino e data já estão selecionados.
class FlightSearchQuery {
  const FlightSearchQuery({
    required this.origin,
    required this.destination,
    required this.date,
  });

  final Destination origin;
  final Destination destination;
  final DateTime date;
}

/// Tipo de viagem — Round Trip mostra o campo "Return"; Multi-city mostra
/// a lista de trechos extras abaixo do card principal. O backend não
/// modela nada disso: `POST /bookings` é sempre 1 voo por vez, sem
/// conceito de ida-e-volta nem reserva multi-trecho. Por isso Multi-city
/// não é decorativo — é N compras reais e independentes encadeadas na
/// mesma jornada (busca→detalhe→assento→confirmação, repetido por
/// trecho), não um trecho de verdade com o resto fingido. Ver
/// `_FlightSearchPageState._search`.
enum _TripType {
  roundTrip('Round Trip'),
  oneWay('One Way'),
  multiCity('Multi-city');

  const _TripType(this.label);
  final String label;
}

/// Um trecho extra da jornada Multi-city — o trecho principal já é
/// representado pelos campos soltos (`_origin`/`_destination`/`_date`) do
/// próprio state, então isso só existe para o 2º trecho em diante.
class _FlightLeg {
  _FlightLeg({required this.date});

  Destination? origin;
  Destination? destination;
  DateTime date;
}

/// Tela de busca — origem/destino (seletor de aeroporto conhecido) e data.
/// Passageiros não é um campo de verdade ainda: o backend não modela
/// quantidade de passageiro na busca (isso entra na reserva, M5).
class FlightSearchPage extends ConsumerStatefulWidget {
  const FlightSearchPage({
    super.key,
    required this.onSearch,
    this.onSelectRegion,
    this.actions,
  });

  /// Sempre a lista completa de trechos, na ordem em que devem ser
  /// buscados — 1 item pra Round Trip/One Way, 1+N pra Multi-city (ver
  /// [_TripType]).
  final ValueChanged<List<FlightSearchQuery>> onSearch;

  /// Tocar um card do carrossel de regiões chama isto — quem monta esta
  /// página decide o que fazer (levar pra aba Explore já filtrada
  /// naquela região, no caso do app).
  final ValueChanged<String>? onSelectRegion;
  final List<Widget>? actions;

  @override
  ConsumerState<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends ConsumerState<FlightSearchPage> {
  // Nascem `null` — não dá mais pra popular no field initializer, a lista
  // de destinos agora vem de `GET /destinations` (assíncrono). Ver o
  // `ref.listen` no `build()`: assim que a 1ª busca resolve, os 2
  // primeiros destinos preenchem `_origin`/`_destination`, só se o usuário
  // ainda não tiver escolhido nada.
  Destination? _origin;
  Destination? _destination;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 8));
  _TripType _tripType = _TripType.roundTrip;
  final List<_FlightLeg> _extraLegs = [];

  static final _dateFormat = DateFormat('EEE, MMM d, yyyy');

  void _selectDestination(Destination destination) {
    setState(() => _destination = destination);
  }

  /// Google Flights (referência que o usuário confirmou) começa Multi-city
  /// com só 1 trecho visível (o principal, já existente) — nenhum extra é
  /// criado sozinho. O usuário adiciona um de cada vez com "Add another
  /// flight", até no máximo 5 no total (mesmo limite do Google Flights).
  static const _maxLegs = 5;

  void _selectTripType(_TripType type) {
    setState(() => _tripType = type);
  }

  bool get _canAddLeg => _extraLegs.length + 1 < _maxLegs;

  void _addLeg() {
    if (!_canAddLeg) return;
    // O destino do trecho anterior já vem preenchido como origem do
    // próximo — mesmo encadeamento automático do Google Flights (quem
    // viaja pra vários lugares geralmente segue voando de onde chegou).
    final previousDestination = _extraLegs.isEmpty
        ? _destination
        : _extraLegs.last.destination;
    final lastDate = _extraLegs.isEmpty ? _date : _extraLegs.last.date;
    setState(
      () => _extraLegs.add(
        _FlightLeg(date: lastDate.add(const Duration(days: 1)))
          ..origin = previousDestination,
      ),
    );
  }

  void _removeLeg(int index) {
    setState(() => _extraLegs.removeAt(index));
  }

  void _swapLeg(int index) {
    setState(() {
      final leg = _extraLegs[index];
      final origin = leg.origin;
      leg.origin = leg.destination;
      leg.destination = origin;
    });
  }

  Future<void> _pickLegOrigin(int index) async {
    final picked = await showAirportPickerSheet(context, _destinations);
    if (picked != null) {
      setState(() => _extraLegs[index].origin = picked);
    }
  }

  Future<void> _pickLegDestination(int index) async {
    final picked = await showAirportPickerSheet(context, _destinations);
    if (picked != null) {
      setState(() => _extraLegs[index].destination = picked);
    }
  }

  Future<void> _pickLegDate(int index) async {
    final leg = _extraLegs[index];
    final picked = await showDatePicker(
      context: context,
      initialDate: leg.date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => leg.date = picked);
  }

  Future<void> _pickOrigin() async {
    final picked = await showAirportPickerSheet(context, _destinations);
    if (picked != null) setState(() => _origin = picked);
  }

  Future<void> _pickDestination() async {
    final picked = await showAirportPickerSheet(context, _destinations);
    if (picked != null) setState(() => _destination = picked);
  }

  void _swap() {
    setState(() {
      final origin = _origin;
      _origin = _destination;
      _destination = origin;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      // Volta não pode ser antes da ida.
      if (_returnDate.isBefore(_date)) {
        _returnDate = _date.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _pickReturnDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate.isBefore(_date)
          ? _date.add(const Duration(days: 1))
          : _returnDate,
      firstDate: _date,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _returnDate = picked);
  }

  bool get _canSearch {
    if (_origin == null || _destination == null) return false;
    if (_tripType != _TripType.multiCity) return true;
    return _extraLegs.every(
      (leg) => leg.origin != null && leg.destination != null,
    );
  }

  void _search() {
    final origin = _origin;
    final destination = _destination;
    if (!_canSearch || origin == null || destination == null) return;

    final queries = [
      FlightSearchQuery(origin: origin, destination: destination, date: _date),
      if (_tripType == _TripType.multiCity)
        for (final leg in _extraLegs)
          FlightSearchQuery(
            origin: leg.origin!,
            destination: leg.destination!,
            date: leg.date,
          ),
    ];
    widget.onSearch(queries);
  }

  /// Lista de destinos já carregada (vazia enquanto `featuredDestinationsProvider`
  /// ainda não resolveu, ou se der erro) — usada pra popular o seletor de
  /// origem/destino sem cada picker precisar ler o provider sozinho.
  List<Destination> get _destinations =>
      ref.read(featuredDestinationsProvider).value ?? const [];

  /// Puxar pra baixo refaz a busca de destinos — a Home fica montada o
  /// tempo todo (`IndexedStack` do shell), então sem isso o "from $X"
  /// nunca se atualiza sozinho, mesmo com voos novos cadastrados depois
  /// que a tela já carregou. `ref.refresh(...future)` (em vez de só
  /// `invalidate`) devolve o `Future` da busca nova, então dá pra esperar
  /// terminar antes do indicador de "puxar pra atualizar" sumir.
  Future<void> _onRefresh() async {
    final _ = await ref.refresh(featuredDestinationsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    // Chega aqui vindo da aba Explore com um destino escolhido — o
    // `IndexedStack` do shell mantém a Home montada mesmo fora de tela,
    // então `initState` já rodou muito antes de qualquer seleção no
    // Explore; só `ref.listen` continua reagindo depois disso. Limpa o
    // provider assim que consome (não é estado de busca persistente, só
    // uma ponte de navegação).
    ref.listen<Destination?>(prefillDestinationProvider, (previous, next) {
      if (next == null) return;
      ref.read(prefillDestinationProvider.notifier).set(null);
      setState(() => _destination = next);
    });

    // A 1ª vez que a lista de destinos chega, popula origem/destino com os
    // 2 primeiros — só se o usuário ainda não tiver escolhido nada (não
    // sobrescreve uma seleção manual em refreshes seguintes).
    ref.listen<AsyncValue<List<Destination>>>(featuredDestinationsProvider, (
      previous,
      next,
    ) {
      final destinations = next.value;
      if (destinations == null || destinations.isEmpty) return;
      if (_origin != null && _destination != null) return;
      setState(() {
        _origin ??= destinations.first;
        _destination ??= destinations.length > 1
            ? destinations[1]
            : destinations.first;
      });
    });

    final destinationsAsync = ref.watch(featuredDestinationsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: _HomeHeroBar(actions: widget.actions),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Zona azul — mesma cor da hero bar, o cartão de busca "flutua"
              // dentro dela (referência: Figma Make "App de viagem com
              // design system").
              Container(
                color: colorScheme.primary,
                padding: const EdgeInsets.fromLTRB(
                  DbookSpacing.lg,
                  0,
                  DbookSpacing.lg,
                  DbookSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TripTypeRow(
                      selected: _tripType,
                      onChanged: _selectTripType,
                      enabled: false,
                    ),
                    const SizedBox(height: DbookSpacing.md),
                    DbookTripSummaryCard(
                      origin: _origin?.label ?? 'Selecionar',
                      destination: _destination?.label ?? 'Selecionar',
                      dateRangeLabel: _dateFormat.format(_date),
                      returnDateLabel: _tripType == _TripType.roundTrip
                          ? _dateFormat.format(_returnDate)
                          : null,
                      passengersLabel: '1 Passenger',
                      onTapRoute: _pickOrigin,
                      onTapDestination: _pickDestination,
                      onSwap: _swap,
                      onTapDates: _pickDate,
                      onTapReturnDate: _pickReturnDate,
                      searchLabel: 'Search Flights',
                      onSearch: _canSearch ? _search : null,
                      // Multi-city: trechos extras são seções do MESMO
                      // card (divididas por uma linha fina), não cards
                      // separados — confirmado com o usuário depois de
                      // pesquisar a referência real (Google Flights).
                      extraContent: _tripType != _TripType.multiCity
                          ? null
                          : [
                              for (var i = 0; i < _extraLegs.length; i++) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: DbookSpacing.sm,
                                  ),
                                  child: Divider(height: 1),
                                ),
                                _ExtraLegSection(
                                  index: i,
                                  leg: _extraLegs[i],
                                  onRemove: () => _removeLeg(i),
                                  onSwap: () => _swapLeg(i),
                                  onTapOrigin: () => _pickLegOrigin(i),
                                  onTapDestination: () =>
                                      _pickLegDestination(i),
                                  onTapDate: () => _pickLegDate(i),
                                  dateFormat: _dateFormat,
                                ),
                              ],
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: DbookSpacing.sm,
                                ),
                                child: Divider(height: 1),
                              ),
                              DbookButton(
                                label: 'Add another flight',
                                icon: Icons.add,
                                variant: DbookButtonVariant.text,
                                onPressed: _canAddLeg ? _addLeg : null,
                              ),
                            ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(DbookSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DbookSectionLabel(
                      text: 'Destinos em destaque',
                      icon: Icons.travel_explore_outlined,
                    ),
                    const SizedBox(height: DbookSpacing.md),
                    switch (destinationsAsync) {
                      AsyncData(:final value) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DestinationCardGrid(
                            destinations: value
                                .where((d) => d.isPopular)
                                .toList(),
                            onSelect: _selectDestination,
                          ),
                          if (widget.onSelectRegion != null) ...[
                            const SizedBox(height: DbookSpacing.xl),
                            const DbookSectionLabel(
                              text: 'Explore por região',
                              icon: Icons.public_outlined,
                            ),
                            const SizedBox(height: DbookSpacing.md),
                            RegionCarousel(
                              destinations: value,
                              onSelectRegion: widget.onSelectRegion!,
                            ),
                          ],
                        ],
                      ),
                      AsyncError() => DbookStatusPlaceholder(
                        icon: Icons.error_outline,
                        iconColor: Theme.of(context).colorScheme.error,
                        title: 'Não foi possível carregar',
                        message: 'Tente de novo em instantes.',
                        actionLabel: 'Tentar de novo',
                        onAction: () =>
                            ref.invalidate(featuredDestinationsProvider),
                      ),
                      _ => const DbookLoadingIndicator(
                        message: 'Carregando destinos...',
                      ),
                    },
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Um trecho extra da jornada Multi-city (2º voo em diante) — seção do
/// MESMO card do trecho principal (sem `Card` própria; quem chama já
/// desenha um `Divider` antes), com origem/destino lado a lado (não
/// empilhados) pra caber compacto quando há vários trechos, seguindo a
/// referência que o usuário mandou (fluxo "Várias cidades" do Google
/// Flights).
class _ExtraLegSection extends StatelessWidget {
  const _ExtraLegSection({
    required this.index,
    required this.leg,
    required this.onRemove,
    required this.onSwap,
    required this.onTapOrigin,
    required this.onTapDestination,
    required this.onTapDate,
    required this.dateFormat,
  });

  final int index;
  final _FlightLeg leg;
  final VoidCallback onRemove;
  final VoidCallback onSwap;
  final VoidCallback onTapOrigin;
  final VoidCallback onTapDestination;
  final VoidCallback onTapDate;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: ValueKey('extra_leg_$index'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Flight ${index + 2}', style: textTheme.labelLarge),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove flight',
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: DbookSpacing.xs),
        Row(
          children: [
            Expanded(
              child: _CompactFieldBox(
                icon: Icons.flight_takeoff,
                value: leg.origin?.label ?? 'From',
                onTap: onTapOrigin,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: onSwap,
              visualDensity: VisualDensity.compact,
              color: colorScheme.primary,
            ),
            Expanded(
              child: _CompactFieldBox(
                icon: Icons.flight_land,
                value: leg.destination?.label ?? 'To',
                onTap: onTapDestination,
              ),
            ),
          ],
        ),
        const SizedBox(height: DbookSpacing.sm),
        _CompactFieldBox(
          icon: Icons.calendar_today_outlined,
          value: dateFormat.format(leg.date),
          onTap: onTapDate,
        ),
      ],
    );
  }
}

class _CompactFieldBox extends StatelessWidget {
  const _CompactFieldBox({required this.icon, required this.value, this.onTap});

  final IconData icon;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DbookRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: DbookSpacing.sm,
          vertical: DbookSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(DbookRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: DbookSpacing.xs),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round Trip / One Way / Multi-city — três rádios numa linha, sem fundo
/// próprio (fica sobre a zona azul da tela de busca).
///
/// [enabled] = `false` deixa os rádios visíveis (mostrando qual tipo
/// está selecionado) mas sem interação nenhuma — pedido do usuário
/// depois de retrabalhos repetidos no comportamento de Multi-city; a
/// implementação continua no código (`_TripType`, `_extraLegs` etc.),
/// só a troca de tipo fica pausada até isso ser revisado de novo.
class _TripTypeRow extends StatelessWidget {
  const _TripTypeRow({
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final _TripType selected;
  final ValueChanged<_TripType> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final row = RadioGroup<_TripType>(
      groupValue: selected,
      onChanged: (value) => onChanged(value!),
      child: Row(
        children: [
          for (final type in _TripType.values)
            Padding(
              padding: const EdgeInsets.only(right: DbookSpacing.sm),
              child: InkWell(
                onTap: enabled ? () => onChanged(type) : null,
                borderRadius: BorderRadius.circular(DbookRadius.full),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: DbookSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<_TripType>(
                        value: type,
                        fillColor: WidgetStatePropertyAll(
                          colorScheme.onPrimary,
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: DbookSpacing.xs),
                      Text(
                        type.label,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: selected == type
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (enabled) return row;
    return IgnorePointer(child: Opacity(opacity: 0.5, child: row));
  }
}

/// Cabeçalho da Home — bloco na cor de marca com logo e tagline, no lugar
/// da app bar plana das outras telas (referência visual: Figma Make "App
/// de viagem com design system"). [actions] vai na `AppBar` de verdade por
/// baixo, igual qualquer outra tela — sem Drawer aqui, a navegação vive
/// nas abas do rodapé.
class _HomeHeroBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeHeroBar({this.actions});

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      toolbarHeight: 72,
      actions: actions,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DbookRadius.md),
            ),
            child: Icon(
              Icons.flight_takeoff,
              color: colorScheme.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: DbookSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DBook',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Book Smarter, Travel Happier',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
