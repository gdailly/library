//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/book_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'series_volume_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SeriesVolumeResponse {
  /// Returns a new [SeriesVolumeResponse] instance.
  SeriesVolumeResponse({

    required  this.number,

     this.title,

     this.isbn13,

     this.year,

     this.coverUrl,

    required  this.books,
  });

  @JsonKey(
    
    name: r'number',
    required: true,
    includeIfNull: false,
  )


  final int number;



  @JsonKey(
    
    name: r'title',
    required: false,
    includeIfNull: false,
  )


  final String? title;



  @JsonKey(
    
    name: r'isbn13',
    required: false,
    includeIfNull: false,
  )


  final String? isbn13;



  @JsonKey(
    
    name: r'year',
    required: false,
    includeIfNull: false,
  )


  final int? year;



  @JsonKey(
    
    name: r'coverUrl',
    required: false,
    includeIfNull: false,
  )


  final String? coverUrl;



  @JsonKey(
    
    name: r'books',
    required: true,
    includeIfNull: false,
  )


  final List<BookResponse> books;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SeriesVolumeResponse &&
      other.number == number &&
      other.title == title &&
      other.isbn13 == isbn13 &&
      other.year == year &&
      other.coverUrl == coverUrl &&
      other.books == books;

    @override
    int get hashCode =>
        number.hashCode +
        title.hashCode +
        isbn13.hashCode +
        year.hashCode +
        coverUrl.hashCode +
        books.hashCode;

  factory SeriesVolumeResponse.fromJson(Map<String, dynamic> json) => _$SeriesVolumeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesVolumeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

