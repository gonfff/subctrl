import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/repositories/currency_rate_repository.dart';

class GetCurrencyRatesUseCase {
  GetCurrencyRatesUseCase(this._repository);

  final CurrencyRateRepository _repository;

  Future<List<CurrencyRate>> call(String baseCurrencyCode) {
    return _repository.getRates(baseCurrencyCode.toUpperCase());
  }
}
