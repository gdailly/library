// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReadingRequestCWProxy {
  ReadingRequest status(ReadingStatus status);

  ReadingRequest rating(int? rating);

  ReadingRequest review(String? review);

  ReadingRequest startedOn(DateTime? startedOn);

  ReadingRequest finishedOn(DateTime? finishedOn);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadingRequest call({
    ReadingStatus status,
    int? rating,
    String? review,
    DateTime? startedOn,
    DateTime? finishedOn,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReadingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReadingRequest.copyWith.fieldName(...)`
class _$ReadingRequestCWProxyImpl implements _$ReadingRequestCWProxy {
  const _$ReadingRequestCWProxyImpl(this._value);

  final ReadingRequest _value;

  @override
  ReadingRequest status(ReadingStatus status) => this(status: status);

  @override
  ReadingRequest rating(int? rating) => this(rating: rating);

  @override
  ReadingRequest review(String? review) => this(review: review);

  @override
  ReadingRequest startedOn(DateTime? startedOn) => this(startedOn: startedOn);

  @override
  ReadingRequest finishedOn(DateTime? finishedOn) =>
      this(finishedOn: finishedOn);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReadingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReadingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ReadingRequest call({
    Object? status = const $CopyWithPlaceholder(),
    Object? rating = const $CopyWithPlaceholder(),
    Object? review = const $CopyWithPlaceholder(),
    Object? startedOn = const $CopyWithPlaceholder(),
    Object? finishedOn = const $CopyWithPlaceholder(),
  }) {
    return ReadingRequest(
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

extension $ReadingRequestCopyWith on ReadingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfReadingRequest.copyWith(...)` or like so:`instanceOfReadingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReadingRequestCWProxy get copyWith => _$ReadingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingRequest _$ReadingRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReadingRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status']);
      final val = ReadingRequest(
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

Map<String, dynamic> _$ReadingRequestToJson(ReadingRequest instance) =>
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
