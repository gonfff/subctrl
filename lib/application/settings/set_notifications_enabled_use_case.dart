import 'package:subctrl/domain/repositories/settings_repository.dart';

class SetNotificationsEnabledUseCase {
  SetNotificationsEnabledUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(bool isEnabled) {
    return _repository.setNotificationsEnabled(isEnabled);
  }
}
