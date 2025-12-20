import 'package:subctrl/domain/repositories/settings_repository.dart';

class GetCurrencyRatesAutoDownloadUseCase {
  GetCurrencyRatesAutoDownloadUseCase(this._repository);

  final SettingsRepository _repository;

  Future<bool> call() {
    return _repository.getCurrencyRatesAutoDownloadEnabled();
  }
}
