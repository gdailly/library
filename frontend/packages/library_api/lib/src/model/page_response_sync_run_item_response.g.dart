// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_sync_run_item_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseSyncRunItemResponseCWProxy {
  PageResponseSyncRunItemResponse items(List<SyncRunItemResponse> items);

  PageResponseSyncRunItemResponse page(int page);

  PageResponseSyncRunItemResponse size(int size);

  PageResponseSyncRunItemResponse totalItems(int totalItems);

  PageResponseSyncRunItemResponse totalPages(int totalPages);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseSyncRunItemResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseSyncRunItemResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseSyncRunItemResponse call({
    List<SyncRunItemResponse> items,
    int page,
    int size,
    int totalItems,
    int totalPages,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseSyncRunItemResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseSyncRunItemResponse.copyWith.fieldName(...)`
class _$PageResponseSyncRunItemResponseCWProxyImpl
    implements _$PageResponseSyncRunItemResponseCWProxy {
  const _$PageResponseSyncRunItemResponseCWProxyImpl(this._value);

  final PageResponseSyncRunItemResponse _value;

  @override
  PageResponseSyncRunItemResponse items(List<SyncRunItemResponse> items) =>
      this(items: items);

  @override
  PageResponseSyncRunItemResponse page(int page) => this(page: page);

  @override
  PageResponseSyncRunItemResponse size(int size) => this(size: size);

  @override
  PageResponseSyncRunItemResponse totalItems(int totalItems) =>
      this(totalItems: totalItems);

  @override
  PageResponseSyncRunItemResponse totalPages(int totalPages) =>
      this(totalPages: totalPages);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseSyncRunItemResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseSyncRunItemResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseSyncRunItemResponse call({
    Object? items = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalItems = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
  }) {
    return PageResponseSyncRunItemResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<SyncRunItemResponse>,
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

extension $PageResponseSyncRunItemResponseCopyWith
    on PageResponseSyncRunItemResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseSyncRunItemResponse.copyWith(...)` or like so:`instanceOfPageResponseSyncRunItemResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseSyncRunItemResponseCWProxy get copyWith =>
      _$PageResponseSyncRunItemResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseSyncRunItemResponse _$PageResponseSyncRunItemResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponseSyncRunItemResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'page', 'size', 'totalItems', 'totalPages'],
  );
  final val = PageResponseSyncRunItemResponse(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => SyncRunItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert('page', (v) => (v as num).toInt()),
    size: $checkedConvert('size', (v) => (v as num).toInt()),
    totalItems: $checkedConvert('totalItems', (v) => (v as num).toInt()),
    totalPages: $checkedConvert('totalPages', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$PageResponseSyncRunItemResponseToJson(
  PageResponseSyncRunItemResponse instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'page': instance.page,
  'size': instance.size,
  'totalItems': instance.totalItems,
  'totalPages': instance.totalPages,
};
