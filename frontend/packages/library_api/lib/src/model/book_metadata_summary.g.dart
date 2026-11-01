// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_metadata_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BookMetadataSummaryCWProxy {
  BookMetadataSummary id(int id);

  BookMetadataSummary title(String title);

  BookMetadataSummary authors(String? authors);

  BookMetadataSummary isbn13(String isbn13);

  BookMetadataSummary hasCover(bool hasCover);

  BookMetadataSummary sources(List<MetadataSource> sources);

  BookMetadataSummary fetchedAt(DateTime? fetchedAt);

  BookMetadataSummary notFound(bool notFound);

  BookMetadataSummary differences(List<String> differences);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookMetadataSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookMetadataSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  BookMetadataSummary call({
    int id,
    String title,
    String? authors,
    String isbn13,
    bool hasCover,
    List<MetadataSource> sources,
    DateTime? fetchedAt,
    bool notFound,
    List<String> differences,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBookMetadataSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBookMetadataSummary.copyWith.fieldName(...)`
class _$BookMetadataSummaryCWProxyImpl implements _$BookMetadataSummaryCWProxy {
  const _$BookMetadataSummaryCWProxyImpl(this._value);

  final BookMetadataSummary _value;

  @override
  BookMetadataSummary id(int id) => this(id: id);

  @override
  BookMetadataSummary title(String title) => this(title: title);

  @override
  BookMetadataSummary authors(String? authors) => this(authors: authors);

  @override
  BookMetadataSummary isbn13(String isbn13) => this(isbn13: isbn13);

  @override
  BookMetadataSummary hasCover(bool hasCover) => this(hasCover: hasCover);

  @override
  BookMetadataSummary sources(List<MetadataSource> sources) =>
      this(sources: sources);

  @override
  BookMetadataSummary fetchedAt(DateTime? fetchedAt) =>
      this(fetchedAt: fetchedAt);

  @override
  BookMetadataSummary notFound(bool notFound) => this(notFound: notFound);

  @override
  BookMetadataSummary differences(List<String> differences) =>
      this(differences: differences);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookMetadataSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookMetadataSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  BookMetadataSummary call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? authors = const $CopyWithPlaceholder(),
    Object? isbn13 = const $CopyWithPlaceholder(),
    Object? hasCover = const $CopyWithPlaceholder(),
    Object? sources = const $CopyWithPlaceholder(),
    Object? fetchedAt = const $CopyWithPlaceholder(),
    Object? notFound = const $CopyWithPlaceholder(),
    Object? differences = const $CopyWithPlaceholder(),
  }) {
    return BookMetadataSummary(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      authors: authors == const $CopyWithPlaceholder()
          ? _value.authors
          // ignore: cast_nullable_to_non_nullable
          : authors as String?,
      isbn13: isbn13 == const $CopyWithPlaceholder()
          ? _value.isbn13
          // ignore: cast_nullable_to_non_nullable
          : isbn13 as String,
      hasCover: hasCover == const $CopyWithPlaceholder()
          ? _value.hasCover
          // ignore: cast_nullable_to_non_nullable
          : hasCover as bool,
      sources: sources == const $CopyWithPlaceholder()
          ? _value.sources
          // ignore: cast_nullable_to_non_nullable
          : sources as List<MetadataSource>,
      fetchedAt: fetchedAt == const $CopyWithPlaceholder()
          ? _value.fetchedAt
          // ignore: cast_nullable_to_non_nullable
          : fetchedAt as DateTime?,
      notFound: notFound == const $CopyWithPlaceholder()
          ? _value.notFound
          // ignore: cast_nullable_to_non_nullable
          : notFound as bool,
      differences: differences == const $CopyWithPlaceholder()
          ? _value.differences
          // ignore: cast_nullable_to_non_nullable
          : differences as List<String>,
    );
  }
}

extension $BookMetadataSummaryCopyWith on BookMetadataSummary {
  /// Returns a callable class that can be used as follows: `instanceOfBookMetadataSummary.copyWith(...)` or like so:`instanceOfBookMetadataSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BookMetadataSummaryCWProxy get copyWith =>
      _$BookMetadataSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookMetadataSummary _$BookMetadataSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BookMetadataSummary', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'title',
          'isbn13',
          'hasCover',
          'sources',
          'notFound',
          'differences',
        ],
      );
      final val = BookMetadataSummary(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        title: $checkedConvert('title', (v) => v as String),
        authors: $checkedConvert('authors', (v) => v as String?),
        isbn13: $checkedConvert('isbn13', (v) => v as String),
        hasCover: $checkedConvert('hasCover', (v) => v as bool),
        sources: $checkedConvert(
          'sources',
          (v) => (v as List<dynamic>)
              .map((e) => $enumDecode(_$MetadataSourceEnumMap, e))
              .toList(),
        ),
        fetchedAt: $checkedConvert(
          'fetchedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        notFound: $checkedConvert('notFound', (v) => v as bool),
        differences: $checkedConvert(
          'differences',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BookMetadataSummaryToJson(
  BookMetadataSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'authors': ?instance.authors,
  'isbn13': instance.isbn13,
  'hasCover': instance.hasCover,
  'sources': instance.sources.map((e) => _$MetadataSourceEnumMap[e]!).toList(),
  'fetchedAt': ?instance.fetchedAt?.toIso8601String(),
  'notFound': instance.notFound,
  'differences': instance.differences,
};

const _$MetadataSourceEnumMap = {
  MetadataSource.LIBRARY: 'LIBRARY',
  MetadataSource.OPEN_LIBRARY: 'OPEN_LIBRARY',
  MetadataSource.GOOGLE_BOOKS: 'GOOGLE_BOOKS',
  MetadataSource.BNF: 'BNF',
};
