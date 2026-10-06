//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/library_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'me_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeResponse {
  /// Returns a new [MeResponse] instance.
  MeResponse({

    required  this.id,

    required  this.email,

     this.name,

     this.avatarUrl,

    required  this.libraries,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



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
    
    name: r'libraries',
    required: true,
    includeIfNull: false,
  )


  final List<LibrarySummary> libraries;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MeResponse &&
      other.id == id &&
      other.email == email &&
      other.name == name &&
      other.avatarUrl == avatarUrl &&
      other.libraries == libraries;

    @override
    int get hashCode =>
        id.hashCode +
        email.hashCode +
        name.hashCode +
        avatarUrl.hashCode +
        libraries.hashCode;

  factory MeResponse.fromJson(Map<String, dynamic> json) => _$MeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

