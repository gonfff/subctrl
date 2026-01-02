import 'package:flutter/cupertino.dart';

Color colorFromHex(
  String hexColor, {
  Color? fallbackColor,
}) {
  var hex = hexColor.replaceFirst('#', '').trim();
  if (hex.isEmpty) {
    if (fallbackColor != null) {
      return fallbackColor;
    }
    throw const FormatException('Hex color cannot be empty');
  }
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  final value = int.tryParse(hex, radix: 16);
  if (value == null) {
    if (fallbackColor != null) {
      return fallbackColor;
    }
    throw FormatException('Invalid hex color: $hexColor');
  }
  return Color(value);
}

String hexFromColor(Color color, {bool includeAlpha = false}) {
  final buffer = StringBuffer('#');
  if (includeAlpha) {
    buffer.write(color.alpha.toRadixString(16).padLeft(2, '0'));
  }
  buffer
    ..write(color.red.toRadixString(16).padLeft(2, '0'))
    ..write(color.green.toRadixString(16).padLeft(2, '0'))
    ..write(color.blue.toRadixString(16).padLeft(2, '0'));
  return buffer.toString().toUpperCase();
}
