// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CategoryResponseCWProxy {
  CategoryResponse id(int id);

  CategoryResponse name(String name);

  CategoryResponse color(String color);

  CategoryResponse bookCount(int? bookCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CategoryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CategoryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CategoryResponse call({int id, String name, String color, int? bookCount});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCategoryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCategoryResponse.copyWith.fieldName(...)`
class _$CategoryResponseCWProxyImpl implements _$CategoryResponseCWProxy {
  const _$CategoryResponseCWProxyImpl(this._value);

  final CategoryResponse _value;

  @override
  CategoryResponse id(int id) => this(id: id);

  @override
  CategoryResponse name(String name) => this(name: name);

  @override
  CategoryResponse color(String color) => this(color: color);

  @override
  CategoryResponse bookCount(int? bookCount) => this(bookCount: bookCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CategoryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CategoryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  CategoryResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? bookCount = const $CopyWithPlaceholder(),
  }) {
    return CategoryResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as String,
      bookCount: bookCount == const $CopyWithPlaceholder()
          ? _value.bookCount
          // ignore: cast_nullable_to_non_nullable
          : bookCount as int?,
    );
  }
}

extension $CategoryResponseCopyWith on CategoryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfCategoryResponse.copyWith(...)` or like so:`instanceOfCategoryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CategoryResponseCWProxy get copyWith => _$CategoryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryResponse _$CategoryResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CategoryResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name', 'color']);
      final val = CategoryResponse(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String),
        color: $checkedConvert('color', (v) => v as String),
        bookCount: $checkedConvert('bookCount', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$CategoryResponseToJson(CategoryResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color': instance.color,
      'bookCount': ?instance.bookCount,
    };
