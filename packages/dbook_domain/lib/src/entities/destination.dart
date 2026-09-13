import 'package:freezed_annotation/freezed_annotation.dart';

part 'destination.freezed.dart';

/// Um destino conhecido pelo DBook — espelha `DestinationResponse` do
/// backend (`GET /destinations`). Alimenta a grade "Destinos em
/// destaque", a aba Explore e o seletor de origem/destino da busca: o
/// app não tem nenhuma lista de aeroportos própria, só renderiza o que
/// a API manda.
@freezed
abstract class Destination with _$Destination {
  const Destination._();

  const factory Destination({
    required String iataCode,
    required String city,
    required String country,
    required String photoUrl,
    double? lowestPrice,
  }) = _Destination;

  String get label => '$city ($iataCode)';
}
