import 'package:subtrackr/domain/repositories/settings_repository.dart';

class SetCurrencyRatesAutoDownloadUseCase {
  SetCurrencyRatesAutoDownloadUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(bool isEnabled) {
    return _repository.setCurrencyRatesAutoDownloadEnabled(isEnabled);
  }
}
