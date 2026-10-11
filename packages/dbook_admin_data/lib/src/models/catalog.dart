import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';

import '../json.dart';

enum FlightStatus { scheduled, cancelled, unknown }

FlightStatus flightStatusFromWire(String value) => switch (value) {
  'SCHEDULED' => FlightStatus.scheduled,
  'CANCELLED' => FlightStatus.cancelled,
  _ => () {
    onUnknownWireValue('FlightStatus', value);
    return FlightStatus.unknown;
  }(),
};

String flightStatusToWire(FlightStatus status) => switch (status) {
  FlightStatus.scheduled => 'SCHEDULED',
  FlightStatus.cancelled => 'CANCELLED',
  FlightStatus.unknown => 'UNKNOWN',
};

String seatClassToWire(SeatClass seatClass) => switch (seatClass) {
  SeatClass.economy => 'ECONOMY',
  SeatClass.premiumEconomy => 'PREMIUM_ECONOMY',
  SeatClass.business => 'BUSINESS',
  SeatClass.first => 'FIRST',
  SeatClass.unknown => 'ECONOMY',
};

/// Os filtros da lista de voos; chave do provider e conteúdo da URL.
typedef FlightQuery = ({
  String origin,
  String destination,
  String airline,
  DateTime? departureFrom,
  DateTime? departureTo,
  FlightStatus? status,
  int page,
  int size,
});

const FlightQuery defaultFlightQuery = (
  origin: '',
  destination: '',
  airline: '',
  departureFrom: null,
  departureTo: null,
  status: null,
  page: 0,
  size: 20,
);

class AdminFlight {
  const AdminFlight({
    required this.id,
    required this.flightNumber,
    required this.airlineIataCode,
    required this.origin,
    required this.destination,
    required this.seatClass,
    required this.price,
    required this.totalCapacity,
    required this.availableSeats,
    required this.reservedSeats,
    required this.aircraftType,
    required this.seatLayout,
    required this.status,
    required this.version,
    this.airlineName,
    this.departureTime,
    this.arrivalTime,
  });

  factory AdminFlight.fromJson(Json json) => AdminFlight(
    id: json.count('id'),
    flightNumber: json.text('flightNumber'),
    airlineIataCode: json.text('airlineIataCode'),
    airlineName: json.str('airlineName'),
    origin: json.text('origin'),
    destination: json.text('destination'),
    departureTime: json.time('departureTime'),
    arrivalTime: json.time('arrivalTime'),
    seatClass: seatClassFromWire(json.text('seatClass')),
    price: json.decimal('price') ?? 0,
    totalCapacity: json.count('totalCapacity'),
    availableSeats: json.count('availableSeats'),
    reservedSeats: json.count('reservedSeats'),
    aircraftType: json.text('aircraftType'),
    seatLayout: [
      for (final n in (json['seatLayout'] as List? ?? const []))
        if (n is num) n.toInt(),
    ],
    status: flightStatusFromWire(json.text('status')),
    version: json.count('version'),
  );

  final int id;
  final String flightNumber;
  final String airlineIataCode;
  final String? airlineName;
  final String origin;
  final String destination;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final SeatClass seatClass;
  final double price;
  final int totalCapacity;
  final int availableSeats;
  final int reservedSeats;
  final String aircraftType;
  final List<int> seatLayout;
  final FlightStatus status;

  /// A versão lida: vai de volta na edição para o servidor detectar que
  /// outra pessoa alterou o voo antes (`STALE_VERSION`).
  final int version;

  bool get isCancelled => status == FlightStatus.cancelled;
}

class AdminFlightDetail {
  const AdminFlightDetail({required this.flight, required this.activeBookings});

  factory AdminFlightDetail.fromJson(Json json) => AdminFlightDetail(
    flight: AdminFlight.fromJson(json.obj('flight') ?? const {}),
    activeBookings: json.count('activeBookings'),
  );

  final AdminFlight flight;
  final int activeBookings;
}

/// Os campos do formulário de voo (cadastro e edição).
class FlightForm {
  const FlightForm({
    required this.flightNumber,
    required this.airlineIataCode,
    required this.originIataCode,
    required this.destinationIataCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.seatClass,
    required this.price,
    required this.totalCapacity,
    required this.aircraftType,
  });

  factory FlightForm.fromFlight(AdminFlight flight) => FlightForm(
    flightNumber: flight.flightNumber,
    airlineIataCode: flight.airlineIataCode,
    originIataCode: flight.origin,
    destinationIataCode: flight.destination,
    departureTime: flight.departureTime ?? DateTime.now(),
    arrivalTime: flight.arrivalTime ?? DateTime.now(),
    seatClass: flight.seatClass,
    price: flight.price,
    totalCapacity: flight.totalCapacity,
    aircraftType: flight.aircraftType,
  );

  final String flightNumber;
  final String airlineIataCode;
  final String originIataCode;
  final String destinationIataCode;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final SeatClass seatClass;
  final double price;
  final int totalCapacity;
  final String aircraftType;

