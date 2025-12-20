import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/domain/repositories/currency_repository.dart';

class AddCustomCurrencyUseCase {
  AddCustomCurrencyUseCase(this._repository);

  final CurrencyRepository _repository;

  Future<Currency> call({
    required String code,
    required String name,
    String? symbol,
  }) {
    return _repository.addCustomCurrency(
      code: code,
      name: name,
      symbol: symbol,
    );
  }
}
