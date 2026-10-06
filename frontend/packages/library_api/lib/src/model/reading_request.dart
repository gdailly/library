//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/reading_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reading_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReadingRequest {
  /// Returns a new [ReadingRequest] instance.
  ReadingRequest({

    required  this.status,

     this.rating,

     this.review,

     this.startedOn,

     this.finishedOn,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ReadingStatus status;



          // minimum: 1
          // maximum: 5
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



  @JsonKey(
    
    name: r'startedOn',
    required: false,
    includeIfNull: false,
  )


  final DateTime? startedOn;



  @JsonKey(
    
    name: r'finishedOn',
    required: false,
    includeIfNull: false,
  )


  final DateTime? finishedOn;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReadingRequest &&
      other.status == status &&
      other.rating == rating &&
      other.review == review &&
      other.startedOn == startedOn &&
      other.finishedOn == finishedOn;

    @override
    int get hashCode =>
        status.hashCode +
        rating.hashCode +
        review.hashCode +
        startedOn.hashCode +
        finishedOn.hashCode;

  factory ReadingRequest.fromJson(Map<String, dynamic> json) => _$ReadingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

