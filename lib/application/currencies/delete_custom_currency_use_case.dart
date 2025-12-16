import 'package:subtrackr/domain/repositories/currency_repository.dart';

class DeleteCustomCurrencyUseCase {
  DeleteCustomCurrencyUseCase(this._repository);

  final CurrencyRepository _repository;

  Future<void> call(String code) {
    return _repository.deleteCustomCurrency(code);
  }
}
