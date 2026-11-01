// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apply_metadata_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApplyMetadataRequestCWProxy {
  ApplyMetadataRequest source_(MetadataSource source_);

  ApplyMetadataRequest fields(List<String> fields);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyMetadataRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyMetadataRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyMetadataRequest call({MetadataSource source_, List<String> fields});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApplyMetadataRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApplyMetadataRequest.copyWith.fieldName(...)`
class _$ApplyMetadataRequestCWProxyImpl
    implements _$ApplyMetadataRequestCWProxy {
  const _$ApplyMetadataRequestCWProxyImpl(this._value);

  final ApplyMetadataRequest _value;

  @override
  ApplyMetadataRequest source_(MetadataSource source_) =>
      this(source_: source_);

  @override
  ApplyMetadataRequest fields(List<String> fields) => this(fields: fields);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApplyMetadataRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApplyMetadataRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ApplyMetadataRequest call({
    Object? source_ = const $CopyWithPlaceholder(),
    Object? fields = const $CopyWithPlaceholder(),
  }) {
    return ApplyMetadataRequest(
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as MetadataSource,
      fields: fields == const $CopyWithPlaceholder()
          ? _value.fields
          // ignore: cast_nullable_to_non_nullable
          : fields as List<String>,
    );
  }
}

extension $ApplyMetadataRequestCopyWith on ApplyMetadataRequest {
  /// Returns a callable class that can be used as follows: `instanceOfApplyMetadataRequest.copyWith(...)` or like so:`instanceOfApplyMetadataRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApplyMetadataRequestCWProxy get copyWith =>
      _$ApplyMetadataRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplyMetadataRequest _$ApplyMetadataRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ApplyMetadataRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['source', 'fields']);
  final val = ApplyMetadataRequest(
    source_: $checkedConvert(
      'source',
      (v) => $enumDecode(_$MetadataSourceEnumMap, v),
    ),
    fields: $checkedConvert(
      'fields',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$ApplyMetadataRequestToJson(
  ApplyMetadataRequest instance,
) => <String, dynamic>{
  'source': _$MetadataSourceEnumMap[instance.source_]!,
  'fields': instance.fields,
};

const _$MetadataSourceEnumMap = {
  MetadataSource.LIBRARY: 'LIBRARY',
  MetadataSource.OPEN_LIBRARY: 'OPEN_LIBRARY',
  MetadataSource.GOOGLE_BOOKS: 'GOOGLE_BOOKS',
  MetadataSource.BNF: 'BNF',
};
