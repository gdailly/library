//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/sync_run_state.dart';
import 'package:library_api/src/model/sync_kind.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_run_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SyncRunResponse {
  /// Returns a new [SyncRunResponse] instance.
  SyncRunResponse({

    required  this.id,

    required  this.kind,

     this.startedBy,

    required  this.state,

    required  this.total,

    required  this.processed,

    required  this.succeeded,

    required  this.unchanged,

    required  this.notFound,

    required  this.failed,

    required  this.startedAt,

     this.finishedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final SyncKind kind;



  @JsonKey(
    
    name: r'startedBy',
    required: false,
    includeIfNull: false,
  )


  final String? startedBy;



  @JsonKey(
    
    name: r'state',
    required: true,
    includeIfNull: false,
  )


  final SyncRunState state;



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
    
    name: r'succeeded',
    required: true,
    includeIfNull: false,
  )


  final int succeeded;



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
    required: true,
    includeIfNull: false,
  )


  final DateTime startedAt;



  @JsonKey(
    
    name: r'finishedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? finishedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SyncRunResponse &&
      other.id == id &&
      other.kind == kind &&
      other.startedBy == startedBy &&
      other.state == state &&
      other.total == total &&
      other.processed == processed &&
      other.succeeded == succeeded &&
      other.unchanged == unchanged &&
      other.notFound == notFound &&
      other.failed == failed &&
      other.startedAt == startedAt &&
      other.finishedAt == finishedAt;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        startedBy.hashCode +
        state.hashCode +
        total.hashCode +
        processed.hashCode +
        succeeded.hashCode +
        unchanged.hashCode +
        notFound.hashCode +
        failed.hashCode +
        startedAt.hashCode +
        finishedAt.hashCode;

  factory SyncRunResponse.fromJson(Map<String, dynamic> json) => _$SyncRunResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SyncRunResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

