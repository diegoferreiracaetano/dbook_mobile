import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_core_session/dbook_core_session.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final destinationReviewRepositoryProvider =
    Provider<DestinationReviewRepository>(
      (ref) => DestinationReviewRepositoryImpl(ref.watch(dioProvider)),
    );

/// Os ids das avaliações que **a pessoa logada escreveu**. O backend público
/// não diz quais são "minhas" (só o primeiro nome do autor), então o app
/// cruza com as reservas dela: quem monta a ponte é o `main` (features não se
/// importam), sobrescrevendo este provider.
final ownReviewIdsProvider = Provider<Set<int>>((ref) => const {});

/// Se há sessão. Só então aparecem editar, apagar e denunciar. Sobrescrito
/// pelo `main`, que conhece a feature de auth.
final isLoggedInProvider = Provider<bool>((ref) => false);

class DestinationReviewsState {
  const DestinationReviewsState({
    this.summary,
    this.items = const [],
    this.page = 0,
    this.hasMore = false,
    this.sort = ReviewSort.recent,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
    this.loadMoreError,
  });

  final ReviewSummary? summary;
  final List<PublicReview> items;
  final int page;
  final bool hasMore;
  final ReviewSort sort;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;
  final Object? loadMoreError;

  DestinationReviewsState copyWith({
    ReviewSummary? summary,
    List<PublicReview>? items,
    int? page,
    bool? hasMore,
    ReviewSort? sort,
    bool? isLoading,
    bool? isLoadingMore,
    Object? Function()? error,
    Object? Function()? loadMoreError,
  }) => DestinationReviewsState(
    summary: summary ?? this.summary,
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    sort: sort ?? this.sort,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error == null ? this.error : error(),
    loadMoreError: loadMoreError == null ? this.loadMoreError : loadMoreError(),
  );
}

/// As avaliações de um destino: primeira página, mais páginas por rolagem, e
/// o que o autor faz com a sua (editar, apagar).
class DestinationReviewsNotifier extends Notifier<DestinationReviewsState> {
  DestinationReviewsNotifier(this.iataCode);

  final String iataCode;

  DestinationReviewRepository get _repository =>
      ref.read(destinationReviewRepositoryProvider);

  @override
  DestinationReviewsState build() {
    Future<void>.microtask(refresh);
    return const DestinationReviewsState();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final result = await _repository.list(iataCode, sort: state.sort);
      state = DestinationReviewsState(
        summary: result.summary,
        items: result.page.items,
        page: result.page.page,
        hasMore: result.page.hasMore,
        sort: state.sort,
        isLoading: false,
      );
    } on Object catch (error) {
      state = state.copyWith(isLoading: false, error: () => error);
    }
  }

  Future<void> setSort(ReviewSort sort) async {
    if (sort == state.sort) return;
    state = state.copyWith(sort: sort);
    await refresh();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true, loadMoreError: () => null);
    try {
      final result = await _repository.list(
        iataCode,
        sort: state.sort,
        page: state.page + 1,
      );
      state = state.copyWith(
        items: [...state.items, ...result.page.items],
        page: result.page.page,
        hasMore: result.page.hasMore,
        isLoadingMore: false,
      );
    } on Object catch (error) {
      state = state.copyWith(isLoadingMore: false, loadMoreError: () => error);
    }
  }

  /// Editar a própria avaliação: aparece na hora; se o servidor recusa,
  /// volta o que era e o erro sobe para a tela avisar.
  Future<void> edit(
    PublicReview review, {
    required int rating,
    required String comment,
  }) async {
    final before = state.items;
    state = state.copyWith(
      items: [
        for (final r in before)
          r.id == review.id ? r.copyWith(rating: rating, comment: comment) : r,
      ],
    );
    try {
      await _repository.edit(review.id, rating: rating, comment: comment);
      await refresh(); // a média e a distribuição mudaram
    } on Object {
      state = state.copyWith(items: before);
      rethrow;
    }
  }

  /// Tira a avaliação da lista na hora (para a tela oferecer "Desfazer").
  /// Devolve a posição para [restore].
  int hideLocally(PublicReview review) {
    final index = state.items.indexWhere((r) => r.id == review.id);
    state = state.copyWith(
      items: [
        for (final r in state.items)
          if (r.id != review.id) r,
      ],
    );
    return index;
  }

  void restore(PublicReview review, int index) {
    final items = [...state.items];
    items.insert(index.clamp(0, items.length), review);
    state = state.copyWith(items: items);
  }

  /// Apaga de verdade no servidor (depois do prazo do "Desfazer").
  Future<void> commitDelete(PublicReview review, int index) async {
    try {
      await _repository.delete(review.id);
      await refresh();
    } on Object {
      restore(review, index);
      rethrow;
    }
  }

  Future<void> report(PublicReview review, String reason) =>
      _repository.report(review.id, reason);
}

final destinationReviewsNotifierProvider = NotifierProvider.autoDispose
    .family<DestinationReviewsNotifier, DestinationReviewsState, String>(
      DestinationReviewsNotifier.new,
    );
