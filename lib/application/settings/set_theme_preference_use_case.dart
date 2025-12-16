import 'package:subctrl/domain/repositories/settings_repository.dart';

class SetThemePreferenceUseCase {
  SetThemePreferenceUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(String preference) {
    return _repository.setThemePreference(preference);
  }
}
