//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/metadata_source.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'apply_metadata_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApplyMetadataRequest {
  /// Returns a new [ApplyMetadataRequest] instance.
  ApplyMetadataRequest({

    required  this.source_,

    required  this.fields,
  });

  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final MetadataSource source_;



  @JsonKey(
    
    name: r'fields',
    required: true,
    includeIfNull: false,
  )


  final List<String> fields;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ApplyMetadataRequest &&
      other.source_ == source_ &&
      other.fields == fields;

    @override
    int get hashCode =>
        source_.hashCode +
        fields.hashCode;

  factory ApplyMetadataRequest.fromJson(Map<String, dynamic> json) => _$ApplyMetadataRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ApplyMetadataRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

