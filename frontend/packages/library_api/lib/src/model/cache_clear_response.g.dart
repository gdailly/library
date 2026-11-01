// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_clear_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CacheClearResponseCWProxy {
  CacheClearResponse deleted(int deleted);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CacheClearResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CacheClearResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CacheClearResponse call({int deleted});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCacheClearResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCacheClearResponse.copyWith.fieldName(...)`
class _$CacheClearResponseCWProxyImpl implements _$CacheClearResponseCWProxy {
  const _$CacheClearResponseCWProxyImpl(this._value);

  final CacheClearResponse _value;

  @override
  CacheClearResponse deleted(int deleted) => this(deleted: deleted);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CacheClearResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CacheClearResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CacheClearResponse call({Object? deleted = const $CopyWithPlaceholder()}) {
    return CacheClearResponse(
      deleted: deleted == const $CopyWithPlaceholder()
          ? _value.deleted
          // ignore: cast_nullable_to_non_nullable
          : deleted as int,
    );
  }
}

extension $CacheClearResponseCopyWith on CacheClearResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCacheClearResponse.copyWith(...)` or like so:`instanceOfCacheClearResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CacheClearResponseCWProxy get copyWith =>
      _$CacheClearResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CacheClearResponse _$CacheClearResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CacheClearResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['deleted']);
      final val = CacheClearResponse(
        deleted: $checkedConvert('deleted', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$CacheClearResponseToJson(CacheClearResponse instance) =>
    <String, dynamic>{'deleted': instance.deleted};
