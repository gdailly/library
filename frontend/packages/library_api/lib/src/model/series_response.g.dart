// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SeriesResponseCWProxy {
  SeriesResponse name(String name);

  SeriesResponse books(int books);

  SeriesResponse owned(int owned);

  SeriesResponse ownedNumbers(List<int> ownedNumbers);

  SeriesResponse wishedNumbers(List<int> wishedNumbers);

  SeriesResponse missingNumbers(List<int> missingNumbers);

  SeriesResponse lastNumber(int? lastNumber);

  SeriesResponse unnumbered(int unnumbered);

  SeriesResponse cover(CoverResponse? cover);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeriesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeriesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeriesResponse call({
    String name,
    int books,
    int owned,
    List<int> ownedNumbers,
    List<int> wishedNumbers,
    List<int> missingNumbers,
    int? lastNumber,
    int unnumbered,
    CoverResponse? cover,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSeriesResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSeriesResponse.copyWith.fieldName(...)`
class _$SeriesResponseCWProxyImpl implements _$SeriesResponseCWProxy {
  const _$SeriesResponseCWProxyImpl(this._value);

  final SeriesResponse _value;

  @override
  SeriesResponse name(String name) => this(name: name);

  @override
  SeriesResponse books(int books) => this(books: books);

  @override
  SeriesResponse owned(int owned) => this(owned: owned);

  @override
  SeriesResponse ownedNumbers(List<int> ownedNumbers) =>
      this(ownedNumbers: ownedNumbers);

  @override
  SeriesResponse wishedNumbers(List<int> wishedNumbers) =>
      this(wishedNumbers: wishedNumbers);

  @override
  SeriesResponse missingNumbers(List<int> missingNumbers) =>
      this(missingNumbers: missingNumbers);

  @override
  SeriesResponse lastNumber(int? lastNumber) => this(lastNumber: lastNumber);

  @override
  SeriesResponse unnumbered(int unnumbered) => this(unnumbered: unnumbered);

  @override
  SeriesResponse cover(CoverResponse? cover) => this(cover: cover);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeriesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeriesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeriesResponse call({
    Object? name = const $CopyWithPlaceholder(),
    Object? books = const $CopyWithPlaceholder(),
    Object? owned = const $CopyWithPlaceholder(),
    Object? ownedNumbers = const $CopyWithPlaceholder(),
    Object? wishedNumbers = const $CopyWithPlaceholder(),
    Object? missingNumbers = const $CopyWithPlaceholder(),
    Object? lastNumber = const $CopyWithPlaceholder(),
    Object? unnumbered = const $CopyWithPlaceholder(),
    Object? cover = const $CopyWithPlaceholder(),
  }) {
    return SeriesResponse(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      books: books == const $CopyWithPlaceholder()
          ? _value.books
          // ignore: cast_nullable_to_non_nullable
          : books as int,
      owned: owned == const $CopyWithPlaceholder()
          ? _value.owned
          // ignore: cast_nullable_to_non_nullable
          : owned as int,
      ownedNumbers: ownedNumbers == const $CopyWithPlaceholder()
          ? _value.ownedNumbers
          // ignore: cast_nullable_to_non_nullable
          : ownedNumbers as List<int>,
      wishedNumbers: wishedNumbers == const $CopyWithPlaceholder()
          ? _value.wishedNumbers
          // ignore: cast_nullable_to_non_nullable
          : wishedNumbers as List<int>,
      missingNumbers: missingNumbers == const $CopyWithPlaceholder()
          ? _value.missingNumbers
          // ignore: cast_nullable_to_non_nullable
          : missingNumbers as List<int>,
      lastNumber: lastNumber == const $CopyWithPlaceholder()
          ? _value.lastNumber
          // ignore: cast_nullable_to_non_nullable
          : lastNumber as int?,
      unnumbered: unnumbered == const $CopyWithPlaceholder()
          ? _value.unnumbered
          // ignore: cast_nullable_to_non_nullable
          : unnumbered as int,
      cover: cover == const $CopyWithPlaceholder()
          ? _value.cover
          // ignore: cast_nullable_to_non_nullable
          : cover as CoverResponse?,
    );
  }
}

extension $SeriesResponseCopyWith on SeriesResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSeriesResponse.copyWith(...)` or like so:`instanceOfSeriesResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SeriesResponseCWProxy get copyWith => _$SeriesResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeriesResponse _$SeriesResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SeriesResponse', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'name',
          'books',
          'owned',
          'ownedNumbers',
          'wishedNumbers',
          'missingNumbers',
          'unnumbered',
        ],
      );
      final val = SeriesResponse(
        name: $checkedConvert('name', (v) => v as String),
        books: $checkedConvert('books', (v) => (v as num).toInt()),
        owned: $checkedConvert('owned', (v) => (v as num).toInt()),
        ownedNumbers: $checkedConvert(
          'ownedNumbers',
          (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
        wishedNumbers: $checkedConvert(
          'wishedNumbers',
          (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
        missingNumbers: $checkedConvert(
          'missingNumbers',
          (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
        lastNumber: $checkedConvert('lastNumber', (v) => (v as num?)?.toInt()),
        unnumbered: $checkedConvert('unnumbered', (v) => (v as num).toInt()),
        cover: $checkedConvert(
          'cover',
          (v) => v == null
              ? null
              : CoverResponse.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SeriesResponseToJson(SeriesResponse instance) =>
    <String, dynamic>{
      'name': instance.name,
      'books': instance.books,
      'owned': instance.owned,
      'ownedNumbers': instance.ownedNumbers,
      'wishedNumbers': instance.wishedNumbers,
      'missingNumbers': instance.missingNumbers,
      'lastNumber': ?instance.lastNumber,
      'unnumbered': instance.unnumbered,
      'cover': ?instance.cover?.toJson(),
    };
