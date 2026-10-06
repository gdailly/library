// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MeResponseCWProxy {
  MeResponse id(int id);

  MeResponse email(String email);

  MeResponse name(String? name);

  MeResponse avatarUrl(String? avatarUrl);

  MeResponse libraries(List<LibrarySummary> libraries);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MeResponse call({
    int id,
    String email,
    String? name,
    String? avatarUrl,
    List<LibrarySummary> libraries,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMeResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMeResponse.copyWith.fieldName(...)`
class _$MeResponseCWProxyImpl implements _$MeResponseCWProxy {
  const _$MeResponseCWProxyImpl(this._value);

  final MeResponse _value;

  @override
  MeResponse id(int id) => this(id: id);

  @override
  MeResponse email(String email) => this(email: email);

  @override
  MeResponse name(String? name) => this(name: name);

  @override
  MeResponse avatarUrl(String? avatarUrl) => this(avatarUrl: avatarUrl);

  @override
  MeResponse libraries(List<LibrarySummary> libraries) =>
      this(libraries: libraries);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MeResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MeResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MeResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? avatarUrl = const $CopyWithPlaceholder(),
    Object? libraries = const $CopyWithPlaceholder(),
  }) {
    return MeResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      avatarUrl: avatarUrl == const $CopyWithPlaceholder()
          ? _value.avatarUrl
          // ignore: cast_nullable_to_non_nullable
          : avatarUrl as String?,
      libraries: libraries == const $CopyWithPlaceholder()
          ? _value.libraries
          // ignore: cast_nullable_to_non_nullable
          : libraries as List<LibrarySummary>,
    );
  }
}

extension $MeResponseCopyWith on MeResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMeResponse.copyWith(...)` or like so:`instanceOfMeResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MeResponseCWProxy get copyWith => _$MeResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeResponse _$MeResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'email', 'libraries']);
      final val = MeResponse(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        email: $checkedConvert('email', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String?),
        avatarUrl: $checkedConvert('avatarUrl', (v) => v as String?),
        libraries: $checkedConvert(
          'libraries',
          (v) => (v as List<dynamic>)
              .map((e) => LibrarySummary.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeResponseToJson(MeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': ?instance.name,
      'avatarUrl': ?instance.avatarUrl,
      'libraries': instance.libraries.map((e) => e.toJson()).toList(),
    };
