import 'package:subtrackr/domain/repositories/currency_rate_repository.dart';

class DeleteCurrencyRateUseCase {
  DeleteCurrencyRateUseCase(this._repository);

  final CurrencyRateRepository _repository;

  Future<void> call({
    required String baseCurrencyCode,
    required String quoteCurrencyCode,
  }) {
    return _repository.deleteRate(
      baseCode: baseCurrencyCode,
      quoteCode: quoteCurrencyCode,
    );
  }
}
