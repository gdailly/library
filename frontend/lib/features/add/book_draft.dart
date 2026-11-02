import 'package:library_api/library_api.dart';
import 'package:material_ui/material_ui.dart';

/// Editable copy of a book: from an ISBN lookup, an existing book or nothing (manual entry).
class BookDraft {
  BookDraft({
    this.isbn,
    String? title,
    String? subtitle,
    String? series,
    int? seriesNumber,
    String? authors,
    String? publisher,
    int? year,
    int? pages,
    this.language,
    this.summary,
    this.owned = true,
    Set<int>? categoryIds,
  })  : title = TextEditingController(text: title),
        subtitle = TextEditingController(text: subtitle),
        series = TextEditingController(text: series),
        seriesNumber = TextEditingController(text: seriesNumber?.toString()),
        authors = TextEditingController(text: authors),
        publisher = TextEditingController(text: publisher),
        year = TextEditingController(text: year?.toString()),
        pages = TextEditingController(text: pages?.toString()),
        categoryIds = categoryIds ?? {};

  factory BookDraft.fromLookup(IsbnLookupResponse lookup) => BookDraft(
        isbn: lookup.isbn13,
        title: lookup.title,
        subtitle: lookup.subtitle,
        series: lookup.series,
        seriesNumber: lookup.seriesNumber,
        authors: lookup.authors,
        publisher: lookup.publisher,
        year: lookup.year,
        pages: lookup.pages,
        language: lookup.language,
        summary: lookup.summary,
      );

  factory BookDraft.fromBook(BookResponse book) => BookDraft(
        isbn: book.isbn13,
        title: book.title,
        subtitle: book.subtitle,
        series: book.series,
        seriesNumber: book.seriesNumber,
        authors: book.authors,
        publisher: book.publisher,
        year: book.year,
        pages: book.pages,
        language: book.language,
        summary: book.summary,
        owned: book.owned,
        categoryIds: {for (final category in book.categories) category.id},
      );

  String? isbn;
  final TextEditingController title;
  final TextEditingController subtitle;
  final TextEditingController series;
  final TextEditingController seriesNumber;
  final TextEditingController authors;
  final TextEditingController publisher;
  final TextEditingController year;
  final TextEditingController pages;
  final String? language;
  final String? summary;
  bool owned;
  final Set<int> categoryIds;

  /// What is missing before saving, in French; null when the draft can be saved.
  String? validate() {
    if (title.text.trim().isEmpty) {
      return 'Le titre est obligatoire.';
    }
    if (year.text.trim().isNotEmpty && int.tryParse(year.text.trim()) == null) {
      return 'L\'année doit être un nombre.';
    }
    if (pages.text.trim().isNotEmpty && (int.tryParse(pages.text.trim()) ?? 0) < 1) {
      return 'Le nombre de pages doit être un entier positif.';
    }
    if (seriesNumber.text.trim().isNotEmpty && series.text.trim().isEmpty) {
      return 'Indique la série de ce tome.';
    }
    return null;
  }

  BookRequest toRequest() {
    String? text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    return BookRequest(
      isbn: isbn,
      title: title.text.trim(),
      subtitle: text(subtitle),
      series: text(series),
      seriesNumber: text(series) == null ? null : int.tryParse(seriesNumber.text.trim()),
      authors: text(authors),
      publisher: text(publisher),
      year: int.tryParse(year.text.trim()),
      pages: int.tryParse(pages.text.trim()),
      language: language,
      summary: summary,
      owned: owned,
      categoryIds: categoryIds.toList(),
    );
  }

  /// "Le Livre de Poche · 1990 · 448 p."
  String details() => [
        publisher.text.trim(),
        year.text.trim(),
        if (pages.text.trim().isNotEmpty) '${pages.text.trim()} p.',
      ].where((part) => part.isNotEmpty).join(' · ');

  void dispose() {
    for (final controller in [title, subtitle, series, seriesNumber, authors, publisher, year, pages]) {
      controller.dispose();
    }
  }
}
