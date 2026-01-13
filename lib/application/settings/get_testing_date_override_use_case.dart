import 'package:subctrl/domain/repositories/settings_repository.dart';

class GetTestingDateOverrideUseCase {
  GetTestingDateOverrideUseCase(this._repository);

  final SettingsRepository _repository;

  Future<DateTime?> call() {
    return _repository.getTestingDateOverride();
  }
}
