// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_run_item_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SyncRunItemResponseCWProxy {
  SyncRunItemResponse id(int id);

  SyncRunItemResponse label(String label);

  SyncRunItemResponse outcome(SyncItemOutcome outcome);

  SyncRunItemResponse detail(String? detail);

  SyncRunItemResponse childCount(int childCount);

  SyncRunItemResponse createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SyncRunItemResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SyncRunItemResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncRunItemResponse call({
    int id,
    String label,
    SyncItemOutcome outcome,
    String? detail,
    int childCount,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSyncRunItemResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSyncRunItemResponse.copyWith.fieldName(...)`
class _$SyncRunItemResponseCWProxyImpl implements _$SyncRunItemResponseCWProxy {
  const _$SyncRunItemResponseCWProxyImpl(this._value);

  final SyncRunItemResponse _value;

  @override
  SyncRunItemResponse id(int id) => this(id: id);

  @override
  SyncRunItemResponse label(String label) => this(label: label);

  @override
  SyncRunItemResponse outcome(SyncItemOutcome outcome) =>
      this(outcome: outcome);

  @override
  SyncRunItemResponse detail(String? detail) => this(detail: detail);

  @override
  SyncRunItemResponse childCount(int childCount) =>
      this(childCount: childCount);

  @override
  SyncRunItemResponse createdAt(DateTime createdAt) =>
      this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SyncRunItemResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SyncRunItemResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncRunItemResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? outcome = const $CopyWithPlaceholder(),
    Object? detail = const $CopyWithPlaceholder(),
    Object? childCount = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return SyncRunItemResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      outcome: outcome == const $CopyWithPlaceholder()
          ? _value.outcome
          // ignore: cast_nullable_to_non_nullable
          : outcome as SyncItemOutcome,
      detail: detail == const $CopyWithPlaceholder()
          ? _value.detail
          // ignore: cast_nullable_to_non_nullable
          : detail as String?,
      childCount: childCount == const $CopyWithPlaceholder()
          ? _value.childCount
          // ignore: cast_nullable_to_non_nullable
          : childCount as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $SyncRunItemResponseCopyWith on SyncRunItemResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSyncRunItemResponse.copyWith(...)` or like so:`instanceOfSyncRunItemResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SyncRunItemResponseCWProxy get copyWith =>
      _$SyncRunItemResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncRunItemResponse _$SyncRunItemResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SyncRunItemResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'label', 'outcome', 'childCount', 'createdAt'],
  );
  final val = SyncRunItemResponse(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    label: $checkedConvert('label', (v) => v as String),
    outcome: $checkedConvert(
      'outcome',
      (v) => $enumDecode(_$SyncItemOutcomeEnumMap, v),
    ),
    detail: $checkedConvert('detail', (v) => v as String?),
    childCount: $checkedConvert('childCount', (v) => (v as num).toInt()),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$SyncRunItemResponseToJson(
  SyncRunItemResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'outcome': _$SyncItemOutcomeEnumMap[instance.outcome]!,
  'detail': ?instance.detail,
  'childCount': instance.childCount,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$SyncItemOutcomeEnumMap = {
  SyncItemOutcome.UPDATED: 'UPDATED',
  SyncItemOutcome.UNCHANGED: 'UNCHANGED',
  SyncItemOutcome.FOUND: 'FOUND',
  SyncItemOutcome.NOT_FOUND: 'NOT_FOUND',
  SyncItemOutcome.NO_REFERENCE: 'NO_REFERENCE',
  SyncItemOutcome.FAILED: 'FAILED',
  SyncItemOutcome.ADDED: 'ADDED',
  SyncItemOutcome.REMOVED: 'REMOVED',
};
