// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_sync_job_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SeriesSyncJobResponseCWProxy {
  SeriesSyncJobResponse state(SyncState state);

  SeriesSyncJobResponse total(int total);

  SeriesSyncJobResponse processed(int processed);

  SeriesSyncJobResponse found(int found);

  SeriesSyncJobResponse notFound(int notFound);

  SeriesSyncJobResponse failed(int failed);

  SeriesSyncJobResponse startedAt(DateTime? startedAt);

  SeriesSyncJobResponse finishedAt(DateTime? finishedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeriesSyncJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeriesSyncJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeriesSyncJobResponse call({
    SyncState state,
    int total,
    int processed,
    int found,
    int notFound,
    int failed,
    DateTime? startedAt,
    DateTime? finishedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSeriesSyncJobResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSeriesSyncJobResponse.copyWith.fieldName(...)`
class _$SeriesSyncJobResponseCWProxyImpl
    implements _$SeriesSyncJobResponseCWProxy {
  const _$SeriesSyncJobResponseCWProxyImpl(this._value);

  final SeriesSyncJobResponse _value;

  @override
  SeriesSyncJobResponse state(SyncState state) => this(state: state);

  @override
  SeriesSyncJobResponse total(int total) => this(total: total);

  @override
  SeriesSyncJobResponse processed(int processed) => this(processed: processed);

  @override
  SeriesSyncJobResponse found(int found) => this(found: found);

  @override
  SeriesSyncJobResponse notFound(int notFound) => this(notFound: notFound);

  @override
  SeriesSyncJobResponse failed(int failed) => this(failed: failed);

  @override
  SeriesSyncJobResponse startedAt(DateTime? startedAt) =>
      this(startedAt: startedAt);

  @override
  SeriesSyncJobResponse finishedAt(DateTime? finishedAt) =>
      this(finishedAt: finishedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeriesSyncJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeriesSyncJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeriesSyncJobResponse call({
    Object? state = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? processed = const $CopyWithPlaceholder(),
    Object? found = const $CopyWithPlaceholder(),
    Object? notFound = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? finishedAt = const $CopyWithPlaceholder(),
  }) {
    return SeriesSyncJobResponse(
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
      found: found == const $CopyWithPlaceholder()
          ? _value.found
          // ignore: cast_nullable_to_non_nullable
          : found as int,
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

extension $SeriesSyncJobResponseCopyWith on SeriesSyncJobResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSeriesSyncJobResponse.copyWith(...)` or like so:`instanceOfSeriesSyncJobResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SeriesSyncJobResponseCWProxy get copyWith =>
      _$SeriesSyncJobResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeriesSyncJobResponse _$SeriesSyncJobResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SeriesSyncJobResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'state',
      'total',
      'processed',
      'found',
      'notFound',
      'failed',
    ],
  );
  final val = SeriesSyncJobResponse(
    state: $checkedConvert('state', (v) => $enumDecode(_$SyncStateEnumMap, v)),
    total: $checkedConvert('total', (v) => (v as num).toInt()),
    processed: $checkedConvert('processed', (v) => (v as num).toInt()),
    found: $checkedConvert('found', (v) => (v as num).toInt()),
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

Map<String, dynamic> _$SeriesSyncJobResponseToJson(
  SeriesSyncJobResponse instance,
) => <String, dynamic>{
  'state': _$SyncStateEnumMap[instance.state]!,
  'total': instance.total,
  'processed': instance.processed,
  'found': instance.found,
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
