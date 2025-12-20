import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/domain/repositories/currency_repository.dart';

class GetCurrenciesUseCase {
  GetCurrenciesUseCase(this._repository);

  final CurrencyRepository _repository;

  Future<List<Currency>> call({bool onlyEnabled = false}) async {
    await _repository.seedIfEmpty();
    return _repository.getCurrencies(onlyEnabled: onlyEnabled);
  }
}
