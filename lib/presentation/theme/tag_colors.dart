import 'package:flutter/cupertino.dart';

class TagColorOption {
  const TagColorOption({required this.hex, required this.label});

  final String hex;
  final String label;

  Color get color {
    final normalized = hex.replaceFirst('#', '').padLeft(6, '0');
    final value = int.parse(normalized, radix: 16);
    return Color(0xFF000000 | value);
  }
}

const tagColorOptions = [
  TagColorOption(hex: '#FF6B6B', label: 'Coral'),
  TagColorOption(hex: '#FF9F1C', label: 'Orange'),
  TagColorOption(hex: '#FFD166', label: 'Amber'),
  TagColorOption(hex: '#06D6A0', label: 'Mint'),
  TagColorOption(hex: '#118AB2', label: 'Blue'),
  TagColorOption(hex: '#5C6BFF', label: 'Indigo'),
  TagColorOption(hex: '#C77DFF', label: 'Violet'),
  TagColorOption(hex: '#F15BB5', label: 'Pink'),
];
