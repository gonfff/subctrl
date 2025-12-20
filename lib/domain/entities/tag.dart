class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  final int id;
  final String name;
  final String colorHex;

  Tag copyWith({
    int? id,
    String? name,
    String? colorHex,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
