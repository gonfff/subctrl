import 'package:subctrl/domain/repositories/settings_repository.dart';

class SetTestingDateOverrideUseCase {
  SetTestingDateOverrideUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(DateTime? value) {
    return _repository.setTestingDateOverride(value);
  }
}
