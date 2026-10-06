//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/metadata_source.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'isbn_lookup_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IsbnLookupResponse {
  /// Returns a new [IsbnLookupResponse] instance.
  IsbnLookupResponse({

    required  this.isbn13,

    required  this.source_,

     this.existingBookId,

    required  this.title,

     this.subtitle,

     this.authors,

     this.publisher,

     this.year,

     this.pages,

     this.language,

     this.summary,

     this.coverUrl,
  });

  @JsonKey(
    
    name: r'isbn13',
    required: true,
    includeIfNull: false,
  )


  final String isbn13;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final MetadataSource source_;



  @JsonKey(
    
    name: r'existingBookId',
    required: false,
    includeIfNull: false,
  )


  final int? existingBookId;



  @JsonKey(
    
    name: r'title',
    required: true,
    includeIfNull: false,
  )


  final String title;



  @JsonKey(
    
    name: r'subtitle',
    required: false,
    includeIfNull: false,
  )


  final String? subtitle;



  @JsonKey(
    
    name: r'authors',
    required: false,
    includeIfNull: false,
  )


  final String? authors;



  @JsonKey(
    
    name: r'publisher',
    required: false,
    includeIfNull: false,
  )


  final String? publisher;



  @JsonKey(
    
    name: r'year',
    required: false,
    includeIfNull: false,
  )


  final int? year;



  @JsonKey(
    
    name: r'pages',
    required: false,
    includeIfNull: false,
  )


  final int? pages;



  @JsonKey(
    
    name: r'language',
    required: false,
    includeIfNull: false,
  )


  final String? language;



  @JsonKey(
    
    name: r'summary',
    required: false,
    includeIfNull: false,
  )


  final String? summary;



  @JsonKey(
    
    name: r'coverUrl',
    required: false,
    includeIfNull: false,
  )


  final String? coverUrl;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IsbnLookupResponse &&
      other.isbn13 == isbn13 &&
      other.source_ == source_ &&
      other.existingBookId == existingBookId &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.authors == authors &&
      other.publisher == publisher &&
      other.year == year &&
      other.pages == pages &&
      other.language == language &&
      other.summary == summary &&
      other.coverUrl == coverUrl;

    @override
    int get hashCode =>
        isbn13.hashCode +
        source_.hashCode +
        existingBookId.hashCode +
        title.hashCode +
        subtitle.hashCode +
        authors.hashCode +
        publisher.hashCode +
        year.hashCode +
        pages.hashCode +
        language.hashCode +
        summary.hashCode +
        coverUrl.hashCode;

  factory IsbnLookupResponse.fromJson(Map<String, dynamic> json) => _$IsbnLookupResponseFromJson(json);

  Map<String, dynamic> toJson() => _$IsbnLookupResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

