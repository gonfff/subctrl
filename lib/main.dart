import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:subtrackr/application/app_dependencies.dart';
import 'package:subtrackr/presentation/l10n/app_localizations.dart';
import 'package:subtrackr/presentation/screens/analytics_screen.dart';
import 'package:subtrackr/presentation/screens/subscriptions_screen.dart';
import 'package:subtrackr/presentation/theme/theme_preference.dart';
import 'package:subtrackr/presentation/types/settings_callbacks.dart';

void main() {
  runApp(const SubtrackrApp());
}

class SubtrackrApp extends StatefulWidget {
  const SubtrackrApp({super.key});

  @override
  State<SubtrackrApp> createState() => _SubtrackrAppState();
}

class _SubtrackrAppState extends State<SubtrackrApp> {
  ThemePreference _themePreference = ThemePreference.system;
  Locale? _locale;
  String? _baseCurrencyCode =
      'USD'; // Default value to avoid null during initialization
  bool _isCurrencyRatesAutoDownloadEnabled = true;
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
    var storedBaseCurrency =
        await _dependencies.getBaseCurrencyCodeUseCase();
    final shouldDownloadRates =
        await _dependencies.getCurrencyRatesAutoDownloadUseCase();

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
    });

    if (shouldPersistBaseCurrency) {
      await _dependencies.setBaseCurrencyCodeUseCase(storedBaseCurrency);
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
    unawaited(
      _dependencies.setCurrencyRatesAutoDownloadUseCase(value),
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
      title: 'Subtrackr',
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
