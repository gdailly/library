// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CategoryRequestCWProxy {
  CategoryRequest name(String name);

  CategoryRequest color(String color);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CategoryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CategoryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CategoryRequest call({String name, String color});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCategoryRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCategoryRequest.copyWith.fieldName(...)`
class _$CategoryRequestCWProxyImpl implements _$CategoryRequestCWProxy {
  const _$CategoryRequestCWProxyImpl(this._value);

  final CategoryRequest _value;

  @override
  CategoryRequest name(String name) => this(name: name);

  @override
  CategoryRequest color(String color) => this(color: color);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CategoryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CategoryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CategoryRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
  }) {
    return CategoryRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as String,
    );
  }
}

extension $CategoryRequestCopyWith on CategoryRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCategoryRequest.copyWith(...)` or like so:`instanceOfCategoryRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CategoryRequestCWProxy get copyWith => _$CategoryRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryRequest _$CategoryRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CategoryRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'color']);
      final val = CategoryRequest(
        name: $checkedConvert('name', (v) => v as String),
        color: $checkedConvert('color', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CategoryRequestToJson(CategoryRequest instance) =>
    <String, dynamic>{'name': instance.name, 'color': instance.color};
