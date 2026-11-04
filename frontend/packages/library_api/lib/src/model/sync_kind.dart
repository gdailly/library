//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SyncKind {
  @JsonValue(r'METADATA_FILL')
  METADATA_FILL(r'METADATA_FILL'),
  @JsonValue(r'METADATA_FETCH')
  METADATA_FETCH(r'METADATA_FETCH'),
  @JsonValue(r'METADATA_BOOK')
  METADATA_BOOK(r'METADATA_BOOK'),
  @JsonValue(r'SERIES_ALL')
  SERIES_ALL(r'SERIES_ALL'),
  @JsonValue(r'SERIES_SCHEDULED')
  SERIES_SCHEDULED(r'SERIES_SCHEDULED'),
  @JsonValue(r'SERIES_ONE')
  SERIES_ONE(r'SERIES_ONE');

  const SyncKind(this.value);

  final String value;

  @override
  String toString() => value;
}
