//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/sync_state.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'series_sync_job_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SeriesSyncJobResponse {
  /// Returns a new [SeriesSyncJobResponse] instance.
  SeriesSyncJobResponse({

    required  this.state,

    required  this.total,

    required  this.processed,

    required  this.found,

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
    
    name: r'found',
    required: true,
    includeIfNull: false,
  )


  final int found;



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
    bool operator ==(Object other) => identical(this, other) || other is SeriesSyncJobResponse &&
      other.state == state &&
      other.total == total &&
      other.processed == processed &&
      other.found == found &&
      other.notFound == notFound &&
      other.failed == failed &&
      other.startedAt == startedAt &&
      other.finishedAt == finishedAt;

    @override
    int get hashCode =>
        state.hashCode +
        total.hashCode +
        processed.hashCode +
        found.hashCode +
        notFound.hashCode +
        failed.hashCode +
        startedAt.hashCode +
        finishedAt.hashCode;

  factory SeriesSyncJobResponse.fromJson(Map<String, dynamic> json) => _$SeriesSyncJobResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesSyncJobResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

