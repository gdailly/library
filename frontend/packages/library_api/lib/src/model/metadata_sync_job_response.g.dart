// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata_sync_job_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MetadataSyncJobResponseCWProxy {
  MetadataSyncJobResponse state(SyncState state);

  MetadataSyncJobResponse total(int total);

  MetadataSyncJobResponse processed(int processed);

  MetadataSyncJobResponse updated(int updated);

  MetadataSyncJobResponse unchanged(int unchanged);

  MetadataSyncJobResponse notFound(int notFound);

  MetadataSyncJobResponse failed(int failed);

  MetadataSyncJobResponse startedAt(DateTime? startedAt);

  MetadataSyncJobResponse finishedAt(DateTime? finishedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MetadataSyncJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MetadataSyncJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MetadataSyncJobResponse call({
    SyncState state,
    int total,
    int processed,
    int updated,
    int unchanged,
    int notFound,
    int failed,
    DateTime? startedAt,
    DateTime? finishedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMetadataSyncJobResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMetadataSyncJobResponse.copyWith.fieldName(...)`
class _$MetadataSyncJobResponseCWProxyImpl
    implements _$MetadataSyncJobResponseCWProxy {
  const _$MetadataSyncJobResponseCWProxyImpl(this._value);

  final MetadataSyncJobResponse _value;

  @override
  MetadataSyncJobResponse state(SyncState state) => this(state: state);

  @override
  MetadataSyncJobResponse total(int total) => this(total: total);

  @override
  MetadataSyncJobResponse processed(int processed) =>
      this(processed: processed);

  @override
  MetadataSyncJobResponse updated(int updated) => this(updated: updated);

  @override
  MetadataSyncJobResponse unchanged(int unchanged) =>
      this(unchanged: unchanged);

  @override
  MetadataSyncJobResponse notFound(int notFound) => this(notFound: notFound);

  @override
  MetadataSyncJobResponse failed(int failed) => this(failed: failed);

  @override
  MetadataSyncJobResponse startedAt(DateTime? startedAt) =>
      this(startedAt: startedAt);

  @override
  MetadataSyncJobResponse finishedAt(DateTime? finishedAt) =>
      this(finishedAt: finishedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MetadataSyncJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MetadataSyncJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MetadataSyncJobResponse call({
    Object? state = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? processed = const $CopyWithPlaceholder(),
    Object? updated = const $CopyWithPlaceholder(),
    Object? unchanged = const $CopyWithPlaceholder(),
    Object? notFound = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? finishedAt = const $CopyWithPlaceholder(),
  }) {
    return MetadataSyncJobResponse(
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as SyncState,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
      processed: processed == const $CopyWithPlaceholder()
          ? _value.processed
          // ignore: cast_nullable_to_non_nullable
          : processed as int,
      updated: updated == const $CopyWithPlaceholder()
          ? _value.updated
          // ignore: cast_nullable_to_non_nullable
          : updated as int,
      unchanged: unchanged == const $CopyWithPlaceholder()
          ? _value.unchanged
          // ignore: cast_nullable_to_non_nullable
          : unchanged as int,
      notFound: notFound == const $CopyWithPlaceholder()
          ? _value.notFound
          // ignore: cast_nullable_to_non_nullable
          : notFound as int,
      failed: failed == const $CopyWithPlaceholder()
          ? _value.failed
          // ignore: cast_nullable_to_non_nullable
          : failed as int,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
      finishedAt: finishedAt == const $CopyWithPlaceholder()
          ? _value.finishedAt
          // ignore: cast_nullable_to_non_nullable
          : finishedAt as DateTime?,
    );
  }
}

extension $MetadataSyncJobResponseCopyWith on MetadataSyncJobResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMetadataSyncJobResponse.copyWith(...)` or like so:`instanceOfMetadataSyncJobResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MetadataSyncJobResponseCWProxy get copyWith =>
      _$MetadataSyncJobResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MetadataSyncJobResponse _$MetadataSyncJobResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MetadataSyncJobResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'state',
      'total',
      'processed',
      'updated',
      'unchanged',
      'notFound',
      'failed',
    ],
  );
  final val = MetadataSyncJobResponse(
    state: $checkedConvert('state', (v) => $enumDecode(_$SyncStateEnumMap, v)),
    total: $checkedConvert('total', (v) => (v as num).toInt()),
    processed: $checkedConvert('processed', (v) => (v as num).toInt()),
    updated: $checkedConvert('updated', (v) => (v as num).toInt()),
    unchanged: $checkedConvert('unchanged', (v) => (v as num).toInt()),
    notFound: $checkedConvert('notFound', (v) => (v as num).toInt()),
    failed: $checkedConvert('failed', (v) => (v as num).toInt()),
    startedAt: $checkedConvert(
      'startedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    finishedAt: $checkedConvert(
      'finishedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$MetadataSyncJobResponseToJson(
  MetadataSyncJobResponse instance,
) => <String, dynamic>{
  'state': _$SyncStateEnumMap[instance.state]!,
  'total': instance.total,
  'processed': instance.processed,
  'updated': instance.updated,
  'unchanged': instance.unchanged,
  'notFound': instance.notFound,
  'failed': instance.failed,
  'startedAt': ?instance.startedAt?.toIso8601String(),
  'finishedAt': ?instance.finishedAt?.toIso8601String(),
};

const _$SyncStateEnumMap = {
  SyncState.IDLE: 'IDLE',
  SyncState.RUNNING: 'RUNNING',
  SyncState.DONE: 'DONE',
};
