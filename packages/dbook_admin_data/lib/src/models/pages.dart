import '../json.dart';

/// Página do servidor: `{items, page, size, totalElements, totalPages}`. A
/// página começa em 0.
class PageOf<T> {
  const PageOf({
    required this.items,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageOf.fromJson(Json json, T Function(Json json) parse) => PageOf(
    items: json.list('items', parse),
    page: json.count('page'),
    size: json.integer('size') ?? 20,
    totalElements: json.count('totalElements'),
    totalPages: json.count('totalPages'),
  );

  final List<T> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
}

/// Página por cursor (auditoria, notificações): `nextCursor` é `null` na
/// última.
class CursorPage<T> {
  const CursorPage({required this.items, this.nextCursor});

  factory CursorPage.fromJson(Json json, T Function(Json json) parse) =>
      CursorPage(
        items: json.list('items', parse),
        nextCursor: json.str('nextCursor'),
      );

  final List<T> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}
