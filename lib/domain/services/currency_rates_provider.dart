import 'package:subtrackr/domain/entities/currency_rate.dart';
import 'package:subtrackr/domain/entities/subscription.dart';

abstract class CurrencyRatesProvider {
  Future<List<CurrencyRate>> fetchRates({
    required String baseCurrencyCode,
    required Iterable<Subscription> subscriptions,
  });
}

class CurrencyRatesFetchException implements Exception {
  CurrencyRatesFetchException(this.message);

  final String message;

  @override
  String toString() => 'CurrencyRatesFetchException: $message';
}
