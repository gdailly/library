// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MemberRequestCWProxy {
  MemberRequest email(String email);

  MemberRequest role(Role? role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MemberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MemberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MemberRequest call({String email, Role? role});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMemberRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMemberRequest.copyWith.fieldName(...)`
class _$MemberRequestCWProxyImpl implements _$MemberRequestCWProxy {
  const _$MemberRequestCWProxyImpl(this._value);

  final MemberRequest _value;

  @override
  MemberRequest email(String email) => this(email: email);

  @override
  MemberRequest role(Role? role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MemberRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MemberRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MemberRequest call({
    Object? email = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return MemberRequest(
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as Role?,
    );
  }
}

extension $MemberRequestCopyWith on MemberRequest {
  /// Returns a callable class that can be used as follows: `instanceOfMemberRequest.copyWith(...)` or like so:`instanceOfMemberRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MemberRequestCWProxy get copyWith => _$MemberRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberRequest _$MemberRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MemberRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['email']);
      final val = MemberRequest(
        email: $checkedConvert('email', (v) => v as String),
        role: $checkedConvert(
          'role',
          (v) => $enumDecodeNullable(_$RoleEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MemberRequestToJson(MemberRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'role': ?_$RoleEnumMap[instance.role],
    };

const _$RoleEnumMap = {Role.OWNER: 'OWNER', Role.MEMBER: 'MEMBER'};
