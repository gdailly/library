// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cover_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CoverResponseCWProxy {
  CoverResponse thumbUrl(String thumbUrl);

  CoverResponse mediumUrl(String mediumUrl);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoverResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoverResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CoverResponse call({String thumbUrl, String mediumUrl});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCoverResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCoverResponse.copyWith.fieldName(...)`
class _$CoverResponseCWProxyImpl implements _$CoverResponseCWProxy {
  const _$CoverResponseCWProxyImpl(this._value);

  final CoverResponse _value;

  @override
  CoverResponse thumbUrl(String thumbUrl) => this(thumbUrl: thumbUrl);

  @override
  CoverResponse mediumUrl(String mediumUrl) => this(mediumUrl: mediumUrl);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CoverResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CoverResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CoverResponse call({
    Object? thumbUrl = const $CopyWithPlaceholder(),
    Object? mediumUrl = const $CopyWithPlaceholder(),
  }) {
    return CoverResponse(
      thumbUrl: thumbUrl == const $CopyWithPlaceholder()
          ? _value.thumbUrl
          // ignore: cast_nullable_to_non_nullable
          : thumbUrl as String,
      mediumUrl: mediumUrl == const $CopyWithPlaceholder()
          ? _value.mediumUrl
          // ignore: cast_nullable_to_non_nullable
          : mediumUrl as String,
    );
  }
}

extension $CoverResponseCopyWith on CoverResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCoverResponse.copyWith(...)` or like so:`instanceOfCoverResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CoverResponseCWProxy get copyWith => _$CoverResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoverResponse _$CoverResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CoverResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['thumbUrl', 'mediumUrl']);
      final val = CoverResponse(
        thumbUrl: $checkedConvert('thumbUrl', (v) => v as String),
        mediumUrl: $checkedConvert('mediumUrl', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CoverResponseToJson(CoverResponse instance) =>
    <String, dynamic>{
      'thumbUrl': instance.thumbUrl,
      'mediumUrl': instance.mediumUrl,
    };
