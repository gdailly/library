// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_admin_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MetadataAdminResponseCWProxy {
  MetadataAdminResponse books(int books);

  MetadataAdminResponse booksWithIsbn(int booksWithIsbn);

  MetadataAdminResponse cachedIsbns(int cachedIsbns);

  MetadataAdminResponse cachedNotFound(int cachedNotFound);

  MetadataAdminResponse job(MetadataSyncJobResponse job);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MetadataAdminResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MetadataAdminResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MetadataAdminResponse call({
    int books,
    int booksWithIsbn,
    int cachedIsbns,
    int cachedNotFound,
    MetadataSyncJobResponse job,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMetadataAdminResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMetadataAdminResponse.copyWith.fieldName(...)`
class _$MetadataAdminResponseCWProxyImpl
    implements _$MetadataAdminResponseCWProxy {
  const _$MetadataAdminResponseCWProxyImpl(this._value);

  final MetadataAdminResponse _value;

  @override
  MetadataAdminResponse books(int books) => this(books: books);

  @override
  MetadataAdminResponse booksWithIsbn(int booksWithIsbn) =>
      this(booksWithIsbn: booksWithIsbn);

  @override
  MetadataAdminResponse cachedIsbns(int cachedIsbns) =>
      this(cachedIsbns: cachedIsbns);

  @override
  MetadataAdminResponse cachedNotFound(int cachedNotFound) =>
      this(cachedNotFound: cachedNotFound);

  @override
  MetadataAdminResponse job(MetadataSyncJobResponse job) => this(job: job);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MetadataAdminResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MetadataAdminResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MetadataAdminResponse call({
    Object? books = const $CopyWithPlaceholder(),
    Object? booksWithIsbn = const $CopyWithPlaceholder(),
    Object? cachedIsbns = const $CopyWithPlaceholder(),
    Object? cachedNotFound = const $CopyWithPlaceholder(),
    Object? job = const $CopyWithPlaceholder(),
  }) {
    return MetadataAdminResponse(
      books: books == const $CopyWithPlaceholder()
          ? _value.books
          // ignore: cast_nullable_to_non_nullable
          : books as int,
      booksWithIsbn: booksWithIsbn == const $CopyWithPlaceholder()
          ? _value.booksWithIsbn
          // ignore: cast_nullable_to_non_nullable
          : booksWithIsbn as int,
      cachedIsbns: cachedIsbns == const $CopyWithPlaceholder()
          ? _value.cachedIsbns
          // ignore: cast_nullable_to_non_nullable
          : cachedIsbns as int,
      cachedNotFound: cachedNotFound == const $CopyWithPlaceholder()
          ? _value.cachedNotFound
          // ignore: cast_nullable_to_non_nullable
          : cachedNotFound as int,
      job: job == const $CopyWithPlaceholder()
          ? _value.job
          // ignore: cast_nullable_to_non_nullable
          : job as MetadataSyncJobResponse,
    );
  }
}

extension $MetadataAdminResponseCopyWith on MetadataAdminResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMetadataAdminResponse.copyWith(...)` or like so:`instanceOfMetadataAdminResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MetadataAdminResponseCWProxy get copyWith =>
      _$MetadataAdminResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetadataAdminResponse _$MetadataAdminResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MetadataAdminResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'books',
      'booksWithIsbn',
      'cachedIsbns',
      'cachedNotFound',
      'job',
    ],
  );
  final val = MetadataAdminResponse(
    books: $checkedConvert('books', (v) => (v as num).toInt()),
    booksWithIsbn: $checkedConvert('booksWithIsbn', (v) => (v as num).toInt()),
    cachedIsbns: $checkedConvert('cachedIsbns', (v) => (v as num).toInt()),
    cachedNotFound: $checkedConvert(
      'cachedNotFound',
      (v) => (v as num).toInt(),
    ),
    job: $checkedConvert(
      'job',
      (v) => MetadataSyncJobResponse.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$MetadataAdminResponseToJson(
  MetadataAdminResponse instance,
) => <String, dynamic>{
  'books': instance.books,
  'booksWithIsbn': instance.booksWithIsbn,
  'cachedIsbns': instance.cachedIsbns,
  'cachedNotFound': instance.cachedNotFound,
  'job': instance.job.toJson(),
};
