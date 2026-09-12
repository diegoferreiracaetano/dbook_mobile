import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/known_airports.dart';
import 'airport_picker_sheet.dart';

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
class FlightSearchPage extends StatefulWidget {
  const FlightSearchPage({super.key, required this.onSearch, this.actions});

  final ValueChanged<FlightSearchQuery> onSearch;
  final List<Widget>? actions;

  @override
  State<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage> {
  KnownAirport? _origin = knownAirports.first;
  KnownAirport? _destination = knownAirports.length > 1
      ? knownAirports[1]
      : null;
  DateTime _date = DateTime.now().add(const Duration(days: 1));

  static final _dateFormat = DateFormat('EEE, MMM d, yyyy');

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
    return Scaffold(
      appBar: DbookAppBar(title: 'DBook', actions: widget.actions),
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
