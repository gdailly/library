//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/sync_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'metadata_sync_job_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MetadataSyncJobResponse {
  /// Returns a new [MetadataSyncJobResponse] instance.
  MetadataSyncJobResponse({

    required  this.state,

    required  this.total,

    required  this.processed,

    required  this.updated,

    required  this.unchanged,

    required  this.notFound,

    required  this.failed,

     this.startedAt,

     this.finishedAt,
  });

  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final SyncState state;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final int total;



  @JsonKey(
    
    name: r'processed',
    required: true,
    includeIfNull: false,
  )


  final int processed;



  @JsonKey(
    
    name: r'updated',
    required: true,
    includeIfNull: false,
  )


  final int updated;



  @JsonKey(
    
    name: r'unchanged',
    required: true,
    includeIfNull: false,
  )


  final int unchanged;



  @JsonKey(
    
    name: r'notFound',
    required: true,
    includeIfNull: false,
  )


  final int notFound;



  @JsonKey(
    
    name: r'failed',
    required: true,
    includeIfNull: false,
  )


  final int failed;



  @JsonKey(
    
    name: r'startedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? startedAt;



  @JsonKey(
    
    name: r'finishedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? finishedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MetadataSyncJobResponse &&
      other.state == state &&
      other.total == total &&
      other.processed == processed &&
      other.updated == updated &&
      other.unchanged == unchanged &&
      other.notFound == notFound &&
      other.failed == failed &&
      other.startedAt == startedAt &&
      other.finishedAt == finishedAt;

    @override
    int get hashCode =>
        state.hashCode +
        total.hashCode +
        processed.hashCode +
        updated.hashCode +
        unchanged.hashCode +
        notFound.hashCode +
        failed.hashCode +
        startedAt.hashCode +
        finishedAt.hashCode;

  factory MetadataSyncJobResponse.fromJson(Map<String, dynamic> json) => _$MetadataSyncJobResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataSyncJobResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

