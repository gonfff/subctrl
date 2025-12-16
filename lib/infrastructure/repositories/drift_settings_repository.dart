import 'package:subctrl/domain/repositories/settings_repository.dart';
import 'package:subctrl/infrastructure/persistence/database.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._database);

  final AppDatabase _database;

  static const _baseCurrencyKey = 'base_currency_code';
  static const _themePreferenceKey = 'theme_preference';
  static const _localeKey = 'locale_code';
  static const _currencyRatesAutoDownloadKey =
      'currency_rates_auto_download_enabled';

  @override
  Future<String?> getBaseCurrencyCode() {
    return _database.getSetting(_baseCurrencyKey);
  }

  @override
  Future<void> setBaseCurrencyCode(String code) {
    return _database.saveSetting(_baseCurrencyKey, code.toUpperCase());
  }

  @override
  Future<String?> getThemePreference() {
    return _database.getSetting(_themePreferenceKey);
  }

  @override
  Future<void> setThemePreference(String preference) {
    return _database.saveSetting(_themePreferenceKey, preference);
  }

  @override
  Future<String?> getLocaleCode() {
    return _database.getSetting(_localeKey);
  }

  @override
  Future<void> setLocaleCode(String? code) {
    return _database.saveSetting(_localeKey, code);
  }

  @override
  Future<bool> getCurrencyRatesAutoDownloadEnabled() async {
    final stored = await _database.getSetting(_currencyRatesAutoDownloadKey);
    if (stored == null) {
      return true;
    }
    return stored == 'true';
  }

  @override
  Future<void> setCurrencyRatesAutoDownloadEnabled(bool value) {
    return _database.saveSetting(
      _currencyRatesAutoDownloadKey,
      value.toString(),
    );
  }
}
