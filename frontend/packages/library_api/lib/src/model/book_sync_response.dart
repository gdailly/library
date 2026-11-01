//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/sync_outcome.dart';
import 'package:library_api/src/model/book_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_sync_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BookSyncResponse {
  /// Returns a new [BookSyncResponse] instance.
  BookSyncResponse({

    required  this.outcome,

    required  this.changedFields,

    required  this.book,
  });

  @JsonKey(
    
    name: r'outcome',
    required: true,
    includeIfNull: false,
  )


  final SyncOutcome outcome;



  @JsonKey(
    
    name: r'changedFields',
    required: true,
    includeIfNull: false,
  )


  final List<String> changedFields;



  @JsonKey(
    
    name: r'book',
    required: true,
    includeIfNull: false,
  )


  final BookResponse book;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BookSyncResponse &&
      other.outcome == outcome &&
      other.changedFields == changedFields &&
      other.book == book;

    @override
    int get hashCode =>
        outcome.hashCode +
        changedFields.hashCode +
        book.hashCode;

  factory BookSyncResponse.fromJson(Map<String, dynamic> json) => _$BookSyncResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BookSyncResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

