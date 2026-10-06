//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/reading_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'other_reading_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OtherReadingResponse {
  /// Returns a new [OtherReadingResponse] instance.
  OtherReadingResponse({

    required  this.userId,

    required  this.name,

    required  this.status,

     this.rating,

     this.review,
  });

  @JsonKey(
    
    name: r'userId',
    required: true,
    includeIfNull: false,
  )


  final int userId;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ReadingStatus status;



  @JsonKey(
    
    name: r'rating',
    required: false,
    includeIfNull: false,
  )


  final int? rating;



  @JsonKey(
    
    name: r'review',
    required: false,
    includeIfNull: false,
  )


  final String? review;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OtherReadingResponse &&
      other.userId == userId &&
      other.name == name &&
      other.status == status &&
      other.rating == rating &&
      other.review == review;

    @override
    int get hashCode =>
        userId.hashCode +
        name.hashCode +
        status.hashCode +
        rating.hashCode +
        review.hashCode;

  factory OtherReadingResponse.fromJson(Map<String, dynamic> json) => _$OtherReadingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OtherReadingResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

