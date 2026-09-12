/// Aeroporto conhecido pra montar o seletor de origem/destino na busca.
class KnownAirport {
  const KnownAirport({
    required this.iataCode,
    required this.city,
    required this.country,
    this.photoUrl,
  });

  final String iataCode;
  final String city;
  final String country;

  /// Foto real do destino (Unsplash) pros cards de "Destinos em destaque"
  /// e da aba Explore — ver `docs/destination_photo_credits.md`. Opcional:
  /// `DbookDestinationCard` cai pro degradê quando não há foto.
  final String? photoUrl;

  String get label => '$city ($iataCode)';
}

/// O backend não expõe um endpoint pra listar aeroportos (só
/// `/flights/search` recebe código IATA) — esta lista espelha o seed de
/// desenvolvimento (`V2__seed_airports.sql`), só pra alimentar o seletor da
/// busca sem precisar digitar o código IATA de cabeça.
const knownAirports = [
  KnownAirport(
    iataCode: 'GRU',
    city: 'São Paulo',
    country: 'Brasil',
    photoUrl:
        'https://images.unsplash.com/photo-1645918899630-85e2f3132a84'
        '?w=600&h=400&fit=crop&auto=format',
  ),
  KnownAirport(
    iataCode: 'GIG',
    city: 'Rio de Janeiro',
    country: 'Brasil',
    photoUrl:
        'https://images.unsplash.com/photo-1518639192441-8fce0a366e2e'
        '?w=600&h=400&fit=crop&auto=format',
  ),
  KnownAirport(
    iataCode: 'JFK',
    city: 'New York',
    country: 'Estados Unidos',
    photoUrl:
        'https://images.unsplash.com/photo-1496588152823-86ff7695e68f'
        '?w=600&h=400&fit=crop&auto=format',
  ),
];
