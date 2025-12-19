import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:subctrl/application/app_dependencies.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';
import 'package:subctrl/presentation/screens/analytics_screen.dart';
import 'package:subctrl/presentation/screens/subscriptions_screen.dart';
import 'package:subctrl/presentation/theme/theme_preference.dart';
import 'package:subctrl/presentation/types/notification_reminder_option.dart';
import 'package:subctrl/presentation/types/settings_callbacks.dart';

void main() {
  runApp(const SubctrlApp());
}

class SubctrlApp extends StatefulWidget {
  const SubctrlApp({super.key});

  @override
  State<SubctrlApp> createState() => _SubctrlAppState();
}

class _SubctrlAppState extends State<SubctrlApp> {
  ThemePreference _themePreference = ThemePreference.system;
  Locale? _locale;
  String? _baseCurrencyCode =
      'USD'; // Default value to avoid null during initialization
  bool _isCurrencyRatesAutoDownloadEnabled = true;
  bool _areNotificationsEnabled = false;
  NotificationReminderOption _notificationReminderOption =
      NotificationReminderOption.twoDaysBefore;
  late final AppDependencies _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies();
    unawaited(_loadInitialSettings());
  }

  void _handleThemePreferenceChanged(ThemePreference preference) {
    setState(() {
      _themePreference = preference;
    });
    unawaited(_dependencies.setThemePreferenceUseCase(preference.name));
  }

  void _handleLocaleChanged(Locale? locale) {
    setState(() {
      _locale = locale;
    });
    unawaited(_dependencies.setLocaleCodeUseCase(locale?.languageCode));
  }

  Future<void> _loadInitialSettings() async {
    final storedTheme = await _dependencies.getThemePreferenceUseCase();
    final storedLocale = await _dependencies.getLocaleCodeUseCase();
    var storedBaseCurrency = await _dependencies.getBaseCurrencyCodeUseCase();
    final shouldDownloadRates = await _dependencies
        .getCurrencyRatesAutoDownloadUseCase();
    final shouldEnableNotifications =
        await _dependencies.getNotificationsEnabledUseCase();
    final storedReminder =
        await _dependencies.getNotificationReminderOffsetUseCase();
    final reminderOption =
        NotificationReminderOption.fromStorage(storedReminder);
    final shouldPersistReminder = storedReminder == null;

    final themePreference = ThemePreference.values.firstWhere(
      (value) => value.name == storedTheme,
      orElse: () => ThemePreference.system,
    );

    Locale? locale;
    if (storedLocale != null) {
      locale = _resolveLocale(storedLocale);
    }

    final shouldPersistBaseCurrency = storedBaseCurrency == null;
    storedBaseCurrency ??= 'USD';

    if (!mounted) return;
    setState(() {
      _themePreference = themePreference;
      _locale = locale;
      _baseCurrencyCode = storedBaseCurrency;
      _isCurrencyRatesAutoDownloadEnabled = shouldDownloadRates;
      _areNotificationsEnabled = shouldEnableNotifications;
      _notificationReminderOption = reminderOption;
    });

    if (shouldPersistBaseCurrency) {
      await _dependencies.setBaseCurrencyCodeUseCase(storedBaseCurrency);
    }
    if (shouldPersistReminder) {
      await _dependencies.setNotificationReminderOffsetUseCase(
        reminderOption.storageValue,
      );
    }
  }

  Locale _resolveLocale(String code) {
    try {
      return AppLocalizations.supportedLocales.firstWhere(
        (locale) => locale.languageCode == code,
      );
    } catch (_) {
      return Locale(code);
    }
  }

  Future<void> _handleBaseCurrencyChanged(String? code) async {
    if (code == null) return;
    setState(() {
      _baseCurrencyCode = code;
    });
    await _dependencies.setBaseCurrencyCodeUseCase(code);
  }

  void _handleCurrencyRatesAutoDownloadChanged(bool value) {
    setState(() {
      _isCurrencyRatesAutoDownloadEnabled = value;
    });
    unawaited(_dependencies.setCurrencyRatesAutoDownloadUseCase(value));
  }

  void _handleNotificationsPreferenceChanged(bool value) {
    setState(() {
      _areNotificationsEnabled = value;
    });
    unawaited(_dependencies.setNotificationsEnabledUseCase(value));
  }

  void _handleNotificationReminderChanged(
    NotificationReminderOption option,
  ) {
    setState(() {
      _notificationReminderOption = option;
    });
    unawaited(
      _dependencies.setNotificationReminderOffsetUseCase(
        option.storageValue,
      ),
    );
  }

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = switch (_themePreference) {
      ThemePreference.system => null,
      ThemePreference.light => Brightness.light,
      ThemePreference.dark => Brightness.dark,
    };

    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'subctrl',
      theme: brightness == null
          ? null
          : CupertinoThemeData(brightness: brightness),
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: HomeTabs(
        dependencies: _dependencies,
        themePreference: _themePreference,
        onThemePreferenceChanged: _handleThemePreferenceChanged,
        selectedLocale: _locale,
        onLocaleChanged: _handleLocaleChanged,
        baseCurrencyCode: _baseCurrencyCode,
        onBaseCurrencyChanged: _handleBaseCurrencyChanged,
        currencyRatesAutoDownloadEnabled: _isCurrencyRatesAutoDownloadEnabled,
        onCurrencyRatesAutoDownloadChanged:
            _handleCurrencyRatesAutoDownloadChanged,
        notificationsEnabled: _areNotificationsEnabled,
        onNotificationsPreferenceChanged:
            _handleNotificationsPreferenceChanged,
        notificationReminderOption: _notificationReminderOption,
        onNotificationReminderChanged: _handleNotificationReminderChanged,
      ),
    );
  }
}

