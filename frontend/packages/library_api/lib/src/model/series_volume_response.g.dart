// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_volume_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SeriesVolumeResponseCWProxy {
  SeriesVolumeResponse number(int number);

  SeriesVolumeResponse title(String? title);

  SeriesVolumeResponse isbn13(String? isbn13);

  SeriesVolumeResponse year(int? year);

  SeriesVolumeResponse coverUrl(String? coverUrl);

  SeriesVolumeResponse books(List<BookResponse> books);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeriesVolumeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeriesVolumeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeriesVolumeResponse call({
    int number,
    String? title,
    String? isbn13,
    int? year,
    String? coverUrl,
    List<BookResponse> books,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSeriesVolumeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSeriesVolumeResponse.copyWith.fieldName(...)`
class _$SeriesVolumeResponseCWProxyImpl
    implements _$SeriesVolumeResponseCWProxy {
  const _$SeriesVolumeResponseCWProxyImpl(this._value);

  final SeriesVolumeResponse _value;

  @override
  SeriesVolumeResponse number(int number) => this(number: number);

  @override
  SeriesVolumeResponse title(String? title) => this(title: title);

  @override
  SeriesVolumeResponse isbn13(String? isbn13) => this(isbn13: isbn13);

  @override
  SeriesVolumeResponse year(int? year) => this(year: year);

  @override
  SeriesVolumeResponse coverUrl(String? coverUrl) => this(coverUrl: coverUrl);

  @override
  SeriesVolumeResponse books(List<BookResponse> books) => this(books: books);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeriesVolumeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeriesVolumeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeriesVolumeResponse call({
    Object? number = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? isbn13 = const $CopyWithPlaceholder(),
    Object? year = const $CopyWithPlaceholder(),
    Object? coverUrl = const $CopyWithPlaceholder(),
    Object? books = const $CopyWithPlaceholder(),
  }) {
    return SeriesVolumeResponse(
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as int,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      isbn13: isbn13 == const $CopyWithPlaceholder()
          ? _value.isbn13
          // ignore: cast_nullable_to_non_nullable
          : isbn13 as String?,
      year: year == const $CopyWithPlaceholder()
          ? _value.year
          // ignore: cast_nullable_to_non_nullable
          : year as int?,
      coverUrl: coverUrl == const $CopyWithPlaceholder()
          ? _value.coverUrl
          // ignore: cast_nullable_to_non_nullable
          : coverUrl as String?,
      books: books == const $CopyWithPlaceholder()
          ? _value.books
          // ignore: cast_nullable_to_non_nullable
          : books as List<BookResponse>,
    );
  }
}

extension $SeriesVolumeResponseCopyWith on SeriesVolumeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSeriesVolumeResponse.copyWith(...)` or like so:`instanceOfSeriesVolumeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SeriesVolumeResponseCWProxy get copyWith =>
      _$SeriesVolumeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeriesVolumeResponse _$SeriesVolumeResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SeriesVolumeResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['number', 'books']);
  final val = SeriesVolumeResponse(
    number: $checkedConvert('number', (v) => (v as num).toInt()),
    title: $checkedConvert('title', (v) => v as String?),
    isbn13: $checkedConvert('isbn13', (v) => v as String?),
    year: $checkedConvert('year', (v) => (v as num?)?.toInt()),
    coverUrl: $checkedConvert('coverUrl', (v) => v as String?),
    books: $checkedConvert(
      'books',
      (v) => (v as List<dynamic>)
          .map((e) => BookResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SeriesVolumeResponseToJson(
  SeriesVolumeResponse instance,
) => <String, dynamic>{
  'number': instance.number,
  'title': ?instance.title,
  'isbn13': ?instance.isbn13,
  'year': ?instance.year,
  'coverUrl': ?instance.coverUrl,
  'books': instance.books.map((e) => e.toJson()).toList(),
};
