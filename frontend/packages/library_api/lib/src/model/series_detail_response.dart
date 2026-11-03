//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/series_volume_response.dart';
import 'package:library_api/src/model/book_response.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'series_detail_response.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SeriesDetailResponse {
  /// Returns a new [SeriesDetailResponse] instance.
  SeriesDetailResponse({

    required  this.name,

    required  this.volumes,

    required  this.unnumbered,

     this.catalogFetchedAt,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'volumes',
    required: true,
    includeIfNull: false,
  )


  final List<SeriesVolumeResponse> volumes;



  @JsonKey(
    
    name: r'unnumbered',
    required: true,
    includeIfNull: false,
  )


  final List<BookResponse> unnumbered;



  @JsonKey(
    
    name: r'catalogFetchedAt',
    required: false,
    includeIfNull: false,
  )


  final DateTime? catalogFetchedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SeriesDetailResponse &&
      other.name == name &&
      other.volumes == volumes &&
      other.unnumbered == unnumbered &&
      other.catalogFetchedAt == catalogFetchedAt;

    @override
    int get hashCode =>
        name.hashCode +
        volumes.hashCode +
        unnumbered.hashCode +
        catalogFetchedAt.hashCode;

  factory SeriesDetailResponse.fromJson(Map<String, dynamic> json) => _$SeriesDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesDetailResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

