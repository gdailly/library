import 'package:library_api/library_api.dart';

/// Short French name of a metadata source.
String sourceLabel(MetadataSource? source) => switch (source) {
      MetadataSource.BNF => 'BnF',
      MetadataSource.OPEN_LIBRARY => 'Open Library',
      MetadataSource.GOOGLE_BOOKS => 'Google Books',
      MetadataSource.LIBRARY => 'Bibliothèque',
      _ => 'Fusion',
    };

/// The external sources, in the order of the comparison table.
const externalSources = [MetadataSource.BNF, MetadataSource.OPEN_LIBRARY, MetadataSource.GOOGLE_BOOKS];

/// Book fields compared with the sources, with their French label.
const metadataFields = {
  'title': 'Titre',
  'subtitle': 'Sous-titre',
  'authors': 'Auteurs',
  'publisher': 'Éditeur',
  'year': 'Année',
  'pages': 'Pages',
  'language': 'Langue',
  'summary': 'Résumé',
  'cover': 'Couverture',
};

/// A field of a book as text, null when empty.
String? bookValue(BookResponse book, String field) => switch (field) {
      'title' => book.title,
      'subtitle' => book.subtitle,
      'authors' => book.authors,
      'publisher' => book.publisher,
      'year' => book.year?.toString(),
      'pages' => book.pages?.toString(),
      'language' => book.language,
      'summary' => book.summary,
      _ => null,
    };

/// A field of a source's answer as text, null when the source does not know it.
String? sourceValue(SourceMetadataResponse answer, String field) => switch (field) {
      'title' => answer.title,
      'subtitle' => answer.subtitle,
      'authors' => answer.authors,
      'publisher' => answer.publisher,
      'year' => answer.year?.toString(),
      'pages' => answer.pages?.toString(),
      'language' => answer.language,
      'summary' => answer.summary,
      'cover' => answer.coverUrl,
      _ => null,
    };

/// "12/10/2026" for the date an ISBN was looked up.
String shortDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}
