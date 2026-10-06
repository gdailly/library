import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';

import '../../core/api.dart';

/// Search and filters of a book list. [owned] separates the library (true) from the wish list (false).
class BooksQuery {
  const BooksQuery({this.owned = true, this.text = '', this.status});

  final bool owned;
  final String text;
  final ReadingStatus? status;

  BooksQuery copyWith({String? text, ReadingStatus? Function()? status}) => BooksQuery(
        owned: owned,
        text: text ?? this.text,
        status: status == null ? this.status : status(),
      );

  @override
  bool operator ==(Object other) =>
      other is BooksQuery && other.owned == owned && other.text == text && other.status == status;

  @override
  int get hashCode => Object.hash(owned, text, status);
}

class BooksQueryNotifier extends Notifier<BooksQuery> {
  BooksQueryNotifier(this.owned);

  final bool owned;

  @override
  BooksQuery build() => BooksQuery(owned: owned);

  void search(String text) => state = state.copyWith(text: text.trim());

  void filterStatus(ReadingStatus? status) => state = state.copyWith(status: () => status);
}

final libraryQueryProvider = NotifierProvider<BooksQueryNotifier, BooksQuery>(() => BooksQueryNotifier(true));

final wishlistQueryProvider = NotifierProvider<BooksQueryNotifier, BooksQuery>(() => BooksQueryNotifier(false));

/// First page (50 books, by title) matching a query.
final booksProvider = FutureProvider.autoDispose.family<PageResponseBookResponse, BooksQuery>((ref, query) async {
  final response = await ref.watch(libraryApiProvider).getBooksApi().listBooks(
        owned: query.owned,
        q: query.text.isEmpty ? null : query.text,
        status: query.status,
      );
  return response.data!;
});

final bookProvider = FutureProvider.autoDispose.family<BookResponse, int>((ref, id) async {
  final response = await ref.watch(libraryApiProvider).getBooksApi().getBook(id: id);
  return response.data!;
});

/// Grid or list display of the library.
final gridViewProvider = NotifierProvider<GridViewNotifier, bool>(GridViewNotifier.new);

class GridViewNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool grid) => state = grid;
}
