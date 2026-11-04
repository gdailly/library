//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/sync_item_outcome.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_run_item_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SyncRunItemResponse {
  /// Returns a new [SyncRunItemResponse] instance.
  SyncRunItemResponse({

    required  this.id,

    required  this.label,

    required  this.outcome,

     this.detail,

    required  this.childCount,

    required  this.createdAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'outcome',
    required: true,
    includeIfNull: false,
  )


  final SyncItemOutcome outcome;



  @JsonKey(
    
    name: r'detail',
    required: false,
    includeIfNull: false,
  )


  final String? detail;



  @JsonKey(
    
    name: r'childCount',
    required: true,
    includeIfNull: false,
  )


  final int childCount;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SyncRunItemResponse &&
      other.id == id &&
      other.label == label &&
      other.outcome == outcome &&
      other.detail == detail &&
      other.childCount == childCount &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        label.hashCode +
        outcome.hashCode +
        detail.hashCode +
        childCount.hashCode +
        createdAt.hashCode;

  factory SyncRunItemResponse.fromJson(Map<String, dynamic> json) => _$SyncRunItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SyncRunItemResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

