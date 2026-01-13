abstract class SettingsRepository {
  Future<String?> getBaseCurrencyCode();

  Future<void> setBaseCurrencyCode(String code);

  Future<String?> getThemePreference();

  Future<void> setThemePreference(String preference);

  Future<String?> getLocaleCode();

  Future<void> setLocaleCode(String? code);

  Future<bool> getCurrencyRatesAutoDownloadEnabled();

  Future<void> setCurrencyRatesAutoDownloadEnabled(bool value);

  Future<bool> getNotificationsEnabled();

  Future<void> setNotificationsEnabled(bool value);

  Future<String?> getNotificationReminderOffset();

  Future<void> setNotificationReminderOffset(String value);

  Future<DateTime?> getTestingDateOverride();

  Future<void> setTestingDateOverride(DateTime? value);
}
