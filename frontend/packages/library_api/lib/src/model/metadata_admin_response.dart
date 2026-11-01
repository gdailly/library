//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/metadata_sync_job_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'metadata_admin_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MetadataAdminResponse {
  /// Returns a new [MetadataAdminResponse] instance.
  MetadataAdminResponse({

    required  this.books,

    required  this.booksWithIsbn,

    required  this.cachedIsbns,

    required  this.cachedNotFound,

    required  this.job,
  });

  @JsonKey(
    
    name: r'books',
    required: true,
    includeIfNull: false,
  )


  final int books;



  @JsonKey(
    
    name: r'booksWithIsbn',
    required: true,
    includeIfNull: false,
  )


  final int booksWithIsbn;



  @JsonKey(
    
    name: r'cachedIsbns',
    required: true,
    includeIfNull: false,
  )


  final int cachedIsbns;



  @JsonKey(
    
    name: r'cachedNotFound',
    required: true,
    includeIfNull: false,
  )


  final int cachedNotFound;



  @JsonKey(
    
    name: r'job',
    required: true,
    includeIfNull: false,
  )


  final MetadataSyncJobResponse job;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MetadataAdminResponse &&
      other.books == books &&
      other.booksWithIsbn == booksWithIsbn &&
      other.cachedIsbns == cachedIsbns &&
      other.cachedNotFound == cachedNotFound &&
      other.job == job;

    @override
    int get hashCode =>
        books.hashCode +
        booksWithIsbn.hashCode +
        cachedIsbns.hashCode +
        cachedNotFound.hashCode +
        job.hashCode;

  factory MetadataAdminResponse.fromJson(Map<String, dynamic> json) => _$MetadataAdminResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MetadataAdminResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

