import 'package:material_ui/material_ui.dart';

/// Color of a "#RRGGBB" string as stored by the API; grey when malformed.
Color colorFromHex(String hex) {
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null || hex.length != 7 ? const Color(0xFF5B6168) : Color(0xFF000000 | value);
}
