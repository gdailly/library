// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_sync_run_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseSyncRunResponseCWProxy {
  PageResponseSyncRunResponse items(List<SyncRunResponse> items);

  PageResponseSyncRunResponse page(int page);

  PageResponseSyncRunResponse size(int size);

  PageResponseSyncRunResponse totalItems(int totalItems);

  PageResponseSyncRunResponse totalPages(int totalPages);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseSyncRunResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseSyncRunResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseSyncRunResponse call({
    List<SyncRunResponse> items,
    int page,
    int size,
    int totalItems,
    int totalPages,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseSyncRunResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseSyncRunResponse.copyWith.fieldName(...)`
class _$PageResponseSyncRunResponseCWProxyImpl
    implements _$PageResponseSyncRunResponseCWProxy {
  const _$PageResponseSyncRunResponseCWProxyImpl(this._value);

  final PageResponseSyncRunResponse _value;

  @override
  PageResponseSyncRunResponse items(List<SyncRunResponse> items) =>
      this(items: items);

  @override
  PageResponseSyncRunResponse page(int page) => this(page: page);

  @override
  PageResponseSyncRunResponse size(int size) => this(size: size);

  @override
  PageResponseSyncRunResponse totalItems(int totalItems) =>
      this(totalItems: totalItems);

  @override
  PageResponseSyncRunResponse totalPages(int totalPages) =>
      this(totalPages: totalPages);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseSyncRunResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseSyncRunResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseSyncRunResponse call({
    Object? items = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalItems = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
  }) {
    return PageResponseSyncRunResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<SyncRunResponse>,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as int,
      size: size == const $CopyWithPlaceholder()
          ? _value.size
          // ignore: cast_nullable_to_non_nullable
          : size as int,
      totalItems: totalItems == const $CopyWithPlaceholder()
          ? _value.totalItems
          // ignore: cast_nullable_to_non_nullable
          : totalItems as int,
      totalPages: totalPages == const $CopyWithPlaceholder()
          ? _value.totalPages
          // ignore: cast_nullable_to_non_nullable
          : totalPages as int,
    );
  }
}

extension $PageResponseSyncRunResponseCopyWith on PageResponseSyncRunResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseSyncRunResponse.copyWith(...)` or like so:`instanceOfPageResponseSyncRunResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseSyncRunResponseCWProxy get copyWith =>
      _$PageResponseSyncRunResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseSyncRunResponse _$PageResponseSyncRunResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponseSyncRunResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'page', 'size', 'totalItems', 'totalPages'],
  );
  final val = PageResponseSyncRunResponse(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => SyncRunResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert('page', (v) => (v as num).toInt()),
    size: $checkedConvert('size', (v) => (v as num).toInt()),
    totalItems: $checkedConvert('totalItems', (v) => (v as num).toInt()),
    totalPages: $checkedConvert('totalPages', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$PageResponseSyncRunResponseToJson(
  PageResponseSyncRunResponse instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'page': instance.page,
  'size': instance.size,
  'totalItems': instance.totalItems,
  'totalPages': instance.totalPages,
};
