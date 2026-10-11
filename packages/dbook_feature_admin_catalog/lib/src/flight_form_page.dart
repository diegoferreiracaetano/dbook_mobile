import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_admin_session/dbook_admin_session.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalog_providers.dart';

/// Cadastro ([id] nulo) e edição de voo. A edição manda de volta a `version`
/// que leu: se outra pessoa salvou antes, o servidor responde
/// `STALE_VERSION` e a tela mostra o que difere, com as opções de recarregar
/// ou de salvar as suas mudanças por cima.
class FlightFormPage extends ConsumerWidget {
  const FlightFormPage({
    super.key,
    this.id,
    required this.onBack,
    required this.onSaved,
  });

  final int? id;
  final VoidCallback onBack;

  /// Depois de salvar (o id do voo, se o servidor o devolveu).
  final ValueChanged<int?> onSaved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final flightId = id;
    if (flightId == null) {
      return _FlightForm(onBack: onBack, onSaved: onSaved);
    }

    final detail = ref.watch(flightDetailProvider(flightId));
    return detail.when(
      loading: () => const DbookLoadingIndicator(),
      error: (error, _) => DbookErrorState(
        message: portalErrorMessage(l10n, error),
        onRetry: () => ref.invalidate(flightDetailProvider(flightId)),
      ),
      // a `version` na chave: recarregar depois de um conflito refaz o formulário
      data: (data) => _FlightForm(
        key: ValueKey('${data.flight.id}-${data.flight.version}'),
        detail: data,
        onBack: onBack,
        onSaved: onSaved,
      ),
    );
  }
}

class _FlightForm extends ConsumerStatefulWidget {
  const _FlightForm({
    super.key,
    this.detail,
    required this.onBack,
    required this.onSaved,
  });

  final AdminFlightDetail? detail;
  final VoidCallback onBack;
  final ValueChanged<int?> onSaved;

  @override
  ConsumerState<_FlightForm> createState() => _FlightFormState();
}

class _FlightFormState extends ConsumerState<_FlightForm> {
  final _formKey = GlobalKey<FormState>();
  late final _number = TextEditingController(text: _flight?.flightNumber ?? '');
  late final _price = TextEditingController(
    text: _flight == null ? '' : _flight!.price.toStringAsFixed(2),
  );
  late final _capacity = TextEditingController(
    text: _flight?.totalCapacity.toString() ?? '',
  );
  String? _airline;
  String? _origin;
  String? _destination;
  late SeatClass _seatClass = _flight?.seatClass ?? SeatClass.economy;
  String? _aircraft;
  DateTime? _departure;
  DateTime? _arrival;
  late int _baseVersion = _flight?.version ?? 0;
  bool _busy = false;
  String? _error;
  AdminFlight? _conflictWith;

  AdminFlight? get _flight => widget.detail?.flight;
  bool get _isEdit => widget.detail != null;
  bool get _readOnly => _flight?.isCancelled ?? false;
  bool get _aircraftLocked => (_flight?.reservedSeats ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    final flight = _flight;
    if (flight != null) {
      _airline = flight.airlineIataCode;
      _origin = flight.origin;
      _destination = flight.destination;
      _aircraft = flight.aircraftType;
      _departure = flight.departureTime;
      _arrival = flight.arrivalTime;
    }
  }

  @override
  void dispose() {
    _number.dispose();
    _price.dispose();
    _capacity.dispose();
    super.dispose();
  }

  FlightForm? _collect() {
    final departure = _departure;
    final arrival = _arrival;
    final price = double.tryParse(_price.text.replaceAll(',', '.'));
    final capacity = int.tryParse(_capacity.text.trim());
    if (_airline == null ||
        _origin == null ||
        _destination == null ||
        _aircraft == null ||
        departure == null ||
        arrival == null ||
        price == null ||
        capacity == null) {
      return null;
    }
    return FlightForm(
      flightNumber: _number.text,
      airlineIataCode: _airline!,
      originIataCode: _origin!,
      destinationIataCode: _destination!,
      departureTime: departure,
      arrivalTime: arrival,
      seatClass: _seatClass,
      price: price,
      totalCapacity: capacity,
      aircraftType: _aircraft!,
    );
  }

