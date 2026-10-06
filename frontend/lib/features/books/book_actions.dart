import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:library_api/library_api.dart';

import '../../core/api.dart';
import 'books_providers.dart';

/// The update request that keeps a book as it is, except for what the caller changes.
BookRequest requestFrom(BookResponse book, {bool? owned}) => BookRequest(
      isbn: book.isbn13,
      title: book.title,
      subtitle: book.subtitle,
      authors: book.authors,
      publisher: book.publisher,
      year: book.year,
      pages: book.pages,
      language: book.language,
      summary: book.summary,
      owned: owned ?? book.owned,
      categoryIds: [for (final category in book.categories) category.id],
    );

/// Mutations of books shared by several screens; each refreshes the lists afterwards.
class BookActions {
  BookActions(this._ref);

  final Ref _ref;

  BooksApi get _books => _ref.read(libraryApiProvider).getBooksApi();

  /// "Je l'ai": moves a wish to the library.
  Future<void> markOwned(BookResponse book) async {
    await _books.updateBook(id: book.id, bookRequest: requestFrom(book, owned: true));
    _refresh(book.id);
  }

  Future<BookResponse> save(int? id, BookRequest request) async {
    final response = id == null
        ? await _books.createBook(bookRequest: request)
        : await _books.updateBook(id: id, bookRequest: request);
    _refresh(response.data!.id);
    return response.data!;
  }

  Future<void> delete(int id) async {
    await _books.deleteBook(id: id);
    _ref.invalidate(booksProvider);
  }

  void _refresh(int id) {
    _ref
      ..invalidate(booksProvider)
      ..invalidate(bookProvider(id));
  }
}

final bookActionsProvider = Provider<BookActions>(BookActions.new);
