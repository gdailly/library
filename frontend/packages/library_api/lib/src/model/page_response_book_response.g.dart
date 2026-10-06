// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_response_book_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PageResponseBookResponseCWProxy {
  PageResponseBookResponse items(List<BookResponse> items);

  PageResponseBookResponse page(int page);

  PageResponseBookResponse size(int size);

  PageResponseBookResponse totalItems(int totalItems);

  PageResponseBookResponse totalPages(int totalPages);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseBookResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseBookResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseBookResponse call({
    List<BookResponse> items,
    int page,
    int size,
    int totalItems,
    int totalPages,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPageResponseBookResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPageResponseBookResponse.copyWith.fieldName(...)`
class _$PageResponseBookResponseCWProxyImpl
    implements _$PageResponseBookResponseCWProxy {
  const _$PageResponseBookResponseCWProxyImpl(this._value);

  final PageResponseBookResponse _value;

  @override
  PageResponseBookResponse items(List<BookResponse> items) =>
      this(items: items);

  @override
  PageResponseBookResponse page(int page) => this(page: page);

  @override
  PageResponseBookResponse size(int size) => this(size: size);

  @override
  PageResponseBookResponse totalItems(int totalItems) =>
      this(totalItems: totalItems);

  @override
  PageResponseBookResponse totalPages(int totalPages) =>
      this(totalPages: totalPages);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PageResponseBookResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PageResponseBookResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  PageResponseBookResponse call({
    Object? items = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? size = const $CopyWithPlaceholder(),
    Object? totalItems = const $CopyWithPlaceholder(),
    Object? totalPages = const $CopyWithPlaceholder(),
  }) {
    return PageResponseBookResponse(
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<BookResponse>,
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

extension $PageResponseBookResponseCopyWith on PageResponseBookResponse {
  /// Returns a callable class that can be used as follows: `instanceOfPageResponseBookResponse.copyWith(...)` or like so:`instanceOfPageResponseBookResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PageResponseBookResponseCWProxy get copyWith =>
      _$PageResponseBookResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResponseBookResponse _$PageResponseBookResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PageResponseBookResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['items', 'page', 'size', 'totalItems', 'totalPages'],
  );
  final val = PageResponseBookResponse(
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map((e) => BookResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert('page', (v) => (v as num).toInt()),
    size: $checkedConvert('size', (v) => (v as num).toInt()),
    totalItems: $checkedConvert('totalItems', (v) => (v as num).toInt()),
    totalPages: $checkedConvert('totalPages', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$PageResponseBookResponseToJson(
  PageResponseBookResponse instance,
) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'page': instance.page,
  'size': instance.size,
  'totalItems': instance.totalItems,
  'totalPages': instance.totalPages,
};
