//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SyncItemOutcome {
  @JsonValue(r'UPDATED')
  UPDATED(r'UPDATED'),
  @JsonValue(r'UNCHANGED')
  UNCHANGED(r'UNCHANGED'),
  @JsonValue(r'FOUND')
  FOUND(r'FOUND'),
  @JsonValue(r'NOT_FOUND')
  NOT_FOUND(r'NOT_FOUND'),
  @JsonValue(r'NO_REFERENCE')
  NO_REFERENCE(r'NO_REFERENCE'),
  @JsonValue(r'FAILED')
  FAILED(r'FAILED'),
  @JsonValue(r'ADDED')
  ADDED(r'ADDED'),
  @JsonValue(r'REMOVED')
  REMOVED(r'REMOVED');

  const SyncItemOutcome(this.value);

  final String value;

  @override
  String toString() => value;
}
