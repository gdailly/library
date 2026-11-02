// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_metadata_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SourceMetadataResponseCWProxy {
  SourceMetadataResponse source_(MetadataSource? source_);

  SourceMetadataResponse title(String title);

  SourceMetadataResponse subtitle(String? subtitle);

  SourceMetadataResponse series(String? series);

  SourceMetadataResponse seriesNumber(int? seriesNumber);

  SourceMetadataResponse authors(String? authors);

  SourceMetadataResponse publisher(String? publisher);

  SourceMetadataResponse year(int? year);

  SourceMetadataResponse pages(int? pages);

  SourceMetadataResponse language(String? language);

  SourceMetadataResponse summary(String? summary);

  SourceMetadataResponse coverUrl(String? coverUrl);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SourceMetadataResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SourceMetadataResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SourceMetadataResponse call({
    MetadataSource? source_,
    String title,
    String? subtitle,
    String? series,
    int? seriesNumber,
    String? authors,
    String? publisher,
    int? year,
    int? pages,
    String? language,
    String? summary,
    String? coverUrl,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSourceMetadataResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSourceMetadataResponse.copyWith.fieldName(...)`
class _$SourceMetadataResponseCWProxyImpl
    implements _$SourceMetadataResponseCWProxy {
  const _$SourceMetadataResponseCWProxyImpl(this._value);

  final SourceMetadataResponse _value;

  @override
  SourceMetadataResponse source_(MetadataSource? source_) =>
      this(source_: source_);

  @override
  SourceMetadataResponse title(String title) => this(title: title);

  @override
  SourceMetadataResponse subtitle(String? subtitle) => this(subtitle: subtitle);

  @override
  SourceMetadataResponse series(String? series) => this(series: series);

  @override
  SourceMetadataResponse seriesNumber(int? seriesNumber) =>
      this(seriesNumber: seriesNumber);

  @override
  SourceMetadataResponse authors(String? authors) => this(authors: authors);

  @override
  SourceMetadataResponse publisher(String? publisher) =>
      this(publisher: publisher);

  @override
  SourceMetadataResponse year(int? year) => this(year: year);

  @override
  SourceMetadataResponse pages(int? pages) => this(pages: pages);

  @override
  SourceMetadataResponse language(String? language) => this(language: language);

  @override
  SourceMetadataResponse summary(String? summary) => this(summary: summary);

  @override
  SourceMetadataResponse coverUrl(String? coverUrl) => this(coverUrl: coverUrl);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SourceMetadataResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SourceMetadataResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SourceMetadataResponse call({
    Object? source_ = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? subtitle = const $CopyWithPlaceholder(),
    Object? series = const $CopyWithPlaceholder(),
    Object? seriesNumber = const $CopyWithPlaceholder(),
    Object? authors = const $CopyWithPlaceholder(),
    Object? publisher = const $CopyWithPlaceholder(),
    Object? year = const $CopyWithPlaceholder(),
    Object? pages = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? coverUrl = const $CopyWithPlaceholder(),
  }) {
    return SourceMetadataResponse(
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as MetadataSource?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      subtitle: subtitle == const $CopyWithPlaceholder()
          ? _value.subtitle
          // ignore: cast_nullable_to_non_nullable
          : subtitle as String?,
      series: series == const $CopyWithPlaceholder()
          ? _value.series
          // ignore: cast_nullable_to_non_nullable
          : series as String?,
      seriesNumber: seriesNumber == const $CopyWithPlaceholder()
          ? _value.seriesNumber
          // ignore: cast_nullable_to_non_nullable
          : seriesNumber as int?,
      authors: authors == const $CopyWithPlaceholder()
          ? _value.authors
          // ignore: cast_nullable_to_non_nullable
          : authors as String?,
      publisher: publisher == const $CopyWithPlaceholder()
          ? _value.publisher
          // ignore: cast_nullable_to_non_nullable
          : publisher as String?,
      year: year == const $CopyWithPlaceholder()
          ? _value.year
          // ignore: cast_nullable_to_non_nullable
          : year as int?,
      pages: pages == const $CopyWithPlaceholder()
          ? _value.pages
          // ignore: cast_nullable_to_non_nullable
          : pages as int?,
      language: language == const $CopyWithPlaceholder()
          ? _value.language
          // ignore: cast_nullable_to_non_nullable
          : language as String?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String?,
      coverUrl: coverUrl == const $CopyWithPlaceholder()
          ? _value.coverUrl
          // ignore: cast_nullable_to_non_nullable
          : coverUrl as String?,
    );
  }
}

extension $SourceMetadataResponseCopyWith on SourceMetadataResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSourceMetadataResponse.copyWith(...)` or like so:`instanceOfSourceMetadataResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SourceMetadataResponseCWProxy get copyWith =>
      _$SourceMetadataResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceMetadataResponse _$SourceMetadataResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SourceMetadataResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['title']);
  final val = SourceMetadataResponse(
    source_: $checkedConvert(
      'source',
      (v) => $enumDecodeNullable(_$MetadataSourceEnumMap, v),
    ),
    title: $checkedConvert('title', (v) => v as String),
    subtitle: $checkedConvert('subtitle', (v) => v as String?),
    series: $checkedConvert('series', (v) => v as String?),
    seriesNumber: $checkedConvert('seriesNumber', (v) => (v as num?)?.toInt()),
    authors: $checkedConvert('authors', (v) => v as String?),
    publisher: $checkedConvert('publisher', (v) => v as String?),
    year: $checkedConvert('year', (v) => (v as num?)?.toInt()),
    pages: $checkedConvert('pages', (v) => (v as num?)?.toInt()),
    language: $checkedConvert('language', (v) => v as String?),
    summary: $checkedConvert('summary', (v) => v as String?),
    coverUrl: $checkedConvert('coverUrl', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$SourceMetadataResponseToJson(
  SourceMetadataResponse instance,
) => <String, dynamic>{
  'source': ?_$MetadataSourceEnumMap[instance.source_],
  'title': instance.title,
  'subtitle': ?instance.subtitle,
  'series': ?instance.series,
  'seriesNumber': ?instance.seriesNumber,
  'authors': ?instance.authors,
  'publisher': ?instance.publisher,
  'year': ?instance.year,
  'pages': ?instance.pages,
  'language': ?instance.language,
  'summary': ?instance.summary,
  'coverUrl': ?instance.coverUrl,
};

const _$MetadataSourceEnumMap = {
  MetadataSource.LIBRARY: 'LIBRARY',
  MetadataSource.OPEN_LIBRARY: 'OPEN_LIBRARY',
  MetadataSource.GOOGLE_BOOKS: 'GOOGLE_BOOKS',
  MetadataSource.BNF: 'BNF',
};
