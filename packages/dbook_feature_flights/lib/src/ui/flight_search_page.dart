import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/known_airports.dart';
import '../state/flight_providers.dart';
import 'airport_picker_sheet.dart';
import 'destination_grid_card.dart';

/// Dados de busca preenchidos — devolvidos por [onSearch] quando origem,
/// destino e data já estão selecionados.
class FlightSearchQuery {
  const FlightSearchQuery({
    required this.origin,
    required this.destination,
    required this.date,
  });

  final KnownAirport origin;
  final KnownAirport destination;
  final DateTime date;
}

/// Tela de busca — origem/destino (seletor de aeroporto conhecido) e data.
/// Passageiros não é um campo de verdade ainda: o backend não modela
/// quantidade de passageiro na busca (isso entra na reserva, M5).
class FlightSearchPage extends ConsumerStatefulWidget {
  const FlightSearchPage({super.key, required this.onSearch, this.drawer});

  final ValueChanged<FlightSearchQuery> onSearch;
  final Widget? drawer;

  @override
  ConsumerState<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends ConsumerState<FlightSearchPage> {
  KnownAirport? _origin = knownAirports.first;
  KnownAirport? _destination = knownAirports.length > 1
      ? knownAirports[1]
      : null;
  DateTime _date = DateTime.now().add(const Duration(days: 1));

  static final _dateFormat = DateFormat('EEE, MMM d, yyyy');

  void _selectDestination(KnownAirport destination) {
    setState(() => _destination = destination);
  }

  Future<void> _pickOrigin() async {
    final picked = await showAirportPickerSheet(context);
    if (picked != null) setState(() => _origin = picked);
  }

  Future<void> _pickDestination() async {
    final picked = await showAirportPickerSheet(context);
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
    if (picked != null) setState(() => _date = picked);
  }

  bool get _canSearch => _origin != null && _destination != null;

  void _search() {
    final origin = _origin;
    final destination = _destination;
    if (origin == null || destination == null) return;
    widget.onSearch(
      FlightSearchQuery(origin: origin, destination: destination, date: _date),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Chega aqui vindo da aba Explore com um destino escolhido — o
    // `IndexedStack` do shell mantém a Home montada mesmo fora de tela,
    // então `initState` já rodou muito antes de qualquer seleção no
    // Explore; só `ref.listen` continua reagindo depois disso. Limpa o
    // provider assim que consome (não é estado de busca persistente, só
    // uma ponte de navegação).
    ref.listen<KnownAirport?>(prefillDestinationProvider, (previous, next) {
      if (next == null) return;
      ref.read(prefillDestinationProvider.notifier).set(null);
      setState(() => _destination = next);
    });

    return Scaffold(
      appBar: const _HomeHeroBar(),
      drawer: widget.drawer,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DbookSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DbookSectionLabel(
              text: 'Pra onde vamos?',
              icon: Icons.flight_takeoff,
            ),
            const SizedBox(height: DbookSpacing.md),
            DbookTripSummaryCard(
              origin: _origin?.label ?? 'Selecionar',
              destination: _destination?.label ?? 'Selecionar',
              dateRangeLabel: _dateFormat.format(_date),
              passengersLabel: '1 Passenger',
              onTapRoute: _pickOrigin,
              onTapDestination: _pickDestination,
              onSwap: _swap,
              onTapDates: _pickDate,
            ),
            const SizedBox(height: DbookSpacing.xl),
            const DbookSectionLabel(
              text: 'Destinos em destaque',
              icon: Icons.travel_explore_outlined,
            ),
            const SizedBox(height: DbookSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: DbookSpacing.md,
                crossAxisSpacing: DbookSpacing.md,
                childAspectRatio: 0.95,
              ),
              itemCount: knownAirports.length,
              itemBuilder: (context, index) {
                final airport = knownAirports[index];
                return DestinationCard(
                  airport: airport,
                  index: index,
                  onTap: () => _selectDestination(airport),
                );
              },
            ),
          ],
        ),
      ),
      // M9-9.2: ação primária sempre alcançável, fixa no rodapé — nunca
      // solta no fim de um conteúdo que rola.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(DbookSpacing.lg),
        child: DbookButton(
          label: 'Search Flights',
          icon: Icons.search,
          onPressed: _canSearch ? _search : null,
        ),
      ),
    );
  }
}

/// Cabeçalho da Home — bloco na cor de marca com logo e tagline, no lugar
/// da app bar plana das outras telas (referência visual: Figma Make "App
/// de viagem com design system"). Continua sendo uma `AppBar` de verdade
/// por baixo, então o ícone do Drawer aparece sozinho quando [drawer] está
/// setado no `Scaffold` — nada de reimplementar esse comportamento.
class _HomeHeroBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeHeroBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      toolbarHeight: 72,
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
