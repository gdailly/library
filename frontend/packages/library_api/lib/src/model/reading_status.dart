//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum ReadingStatus {
  @JsonValue(r'TO_READ')
  TO_READ(r'TO_READ'),
  @JsonValue(r'READING')
  READING(r'READING'),
  @JsonValue(r'READ')
  READ(r'READ'),
  @JsonValue(r'ABANDONED')
  ABANDONED(r'ABANDONED');

  const ReadingStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
