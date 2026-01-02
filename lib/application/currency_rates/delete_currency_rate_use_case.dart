import 'package:subctrl/domain/repositories/currency_rate_repository.dart';

class DeleteCurrencyRateUseCase {
  DeleteCurrencyRateUseCase(this._repository);

  final CurrencyRateRepository _repository;

  Future<void> call({
    required String baseCurrencyCode,
    required String quoteCurrencyCode,
    required DateTime rateDate,
  }) {
    return _repository.deleteRate(
      baseCode: baseCurrencyCode,
      quoteCode: quoteCurrencyCode,
      rateDate: rateDate,
    );
  }
}
