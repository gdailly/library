//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_request.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BookRequest {
  /// Returns a new [BookRequest] instance.
  BookRequest({

     this.isbn,

    required  this.title,

     this.subtitle,

     this.authors,

     this.publisher,

     this.year,

     this.pages,

     this.language,

     this.summary,

     this.owned,

     this.categoryIds,
  });

  @JsonKey(
    
    name: r'isbn',
    required: false,
    includeIfNull: false,
  )


  final String? isbn;



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



          // minimum: 0
          // maximum: 9999
  @JsonKey(
    
    name: r'year',
    required: false,
    includeIfNull: false,
  )


  final int? year;



          // minimum: 1
          // maximum: 100000
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
    
    name: r'owned',
    required: false,
    includeIfNull: false,
  )


  final bool? owned;



  @JsonKey(
    
    name: r'categoryIds',
    required: false,
    includeIfNull: false,
  )


  final List<int>? categoryIds;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BookRequest &&
      other.isbn == isbn &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.authors == authors &&
      other.publisher == publisher &&
      other.year == year &&
      other.pages == pages &&
      other.language == language &&
      other.summary == summary &&
      other.owned == owned &&
      other.categoryIds == categoryIds;

    @override
    int get hashCode =>
        isbn.hashCode +
        title.hashCode +
        subtitle.hashCode +
        authors.hashCode +
        publisher.hashCode +
        year.hashCode +
        pages.hashCode +
        language.hashCode +
        summary.hashCode +
        owned.hashCode +
        categoryIds.hashCode;

  factory BookRequest.fromJson(Map<String, dynamic> json) => _$BookRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BookRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

