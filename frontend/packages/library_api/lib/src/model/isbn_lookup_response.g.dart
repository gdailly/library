// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isbn_lookup_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IsbnLookupResponseCWProxy {
  IsbnLookupResponse isbn13(String isbn13);

  IsbnLookupResponse source_(MetadataSource source_);

  IsbnLookupResponse existingBookId(int? existingBookId);

  IsbnLookupResponse title(String title);

  IsbnLookupResponse subtitle(String? subtitle);

  IsbnLookupResponse authors(String? authors);

  IsbnLookupResponse publisher(String? publisher);

  IsbnLookupResponse year(int? year);

  IsbnLookupResponse pages(int? pages);

  IsbnLookupResponse language(String? language);

  IsbnLookupResponse summary(String? summary);

  IsbnLookupResponse coverUrl(String? coverUrl);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IsbnLookupResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IsbnLookupResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  IsbnLookupResponse call({
    String isbn13,
    MetadataSource source_,
    int? existingBookId,
    String title,
    String? subtitle,
    String? authors,
    String? publisher,
    int? year,
    int? pages,
    String? language,
    String? summary,
    String? coverUrl,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIsbnLookupResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIsbnLookupResponse.copyWith.fieldName(...)`
class _$IsbnLookupResponseCWProxyImpl implements _$IsbnLookupResponseCWProxy {
  const _$IsbnLookupResponseCWProxyImpl(this._value);

  final IsbnLookupResponse _value;

  @override
  IsbnLookupResponse isbn13(String isbn13) => this(isbn13: isbn13);

  @override
  IsbnLookupResponse source_(MetadataSource source_) => this(source_: source_);

  @override
  IsbnLookupResponse existingBookId(int? existingBookId) =>
      this(existingBookId: existingBookId);

  @override
  IsbnLookupResponse title(String title) => this(title: title);

  @override
  IsbnLookupResponse subtitle(String? subtitle) => this(subtitle: subtitle);

  @override
  IsbnLookupResponse authors(String? authors) => this(authors: authors);

  @override
  IsbnLookupResponse publisher(String? publisher) => this(publisher: publisher);

  @override
  IsbnLookupResponse year(int? year) => this(year: year);

  @override
  IsbnLookupResponse pages(int? pages) => this(pages: pages);

  @override
  IsbnLookupResponse language(String? language) => this(language: language);

  @override
  IsbnLookupResponse summary(String? summary) => this(summary: summary);

  @override
  IsbnLookupResponse coverUrl(String? coverUrl) => this(coverUrl: coverUrl);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IsbnLookupResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IsbnLookupResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  IsbnLookupResponse call({
    Object? isbn13 = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? existingBookId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? subtitle = const $CopyWithPlaceholder(),
    Object? authors = const $CopyWithPlaceholder(),
    Object? publisher = const $CopyWithPlaceholder(),
    Object? year = const $CopyWithPlaceholder(),
    Object? pages = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? coverUrl = const $CopyWithPlaceholder(),
  }) {
    return IsbnLookupResponse(
      isbn13: isbn13 == const $CopyWithPlaceholder()
          ? _value.isbn13
          // ignore: cast_nullable_to_non_nullable
          : isbn13 as String,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as MetadataSource,
      existingBookId: existingBookId == const $CopyWithPlaceholder()
          ? _value.existingBookId
          // ignore: cast_nullable_to_non_nullable
          : existingBookId as int?,
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
      coverUrl: coverUrl == const $CopyWithPlaceholder()
          ? _value.coverUrl
          // ignore: cast_nullable_to_non_nullable
          : coverUrl as String?,
    );
  }
}

extension $IsbnLookupResponseCopyWith on IsbnLookupResponse {
  /// Returns a callable class that can be used as follows: `instanceOfIsbnLookupResponse.copyWith(...)` or like so:`instanceOfIsbnLookupResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IsbnLookupResponseCWProxy get copyWith =>
      _$IsbnLookupResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IsbnLookupResponse _$IsbnLookupResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('IsbnLookupResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['isbn13', 'source', 'title']);
      final val = IsbnLookupResponse(
        isbn13: $checkedConvert('isbn13', (v) => v as String),
        source_: $checkedConvert(
          'source',
          (v) => $enumDecode(_$MetadataSourceEnumMap, v),
        ),
        existingBookId: $checkedConvert(
          'existingBookId',
          (v) => (v as num?)?.toInt(),
        ),
        title: $checkedConvert('title', (v) => v as String),
        subtitle: $checkedConvert('subtitle', (v) => v as String?),
        authors: $checkedConvert('authors', (v) => v as String?),
        publisher: $checkedConvert('publisher', (v) => v as String?),
        year: $checkedConvert('year', (v) => (v as num?)?.toInt()),
        pages: $checkedConvert('pages', (v) => (v as num?)?.toInt()),
        language: $checkedConvert('language', (v) => v as String?),
        summary: $checkedConvert('summary', (v) => v as String?),
        coverUrl: $checkedConvert('coverUrl', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$IsbnLookupResponseToJson(IsbnLookupResponse instance) =>
    <String, dynamic>{
      'isbn13': instance.isbn13,
      'source': _$MetadataSourceEnumMap[instance.source_]!,
      'existingBookId': ?instance.existingBookId,
      'title': instance.title,
      'subtitle': ?instance.subtitle,
      'authors': ?instance.authors,
      'publisher': ?instance.publisher,
      'year': ?instance.year,
      'pages': ?instance.pages,
      'language': ?instance.language,
      'summary': ?instance.summary,
      'coverUrl': ?instance.coverUrl,
    };

const _$MetadataSourceEnumMap = {
  MetadataSource.LIBRARY: 'LIBRARY',
  MetadataSource.OPEN_LIBRARY: 'OPEN_LIBRARY',
  MetadataSource.GOOGLE_BOOKS: 'GOOGLE_BOOKS',
};
