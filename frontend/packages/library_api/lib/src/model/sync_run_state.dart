//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SyncRunState {
  @JsonValue(r'RUNNING')
  RUNNING(r'RUNNING'),
  @JsonValue(r'DONE')
  DONE(r'DONE'),
  @JsonValue(r'INTERRUPTED')
  INTERRUPTED(r'INTERRUPTED');

  const SyncRunState(this.value);

  final String value;

  @override
  String toString() => value;
}
