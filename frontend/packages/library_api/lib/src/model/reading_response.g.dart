// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReadingResponseCWProxy {
  ReadingResponse status(ReadingStatus status);

  ReadingResponse rating(int? rating);

  ReadingResponse review(String? review);

  ReadingResponse startedOn(DateTime? startedOn);

  ReadingResponse finishedOn(DateTime? finishedOn);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadingResponse call({
    ReadingStatus status,
    int? rating,
    String? review,
    DateTime? startedOn,
    DateTime? finishedOn,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReadingResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReadingResponse.copyWith.fieldName(...)`
class _$ReadingResponseCWProxyImpl implements _$ReadingResponseCWProxy {
  const _$ReadingResponseCWProxyImpl(this._value);

  final ReadingResponse _value;

  @override
  ReadingResponse status(ReadingStatus status) => this(status: status);

  @override
  ReadingResponse rating(int? rating) => this(rating: rating);

  @override
  ReadingResponse review(String? review) => this(review: review);

  @override
  ReadingResponse startedOn(DateTime? startedOn) => this(startedOn: startedOn);

  @override
  ReadingResponse finishedOn(DateTime? finishedOn) =>
      this(finishedOn: finishedOn);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadingResponse call({
    Object? status = const $CopyWithPlaceholder(),
    Object? rating = const $CopyWithPlaceholder(),
    Object? review = const $CopyWithPlaceholder(),
    Object? startedOn = const $CopyWithPlaceholder(),
    Object? finishedOn = const $CopyWithPlaceholder(),
  }) {
    return ReadingResponse(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ReadingStatus,
      rating: rating == const $CopyWithPlaceholder()
          ? _value.rating
          // ignore: cast_nullable_to_non_nullable
          : rating as int?,
      review: review == const $CopyWithPlaceholder()
          ? _value.review
          // ignore: cast_nullable_to_non_nullable
          : review as String?,
      startedOn: startedOn == const $CopyWithPlaceholder()
          ? _value.startedOn
          // ignore: cast_nullable_to_non_nullable
          : startedOn as DateTime?,
      finishedOn: finishedOn == const $CopyWithPlaceholder()
          ? _value.finishedOn
          // ignore: cast_nullable_to_non_nullable
          : finishedOn as DateTime?,
    );
  }
}

extension $ReadingResponseCopyWith on ReadingResponse {
  /// Returns a callable class that can be used as follows: `instanceOfReadingResponse.copyWith(...)` or like so:`instanceOfReadingResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReadingResponseCWProxy get copyWith => _$ReadingResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingResponse _$ReadingResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReadingResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status']);
      final val = ReadingResponse(
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$ReadingStatusEnumMap, v),
        ),
        rating: $checkedConvert('rating', (v) => (v as num?)?.toInt()),
        review: $checkedConvert('review', (v) => v as String?),
        startedOn: $checkedConvert(
          'startedOn',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        finishedOn: $checkedConvert(
          'finishedOn',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReadingResponseToJson(ReadingResponse instance) =>
    <String, dynamic>{
      'status': _$ReadingStatusEnumMap[instance.status]!,
      'rating': ?instance.rating,
      'review': ?instance.review,
      'startedOn': ?instance.startedOn?.toIso8601String(),
      'finishedOn': ?instance.finishedOn?.toIso8601String(),
    };

const _$ReadingStatusEnumMap = {
  ReadingStatus.TO_READ: 'TO_READ',
  ReadingStatus.READING: 'READING',
  ReadingStatus.READ: 'READ',
  ReadingStatus.ABANDONED: 'ABANDONED',
};