  Future<void> _submit() async {
    if (_busy || _readOnly) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final form = _collect();
    if (form == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(catalogApiProvider);
    final l10n = context.l10n;
    try {
      int? savedId = _flight?.id;
      if (_isEdit) {
        await api.updateFlight(_flight!.id, form, version: _baseVersion);
      } else {
        savedId = await api.createFlight(form);
      }
      ref.invalidate(flightsProvider);
      if (savedId != null) ref.invalidate(flightDetailProvider(savedId));
      if (!mounted) return;
      showDbookToast(
        context,
        _isEdit ? l10n.flightFormSaved : l10n.flightFormCreated,
        tone: DbookToastTone.success,
      );
      widget.onSaved(savedId);
    } on DbookNetworkException catch (error) {
      if (!mounted) return;
      if (error.code == 'STALE_VERSION' && _isEdit) {
        await _showConflict();
      } else if (error is DbookConflictException) {
        setState(() => _error = l10n.errFlightRule);
      } else {
        setState(() => _error = portalErrorMessage(l10n, error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showConflict() async {
    try {
      final latest = await ref.read(catalogApiProvider).getFlight(_flight!.id);
      if (mounted) setState(() => _conflictWith = latest.flight);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = portalErrorMessage(context.l10n, error));
    }
  }

  Future<void> _cancelFlight() async {
    final l10n = context.l10n;
    final flight = _flight!;
    final confirmed = await showDbookConfirmationDialog(
      context,
      title: l10n.flightCancelTitle(flight.flightNumber),
      message: l10n.flightCancelMessage,
      confirmLabel: l10n.flightCancel,
      cancelLabel: l10n.commonCancel,
      level: DbookConfirmLevel.destructive,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(catalogApiProvider).cancelFlight(flight.id);
      ref.invalidate(flightsProvider);
      ref.invalidate(flightDetailProvider(flight.id));
      if (mounted) {
        showDbookToast(
          context,
          l10n.flightCancelDone,
          tone: DbookToastTone.success,
        );
      }
    } on Object catch (error) {
      ref.invalidate(flightDetailProvider(flight.id));
      if (mounted) {
        showDbookToast(
          context,
          portalErrorMessage(l10n, error),
          tone: DbookToastTone.danger,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final airlines = ref.watch(airlinesProvider);
    final airports = ref.watch(airportsProvider);
    final models = ref.watch(aircraftModelsProvider);
    final flight = _flight;

    final lookupError = airlines.error ?? airports.error ?? models.error;
    final ready = airlines.hasValue && airports.hasValue && models.hasValue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DbookSpacing.xl),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DbookBreadcrumbs(
                items: [
                  DbookBreadcrumbItem(
                    label: l10n.flightFormBackToList,
                    onTap: widget.onBack,
                  ),
                  DbookBreadcrumbItem(
                    label: flight == null
                        ? l10n.flightFormNewTitle
                        : flight.flightNumber,
                  ),
                ],
              ),
              const SizedBox(height: DbookSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      flight == null
                          ? l10n.flightFormNewTitle
                          : l10n.flightFormEditTitle(flight.flightNumber),
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  if (flight != null && !flight.isCancelled)
                    PermissionGate(
                      permission: Permission.flightWrite,
                      child: DbookButton(
                        label: l10n.flightCancel,
                        icon: Icons.cancel_outlined,
                        variant: DbookButtonVariant.secondary,
                        onPressed: widget.detail!.activeBookings > 0
                            ? null
                            : _cancelFlight,
                      ),
                    ),
                ],
              ),
              if (flight != null &&
                  widget.detail!.activeBookings > 0 &&
                  !flight.isCancelled) ...[
                const SizedBox(height: DbookSpacing.sm),
                DbookInlineStatusBanner(
                  tone: DbookBannerTone.info,
                  message:
                      '${l10n.flightCancelActive(widget.detail!.activeBookings)}. ${l10n.flightCancelBlocked}',
                ),
              ],
              if (_readOnly) ...[
                const SizedBox(height: DbookSpacing.md),
                DbookInlineStatusBanner(
                  tone: DbookBannerTone.warning,
                  message: l10n.flightFormCancelledReadOnly,
                ),
              ],
              if (_conflictWith != null) ...[
                const SizedBox(height: DbookSpacing.md),
                _ConflictPanel(
                  differences: _collect() == null
                      ? const []
                      : flightDifferences(_collect()!, _conflictWith!),
                  onReload: () =>
                      ref.invalidate(flightDetailProvider(_flight!.id)),
                  onKeepMine: () {
                    setState(() {
                      _baseVersion = _conflictWith!.version;
                      _conflictWith = null;
                    });
                    _submit();
                  },
                ),
              ],
              const SizedBox(height: DbookSpacing.lg),
              if (lookupError != null)
                DbookErrorState(
                  message: portalErrorMessage(l10n, lookupError),
                  onRetry: () {
                    ref.invalidate(airlinesProvider);
                    ref.invalidate(airportsProvider);
                    ref.invalidate(aircraftModelsProvider);
                  },
                )
              else if (!ready)
                const SizedBox(
                  height: DbookSizes.loadingMd,
                  child: DbookLoadingIndicator(),
                )
              else
                _buildForm(
                  context,
                  airlines.value!,
                  airports.value!,
                  models.value!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    List<Airline> airlines,
    List<Airport> airports,
    List<AircraftModel> models,
  ) {
    final l10n = context.l10n;
    final enabled = !_busy && !_readOnly;
    final reserved = _flight?.reservedSeats ?? 0;

    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.flightFormRequired : null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) ...[
            Semantics(liveRegion: true, child: DbookFieldError(_error!)),
            const SizedBox(height: DbookSpacing.md),
          ],
          DbookTextField(
            label: l10n.flightFormNumber,
            controller: _number,
            enabled: enabled,
            validator: required,
          ),
          const SizedBox(height: DbookSpacing.lg),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _airline,
            decoration: InputDecoration(labelText: l10n.flightFormAirline),
            items: [
              for (final a in airlines)
                DropdownMenuItem(
                  value: a.iataCode,
                  child: Text('${a.iataCode} · ${a.name}'),
                ),
            ],
            validator: (v) => v == null ? l10n.flightFormRequired : null,
            onChanged: enabled ? (v) => setState(() => _airline = v) : null,
          ),
          const SizedBox(height: DbookSpacing.lg),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _origin,
                  decoration: InputDecoration(labelText: l10n.flightFormOrigin),
                  items: [
                    for (final a in airports)
                      DropdownMenuItem(
                        value: a.iataCode,
                        child: Text('${a.iataCode} · ${a.city}'),
                      ),
                  ],
                  validator: (v) => v == null ? l10n.flightFormRequired : null,
                  onChanged: enabled
                      ? (v) => setState(() => _origin = v)
                      : null,
                ),
              ),
              const SizedBox(width: DbookSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _destination,
                  decoration: InputDecoration(
                    labelText: l10n.flightFormDestination,
                  ),
                  items: [
                    for (final a in airports)
                      DropdownMenuItem(
                        value: a.iataCode,
                        child: Text('${a.iataCode} · ${a.city}'),
                      ),
                  ],
                  validator: (v) {
                    if (v == null) return l10n.flightFormRequired;
                    return v == _origin ? l10n.flightFormSameAirport : null;
                  },
                  onChanged: enabled
                      ? (v) => setState(() => _destination = v)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _DateTimeField(
                  label: l10n.flightFormDeparture,
                  value: _departure,
                  enabled: enabled,
                  validator: (v) => v == null ? l10n.flightFormRequired : null,
                  onChanged: (v) => setState(() => _departure = v),
                ),
              ),
              const SizedBox(width: DbookSpacing.md),
              Expanded(
                child: _DateTimeField(
                  label: l10n.flightFormArrival,
                  value: _arrival,
                  enabled: enabled,
                  validator: (v) {
                    if (v == null) return l10n.flightFormRequired;
                    final departure = _departure;
                    return departure != null && !v.isAfter(departure)
                        ? l10n.flightFormArrivalAfterDeparture
                        : null;
                  },
                  onChanged: (v) => setState(() => _arrival = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          DropdownButtonFormField<SeatClass>(
            isExpanded: true,
            initialValue: _seatClass,
            decoration: InputDecoration(labelText: l10n.flightFormClass),
            items: [
              for (final c in SeatClass.values)
                if (c != SeatClass.unknown)
                  DropdownMenuItem(
                    value: c,
                    child: Text(seatClassLabel(l10n, c)),
                  ),
            ],
            onChanged: enabled
                ? (v) => setState(() => _seatClass = v ?? _seatClass)
                : null,
          ),
          const SizedBox(height: DbookSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DbookTextField(
                  label: l10n.flightFormPrice,
                  controller: _price,
                  enabled: enabled,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final value = double.tryParse(
                      (v ?? '').replaceAll(',', '.'),
                    );
                    return value == null || value <= 0
                        ? l10n.flightFormPriceInvalid
                        : null;
                  },
                ),
              ),
              const SizedBox(width: DbookSpacing.md),
              Expanded(
                child: DbookTextField(
                  label: l10n.flightFormCapacity,
                  controller: _capacity,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  helperText: reserved > 0
                      ? l10n.flightFormReserved(reserved)
                      : null,
                  validator: (v) {
                    final value = int.tryParse((v ?? '').trim());
                    if (value == null || value <= 0) {
                      return l10n.flightFormCapacityInvalid;
                    }
                    return value < reserved
                        ? l10n.flightFormReserved(reserved)
                        : null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: DbookSpacing.lg),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: models.any((m) => m.name == _aircraft)
                ? _aircraft
                : null,
            decoration: InputDecoration(
              labelText: l10n.flightFormAircraft,
              helperText: _aircraftLocked
                  ? l10n.flightFormAircraftLocked
                  : null,
            ),
            items: [
              for (final m in models)
                DropdownMenuItem(
                  value: m.name,
                  child: Text('${m.name} (${m.seatLayout.join('-')})'),
                ),
            ],
            validator: (v) => v == null ? l10n.flightFormRequired : null,
            onChanged: enabled && !_aircraftLocked
                ? (v) => setState(() => _aircraft = v)
                : null,
          ),
          const SizedBox(height: DbookSpacing.xl),
          if (!_readOnly)
            PermissionGate(
              permission: Permission.flightWrite,
              child: DbookButton(
                label: l10n.flightFormSave,
                isLoading: _busy,
                onPressed: _submit,
              ),
            ),
        ],
      ),
    );
  }
}

/// Data e hora num campo só: toca para escolher a data e depois a hora.
class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final DateTime? value;
  final bool enabled;
  final ValueChanged<DateTime> onChanged;
  final FormFieldValidator<DateTime>? validator;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial = value ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FormField<DateTime>(
      key: ValueKey(value),
      initialValue: value,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) => InkWell(
        onTap: enabled ? () => _pick(context) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.event_outlined),
            errorText: state.errorText,
          ),
          child: Text(
            value == null
                ? l10n.flightFormPickDateTime
                : PortalFormats.dateTime(value!),
          ),
        ),
      ),
    );
  }
}

