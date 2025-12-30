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
