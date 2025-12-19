import 'package:subctrl/domain/repositories/settings_repository.dart';

class GetNotificationsEnabledUseCase {
  GetNotificationsEnabledUseCase(this._repository);

  final SettingsRepository _repository;

  Future<bool> call() {
    return _repository.getNotificationsEnabled();
  }
}
