import 'package:subtrackr/domain/repositories/settings_repository.dart';

class SetLocaleCodeUseCase {
  SetLocaleCodeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(String? code) {
    return _repository.setLocaleCode(code);
  }
}
