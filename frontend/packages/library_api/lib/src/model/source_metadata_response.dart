//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/metadata_source.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'source_metadata_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SourceMetadataResponse {
  /// Returns a new [SourceMetadataResponse] instance.
  SourceMetadataResponse({

     this.source_,

    required  this.title,

     this.subtitle,

     this.series,

     this.seriesNumber,

     this.authors,

     this.publisher,

     this.year,

     this.pages,

     this.language,

     this.summary,

     this.coverUrl,
  });

  @JsonKey(
    
    name: r'source',
    required: false,
    includeIfNull: false,
  )


  final MetadataSource? source_;



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
    
    name: r'series',
    required: false,
    includeIfNull: false,
  )


  final String? series;



  @JsonKey(
    
    name: r'seriesNumber',
    required: false,
    includeIfNull: false,
  )


  final int? seriesNumber;



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
    bool operator ==(Object other) => identical(this, other) || other is SourceMetadataResponse &&
      other.source_ == source_ &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.series == series &&
      other.seriesNumber == seriesNumber &&
      other.authors == authors &&
      other.publisher == publisher &&
      other.year == year &&
      other.pages == pages &&
      other.language == language &&
      other.summary == summary &&
      other.coverUrl == coverUrl;

    @override
    int get hashCode =>
        source_.hashCode +
        title.hashCode +
        subtitle.hashCode +
        series.hashCode +
        seriesNumber.hashCode +
        authors.hashCode +
        publisher.hashCode +
        year.hashCode +
        pages.hashCode +
        language.hashCode +
        summary.hashCode +
        coverUrl.hashCode;

  factory SourceMetadataResponse.fromJson(Map<String, dynamic> json) => _$SourceMetadataResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SourceMetadataResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

