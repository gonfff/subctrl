import 'package:subctrl/domain/repositories/settings_repository.dart';
import 'package:subctrl/infrastructure/persistence/daos/settings_dao.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._dao);

  final SettingsDao _dao;

  static const _baseCurrencyKey = 'base_currency_code';
  static const _themePreferenceKey = 'theme_preference';
  static const _localeKey = 'locale_code';
  static const _currencyRatesAutoDownloadKey =
      'currency_rates_auto_download_enabled';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _notificationReminderOffsetKey =
      'notification_reminder_offset';

  @override
  Future<String?> getBaseCurrencyCode() {
    return _dao.getSetting(_baseCurrencyKey);
  }

  @override
  Future<void> setBaseCurrencyCode(String code) {
    return _dao.saveSetting(_baseCurrencyKey, code.toUpperCase());
  }

  @override
  Future<String?> getThemePreference() {
    return _dao.getSetting(_themePreferenceKey);
  }

  @override
  Future<void> setThemePreference(String preference) {
    return _dao.saveSetting(_themePreferenceKey, preference);
  }

  @override
  Future<String?> getLocaleCode() {
    return _dao.getSetting(_localeKey);
  }

  @override
  Future<void> setLocaleCode(String? code) {
    return _dao.saveSetting(_localeKey, code);
  }

  @override
  Future<bool> getCurrencyRatesAutoDownloadEnabled() async {
    final stored = await _dao.getSetting(_currencyRatesAutoDownloadKey);
    if (stored == null) {
      return true;
    }
    return stored == 'true';
  }

  @override
  Future<void> setCurrencyRatesAutoDownloadEnabled(bool value) {
    return _dao.saveSetting(
      _currencyRatesAutoDownloadKey,
      value.toString(),
    );
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    final stored = await _dao.getSetting(_notificationsEnabledKey);
    return stored == 'true';
  }

  @override
  Future<void> setNotificationsEnabled(bool value) {
    return _dao.saveSetting(
      _notificationsEnabledKey,
      value.toString(),
    );
  }

  @override
  Future<String?> getNotificationReminderOffset() {
    return _dao.getSetting(_notificationReminderOffsetKey);
  }

  @override
  Future<void> setNotificationReminderOffset(String value) {
    return _dao.saveSetting(_notificationReminderOffsetKey, value);
  }
}
