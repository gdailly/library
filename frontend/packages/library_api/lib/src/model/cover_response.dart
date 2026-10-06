//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cover_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CoverResponse {
  /// Returns a new [CoverResponse] instance.
  CoverResponse({

    required  this.thumbUrl,

    required  this.mediumUrl,
  });

  @JsonKey(
    
    name: r'thumbUrl',
    required: true,
    includeIfNull: false,
  )


  final String thumbUrl;



  @JsonKey(
    
    name: r'mediumUrl',
    required: true,
    includeIfNull: false,
  )


  final String mediumUrl;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CoverResponse &&
      other.thumbUrl == thumbUrl &&
      other.mediumUrl == mediumUrl;

    @override
    int get hashCode =>
        thumbUrl.hashCode +
        mediumUrl.hashCode;

  factory CoverResponse.fromJson(Map<String, dynamic> json) => _$CoverResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CoverResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

