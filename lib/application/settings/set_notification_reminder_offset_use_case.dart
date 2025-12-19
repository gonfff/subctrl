import 'package:subctrl/domain/repositories/settings_repository.dart';

class SetNotificationReminderOffsetUseCase {
  SetNotificationReminderOffsetUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(String value) {
    return _repository.setNotificationReminderOffset(value);
  }
}
