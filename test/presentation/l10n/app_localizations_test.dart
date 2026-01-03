import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';

void main() {
  test('returns English strings for English locale', () {
    final localizations = AppLocalizations(const Locale('en'));

    expect(localizations.addButtonLabel, 'Add');
    expect(localizations.settingsTitle, 'Settings');
  });

  test('returns Russian strings for Russian locale', () {
    final localizations = AppLocalizations(const Locale('ru'));

    expect(localizations.addButtonLabel, 'Добавить');
    expect(localizations.settingsTitle, 'Настройки');
  });

  test('falls back to English when locale is unsupported', () {
    final localizations = AppLocalizations(const Locale('fr'));

    expect(localizations.analyticsTitle, 'Analytics');
  });

  test('notificationReminderBody replaces template values', () {
    final localizations = AppLocalizations(const Locale('en'));

    final result = localizations.notificationReminderBody('Netflix', 'Jan 1');

    expect(result, 'Netflix will renew on Jan 1');
  });

  test('baseCurrencyValue replaces amount', () {
    final localizations = AppLocalizations(const Locale('en'));

    expect(localizations.baseCurrencyValue('42.00'), '≈ 42.00');
  });

  test('settingsCurrenciesEnabledLabel uses count', () {
    final localizations = AppLocalizations(const Locale('en'));

    expect(localizations.settingsCurrenciesEnabledLabel(3), '3 enabled');
  });

  test('languageNameForLocale falls back to language code', () {
    expect(AppLocalizations.languageNameForLocale(const Locale('fr')), 'fr');
  });

  test('exposes all localized strings', () {
    final localizations = AppLocalizations(const Locale('en'));

    final values = <String>[
      localizations.subscriptionsTitle,
      localizations.analyticsTitle,
      localizations.analyticsPlaceholder,
      localizations.analyticsFiltersTitle,
      localizations.analyticsFiltersPeriodTitle,
      localizations.analyticsFiltersTagsTitle,
      localizations.analyticsFiltersTagsEmpty,
      localizations.analyticsPeriodAllTime,
      localizations.analyticsPeriodMonth,
      localizations.analyticsPeriodQuarter,
      localizations.analyticsPeriodYear,
      localizations.analyticsFiltersClear,
      localizations.analyticsSummaryPeriodLabel,
      localizations.analyticsSummarySpentLabel,
      localizations.analyticsSummaryTotalLabel,
      localizations.analyticsBreakdownPaidLabel('10'),
      localizations.analyticsBreakdownUpcomingLabel('5'),
      localizations.addButtonLabel,
      localizations.settingsTitle,
      localizations.settingsGeneralSection,
      localizations.settingsBaseCurrency,
      localizations.settingsBaseCurrencyUnset,
      localizations.settingsThemeSection,
      localizations.settingsLanguageSection,
      localizations.settingsNotificationsLabel,
      localizations.settingsNotificationsPermissionDenied,
      localizations.settingsNotificationsOpenSettings,
      localizations.settingsNotificationsTitle,
      localizations.settingsNotificationsStatusOn,
      localizations.settingsNotificationsStatusOff,
      localizations.settingsNotificationsWhen,
      localizations.settingsNotificationsWeekBefore,
      localizations.settingsNotificationsTwoDaysBefore,
      localizations.settingsNotificationsDayBefore,
      localizations.settingsNotificationsSameDay,
      localizations.notificationReminderTitle,
      localizations.settingsCurrenciesSection,
      localizations.settingsCurrenciesManage,
      localizations.settingsTagsSection,
      localizations.settingsTagsManage,
      localizations.settingsTagsTitle,
      localizations.settingsTagsAdd,
      localizations.settingsTagsEdit,
      localizations.settingsTagNameLabel,
      localizations.settingsTagColorLabel,
      localizations.settingsTagColorCustomLabel,
      localizations.settingsTagColorPickerBrightness,
      localizations.settingsTagEmpty,
      localizations.settingsTagDeleteConfirm,
      localizations.settingsTagSearchPlaceholder,
      localizations.settingsTagDuplicateError,
      localizations.settingsAboutSection,
      localizations.settingsAboutAuthor,
      localizations.settingsAboutProjects,
      localizations.settingsAboutTelegram,
      localizations.settingsAboutSupport,
      localizations.settingsAboutVersion,
      localizations.settingsCopyAction,
      localizations.settingsSupportLoading,
      localizations.settingsSupportError,
      localizations.settingsSupportRetry,
      localizations.settingsSupportEmpty,
      localizations.settingsCopySuccess,
      localizations.settingsVersionUnknown,
      localizations.settingsCurrenciesTitle,
      localizations.settingsCurrenciesAddCustom,
      localizations.settingsCurrenciesDefaultList,
      localizations.settingsCurrenciesCustomList,
      localizations.settingsCurrencyCodeLabel,
      localizations.settingsCurrencyNameLabel,
      localizations.settingsCurrencySymbolLabel,
      localizations.settingsCurrencyAddAction,
      localizations.settingsCurrencyDuplicateError,
      localizations.settingsCurrencyDeleteConfirm,
      localizations.settingsCurrencyRatesAutoDownload,
      localizations.settingsCurrencyRatesTitle,
      localizations.settingsCurrencyRatesEmpty,
      localizations.settingsCurrencyRatesSortCurrency,
      localizations.settingsCurrencyRatesSortDate,
      localizations.settingsCurrencyRatesAdd,
      localizations.settingsCurrencyRatesManualTitle,
      localizations.settingsCurrencyRatesQuoteLabel,
      localizations.settingsCurrencyRatesValueLabel,
      localizations.settingsCurrencyRatesDateLabel,
      localizations.settingsLoading,
      localizations.settingsClose,
      localizations.deleteAction,
      localizations.themeSystem,
      localizations.themeLight,
      localizations.themeDark,
      localizations.languageSystem,
      localizations.currencyPickerTitle,
      localizations.currencySearchPlaceholder,
      localizations.currencySearchEmpty,
      localizations.newSubscriptionTitle,
      localizations.editSubscriptionTitle,
      localizations.subscriptionNameLabel,
      localizations.subscriptionNamePlaceholder,
      localizations.subscriptionNameError,
      localizations.amountLabel,
      localizations.amountPlaceholder,
      localizations.amountError,
      localizations.currencyLabel,
      localizations.periodLabel,
      localizations.purchaseDateLabel,
      localizations.purchaseDatePlaceholder,
      localizations.purchaseDateError,
      localizations.subscriptionTagLabel,
      localizations.subscriptionTagNone,
      localizations.subscriptionDeleteConfirm,
      localizations.subscriptionActiveLabel,
      localizations.tagPickerTitle,
      localizations.tagSearchPlaceholder,
      localizations.tagSearchEmpty,
      localizations.nextPaymentLabel,
      localizations.nextPaymentPlaceholder,
      localizations.addAction,
      localizations.done,
      localizations.nextPaymentPrefix,
      localizations.emptyStateTitle,
      localizations.emptyStateMessage,
      localizations.subscriptionSearchPlaceholder,
      localizations.subscriptionSearchEmpty,
      localizations.billingCycleMonthly,
      localizations.billingCycleQuarterly,
      localizations.billingCycleYearly,
      localizations.billingCycleDaily,
      localizations.billingCycleWeekly,
      localizations.billingCycleBiweekly,
      localizations.billingCycleFourWeekly,
      localizations.billingCycleSemiannual,
      localizations.billingCycleMonthlyShort,
      localizations.billingCycleQuarterlyShort,
      localizations.billingCycleYearlyShort,
      localizations.billingCycleDailyShort,
      localizations.billingCycleWeeklyShort,
      localizations.billingCycleBiweeklyShort,
      localizations.billingCycleFourWeeklyShort,
      localizations.billingCycleSemiannualShort,
      localizations.baseCurrencyValue('10'),
      localizations.settingsCurrenciesEnabledLabel(1),
      localizations.notificationReminderBody('Name', 'Date'),
      localizations.localeName,
    ];

    expect(values, everyElement(isNotEmpty));
  });

  test('localizations delegate supports known locales', () async {
    final delegate =
        AppLocalizations.localizationsDelegates.first
            as LocalizationsDelegate<AppLocalizations>;

    expect(delegate.isSupported(const Locale('en')), isTrue);
    expect(delegate.isSupported(const Locale('ru')), isTrue);
    expect(delegate.isSupported(const Locale('fr')), isFalse);

    final loaded = await delegate.load(const Locale('en'));
    expect(loaded.analyticsTitle, 'Analytics');
    expect(delegate.shouldReload(delegate), isFalse);
  });
}