  /// Horário **sem fuso**, como o backend o guarda (`2026-10-01T08:00:00`).
  static String localTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)}'
        'T${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  Map<String, Object?> toJson() => {
    'flightNumber': flightNumber.trim(),
    'airlineIataCode': airlineIataCode.trim().toUpperCase(),
    'originIataCode': originIataCode.trim().toUpperCase(),
    'destinationIataCode': destinationIataCode.trim().toUpperCase(),
    'departureTime': localTime(departureTime),
    'arrivalTime': localTime(arrivalTime),
    'seatClass': seatClassToWire(seatClass),
    'price': price,
    'totalCapacity': totalCapacity,
    'aircraftType': aircraftType,
  };
}

/// Em que os dois lados de um conflito de edição divergem: o que a pessoa
/// editou e o que está no servidor agora.
class FlightDifference {
  const FlightDifference(this.field, this.mine, this.theirs);

  final String field;
  final String mine;
  final String theirs;
}

List<FlightDifference> flightDifferences(FlightForm mine, AdminFlight theirs) {
  String t(DateTime? d) => d == null ? '—' : FlightForm.localTime(d);
  final pairs = <(String, String, String)>[
    ('flightNumber', mine.flightNumber.trim(), theirs.flightNumber),
    (
      'airlineIataCode',
      mine.airlineIataCode.trim().toUpperCase(),
      theirs.airlineIataCode,
    ),
    ('originIataCode', mine.originIataCode.trim().toUpperCase(), theirs.origin),
    (
      'destinationIataCode',
      mine.destinationIataCode.trim().toUpperCase(),
      theirs.destination,
    ),
    ('departureTime', t(mine.departureTime), t(theirs.departureTime)),
    ('arrivalTime', t(mine.arrivalTime), t(theirs.arrivalTime)),
    (
      'seatClass',
      seatClassToWire(mine.seatClass),
      seatClassToWire(theirs.seatClass),
    ),
    ('price', mine.price.toStringAsFixed(2), theirs.price.toStringAsFixed(2)),
    ('totalCapacity', '${mine.totalCapacity}', '${theirs.totalCapacity}'),
    ('aircraftType', mine.aircraftType, theirs.aircraftType),
  ];
  return [
    for (final (field, a, b) in pairs)
      if (a != b) FlightDifference(field, a, b),
  ];
}

class Airline {
  const Airline({
    required this.iataCode,
    required this.name,
    this.id,
    this.logoUrl,
  });

  factory Airline.fromJson(Json json) => Airline(
    id: json.integer('id'),
    iataCode: json.text('iataCode'),
    name: json.text('name'),
    logoUrl: json.str('logoUrl'),
  );

  final int? id;
  final String iataCode;
  final String name;
  final String? logoUrl;
}

class Airport {
  const Airport({
    required this.iataCode,
    required this.name,
    required this.city,
    required this.country,
    required this.photoUrl,
    required this.region,
    required this.isPopular,
    this.id,
  });

  factory Airport.fromJson(Json json) => Airport(
    id: json.integer('id'),
    iataCode: json.text('iataCode'),
    name: json.text('name'),
    city: json.text('city'),
    country: json.text('country'),
    photoUrl: json.text('photoUrl'),
    region: json.text('region'),
    isPopular: json.flag('isPopular'),
  );

  final int? id;
  final String iataCode;
  final String name;
  final String city;
  final String country;
  final String photoUrl;
  final String region;
  final bool isPopular;

  Map<String, Object?> toJson() => {
    'iataCode': iataCode.trim().toUpperCase(),
    'name': name.trim(),
    'city': city.trim(),
    'country': country.trim(),
    'photoUrl': photoUrl.trim(),
    'region': region.trim(),
    'isPopular': isPopular,
  };
}

class AircraftModel {
  const AircraftModel({
    required this.name,
    required this.seatLayout,
    required this.seatsPerRow,
  });

  factory AircraftModel.fromJson(Json json) => AircraftModel(
    name: json.text('name'),
    seatsPerRow: json.count('seatsPerRow'),
    seatLayout: [
      for (final n in (json['seatLayout'] as List? ?? const []))
        if (n is num) n.toInt(),
    ],
  );

  final String name;
  final List<int> seatLayout;
  final int seatsPerRow;
}

class ImportError {
  const ImportError({required this.line, required this.message});

  factory ImportError.fromJson(Json json) =>
      ImportError(line: json.count('line'), message: json.text('message'));

  final int line;
  final String message;
}

/// O resultado da importação em lote (simulada ou gravada).
class ImportReport {
  const ImportReport({
    required this.dryRun,
    required this.totalRows,
    required this.toCreate,
    required this.alreadyExisting,
    required this.created,
    required this.errors,
  });

  factory ImportReport.fromJson(Json json) => ImportReport(
    dryRun: json.flag('dryRun', fallback: true),
    totalRows: json.count('totalRows'),
    toCreate: json.count('toCreate'),
    alreadyExisting: json.count('alreadyExisting'),
    created: json.count('created'),
    errors: json.list('errors', ImportError.fromJson),
  );

  final bool dryRun;
  final int totalRows;
  final int toCreate;
  final int alreadyExisting;
  final int created;
  final List<ImportError> errors;

  bool get hasErrors => errors.isNotEmpty;
}
