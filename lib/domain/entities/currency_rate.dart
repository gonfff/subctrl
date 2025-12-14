class CurrencyRate {
  const CurrencyRate({
    required this.baseCode,
    required this.quoteCode,
    required this.rate,
    required this.fetchedAt,
  });

  final String baseCode;
  final String quoteCode;
  final double rate;
  final DateTime fetchedAt;
}