class HomeTabs extends StatelessWidget {
  const HomeTabs({
    super.key,
    required this.dependencies,
    required this.themePreference,
    required this.onThemePreferenceChanged,
    required this.selectedLocale,
    required this.onLocaleChanged,
    required this.baseCurrencyCode,
    required this.onBaseCurrencyChanged,
    required this.currencyRatesAutoDownloadEnabled,
    required this.onCurrencyRatesAutoDownloadChanged,
    required this.notificationsEnabled,
    required this.onNotificationsPreferenceChanged,
    required this.notificationReminderOption,
    required this.onNotificationReminderChanged,
  });

  final AppDependencies dependencies;
  final ThemePreference themePreference;
  final ValueChanged<ThemePreference> onThemePreferenceChanged;
  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleChanged;
  final String? baseCurrencyCode;
  final BaseCurrencyChangedCallback onBaseCurrencyChanged;
  final bool currencyRatesAutoDownloadEnabled;
  final ValueChanged<bool> onCurrencyRatesAutoDownloadChanged;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsPreferenceChanged;
  final NotificationReminderOption notificationReminderOption;
  final NotificationReminderChangedCallback onNotificationReminderChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeKey = selectedLocale?.languageCode ?? 'system';
    final themeKey = themePreference.name;
    final baseCurrencyKey = baseCurrencyCode ?? 'none';

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.square_list),
            label: localizations.subscriptionsTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chart_bar),
            label: localizations.analyticsTitle,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          key: index == 0
              ? ValueKey('subscriptions-$themeKey-$localeKey-$baseCurrencyKey')
              : null,
          builder: (context) {
            switch (index) {
              case 0:
                return SubscriptionsScreen(
                  dependencies: dependencies,
                  themePreference: themePreference,
                  onThemePreferenceChanged: onThemePreferenceChanged,
                  selectedLocale: selectedLocale,
                  onLocaleChanged: onLocaleChanged,
                  baseCurrencyCode: baseCurrencyCode,
                  onBaseCurrencyChanged: onBaseCurrencyChanged,
                  currencyRatesAutoDownloadEnabled:
                      currencyRatesAutoDownloadEnabled,
                  onCurrencyRatesAutoDownloadChanged:
                      onCurrencyRatesAutoDownloadChanged,
                  notificationsEnabled: notificationsEnabled,
                  onNotificationsPreferenceChanged:
                      onNotificationsPreferenceChanged,
                  notificationReminderOption: notificationReminderOption,
                  onNotificationReminderChanged:
                      onNotificationReminderChanged,
                );
              case 1:
                return const AnalyticsScreen();
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
