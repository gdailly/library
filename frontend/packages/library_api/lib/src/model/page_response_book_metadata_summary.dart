//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:library_api/src/model/book_metadata_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'page_response_book_metadata_summary.g.dart';


@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PageResponseBookMetadataSummary {
  /// Returns a new [PageResponseBookMetadataSummary] instance.
  PageResponseBookMetadataSummary({

    required  this.items,

    required  this.page,

    required  this.size,

    required  this.totalItems,

    required  this.totalPages,
  });

  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<BookMetadataSummary> items;



  @JsonKey(
    
    name: r'page',
    required: true,
    includeIfNull: false,
  )


  final int page;



  @JsonKey(
    
    name: r'size',
    required: true,
    includeIfNull: false,
  )


  final int size;



  @JsonKey(
    
    name: r'totalItems',
    required: true,
    includeIfNull: false,
  )


  final int totalItems;



  @JsonKey(
    
    name: r'totalPages',
    required: true,
    includeIfNull: false,
  )


  final int totalPages;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PageResponseBookMetadataSummary &&
      other.items == items &&
      other.page == page &&
      other.size == size &&
      other.totalItems == totalItems &&
      other.totalPages == totalPages;

    @override
    int get hashCode =>
        items.hashCode +
        page.hashCode +
        size.hashCode +
        totalItems.hashCode +
        totalPages.hashCode;

  factory PageResponseBookMetadataSummary.fromJson(Map<String, dynamic> json) => _$PageResponseBookMetadataSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PageResponseBookMetadataSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

