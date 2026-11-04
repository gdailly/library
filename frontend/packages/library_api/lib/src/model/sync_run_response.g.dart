// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_run_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SyncRunResponseCWProxy {
  SyncRunResponse id(int id);

  SyncRunResponse kind(SyncKind kind);

  SyncRunResponse startedBy(String? startedBy);

  SyncRunResponse state(SyncRunState state);

  SyncRunResponse total(int total);

  SyncRunResponse processed(int processed);

  SyncRunResponse succeeded(int succeeded);

  SyncRunResponse unchanged(int unchanged);

  SyncRunResponse notFound(int notFound);

  SyncRunResponse failed(int failed);

  SyncRunResponse startedAt(DateTime startedAt);

  SyncRunResponse finishedAt(DateTime? finishedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SyncRunResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SyncRunResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncRunResponse call({
    int id,
    SyncKind kind,
    String? startedBy,
    SyncRunState state,
    int total,
    int processed,
    int succeeded,
    int unchanged,
    int notFound,
    int failed,
    DateTime startedAt,
    DateTime? finishedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSyncRunResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSyncRunResponse.copyWith.fieldName(...)`
class _$SyncRunResponseCWProxyImpl implements _$SyncRunResponseCWProxy {
  const _$SyncRunResponseCWProxyImpl(this._value);

  final SyncRunResponse _value;

  @override
  SyncRunResponse id(int id) => this(id: id);

  @override
  SyncRunResponse kind(SyncKind kind) => this(kind: kind);

  @override
  SyncRunResponse startedBy(String? startedBy) => this(startedBy: startedBy);

  @override
  SyncRunResponse state(SyncRunState state) => this(state: state);

  @override
  SyncRunResponse total(int total) => this(total: total);

  @override
  SyncRunResponse processed(int processed) => this(processed: processed);

  @override
  SyncRunResponse succeeded(int succeeded) => this(succeeded: succeeded);

  @override
  SyncRunResponse unchanged(int unchanged) => this(unchanged: unchanged);

  @override
  SyncRunResponse notFound(int notFound) => this(notFound: notFound);

  @override
  SyncRunResponse failed(int failed) => this(failed: failed);

  @override
  SyncRunResponse startedAt(DateTime startedAt) => this(startedAt: startedAt);

  @override
  SyncRunResponse finishedAt(DateTime? finishedAt) =>
      this(finishedAt: finishedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SyncRunResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SyncRunResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SyncRunResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? startedBy = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? total = const $CopyWithPlaceholder(),
    Object? processed = const $CopyWithPlaceholder(),
    Object? succeeded = const $CopyWithPlaceholder(),
    Object? unchanged = const $CopyWithPlaceholder(),
    Object? notFound = const $CopyWithPlaceholder(),
    Object? failed = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? finishedAt = const $CopyWithPlaceholder(),
  }) {
    return SyncRunResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as SyncKind,
      startedBy: startedBy == const $CopyWithPlaceholder()
          ? _value.startedBy
          // ignore: cast_nullable_to_non_nullable
          : startedBy as String?,
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as SyncRunState,
      total: total == const $CopyWithPlaceholder()
          ? _value.total
          // ignore: cast_nullable_to_non_nullable
          : total as int,
      processed: processed == const $CopyWithPlaceholder()
          ? _value.processed
          // ignore: cast_nullable_to_non_nullable
          : processed as int,
      succeeded: succeeded == const $CopyWithPlaceholder()
          ? _value.succeeded
          // ignore: cast_nullable_to_non_nullable
          : succeeded as int,
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
          : startedAt as DateTime,
      finishedAt: finishedAt == const $CopyWithPlaceholder()
          ? _value.finishedAt
          // ignore: cast_nullable_to_non_nullable
          : finishedAt as DateTime?,
    );
  }
}

extension $SyncRunResponseCopyWith on SyncRunResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSyncRunResponse.copyWith(...)` or like so:`instanceOfSyncRunResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SyncRunResponseCWProxy get copyWith => _$SyncRunResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncRunResponse _$SyncRunResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SyncRunResponse', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'kind',
          'state',
          'total',
          'processed',
          'succeeded',
          'unchanged',
          'notFound',
          'failed',
          'startedAt',
        ],
      );
      final val = SyncRunResponse(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        kind: $checkedConvert('kind', (v) => $enumDecode(_$SyncKindEnumMap, v)),
        startedBy: $checkedConvert('startedBy', (v) => v as String?),
        state: $checkedConvert(
          'state',
          (v) => $enumDecode(_$SyncRunStateEnumMap, v),
        ),
        total: $checkedConvert('total', (v) => (v as num).toInt()),
        processed: $checkedConvert('processed', (v) => (v as num).toInt()),
        succeeded: $checkedConvert('succeeded', (v) => (v as num).toInt()),
        unchanged: $checkedConvert('unchanged', (v) => (v as num).toInt()),
        notFound: $checkedConvert('notFound', (v) => (v as num).toInt()),
        failed: $checkedConvert('failed', (v) => (v as num).toInt()),
        startedAt: $checkedConvert(
          'startedAt',
          (v) => DateTime.parse(v as String),
        ),
        finishedAt: $checkedConvert(
          'finishedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SyncRunResponseToJson(SyncRunResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$SyncKindEnumMap[instance.kind]!,
      'startedBy': ?instance.startedBy,
      'state': _$SyncRunStateEnumMap[instance.state]!,
      'total': instance.total,
      'processed': instance.processed,
      'succeeded': instance.succeeded,
      'unchanged': instance.unchanged,
      'notFound': instance.notFound,
      'failed': instance.failed,
      'startedAt': instance.startedAt.toIso8601String(),
      'finishedAt': ?instance.finishedAt?.toIso8601String(),
    };

const _$SyncKindEnumMap = {
  SyncKind.METADATA_FILL: 'METADATA_FILL',
  SyncKind.METADATA_FETCH: 'METADATA_FETCH',
  SyncKind.METADATA_BOOK: 'METADATA_BOOK',
  SyncKind.SERIES_ALL: 'SERIES_ALL',
  SyncKind.SERIES_SCHEDULED: 'SERIES_SCHEDULED',
  SyncKind.SERIES_ONE: 'SERIES_ONE',
};

const _$SyncRunStateEnumMap = {
  SyncRunState.RUNNING: 'RUNNING',
  SyncRunState.DONE: 'DONE',
  SyncRunState.INTERRUPTED: 'INTERRUPTED',
};
