// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MemberResponseCWProxy {
  MemberResponse userId(int userId);

  MemberResponse email(String email);

  MemberResponse name(String? name);

  MemberResponse avatarUrl(String? avatarUrl);

  MemberResponse role(Role role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MemberResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MemberResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MemberResponse call({
    int userId,
    String email,
    String? name,
    String? avatarUrl,
    Role role,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMemberResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMemberResponse.copyWith.fieldName(...)`
class _$MemberResponseCWProxyImpl implements _$MemberResponseCWProxy {
  const _$MemberResponseCWProxyImpl(this._value);

  final MemberResponse _value;

  @override
  MemberResponse userId(int userId) => this(userId: userId);

  @override
  MemberResponse email(String email) => this(email: email);

  @override
  MemberResponse name(String? name) => this(name: name);

  @override
  MemberResponse avatarUrl(String? avatarUrl) => this(avatarUrl: avatarUrl);

  @override
  MemberResponse role(Role role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MemberResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MemberResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MemberResponse call({
    Object? userId = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? avatarUrl = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return MemberResponse(
      userId: userId == const $CopyWithPlaceholder()
          ? _value.userId
          // ignore: cast_nullable_to_non_nullable
          : userId as int,
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
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as Role,
    );
  }
}

extension $MemberResponseCopyWith on MemberResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMemberResponse.copyWith(...)` or like so:`instanceOfMemberResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MemberResponseCWProxy get copyWith => _$MemberResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberResponse _$MemberResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MemberResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['userId', 'email', 'role']);
      final val = MemberResponse(
        userId: $checkedConvert('userId', (v) => (v as num).toInt()),
        email: $checkedConvert('email', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String?),
        avatarUrl: $checkedConvert('avatarUrl', (v) => v as String?),
        role: $checkedConvert('role', (v) => $enumDecode(_$RoleEnumMap, v)),
      );
      return val;
    });

Map<String, dynamic> _$MemberResponseToJson(MemberResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'name': ?instance.name,
      'avatarUrl': ?instance.avatarUrl,
      'role': _$RoleEnumMap[instance.role]!,
    };

const _$RoleEnumMap = {Role.OWNER: 'OWNER', Role.MEMBER: 'MEMBER'};
