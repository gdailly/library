//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SyncOutcome {
  @JsonValue(r'UPDATED')
  UPDATED(r'UPDATED'),
  @JsonValue(r'UNCHANGED')
  UNCHANGED(r'UNCHANGED'),
  @JsonValue(r'NOT_FOUND')
  NOT_FOUND(r'NOT_FOUND');

  const SyncOutcome(this.value);

  final String value;

  @override
  String toString() => value;
}
