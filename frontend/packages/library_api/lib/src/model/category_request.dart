//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategoryRequest {
  /// Returns a new [CategoryRequest] instance.
  CategoryRequest({

    required  this.name,

    required  this.color,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'color',
    required: true,
    includeIfNull: false,
  )


  final String color;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CategoryRequest &&
      other.name == name &&
      other.color == color;

    @override
    int get hashCode =>
        name.hashCode +
        color.hashCode;

  factory CategoryRequest.fromJson(Map<String, dynamic> json) => _$CategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

