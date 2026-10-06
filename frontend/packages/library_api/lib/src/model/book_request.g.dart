// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BookRequestCWProxy {
  BookRequest isbn(String? isbn);

  BookRequest title(String title);

  BookRequest subtitle(String? subtitle);

  BookRequest authors(String? authors);

  BookRequest publisher(String? publisher);

  BookRequest year(int? year);

  BookRequest pages(int? pages);

  BookRequest language(String? language);

  BookRequest summary(String? summary);

  BookRequest owned(bool? owned);

  BookRequest categoryIds(List<int>? categoryIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BookRequest call({
    String? isbn,
    String title,
    String? subtitle,
    String? authors,
    String? publisher,
    int? year,
    int? pages,
    String? language,
    String? summary,
    bool? owned,
    List<int>? categoryIds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBookRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBookRequest.copyWith.fieldName(...)`
class _$BookRequestCWProxyImpl implements _$BookRequestCWProxy {
  const _$BookRequestCWProxyImpl(this._value);

  final BookRequest _value;

  @override
  BookRequest isbn(String? isbn) => this(isbn: isbn);

  @override
  BookRequest title(String title) => this(title: title);

  @override
  BookRequest subtitle(String? subtitle) => this(subtitle: subtitle);

  @override
  BookRequest authors(String? authors) => this(authors: authors);

  @override
  BookRequest publisher(String? publisher) => this(publisher: publisher);

  @override
  BookRequest year(int? year) => this(year: year);

  @override
  BookRequest pages(int? pages) => this(pages: pages);

  @override
  BookRequest language(String? language) => this(language: language);

  @override
  BookRequest summary(String? summary) => this(summary: summary);

  @override
  BookRequest owned(bool? owned) => this(owned: owned);

  @override
  BookRequest categoryIds(List<int>? categoryIds) =>
      this(categoryIds: categoryIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BookRequest call({
    Object? isbn = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? subtitle = const $CopyWithPlaceholder(),
    Object? authors = const $CopyWithPlaceholder(),
    Object? publisher = const $CopyWithPlaceholder(),
    Object? year = const $CopyWithPlaceholder(),
    Object? pages = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? owned = const $CopyWithPlaceholder(),
    Object? categoryIds = const $CopyWithPlaceholder(),
  }) {
    return BookRequest(
      isbn: isbn == const $CopyWithPlaceholder()
          ? _value.isbn
          // ignore: cast_nullable_to_non_nullable
          : isbn as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      subtitle: subtitle == const $CopyWithPlaceholder()
          ? _value.subtitle
          // ignore: cast_nullable_to_non_nullable
          : subtitle as String?,
      authors: authors == const $CopyWithPlaceholder()
          ? _value.authors
          // ignore: cast_nullable_to_non_nullable
          : authors as String?,
      publisher: publisher == const $CopyWithPlaceholder()
          ? _value.publisher
          // ignore: cast_nullable_to_non_nullable
          : publisher as String?,
      year: year == const $CopyWithPlaceholder()
          ? _value.year
          // ignore: cast_nullable_to_non_nullable
          : year as int?,
      pages: pages == const $CopyWithPlaceholder()
          ? _value.pages
          // ignore: cast_nullable_to_non_nullable
          : pages as int?,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as String?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String?,
      owned: owned == const $CopyWithPlaceholder()
          ? _value.owned
          // ignore: cast_nullable_to_non_nullable
          : owned as bool?,
      categoryIds: categoryIds == const $CopyWithPlaceholder()
          ? _value.categoryIds
          // ignore: cast_nullable_to_non_nullable
          : categoryIds as List<int>?,
    );
  }
}

extension $BookRequestCopyWith on BookRequest {
  /// Returns a callable class that can be used as follows: `instanceOfBookRequest.copyWith(...)` or like so:`instanceOfBookRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BookRequestCWProxy get copyWith => _$BookRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookRequest _$BookRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BookRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['title']);
      final val = BookRequest(
        isbn: $checkedConvert('isbn', (v) => v as String?),
        title: $checkedConvert('title', (v) => v as String),
        subtitle: $checkedConvert('subtitle', (v) => v as String?),
        authors: $checkedConvert('authors', (v) => v as String?),
        publisher: $checkedConvert('publisher', (v) => v as String?),
        year: $checkedConvert('year', (v) => (v as num?)?.toInt()),
        pages: $checkedConvert('pages', (v) => (v as num?)?.toInt()),
        language: $checkedConvert('language', (v) => v as String?),
        summary: $checkedConvert('summary', (v) => v as String?),
        owned: $checkedConvert('owned', (v) => v as bool?),
        categoryIds: $checkedConvert(
          'categoryIds',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BookRequestToJson(BookRequest instance) =>
    <String, dynamic>{
      'isbn': ?instance.isbn,
      'title': instance.title,
      'subtitle': ?instance.subtitle,
      'authors': ?instance.authors,
      'publisher': ?instance.publisher,
      'year': ?instance.year,
      'pages': ?instance.pages,
      'language': ?instance.language,
      'summary': ?instance.summary,
      'owned': ?instance.owned,
      'categoryIds': ?instance.categoryIds,
    };
