abstract class SettingsRepository {
  Future<String?> getBaseCurrencyCode();

  Future<void> setBaseCurrencyCode(String code);

  Future<String?> getThemePreference();

  Future<void> setThemePreference(String preference);

  Future<String?> getLocaleCode();

  Future<void> setLocaleCode(String? code);

  Future<bool> getCurrencyRatesAutoDownloadEnabled();

  Future<void> setCurrencyRatesAutoDownloadEnabled(bool value);
}
