import 'package:subtrackr/domain/repositories/settings_repository.dart';

class SetBaseCurrencyCodeUseCase {
  SetBaseCurrencyCodeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(String code) {
    return _repository.setBaseCurrencyCode(code);
  }
}
