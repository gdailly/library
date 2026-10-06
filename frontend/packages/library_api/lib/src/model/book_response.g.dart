// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BookResponseCWProxy {
  BookResponse id(int id);

  BookResponse isbn13(String? isbn13);

  BookResponse title(String title);

  BookResponse subtitle(String? subtitle);

  BookResponse authors(String? authors);

  BookResponse publisher(String? publisher);

  BookResponse year(int? year);

  BookResponse pages(int? pages);

  BookResponse language(String? language);

  BookResponse summary(String? summary);

  BookResponse owned(bool owned);

  BookResponse addedBy(int? addedBy);

  BookResponse addedByName(String? addedByName);

  BookResponse createdAt(DateTime createdAt);

  BookResponse categories(List<CategoryResponse> categories);

  BookResponse myReading(ReadingResponse? myReading);

  BookResponse cover(CoverResponse? cover);

  BookResponse otherReadings(List<OtherReadingResponse> otherReadings);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BookResponse call({
    int id,
    String? isbn13,
    String title,
    String? subtitle,
    String? authors,
    String? publisher,
    int? year,
    int? pages,
    String? language,
    String? summary,
    bool owned,
    int? addedBy,
    String? addedByName,
    DateTime createdAt,
    List<CategoryResponse> categories,
    ReadingResponse? myReading,
    CoverResponse? cover,
    List<OtherReadingResponse> otherReadings,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBookResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBookResponse.copyWith.fieldName(...)`
class _$BookResponseCWProxyImpl implements _$BookResponseCWProxy {
  const _$BookResponseCWProxyImpl(this._value);

  final BookResponse _value;

  @override
  BookResponse id(int id) => this(id: id);

  @override
  BookResponse isbn13(String? isbn13) => this(isbn13: isbn13);

  @override
  BookResponse title(String title) => this(title: title);

  @override
  BookResponse subtitle(String? subtitle) => this(subtitle: subtitle);

  @override
  BookResponse authors(String? authors) => this(authors: authors);

  @override
  BookResponse publisher(String? publisher) => this(publisher: publisher);

  @override
  BookResponse year(int? year) => this(year: year);

  @override
  BookResponse pages(int? pages) => this(pages: pages);

  @override
  BookResponse language(String? language) => this(language: language);

  @override
  BookResponse summary(String? summary) => this(summary: summary);

  @override
  BookResponse owned(bool owned) => this(owned: owned);

  @override
  BookResponse addedBy(int? addedBy) => this(addedBy: addedBy);

  @override
  BookResponse addedByName(String? addedByName) =>
      this(addedByName: addedByName);

  @override
  BookResponse createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  BookResponse categories(List<CategoryResponse> categories) =>
      this(categories: categories);

  @override
  BookResponse myReading(ReadingResponse? myReading) =>
      this(myReading: myReading);

  @override
  BookResponse cover(CoverResponse? cover) => this(cover: cover);

  @override
  BookResponse otherReadings(List<OtherReadingResponse> otherReadings) =>
      this(otherReadings: otherReadings);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BookResponse call({
    Object? id = const $CopyWithPlaceholder(),
    Object? isbn13 = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? subtitle = const $CopyWithPlaceholder(),
    Object? authors = const $CopyWithPlaceholder(),
    Object? publisher = const $CopyWithPlaceholder(),
    Object? year = const $CopyWithPlaceholder(),
    Object? pages = const $CopyWithPlaceholder(),
    Object? language = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? owned = const $CopyWithPlaceholder(),
    Object? addedBy = const $CopyWithPlaceholder(),
    Object? addedByName = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? categories = const $CopyWithPlaceholder(),
    Object? myReading = const $CopyWithPlaceholder(),
    Object? cover = const $CopyWithPlaceholder(),
    Object? otherReadings = const $CopyWithPlaceholder(),
  }) {
    return BookResponse(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      isbn13: isbn13 == const $CopyWithPlaceholder()
          ? _value.isbn13
          // ignore: cast_nullable_to_non_nullable
          : isbn13 as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      subtitle: subtitle == const $CopyWithPlaceholder()
          ? _value.subtitle
          // ignore: cast_nullable_to_non_nullable
          : subtitle as String?,
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
      owned: owned == const $CopyWithPlaceholder()
          ? _value.owned
          // ignore: cast_nullable_to_non_nullable
          : owned as bool,
      addedBy: addedBy == const $CopyWithPlaceholder()
          ? _value.addedBy
          // ignore: cast_nullable_to_non_nullable
          : addedBy as int?,
      addedByName: addedByName == const $CopyWithPlaceholder()
          ? _value.addedByName
          // ignore: cast_nullable_to_non_nullable
          : addedByName as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      categories: categories == const $CopyWithPlaceholder()
          ? _value.categories
          // ignore: cast_nullable_to_non_nullable
          : categories as List<CategoryResponse>,
      myReading: myReading == const $CopyWithPlaceholder()
          ? _value.myReading
          // ignore: cast_nullable_to_non_nullable
          : myReading as ReadingResponse?,
      cover: cover == const $CopyWithPlaceholder()
          ? _value.cover
          // ignore: cast_nullable_to_non_nullable
          : cover as CoverResponse?,
      otherReadings: otherReadings == const $CopyWithPlaceholder()
          ? _value.otherReadings
          // ignore: cast_nullable_to_non_nullable
          : otherReadings as List<OtherReadingResponse>,
    );
  }
}

extension $BookResponseCopyWith on BookResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBookResponse.copyWith(...)` or like so:`instanceOfBookResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BookResponseCWProxy get copyWith => _$BookResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookResponse _$BookResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BookResponse', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'owned',
      'createdAt',
      'categories',
      'otherReadings',
    ],
  );
  final val = BookResponse(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    isbn13: $checkedConvert('isbn13', (v) => v as String?),
    title: $checkedConvert('title', (v) => v as String),
    subtitle: $checkedConvert('subtitle', (v) => v as String?),
    authors: $checkedConvert('authors', (v) => v as String?),
    publisher: $checkedConvert('publisher', (v) => v as String?),
    year: $checkedConvert('year', (v) => (v as num?)?.toInt()),
    pages: $checkedConvert('pages', (v) => (v as num?)?.toInt()),
    language: $checkedConvert('language', (v) => v as String?),
    summary: $checkedConvert('summary', (v) => v as String?),
    owned: $checkedConvert('owned', (v) => v as bool),
    addedBy: $checkedConvert('addedBy', (v) => (v as num?)?.toInt()),
    addedByName: $checkedConvert('addedByName', (v) => v as String?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    categories: $checkedConvert(
      'categories',
      (v) => (v as List<dynamic>)
          .map((e) => CategoryResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    myReading: $checkedConvert(
      'myReading',
      (v) => v == null
          ? null
          : ReadingResponse.fromJson(v as Map<String, dynamic>),
    ),
    cover: $checkedConvert(
      'cover',
      (v) =>
          v == null ? null : CoverResponse.fromJson(v as Map<String, dynamic>),
    ),
    otherReadings: $checkedConvert(
      'otherReadings',
      (v) => (v as List<dynamic>)
          .map((e) => OtherReadingResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$BookResponseToJson(BookResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isbn13': ?instance.isbn13,
      'title': instance.title,
      'subtitle': ?instance.subtitle,
      'authors': ?instance.authors,
      'publisher': ?instance.publisher,
      'year': ?instance.year,
      'pages': ?instance.pages,
      'language': ?instance.language,
      'summary': ?instance.summary,
      'owned': instance.owned,
      'addedBy': ?instance.addedBy,
      'addedByName': ?instance.addedByName,
      'createdAt': instance.createdAt.toIso8601String(),
      'categories': instance.categories.map((e) => e.toJson()).toList(),
      'myReading': ?instance.myReading?.toJson(),
      'cover': ?instance.cover?.toJson(),
      'otherReadings': instance.otherReadings.map((e) => e.toJson()).toList(),
    };
