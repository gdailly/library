//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/role.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'member_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MemberRequest {
  /// Returns a new [MemberRequest] instance.
  MemberRequest({

    required  this.email,

     this.role,
  });

  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'role',
    required: false,
    includeIfNull: false,
  )


  final Role? role;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MemberRequest &&
      other.email == email &&
      other.role == role;

    @override
    int get hashCode =>
        email.hashCode +
        role.hashCode;

  factory MemberRequest.fromJson(Map<String, dynamic> json) => _$MemberRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MemberRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

