// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_metadata_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BookMetadataResponseCWProxy {
  BookMetadataResponse book(BookResponse book);

  BookMetadataResponse fetchedAt(DateTime? fetchedAt);

  BookMetadataResponse notFound(bool notFound);

  BookMetadataResponse sources(List<SourceMetadataResponse> sources);

  BookMetadataResponse merged(SourceMetadataResponse? merged);

  BookMetadataResponse differences(List<String> differences);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookMetadataResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookMetadataResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BookMetadataResponse call({
    BookResponse book,
    DateTime? fetchedAt,
    bool notFound,
    List<SourceMetadataResponse> sources,
    SourceMetadataResponse? merged,
    List<String> differences,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBookMetadataResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBookMetadataResponse.copyWith.fieldName(...)`
class _$BookMetadataResponseCWProxyImpl
    implements _$BookMetadataResponseCWProxy {
  const _$BookMetadataResponseCWProxyImpl(this._value);

  final BookMetadataResponse _value;

  @override
  BookMetadataResponse book(BookResponse book) => this(book: book);

  @override
  BookMetadataResponse fetchedAt(DateTime? fetchedAt) =>
      this(fetchedAt: fetchedAt);

  @override
  BookMetadataResponse notFound(bool notFound) => this(notFound: notFound);

  @override
  BookMetadataResponse sources(List<SourceMetadataResponse> sources) =>
      this(sources: sources);

  @override
  BookMetadataResponse merged(SourceMetadataResponse? merged) =>
      this(merged: merged);

  @override
  BookMetadataResponse differences(List<String> differences) =>
      this(differences: differences);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookMetadataResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookMetadataResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BookMetadataResponse call({
    Object? book = const $CopyWithPlaceholder(),
    Object? fetchedAt = const $CopyWithPlaceholder(),
    Object? notFound = const $CopyWithPlaceholder(),
    Object? sources = const $CopyWithPlaceholder(),
    Object? merged = const $CopyWithPlaceholder(),
    Object? differences = const $CopyWithPlaceholder(),
  }) {
    return BookMetadataResponse(
      book: book == const $CopyWithPlaceholder()
          ? _value.book
          // ignore: cast_nullable_to_non_nullable
          : book as BookResponse,
      fetchedAt: fetchedAt == const $CopyWithPlaceholder()
          ? _value.fetchedAt
          // ignore: cast_nullable_to_non_nullable
          : fetchedAt as DateTime?,
      notFound: notFound == const $CopyWithPlaceholder()
          ? _value.notFound
          // ignore: cast_nullable_to_non_nullable
          : notFound as bool,
      sources: sources == const $CopyWithPlaceholder()
          ? _value.sources
          // ignore: cast_nullable_to_non_nullable
          : sources as List<SourceMetadataResponse>,
      merged: merged == const $CopyWithPlaceholder()
          ? _value.merged
          // ignore: cast_nullable_to_non_nullable
          : merged as SourceMetadataResponse?,
      differences: differences == const $CopyWithPlaceholder()
          ? _value.differences
          // ignore: cast_nullable_to_non_nullable
          : differences as List<String>,
    );
  }
}

extension $BookMetadataResponseCopyWith on BookMetadataResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBookMetadataResponse.copyWith(...)` or like so:`instanceOfBookMetadataResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BookMetadataResponseCWProxy get copyWith =>
      _$BookMetadataResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookMetadataResponse _$BookMetadataResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BookMetadataResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['book', 'notFound', 'sources', 'differences'],
  );
  final val = BookMetadataResponse(
    book: $checkedConvert(
      'book',
      (v) => BookResponse.fromJson(v as Map<String, dynamic>),
    ),
    fetchedAt: $checkedConvert(
      'fetchedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    notFound: $checkedConvert('notFound', (v) => v as bool),
    sources: $checkedConvert(
      'sources',
      (v) => (v as List<dynamic>)
          .map(
            (e) => SourceMetadataResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
    merged: $checkedConvert(
      'merged',
      (v) => v == null
          ? null
          : SourceMetadataResponse.fromJson(v as Map<String, dynamic>),
    ),
    differences: $checkedConvert(
      'differences',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$BookMetadataResponseToJson(
  BookMetadataResponse instance,
) => <String, dynamic>{
  'book': instance.book.toJson(),
  'fetchedAt': ?instance.fetchedAt?.toIso8601String(),
  'notFound': instance.notFound,
  'sources': instance.sources.map((e) => e.toJson()).toList(),
  'merged': ?instance.merged?.toJson(),
  'differences': instance.differences,
};
