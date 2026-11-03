//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/cover_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'series_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SeriesResponse {
  /// Returns a new [SeriesResponse] instance.
  SeriesResponse({

    required  this.name,

    required  this.books,

    required  this.owned,

    required  this.ownedNumbers,

    required  this.wishedNumbers,

    required  this.missingNumbers,

     this.lastNumber,

    required  this.unnumbered,

     this.catalogVolumes,

     this.cover,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'books',
    required: true,
    includeIfNull: false,
  )


  final int books;



  @JsonKey(
    
    name: r'owned',
    required: true,
    includeIfNull: false,
  )


  final int owned;



  @JsonKey(
    
    name: r'ownedNumbers',
    required: true,
    includeIfNull: false,
  )


  final List<int> ownedNumbers;



  @JsonKey(
    
    name: r'wishedNumbers',
    required: true,
    includeIfNull: false,
  )


  final List<int> wishedNumbers;



  @JsonKey(
    
    name: r'missingNumbers',
    required: true,
    includeIfNull: false,
  )


  final List<int> missingNumbers;



  @JsonKey(
    
    name: r'lastNumber',
    required: false,
    includeIfNull: false,
  )


  final int? lastNumber;



  @JsonKey(
    
    name: r'unnumbered',
    required: true,
    includeIfNull: false,
  )


  final int unnumbered;



  @JsonKey(
    
    name: r'catalogVolumes',
    required: false,
    includeIfNull: false,
  )


  final int? catalogVolumes;



  @JsonKey(
    
    name: r'cover',
    required: false,
    includeIfNull: false,
  )


  final CoverResponse? cover;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SeriesResponse &&
      other.name == name &&
      other.books == books &&
      other.owned == owned &&
      other.ownedNumbers == ownedNumbers &&
      other.wishedNumbers == wishedNumbers &&
      other.missingNumbers == missingNumbers &&
      other.lastNumber == lastNumber &&
      other.unnumbered == unnumbered &&
      other.catalogVolumes == catalogVolumes &&
      other.cover == cover;

    @override
    int get hashCode =>
        name.hashCode +
        books.hashCode +
        owned.hashCode +
        ownedNumbers.hashCode +
        wishedNumbers.hashCode +
        missingNumbers.hashCode +
        lastNumber.hashCode +
        unnumbered.hashCode +
        catalogVolumes.hashCode +
        cover.hashCode;

  factory SeriesResponse.fromJson(Map<String, dynamic> json) => _$SeriesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

