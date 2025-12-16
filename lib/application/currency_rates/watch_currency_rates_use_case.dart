import 'package:subtrackr/domain/entities/currency_rate.dart';
import 'package:subtrackr/domain/repositories/currency_rate_repository.dart';

class WatchCurrencyRatesUseCase {
  WatchCurrencyRatesUseCase(this._repository);

  final CurrencyRateRepository _repository;

  Stream<List<CurrencyRate>> call(String baseCurrencyCode) {
    return _repository.watchRates(baseCurrencyCode.toUpperCase());
  }
}
