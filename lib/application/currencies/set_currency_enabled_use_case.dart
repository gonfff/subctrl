import 'package:subtrackr/domain/repositories/currency_repository.dart';

class SetCurrencyEnabledUseCase {
  SetCurrencyEnabledUseCase(this._repository);

  final CurrencyRepository _repository;

  Future<void> call({
    required String code,
    required bool isEnabled,
  }) {
    return _repository.setCurrencyEnabled(code, isEnabled);
  }
}
