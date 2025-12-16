import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/domain/repositories/currency_repository.dart';

class WatchCurrenciesUseCase {
  WatchCurrenciesUseCase(this._repository);

  final CurrencyRepository _repository;

  Stream<List<Currency>> call({bool onlyEnabled = false}) async* {
    await _repository.seedIfEmpty();
    yield* _repository.watchCurrencies(onlyEnabled: onlyEnabled);
  }
}
