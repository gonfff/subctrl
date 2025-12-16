import 'package:subtrackr/domain/entities/currency_rate.dart';
import 'package:subtrackr/domain/repositories/currency_rate_repository.dart';

class SaveCurrencyRatesUseCase {
  SaveCurrencyRatesUseCase(this._repository);

  final CurrencyRateRepository _repository;

  Future<void> call({
    required String baseCurrencyCode,
    required List<CurrencyRate> rates,
  }) {
    return _repository.saveRates(
      baseCode: baseCurrencyCode,
      rates: rates,
    );
  }
}
