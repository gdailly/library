// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_sync_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BookSyncResponseCWProxy {
  BookSyncResponse outcome(SyncOutcome outcome);

  BookSyncResponse changedFields(List<String> changedFields);

  BookSyncResponse book(BookResponse book);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookSyncResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookSyncResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BookSyncResponse call({
    SyncOutcome outcome,
    List<String> changedFields,
    BookResponse book,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBookSyncResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBookSyncResponse.copyWith.fieldName(...)`
class _$BookSyncResponseCWProxyImpl implements _$BookSyncResponseCWProxy {
  const _$BookSyncResponseCWProxyImpl(this._value);

  final BookSyncResponse _value;

  @override
  BookSyncResponse outcome(SyncOutcome outcome) => this(outcome: outcome);

  @override
  BookSyncResponse changedFields(List<String> changedFields) =>
      this(changedFields: changedFields);

  @override
  BookSyncResponse book(BookResponse book) => this(book: book);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BookSyncResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BookSyncResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BookSyncResponse call({
    Object? outcome = const $CopyWithPlaceholder(),
    Object? changedFields = const $CopyWithPlaceholder(),
    Object? book = const $CopyWithPlaceholder(),
  }) {
    return BookSyncResponse(
      outcome: outcome == const $CopyWithPlaceholder()
          ? _value.outcome
          // ignore: cast_nullable_to_non_nullable
          : outcome as SyncOutcome,
      changedFields: changedFields == const $CopyWithPlaceholder()
          ? _value.changedFields
          // ignore: cast_nullable_to_non_nullable
          : changedFields as List<String>,
      book: book == const $CopyWithPlaceholder()
          ? _value.book
          // ignore: cast_nullable_to_non_nullable
          : book as BookResponse,
    );
  }
}

extension $BookSyncResponseCopyWith on BookSyncResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBookSyncResponse.copyWith(...)` or like so:`instanceOfBookSyncResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BookSyncResponseCWProxy get copyWith => _$BookSyncResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookSyncResponse _$BookSyncResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BookSyncResponse', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['outcome', 'changedFields', 'book'],
      );
      final val = BookSyncResponse(
        outcome: $checkedConvert(
          'outcome',
          (v) => $enumDecode(_$SyncOutcomeEnumMap, v),
        ),
        changedFields: $checkedConvert(
          'changedFields',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        book: $checkedConvert(
          'book',
          (v) => BookResponse.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BookSyncResponseToJson(BookSyncResponse instance) =>
    <String, dynamic>{
      'outcome': _$SyncOutcomeEnumMap[instance.outcome]!,
      'changedFields': instance.changedFields,
      'book': instance.book.toJson(),
    };

const _$SyncOutcomeEnumMap = {
  SyncOutcome.UPDATED: 'UPDATED',
  SyncOutcome.UNCHANGED: 'UNCHANGED',
  SyncOutcome.NOT_FOUND: 'NOT_FOUND',
};
