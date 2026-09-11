/// Aeroporto conhecido pra montar o seletor de origem/destino na busca.
class KnownAirport {
  const KnownAirport({
    required this.iataCode,
    required this.city,
    required this.country,
  });

  final String iataCode;
  final String city;
  final String country;

  String get label => '$city ($iataCode)';
}

/// O backend não expõe um endpoint pra listar aeroportos (só
/// `/flights/search` recebe código IATA) — esta lista espelha o seed de
/// desenvolvimento (`V2__seed_airports.sql`), só pra alimentar o seletor da
/// busca sem precisar digitar o código IATA de cabeça.
const knownAirports = [
  KnownAirport(iataCode: 'GRU', city: 'São Paulo', country: 'Brasil'),
  KnownAirport(iataCode: 'GIG', city: 'Rio de Janeiro', country: 'Brasil'),
  KnownAirport(iataCode: 'JFK', city: 'New York', country: 'Estados Unidos'),
];
