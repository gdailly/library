//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategoryResponse {
  /// Returns a new [CategoryResponse] instance.
  CategoryResponse({

    required  this.id,

    required  this.name,

    required  this.color,

     this.bookCount,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



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



  @JsonKey(
    
    name: r'bookCount',
    required: false,
    includeIfNull: false,
  )


  final int? bookCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CategoryResponse &&
      other.id == id &&
      other.name == name &&
      other.color == color &&
      other.bookCount == bookCount;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        color.hashCode +
        bookCount.hashCode;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) => _$CategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

