import 'package:flutter/cupertino.dart';

import 'package:subctrl/application/app_dependencies.dart';
import 'package:subctrl/presentation/screens/settings_screen.dart';
import 'package:subctrl/presentation/theme/app_theme.dart';
import 'package:subctrl/presentation/theme/theme_preference.dart';
import 'package:subctrl/presentation/types/settings_callbacks.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
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
    final backgroundColor = AppTheme.scaffoldBackgroundColor(context);
    final handleColor = CupertinoColors.systemGrey4.resolveFrom(context);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 250) {
          Navigator.of(context).maybePop();
        }
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.94,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Container(
              color: backgroundColor,
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: Navigator(
                          onGenerateInitialRoutes: (_, __) => [
                            CupertinoPageRoute<void>(
                              builder: (innerContext) => SettingsScreen(
                                dependencies: dependencies,
                                themePreference: themePreference,
                                onThemePreferenceChanged:
                                    onThemePreferenceChanged,
                                selectedLocale: selectedLocale,
                                onLocaleChanged: onLocaleChanged,
                                baseCurrencyCode: baseCurrencyCode,
                                onBaseCurrencyChanged: onBaseCurrencyChanged,
                                currencyRatesAutoDownloadEnabled:
                                    currencyRatesAutoDownloadEnabled,
                                onCurrencyRatesAutoDownloadChanged:
                                    onCurrencyRatesAutoDownloadChanged,
                                onRequestClose: () =>
                                    Navigator.of(context).maybePop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
