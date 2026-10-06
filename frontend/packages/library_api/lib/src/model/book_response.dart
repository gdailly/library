//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/category_response.dart';
import 'package:library_api/src/model/cover_response.dart';
import 'package:library_api/src/model/reading_response.dart';
import 'package:library_api/src/model/other_reading_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BookResponse {
  /// Returns a new [BookResponse] instance.
  BookResponse({

    required  this.id,

     this.isbn13,

    required  this.title,

     this.subtitle,

     this.authors,

     this.publisher,

     this.year,

     this.pages,

     this.language,

     this.summary,

    required  this.owned,

     this.addedBy,

     this.addedByName,

    required  this.createdAt,

    required  this.categories,

     this.myReading,

     this.cover,

    required  this.otherReadings,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final int id;



  @JsonKey(
    
    name: r'isbn13',
    required: false,
    includeIfNull: false,
  )


  final String? isbn13;



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
    
    name: r'owned',
    required: true,
    includeIfNull: false,
  )


  final bool owned;



  @JsonKey(
    
    name: r'addedBy',
    required: false,
    includeIfNull: false,
  )


  final int? addedBy;



  @JsonKey(
    
    name: r'addedByName',
    required: false,
    includeIfNull: false,
  )


  final String? addedByName;



  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'categories',
    required: true,
    includeIfNull: false,
  )


  final List<CategoryResponse> categories;



  @JsonKey(
    
    name: r'myReading',
    required: false,
    includeIfNull: false,
  )


  final ReadingResponse? myReading;



  @JsonKey(
    
    name: r'cover',
    required: false,
    includeIfNull: false,
  )


  final CoverResponse? cover;



  @JsonKey(
    
    name: r'otherReadings',
    required: true,
    includeIfNull: false,
  )


  final List<OtherReadingResponse> otherReadings;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BookResponse &&
      other.id == id &&
      other.isbn13 == isbn13 &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.authors == authors &&
      other.publisher == publisher &&
      other.year == year &&
      other.pages == pages &&
      other.language == language &&
      other.summary == summary &&
      other.owned == owned &&
      other.addedBy == addedBy &&
      other.addedByName == addedByName &&
      other.createdAt == createdAt &&
      other.categories == categories &&
      other.myReading == myReading &&
      other.cover == cover &&
      other.otherReadings == otherReadings;

    @override
    int get hashCode =>
        id.hashCode +
        isbn13.hashCode +
        title.hashCode +
        subtitle.hashCode +
        authors.hashCode +
        publisher.hashCode +
        year.hashCode +
        pages.hashCode +
        language.hashCode +
        summary.hashCode +
        owned.hashCode +
        addedBy.hashCode +
        addedByName.hashCode +
        createdAt.hashCode +
        categories.hashCode +
        myReading.hashCode +
        cover.hashCode +
        otherReadings.hashCode;

  factory BookResponse.fromJson(Map<String, dynamic> json) => _$BookResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BookResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

