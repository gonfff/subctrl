import 'package:subctrl/domain/repositories/settings_repository.dart';

class GetNotificationReminderOffsetUseCase {
  GetNotificationReminderOffsetUseCase(this._repository);

  final SettingsRepository _repository;

  Future<String?> call() {
    return _repository.getNotificationReminderOffset();
  }
}
