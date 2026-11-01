//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/source_metadata_response.dart';
import 'package:library_api/src/model/book_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_metadata_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BookMetadataResponse {
  /// Returns a new [BookMetadataResponse] instance.
  BookMetadataResponse({

    required  this.book,

     this.fetchedAt,

    required  this.notFound,

    required  this.sources,

     this.merged,

    required  this.differences,
  });

  @JsonKey(
    
    name: r'book',
    required: true,
    includeIfNull: false,
  )


  final BookResponse book;



  @JsonKey(
    
    name: r'fetchedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? fetchedAt;



  @JsonKey(
    
    name: r'notFound',
    required: true,
    includeIfNull: false,
  )


  final bool notFound;



  @JsonKey(
    
    name: r'sources',
    required: true,
    includeIfNull: false,
  )


  final List<SourceMetadataResponse> sources;



  @JsonKey(
    
    name: r'merged',
    required: false,
    includeIfNull: false,
  )


  final SourceMetadataResponse? merged;



  @JsonKey(
    
    name: r'differences',
    required: true,
    includeIfNull: false,
  )


  final List<String> differences;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BookMetadataResponse &&
      other.book == book &&
      other.fetchedAt == fetchedAt &&
      other.notFound == notFound &&
      other.sources == sources &&
      other.merged == merged &&
      other.differences == differences;

    @override
    int get hashCode =>
        book.hashCode +
        fetchedAt.hashCode +
        notFound.hashCode +
        sources.hashCode +
        merged.hashCode +
        differences.hashCode;

  factory BookMetadataResponse.fromJson(Map<String, dynamic> json) => _$BookMetadataResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BookMetadataResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

