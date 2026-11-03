// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'series_detail_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SeriesDetailResponseCWProxy {
  SeriesDetailResponse name(String name);

  SeriesDetailResponse volumes(List<SeriesVolumeResponse> volumes);

  SeriesDetailResponse unnumbered(List<BookResponse> unnumbered);

  SeriesDetailResponse catalogFetchedAt(DateTime? catalogFetchedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeriesDetailResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeriesDetailResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeriesDetailResponse call({
    String name,
    List<SeriesVolumeResponse> volumes,
    List<BookResponse> unnumbered,
    DateTime? catalogFetchedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSeriesDetailResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSeriesDetailResponse.copyWith.fieldName(...)`
class _$SeriesDetailResponseCWProxyImpl
    implements _$SeriesDetailResponseCWProxy {
  const _$SeriesDetailResponseCWProxyImpl(this._value);

  final SeriesDetailResponse _value;

  @override
  SeriesDetailResponse name(String name) => this(name: name);

  @override
  SeriesDetailResponse volumes(List<SeriesVolumeResponse> volumes) =>
      this(volumes: volumes);

  @override
  SeriesDetailResponse unnumbered(List<BookResponse> unnumbered) =>
      this(unnumbered: unnumbered);

  @override
  SeriesDetailResponse catalogFetchedAt(DateTime? catalogFetchedAt) =>
      this(catalogFetchedAt: catalogFetchedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SeriesDetailResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SeriesDetailResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SeriesDetailResponse call({
    Object? name = const $CopyWithPlaceholder(),
    Object? volumes = const $CopyWithPlaceholder(),
    Object? unnumbered = const $CopyWithPlaceholder(),
    Object? catalogFetchedAt = const $CopyWithPlaceholder(),
  }) {
    return SeriesDetailResponse(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      volumes: volumes == const $CopyWithPlaceholder()
          ? _value.volumes
          // ignore: cast_nullable_to_non_nullable
          : volumes as List<SeriesVolumeResponse>,
      unnumbered: unnumbered == const $CopyWithPlaceholder()
          ? _value.unnumbered
          // ignore: cast_nullable_to_non_nullable
          : unnumbered as List<BookResponse>,
      catalogFetchedAt: catalogFetchedAt == const $CopyWithPlaceholder()
          ? _value.catalogFetchedAt
          // ignore: cast_nullable_to_non_nullable
          : catalogFetchedAt as DateTime?,
    );
  }
}

extension $SeriesDetailResponseCopyWith on SeriesDetailResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSeriesDetailResponse.copyWith(...)` or like so:`instanceOfSeriesDetailResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SeriesDetailResponseCWProxy get copyWith =>
      _$SeriesDetailResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SeriesDetailResponse _$SeriesDetailResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SeriesDetailResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['name', 'volumes', 'unnumbered']);
  final val = SeriesDetailResponse(
    name: $checkedConvert('name', (v) => v as String),
    volumes: $checkedConvert(
      'volumes',
      (v) => (v as List<dynamic>)
          .map((e) => SeriesVolumeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    unnumbered: $checkedConvert(
      'unnumbered',
      (v) => (v as List<dynamic>)
          .map((e) => BookResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    catalogFetchedAt: $checkedConvert(
      'catalogFetchedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$SeriesDetailResponseToJson(
  SeriesDetailResponse instance,
) => <String, dynamic>{
  'name': instance.name,
  'volumes': instance.volumes.map((e) => e.toJson()).toList(),
  'unnumbered': instance.unnumbered.map((e) => e.toJson()).toList(),
  'catalogFetchedAt': ?instance.catalogFetchedAt?.toIso8601String(),
};
