import 'package:subctrl/domain/repositories/settings_repository.dart';

class GetBaseCurrencyCodeUseCase {
  GetBaseCurrencyCodeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<String?> call() {
    return _repository.getBaseCurrencyCode();
  }
}