class _ConflictPanel extends StatelessWidget {
  const _ConflictPanel({
    required this.differences,
    required this.onReload,
    required this.onKeepMine,
  });

  final List<FlightDifference> differences;
  final VoidCallback onReload;
  final VoidCallback onKeepMine;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      child: Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(DbookSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.conflictTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: DbookSpacing.xs),
              Text(
                differences.isEmpty
                    ? l10n.conflictNoDifferences
                    : l10n.conflictMessage,
              ),
              if (differences.isNotEmpty) ...[
                const SizedBox(height: DbookSpacing.md),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text(
                          l10n.conflictColField,
                          style: theme.textTheme.labelLarge,
                        ),
                        Text(
                          l10n.conflictColMine,
                          style: theme.textTheme.labelLarge,
                        ),
                        Text(
                          l10n.conflictColTheirs,
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                    for (final d in differences)
                      TableRow(
                        children: [
                          Text(d.field, style: DbookTypography.mono),
                          Text(d.mine),
                          Text(d.theirs),
                        ],
                      ),
                  ],
                ),
              ],
              const SizedBox(height: DbookSpacing.md),
              Wrap(
                spacing: DbookSpacing.sm,
                runSpacing: DbookSpacing.sm,
                children: [
                  DbookButton(
                    label: l10n.conflictReload,
                    variant: DbookButtonVariant.secondary,
                    onPressed: onReload,
                  ),
                  DbookButton(
                    label: l10n.conflictKeepMine,
                    onPressed: onKeepMine,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
