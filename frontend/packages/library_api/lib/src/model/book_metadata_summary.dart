//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/metadata_source.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_metadata_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BookMetadataSummary {
  /// Returns a new [BookMetadataSummary] instance.
  BookMetadataSummary({

    required  this.id,

    required  this.title,

     this.authors,

    required  this.isbn13,

    required  this.hasCover,

    required  this.sources,

     this.fetchedAt,

    required  this.notFound,

    required  this.differences,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'authors',
    required: false,
    includeIfNull: false,
  )


  final String? authors;



  @JsonKey(
    
    name: r'isbn13',
    required: true,
    includeIfNull: false,
  )


  final String isbn13;



  @JsonKey(
    
    name: r'hasCover',
    required: true,
    includeIfNull: false,
  )


  final bool hasCover;



  @JsonKey(
    
    name: r'sources',
    required: true,
    includeIfNull: false,
  )


  final List<MetadataSource> sources;



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
    
    name: r'differences',
    required: true,
    includeIfNull: false,
  )


  final List<String> differences;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BookMetadataSummary &&
      other.id == id &&
      other.title == title &&
      other.authors == authors &&
      other.isbn13 == isbn13 &&
      other.hasCover == hasCover &&
      other.sources == sources &&
      other.fetchedAt == fetchedAt &&
      other.notFound == notFound &&
      other.differences == differences;

    @override
    int get hashCode =>
        id.hashCode +
        title.hashCode +
        authors.hashCode +
        isbn13.hashCode +
        hasCover.hashCode +
        sources.hashCode +
        fetchedAt.hashCode +
        notFound.hashCode +
        differences.hashCode;

  factory BookMetadataSummary.fromJson(Map<String, dynamic> json) => _$BookMetadataSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$BookMetadataSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

