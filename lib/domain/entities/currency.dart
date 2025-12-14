class Currency {
  const Currency({
    required this.code,
    required this.name,
    this.symbol,
    required this.isEnabled,
    required this.isCustom,
  });

  final String code;
  final String name;
  final String? symbol;
  final bool isEnabled;
  final bool isCustom;
}
