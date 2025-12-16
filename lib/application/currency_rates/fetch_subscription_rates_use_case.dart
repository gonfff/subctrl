import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/services/currency_rates_provider.dart';

class FetchSubscriptionRatesUseCase {
  FetchSubscriptionRatesUseCase(this._provider);

  final CurrencyRatesProvider _provider;

  Future<List<CurrencyRate>> call({
    required String baseCurrencyCode,
    required Iterable<Subscription> subscriptions,
  }) {
    return _provider.fetchRates(
      baseCurrencyCode: baseCurrencyCode,
      subscriptions: subscriptions,
    );
  }
}
