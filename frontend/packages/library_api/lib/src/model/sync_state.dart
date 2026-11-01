//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum SyncState {
  @JsonValue(r'IDLE')
  IDLE(r'IDLE'),
  @JsonValue(r'RUNNING')
  RUNNING(r'RUNNING'),
  @JsonValue(r'DONE')
  DONE(r'DONE');

  const SyncState(this.value);

  final String value;

  @override
  String toString() => value;
}
