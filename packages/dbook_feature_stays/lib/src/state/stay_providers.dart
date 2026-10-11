import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accommodationRepositoryProvider = Provider<AccommodationRepository>(
  (ref) => AccommodationRepositoryImpl(ref.watch(dioProvider)),
);

/// Resultado de uma busca. A chave é a própria busca (igualdade por valor),
/// então repetir a mesma busca reaproveita o resultado e mudar uma data busca
/// de novo.
/// A busca de hotel em andamento. O formulário (na faixa de marca da Home)
/// grava aqui e a lista de resultados (no corpo) lê daqui: as duas peças
/// ficam em lugares diferentes da tela sem se conhecerem.
class StaySearchNotifier extends Notifier<StaySearch?> {
  @override
  StaySearch? build() => null;

  void search(StaySearch search) => state = search;
}

final staySearchProvider = NotifierProvider<StaySearchNotifier, StaySearch?>(
  StaySearchNotifier.new,
);

final stayResultsProvider = FutureProvider.autoDispose
    .family<List<AccommodationResult>, StaySearch>(
      (ref, search) =>
          ref.watch(accommodationRepositoryProvider).search(search),
    );

/// Hotel em destaque com a busca que o originou (a data e os hóspedes do
/// padrão da Home), para abrir o detalhe com o mesmo recorte.
typedef FeaturedStay = ({AccommodationResult hotel, StaySearch search});

/// Hotéis de um destino para a vitrine da Home: busca real do servidor para
/// duas noites a partir de duas semanas à frente, dois hóspedes. É só o
/// recorte padrão da vitrine; o usuário refina na busca de hotéis.
final featuredStaysProvider = FutureProvider.autoDispose
    .family<List<FeaturedStay>, String>((ref, code) async {
      final checkIn = DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 14)),
      );
      final search = StaySearch(
        destination: code,
        checkIn: checkIn,
        checkOut: checkIn.add(const Duration(days: 2)),
        guests: 2,
      );
      final hotels = await ref
          .watch(accommodationRepositoryProvider)
          .search(search);
      return [for (final hotel in hotels) (hotel: hotel, search: search)];
    });

final stayDetailProvider = FutureProvider.autoDispose
    .family<AccommodationDetail, int>(
      (ref, id) => ref.watch(accommodationRepositoryProvider).detail(id),
    );

final myStaysProvider = FutureProvider.autoDispose<List<StayBooking>>(
  (ref) => ref.watch(accommodationRepositoryProvider).myStays(),
);

/// Mensagem para mostrar ao usuário: a que o backend mandou, quando houver.
String stayErrorMessage(Object error) => error is DbookNetworkException
    ? error.message
    : 'Não foi possível carregar.';
