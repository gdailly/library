// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LibrarySummaryCWProxy {
  LibrarySummary id(int id);

  LibrarySummary name(String? name);

  LibrarySummary role(Role role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LibrarySummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LibrarySummary(...).copyWith(id: 12, name: "My name")
  /// ````
  LibrarySummary call({int id, String? name, Role role});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLibrarySummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLibrarySummary.copyWith.fieldName(...)`
class _$LibrarySummaryCWProxyImpl implements _$LibrarySummaryCWProxy {
  const _$LibrarySummaryCWProxyImpl(this._value);

  final LibrarySummary _value;

  @override
  LibrarySummary id(int id) => this(id: id);

  @override
  LibrarySummary name(String? name) => this(name: name);

  @override
  LibrarySummary role(Role role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LibrarySummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LibrarySummary(...).copyWith(id: 12, name: "My name")
  /// ````
  LibrarySummary call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return LibrarySummary(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as Role,
    );
  }
}

extension $LibrarySummaryCopyWith on LibrarySummary {
  /// Returns a callable class that can be used as follows: `instanceOfLibrarySummary.copyWith(...)` or like so:`instanceOfLibrarySummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LibrarySummaryCWProxy get copyWith => _$LibrarySummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LibrarySummary _$LibrarySummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LibrarySummary', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'role']);
      final val = LibrarySummary(
        id: $checkedConvert('id', (v) => (v as num).toInt()),
        name: $checkedConvert('name', (v) => v as String?),
        role: $checkedConvert('role', (v) => $enumDecode(_$RoleEnumMap, v)),
      );
      return val;
    });

Map<String, dynamic> _$LibrarySummaryToJson(LibrarySummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': ?instance.name,
      'role': _$RoleEnumMap[instance.role]!,
    };

const _$RoleEnumMap = {Role.OWNER: 'OWNER', Role.MEMBER: 'MEMBER'};
