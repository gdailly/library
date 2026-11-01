// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_book_metadata_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseBookMetadataSummaryCWProxy {
  PageResponseBookMetadataSummary items(List<BookMetadataSummary> items);

  PageResponseBookMetadataSummary page(int page);

  PageResponseBookMetadataSummary size(int size);

  PageResponseBookMetadataSummary totalItems(int totalItems);

  PageResponseBookMetadataSummary totalPages(int totalPages);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseBookMetadataSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseBookMetadataSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseBookMetadataSummary call({
    List<BookMetadataSummary> items,
    int page,
    int size,
    int totalItems,
    int totalPages,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseBookMetadataSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseBookMetadataSummary.copyWith.fieldName(...)`
class _$PageResponseBookMetadataSummaryCWProxyImpl
    implements _$PageResponseBookMetadataSummaryCWProxy {
  const _$PageResponseBookMetadataSummaryCWProxyImpl(this._value);

  final PageResponseBookMetadataSummary _value;

  @override
  PageResponseBookMetadataSummary items(List<BookMetadataSummary> items) =>
      this(items: items);

  @override
  PageResponseBookMetadataSummary page(int page) => this(page: page);

  @override
  PageResponseBookMetadataSummary size(int size) => this(size: size);

  @override
  PageResponseBookMetadataSummary totalItems(int totalItems) =>
      this(totalItems: totalItems);

  @override
  PageResponseBookMetadataSummary totalPages(int totalPages) =>
      this(totalPages: totalPages);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseBookMetadataSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseBookMetadataSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseBookMetadataSummary call({
    Object? items = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalItems = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
  }) {
    return PageResponseBookMetadataSummary(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<BookMetadataSummary>,
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

extension $PageResponseBookMetadataSummaryCopyWith
    on PageResponseBookMetadataSummary {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseBookMetadataSummary.copyWith(...)` or like so:`instanceOfPageResponseBookMetadataSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseBookMetadataSummaryCWProxy get copyWith =>
      _$PageResponseBookMetadataSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseBookMetadataSummary _$PageResponseBookMetadataSummaryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponseBookMetadataSummary', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'page', 'size', 'totalItems', 'totalPages'],
  );
  final val = PageResponseBookMetadataSummary(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => BookMetadataSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert('page', (v) => (v as num).toInt()),
    size: $checkedConvert('size', (v) => (v as num).toInt()),
    totalItems: $checkedConvert('totalItems', (v) => (v as num).toInt()),
    totalPages: $checkedConvert('totalPages', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$PageResponseBookMetadataSummaryToJson(
  PageResponseBookMetadataSummary instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'page': instance.page,
  'size': instance.size,
  'totalItems': instance.totalItems,
  'totalPages': instance.totalPages,
};
