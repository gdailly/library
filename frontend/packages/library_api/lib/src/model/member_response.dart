//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/role.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'member_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MemberResponse {
  /// Returns a new [MemberResponse] instance.
  MemberResponse({

    required  this.userId,

    required  this.email,

     this.name,

     this.avatarUrl,

    required  this.role,
  });

  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final int userId;



  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'avatarUrl',
    required: false,
    includeIfNull: false,
  )


  final String? avatarUrl;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final Role role;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MemberResponse &&
      other.userId == userId &&
      other.email == email &&
      other.name == name &&
      other.avatarUrl == avatarUrl &&
      other.role == role;

    @override
    int get hashCode =>
        userId.hashCode +
        email.hashCode +
        name.hashCode +
        avatarUrl.hashCode +
        role.hashCode;

  factory MemberResponse.fromJson(Map<String, dynamic> json) => _$MemberResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MemberResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

