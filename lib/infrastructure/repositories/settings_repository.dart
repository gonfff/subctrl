import 'package:subtrackr/infrastructure/persistence/database.dart';

class SettingsRepository {
  SettingsRepository(this._database);

  final AppDatabase _database;

  static const _baseCurrencyKey = 'base_currency_code';
  static const _themePreferenceKey = 'theme_preference';
  static const _localeKey = 'locale_code';
  static const _currencyRatesAutoDownloadKey =
      'currency_rates_auto_download_enabled';

  Future<String?> getBaseCurrencyCode() {
    return _database.getSetting(_baseCurrencyKey);
  }

  Future<void> setBaseCurrencyCode(String code) {
    return _database.saveSetting(_baseCurrencyKey, code.toUpperCase());
  }

  Future<String?> getThemePreference() {
    return _database.getSetting(_themePreferenceKey);
  }

  Future<void> setThemePreference(String preference) {
    return _database.saveSetting(_themePreferenceKey, preference);
  }

  Future<String?> getLocaleCode() {
    return _database.getSetting(_localeKey);
  }

  Future<void> setLocaleCode(String? code) {
    return _database.saveSetting(_localeKey, code);
  }

  Future<bool> getCurrencyRatesAutoDownloadEnabled() async {
    final stored = await _database.getSetting(_currencyRatesAutoDownloadKey);
    if (stored == null) {
      return true;
    }
    return stored == 'true';
  }

  Future<void> setCurrencyRatesAutoDownloadEnabled(bool value) {
    return _database.saveSetting(
      _currencyRatesAutoDownloadKey,
      value.toString(),
    );
  }
}
