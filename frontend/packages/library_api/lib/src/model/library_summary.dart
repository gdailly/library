//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/role.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'library_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LibrarySummary {
  /// Returns a new [LibrarySummary] instance.
  LibrarySummary({

    required  this.id,

     this.name,

    required  this.role,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'role',
    required: true,
    includeIfNull: false,
  )


  final Role role;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LibrarySummary &&
      other.id == id &&
      other.name == name &&
      other.role == role;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        role.hashCode;

  factory LibrarySummary.fromJson(Map<String, dynamic> json) => _$LibrarySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$LibrarySummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

