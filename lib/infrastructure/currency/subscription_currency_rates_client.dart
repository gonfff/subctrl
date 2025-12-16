import 'package:subtrackr/domain/entities/currency_rate.dart';
import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/domain/repositories/currency_repository.dart';
import 'package:subtrackr/domain/services/currency_rates_provider.dart';
import 'package:subtrackr/infrastructure/currency/yahoo_finance_client.dart';

class SubscriptionCurrencyRatesClient implements CurrencyRatesProvider {
  SubscriptionCurrencyRatesClient({
    required YahooFinanceCurrencyClient yahooFinanceCurrencyClient,
    required CurrencyRepository currencyRepository,
  })  : _yahooClient = yahooFinanceCurrencyClient,
        _currencyRepository = currencyRepository;

  final YahooFinanceCurrencyClient _yahooClient;
  final CurrencyRepository _currencyRepository;

  @override
  Future<List<CurrencyRate>> fetchRates({
    required String baseCurrencyCode,
    required Iterable<Subscription> subscriptions,
  }) async {
    final normalizedBase = baseCurrencyCode.toUpperCase();
    await _currencyRepository.seedIfEmpty();
    final currencies = await _currencyRepository.getCurrencies(
      onlyEnabled: true,
    );
    final builtInCodes = currencies
        .where((currency) => !currency.isCustom)
        .map((currency) => currency.code.toUpperCase())
        .toSet();
    if (!builtInCodes.contains(normalizedBase)) {
      return const [];
    }
    final quoteCodes = subscriptions
        .map((subscription) => subscription.currency.toUpperCase())
        .where((code) => code != normalizedBase && builtInCodes.contains(code))
        .toSet();
    if (quoteCodes.isEmpty) {
      return const [];
    }
    return _yahooClient.fetchRates(
      baseCode: normalizedBase,
      quoteCodes: quoteCodes,
    );
  }
}
