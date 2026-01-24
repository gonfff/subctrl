import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/repositories/currency_repository.dart';
import 'package:subctrl/domain/services/currency_rates_provider.dart';
import 'package:subctrl/infrastructure/currency/proxy_currency_client.dart';

class SubscriptionCurrencyRatesClient implements CurrencyRatesProvider {
  SubscriptionCurrencyRatesClient({
    required ProxyCurrencyRatesClient proxyCurrencyClient,
    required CurrencyRepository currencyRepository,
  }) : _proxyClient = proxyCurrencyClient,
       _currencyRepository = currencyRepository;

  final ProxyCurrencyRatesClient _proxyClient;
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
    return _proxyClient.fetchRates(
      baseCode: normalizedBase,
      quoteCodes: quoteCodes,
    );
  }
}
