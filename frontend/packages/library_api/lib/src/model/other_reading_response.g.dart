// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'other_reading_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OtherReadingResponseCWProxy {
  OtherReadingResponse userId(int userId);

  OtherReadingResponse name(String name);

  OtherReadingResponse status(ReadingStatus status);

  OtherReadingResponse rating(int? rating);

  OtherReadingResponse review(String? review);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtherReadingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtherReadingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OtherReadingResponse call({
    int userId,
    String name,
    ReadingStatus status,
    int? rating,
    String? review,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOtherReadingResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOtherReadingResponse.copyWith.fieldName(...)`
class _$OtherReadingResponseCWProxyImpl
    implements _$OtherReadingResponseCWProxy {
  const _$OtherReadingResponseCWProxyImpl(this._value);

  final OtherReadingResponse _value;

  @override
  OtherReadingResponse userId(int userId) => this(userId: userId);

  @override
  OtherReadingResponse name(String name) => this(name: name);

  @override
  OtherReadingResponse status(ReadingStatus status) => this(status: status);

  @override
  OtherReadingResponse rating(int? rating) => this(rating: rating);

  @override
  OtherReadingResponse review(String? review) => this(review: review);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtherReadingResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtherReadingResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OtherReadingResponse call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? rating = const $CopyWithPlaceholder(),
    Object? review = const $CopyWithPlaceholder(),
  }) {
    return OtherReadingResponse(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
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
    );
  }
}

extension $OtherReadingResponseCopyWith on OtherReadingResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOtherReadingResponse.copyWith(...)` or like so:`instanceOfOtherReadingResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OtherReadingResponseCWProxy get copyWith =>
      _$OtherReadingResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtherReadingResponse _$OtherReadingResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('OtherReadingResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['userId', 'name', 'status']);
  final val = OtherReadingResponse(
    userId: $checkedConvert('userId', (v) => (v as num).toInt()),
    name: $checkedConvert('name', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$ReadingStatusEnumMap, v),
    ),
    rating: $checkedConvert('rating', (v) => (v as num?)?.toInt()),
    review: $checkedConvert('review', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$OtherReadingResponseToJson(
  OtherReadingResponse instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'status': _$ReadingStatusEnumMap[instance.status]!,
  'rating': ?instance.rating,
  'review': ?instance.review,
};

const _$ReadingStatusEnumMap = {
  ReadingStatus.TO_READ: 'TO_READ',
  ReadingStatus.READING: 'READING',
  ReadingStatus.READ: 'READ',
  ReadingStatus.ABANDONED: 'ABANDONED',
};
