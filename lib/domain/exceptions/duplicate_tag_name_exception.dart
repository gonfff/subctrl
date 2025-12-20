class DuplicateTagNameException implements Exception {
  DuplicateTagNameException(this.name);

  final String name;

  @override
  String toString() => 'DuplicateTagNameException: $name';
}
