import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:subtrackr/application/app_dependencies.dart';
import 'package:subtrackr/domain/entities/currency.dart';
import 'package:subtrackr/presentation/l10n/app_localizations.dart';
import 'package:subtrackr/presentation/screens/about_screen.dart';
import 'package:subtrackr/presentation/screens/currency_rates_screen.dart';
import 'package:subtrackr/presentation/screens/currency_settings_screen.dart';
import 'package:subtrackr/presentation/screens/support_screen.dart';
import 'package:subtrackr/presentation/screens/tag_settings_screen.dart';
import 'package:subtrackr/presentation/theme/app_theme.dart';
import 'package:subtrackr/presentation/theme/theme_preference.dart';
import 'package:subtrackr/presentation/types/settings_callbacks.dart';
import 'package:subtrackr/presentation/widgets/currency_picker.dart';
import 'package:subtrackr/presentation/viewmodels/settings_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
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
    required this.onRequestClose,
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
  final VoidCallback onRequestClose;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _viewModel;
  late ThemePreference _currentThemePreference;
  Locale? _currentLocale;
  String? _currentBaseCurrencyCode;
  late bool _isCurrencyRatesAutoDownloadEnabled;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel(widget.dependencies.watchCurrenciesUseCase);
    _currentThemePreference = widget.themePreference;
    _currentLocale = widget.selectedLocale;
    _currentBaseCurrencyCode = widget.baseCurrencyCode?.toUpperCase();
    _isCurrencyRatesAutoDownloadEnabled =
        widget.currencyRatesAutoDownloadEnabled;
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Currency? _resolvedBaseCurrency() {
    final currencies = _viewModel.currencies;
    final code = _currentBaseCurrencyCode;
    if (code == null) return null;
    final normalized = code.toUpperCase();
    try {
      return currencies.firstWhere(
        (currency) => currency.code.toUpperCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themePreference != widget.themePreference) {
      setState(() {
        _currentThemePreference = widget.themePreference;
      });
    }
    if (oldWidget.selectedLocale != widget.selectedLocale) {
      setState(() {
        _currentLocale = widget.selectedLocale;
      });
    }
    if (oldWidget.baseCurrencyCode != widget.baseCurrencyCode) {
      setState(() {
        _currentBaseCurrencyCode = widget.baseCurrencyCode?.toUpperCase();
      });
    }
    if (oldWidget.currencyRatesAutoDownloadEnabled !=
        widget.currencyRatesAutoDownloadEnabled) {
      setState(() {
        _isCurrencyRatesAutoDownloadEnabled =
            widget.currencyRatesAutoDownloadEnabled;
      });
    }
  }

  Future<void> _pickBaseCurrency() async {
    final enabledCurrencies = _viewModel.currencies
        .where((currency) => currency.isEnabled)
        .toList();
    if (enabledCurrencies.isEmpty) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) {
          final localizations = AppLocalizations.of(context);
          return CupertinoAlertDialog(
            title: Text(localizations.settingsBaseCurrency),
            content: Text(localizations.settingsCurrenciesManage),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.settingsClose),
              ),
            ],
          );
        },
      );
      return;
    }
    final selected = await showCurrencyPicker(
      context: context,
      currencies: enabledCurrencies,
      selectedCode: _resolvedBaseCurrency()?.code,
    );
    if (selected != null) {
      final normalized = selected.toUpperCase();
      try {
        await widget.onBaseCurrencyChanged(normalized);
        if (!mounted) return;
        setState(() {
          _currentBaseCurrencyCode = normalized;
        });
      } catch (error, stackTrace) {
        _log(
          'Failed to persist base currency $normalized',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<void> _selectLanguage() async {
    final result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return CupertinoActionSheet(
          title: Text(localizations.settingsLanguageSection),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop('system'),
              child: Text(localizations.languageSystem),
            ),
            for (final locale in AppLocalizations.supportedLocales)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(locale.languageCode),
                child: Text(AppLocalizations.languageNameForLocale(locale)),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.settingsClose),
          ),
        );
      },
    );
    if (result == null) return;
    if (result == 'system') {
      setState(() {
        _currentLocale = null;
      });
      widget.onLocaleChanged(null);
    } else {
      final locale = AppLocalizations.supportedLocales.firstWhere(
        (locale) => locale.languageCode == result,
      );
      setState(() {
        _currentLocale = locale;
      });
      widget.onLocaleChanged(locale);
    }
  }

  Future<void> _selectTheme() async {
    final result = await showCupertinoModalPopup<ThemePreference>(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return CupertinoActionSheet(
          title: Text(localizations.settingsThemeSection),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(context).pop(ThemePreference.system),
              child: Text(localizations.themeSystem),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ThemePreference.light),
              child: Text(localizations.themeLight),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ThemePreference.dark),
              child: Text(localizations.themeDark),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.settingsClose),
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _currentThemePreference = result;
      });
      widget.onThemePreferenceChanged(result);
    }
  }

  Future<void> _openCurrencySettings({
    required CurrencyListCategory category,
  }) async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => CurrencySettingsScreen(
          dependencies: widget.dependencies,
          onClose: widget.onRequestClose,
          category: category,
        ),
      ),
    );
  }

  Future<void> _openTagSettings() async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => TagSettingsScreen(
          dependencies: widget.dependencies,
          onClose: widget.onRequestClose,
        ),
      ),
    );
  }

  Future<void> _openAbout() async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => AboutScreen(onClose: widget.onRequestClose),
      ),
    );
  }

  Future<void> _openSupport() async {
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => SupportScreen(onClose: widget.onRequestClose),
      ),
    );
  }

  void _handleCurrencyRatesAutoDownloadChanged(bool value) {
    setState(() {
      _isCurrencyRatesAutoDownloadEnabled = value;
    });
    widget.onCurrencyRatesAutoDownloadChanged(value);
  }

  Future<void> _openCurrencyRates() async {
    final baseCode =
        _resolvedBaseCurrency()?.code ?? _currentBaseCurrencyCode;
    if (baseCode == null) return;
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => CurrencyRatesScreen(
          dependencies: widget.dependencies,
          baseCurrencyCode: baseCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final currencies = _viewModel.currencies;
        final builtInEnabledCount = currencies
            .where((currency) => !currency.isCustom && currency.isEnabled)
            .length;
        final customEnabledCount = currencies
            .where((currency) => currency.isCustom && currency.isEnabled)
            .length;
        final languageValue = _currentLocale == null
            ? localizations.languageSystem
            : AppLocalizations.languageNameForLocale(_currentLocale!);
        final themeLabel = switch (_currentThemePreference) {
          ThemePreference.system => localizations.themeSystem,
          ThemePreference.light => localizations.themeLight,
          ThemePreference.dark => localizations.themeDark,
        };
        final resolvedBaseCurrency = _resolvedBaseCurrency();
        final resolvedCode =
            resolvedBaseCurrency?.code ?? _currentBaseCurrencyCode;
        final baseCurrencyLabel = _viewModel.isLoading
            ? localizations.settingsLoading
            : resolvedCode?.toUpperCase() ??
                localizations.settingsBaseCurrencyUnset;
        final canOpenRates =
            !_viewModel.isLoading &&
            baseCurrencyLabel != localizations.settingsBaseCurrencyUnset;
        final mediaPadding = MediaQuery.paddingOf(context);

        return CupertinoPageScaffold(
          backgroundColor: AppTheme.scaffoldBackgroundColor(context),
          navigationBar: CupertinoNavigationBar(
            automaticallyImplyLeading: false,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: widget.onRequestClose,
              child: Text(localizations.settingsClose),
            ),
            middle: Text(localizations.settingsTitle),
          ),
          child: ListView(
            padding: EdgeInsets.only(top: 16, bottom: mediaPadding.bottom + 16),
            children: [
              CupertinoFormSection.insetGrouped(
                header: Text(localizations.settingsGeneralSection),
                children: [
                  _SettingsTile(
                    label: localizations.settingsBaseCurrency,
                    value: baseCurrencyLabel,
                    onTap: _viewModel.isLoading ? null : _pickBaseCurrency,
                    showChevron: true,
                  ),
                  _SettingsTile(
                    label: localizations.settingsLanguageSection,
                    value: languageValue,
                    onTap: _selectLanguage,
                    showChevron: true,
                  ),
                  _SettingsTile(
                    label: localizations.settingsThemeSection,
                    value: themeLabel,
                    onTap: _selectTheme,
                    showChevron: true,
                  ),
                ],
              ),
              CupertinoFormSection.insetGrouped(
                header: Text(localizations.settingsCurrenciesSection),
                children: [
                  _SettingsTile(
                    label: localizations.settingsCurrenciesDefaultList,
                    value: localizations.settingsCurrenciesEnabledLabel(
                      builtInEnabledCount,
                    ),
                    onTap: () => _openCurrencySettings(
                      category: CurrencyListCategory.builtIn,
                    ),
                    showChevron: true,
                  ),
                  _SettingsTile(
                    label: localizations.settingsCurrenciesCustomList,
                    value: localizations.settingsCurrenciesEnabledLabel(
                      customEnabledCount,
                    ),
                    onTap: () => _openCurrencySettings(
                      category: CurrencyListCategory.custom,
                    ),
                    showChevron: true,
                  ),
                  _SettingsSwitchTile(
                    label: localizations.settingsCurrencyRatesAutoDownload,
                    value: _isCurrencyRatesAutoDownloadEnabled,
                    onChanged: _handleCurrencyRatesAutoDownloadChanged,
                  ),
                  _SettingsTile(
                    label: localizations.settingsCurrencyRatesTitle,
                    value: canOpenRates ? '' : baseCurrencyLabel,
                    onTap: canOpenRates ? _openCurrencyRates : null,
                    showChevron: true,
                  ),
                ],
              ),
              CupertinoFormSection.insetGrouped(
                header: Text(localizations.settingsTagsSection),
                children: [
                  _SettingsTile(
                    label: localizations.settingsTagsTitle,
                    value: localizations.settingsTagsManage,
                    onTap: _openTagSettings,
                    showChevron: true,
                  ),
                ],
              ),
              CupertinoFormSection.insetGrouped(
                header: Text(localizations.settingsAboutSection),
                children: [
                  _SettingsTile(
                    label: localizations.settingsAboutSection,
                    value: '',
                    onTap: _openAbout,
                    showChevron: true,
                  ),
                  _SettingsTile(
                    label: localizations.settingsAboutSupport,
                    value: '',
                    onTap: _openSupport,
                    showChevron: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

void _log(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(
    message,
    name: 'SettingsScreen',
    error: error,
    stackTrace: stackTrace,
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.label,
    required this.value,
    this.onTap,
    required this.showChevron,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final valueStyle = textStyle.copyWith(
      color: CupertinoColors.systemGrey.resolveFrom(context),
    );
    final row = Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: textStyle)),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: valueStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (showChevron)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(CupertinoIcons.forward, size: 16),
          ),
      ],
    );
    final child = onTap == null
        ? row
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: row,
          );
    return CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final row = Row(
      children: [
        Expanded(child: Text(label, style: textStyle)),
        CupertinoSwitch(value: value, onChanged: onChanged),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: CupertinoFormRow(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: row,
      ),
    );
  }
}
