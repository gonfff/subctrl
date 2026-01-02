import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ru')];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    _AppLocalizationsDelegate(),
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'languageName': 'English',
      'subscriptionsTitle': 'Subscriptions',
      'analyticsTitle': 'Analytics',
      'analyticsPlaceholder': 'Analytics will appear here soon.',
      'analyticsFiltersTitle': 'Filters',
      'analyticsFiltersPeriodTitle': 'Period',
      'analyticsFiltersTagsTitle': 'Tags',
      'analyticsFiltersTagsEmpty': 'Add tags in settings to filter by them.',
      'analyticsPeriodAllTime': 'All time',
      'analyticsPeriodMonth': 'This month',
      'analyticsPeriodQuarter': 'This quarter',
      'analyticsPeriodYear': 'This year',
      'analyticsFiltersClear': 'Clear filters',
      'analyticsSummaryPeriodLabel': 'Period',
      'analyticsSummarySpentLabel': 'Spent in period',
      'analyticsSummaryTotalLabel': 'Total spending',
      'analyticsBreakdownPaidLabel': 'Paid {amount}',
      'analyticsBreakdownUpcomingLabel': 'Upcoming {amount}',
      'addButtonLabel': 'Add',
      'settingsTitle': 'Settings',
      'settingsGeneralSection': 'General',
      'settingsBaseCurrency': 'Base currency',
      'settingsBaseCurrencyUnset': 'Not set',
      'settingsThemeSection': 'Theme',
      'settingsLanguageSection': 'Language',
      'settingsNotificationsLabel': 'Notifications',
      'settingsNotificationsPermissionDenied':
          'Notifications permission was denied. Enable it in system settings.',
      'settingsNotificationsOpenSettings': 'Open settings',
      'settingsNotificationsTitle': 'Notifications',
      'settingsNotificationsStatusOn': 'Enabled',
      'settingsNotificationsStatusOff': 'Disabled',
      'settingsNotificationsWhen': 'Notify me',
      'settingsNotificationsWeekBefore': '1 week before payment',
      'settingsNotificationsTwoDaysBefore': '2 days before payment',
      'settingsNotificationsDayBefore': '1 day before payment',
      'settingsNotificationsSameDay': 'On payment day',
      'notificationReminderTitle': 'Subscription renewal',
      'notificationReminderBody': '{name} will renew on {date}',
      'settingsCurrenciesSection': 'Currencies',
      'settingsCurrenciesManage': 'Manage currencies',
      'settingsTagsSection': 'Tags',
      'settingsTagsManage': 'Manage tags',
      'settingsTagsTitle': 'Tags',
      'settingsTagsAdd': 'Add tag',
      'settingsTagsEdit': 'Update tag',
      'settingsTagNameLabel': 'Name',
      'settingsTagColorLabel': 'Tag color',
      'settingsTagColorCustomLabel': 'Custom color',
      'settingsTagColorPickerBrightness': 'Brightness',
      'settingsTagEmpty': 'No tags yet',
      'settingsTagDeleteConfirm': 'Delete this tag?',
      'settingsTagSearchPlaceholder': 'Search tags',
      'settingsTagDuplicateError': 'A tag with this name already exists',
      'settingsAboutSection': 'About',
      'settingsAboutAuthor': 'Author',
      'settingsAboutProjects': 'Source code',
      'settingsAboutTelegram': 'Telegram',
      'settingsAboutSupport': 'Support the project',
      'settingsAboutVersion': 'App version',
      'settingsCopyAction': 'Copy',
      'settingsCopySuccess': 'Copied to clipboard',
      'settingsVersionUnknown': 'Unknown',
      'settingsCurrenciesEnabledLabel': '{count} enabled',
      'settingsCurrenciesTitle': 'Currencies',
      'settingsCurrenciesAddCustom': 'Add custom currency',
      'settingsCurrenciesDefaultList': 'Default currencies',
      'settingsCurrenciesCustomList': 'Custom currencies',
      'settingsCurrencyCodeLabel': 'Code',
      'settingsCurrencyNameLabel': 'Name',
      'settingsCurrencySymbolLabel': 'Symbol (optional)',
      'settingsCurrencyAddAction': 'Add currency',
      'settingsCurrencyDuplicateError': 'Currency already exists',
      'settingsCurrencyDeleteConfirm': 'Delete this custom currency?',
      'settingsCurrencyRatesAutoDownload': 'Download rates from the internet',
      'settingsCurrencyRatesTitle': 'Currency rates',
      'settingsCurrencyRatesEmpty': 'No rates yet',
      'settingsCurrencyRatesSortCurrency': 'By currency',
      'settingsCurrencyRatesSortDate': 'By date',
      'settingsCurrencyRatesAdd': 'Add manual rate',
      'settingsCurrencyRatesManualTitle': 'Add rate',
      'settingsCurrencyRatesQuoteLabel': 'Currency',
      'settingsCurrencyRatesValueLabel': 'Rate',
      'settingsCurrencyRatesDateLabel': 'Date',
      'settingsLoading': 'Loading...',
      'settingsClose': 'Close',
      'deleteAction': 'Delete',
      'themeSystem': 'System',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'languageSystem': 'System default',
      'currencyPickerTitle': 'Choose currency',
      'currencySearchPlaceholder': 'Search currency',
      'currencySearchEmpty': 'No currencies found',
      'newSubscriptionTitle': 'New subscription',
      'editSubscriptionTitle': 'Edit subscription',
      'subscriptionNameLabel': 'Name',
      'subscriptionNamePlaceholder': 'e.g. Netflix',
      'subscriptionNameError': 'Enter a name',
      'amountLabel': 'Cost',
      'amountPlaceholder': '0.00',
      'amountError': 'Enter a valid amount',
      'currencyLabel': 'Currency',
      'periodLabel': 'Billing period',
      'purchaseDateLabel': 'Purchase date',
      'purchaseDatePlaceholder': 'Select a date',
      'purchaseDateError': 'Choose the purchase date',
      'subscriptionTagLabel': 'Tag',
      'subscriptionTagNone': 'No tag',
      'subscriptionDeleteConfirm': 'Delete this subscription?',
      'subscriptionActiveLabel': 'Active',
      'tagPickerTitle': 'Choose tag',
      'tagSearchPlaceholder': 'Search tag',
      'tagSearchEmpty': 'No tags found',
      'nextPaymentLabel': 'Next payment',
      'nextPaymentPlaceholder': 'Fill in the fields above',
      'addAction': 'Add',
      'done': 'Done',
      'nextPaymentPrefix': 'Next payment',
      'emptyStateTitle': 'No subscriptions yet',
      'emptyStateMessage':
          'Add your first subscription to keep track of payments.',
      'subscriptionSearchPlaceholder': 'Search subscriptions',
      'subscriptionSearchEmpty': 'No subscriptions found',
      'baseCurrencyValue': '≈ {amount}',
      'billingCycleMonthly': 'Monthly',
      'billingCycleQuarterly': 'Quarterly',
      'billingCycleYearly': 'Yearly',
      'billingCycleDaily': 'Daily',
      'billingCycleWeekly': 'Weekly',
      'billingCycleBiweekly': 'Every 2 weeks',
      'billingCycleFourWeekly': 'Every 4 weeks',
      'billingCycleSemiannual': 'Every 6 months',
      'billingCycleMonthlyShort': 'Month',
      'billingCycleQuarterlyShort': 'Quarter',
      'billingCycleYearlyShort': 'Year',
      'billingCycleDailyShort': 'Day',
      'billingCycleWeeklyShort': 'Week',
      'billingCycleBiweeklyShort': '2w',
      'billingCycleFourWeeklyShort': '4w',
      'billingCycleSemiannualShort': '6m',
    },
    'ru': {
      'languageName': 'Русский',
      'subscriptionsTitle': 'Подписки',
      'analyticsTitle': 'Аналитика',
      'analyticsPlaceholder': 'Раздел аналитики появится здесь совсем скоро.',
      'analyticsFiltersTitle': 'Фильтры',
      'analyticsFiltersPeriodTitle': 'Период',
      'analyticsFiltersTagsTitle': 'Теги',
      'analyticsFiltersTagsEmpty':
          'Добавьте теги в настройках, чтобы фильтровать.',
      'analyticsPeriodAllTime': 'За всё время',
      'analyticsPeriodMonth': 'Текущий месяц',
      'analyticsPeriodQuarter': 'Текущий квартал',
      'analyticsPeriodYear': 'Текущий год',
      'analyticsFiltersClear': 'Сбросить фильтры',
      'analyticsSummaryPeriodLabel': 'Период',
      'analyticsSummarySpentLabel': 'Потрачено',
      'analyticsSummaryTotalLabel': 'Всего трат',
      'analyticsBreakdownPaidLabel': 'Оплачено {amount}',
      'analyticsBreakdownUpcomingLabel': 'Осталось {amount}',
      'addButtonLabel': 'Добавить',
      'settingsTitle': 'Настройки',
      'settingsGeneralSection': 'Основные',
      'settingsBaseCurrency': 'Базовая валюта',
      'settingsBaseCurrencyUnset': 'Не выбрана',
      'settingsThemeSection': 'Тема',
      'settingsLanguageSection': 'Язык',
      'settingsNotificationsLabel': 'Уведомления',
      'settingsNotificationsPermissionDenied':
          'Доступ к уведомлениям запрещён. Разрешите его в настройках телефона.',
      'settingsNotificationsOpenSettings': 'Открыть настройки',
      'settingsNotificationsTitle': 'Уведомления',
      'settingsNotificationsStatusOn': 'Включены',
      'settingsNotificationsStatusOff': 'Выключены',
      'settingsNotificationsWhen': 'Когда напоминать',
      'settingsNotificationsWeekBefore': 'За неделю до платежа',
      'settingsNotificationsTwoDaysBefore': 'За 2 дня до платежа',
      'settingsNotificationsDayBefore': 'За день до платежа',
      'settingsNotificationsSameDay': 'В день платежа',
      'notificationReminderTitle': 'Напоминание о подписке',
      'notificationReminderBody': '{name} — будет продлена {date}',
      'settingsCurrenciesSection': 'Валюты',
      'settingsCurrenciesManage': 'Управление списком',
      'settingsTagsSection': 'Теги',
      'settingsTagsManage': 'Управление тегами',
      'settingsTagsTitle': 'Теги',
      'settingsTagsAdd': 'Добавить тег',
      'settingsTagsEdit': 'Обновить тег',
      'settingsTagNameLabel': 'Название',
      'settingsTagColorLabel': 'Цвет',
      'settingsTagColorCustomLabel': 'Пользовательский цвет',
      'settingsTagColorPickerBrightness': 'Яркость',
      'settingsTagEmpty': 'Пока нет тегов',
      'settingsTagDeleteConfirm': 'Удалить этот тег?',
      'settingsTagSearchPlaceholder': 'Поиск тегов',
      'settingsTagDuplicateError': 'Тег с таким названием уже существует',
      'settingsAboutSection': 'О приложении',
      'settingsAboutAuthor': 'Автор',
      'settingsAboutProjects': 'Исходный код',
      'settingsAboutTelegram': 'Телеграм',
      'settingsAboutSupport': 'Поддержать проект',
      'settingsAboutVersion': 'Версия приложения',
      'settingsCopyAction': 'Скопировать',
      'settingsCopySuccess': 'Скопировано',
      'settingsVersionUnknown': 'Неизвестно',
      'settingsCurrenciesEnabledLabel': '{count} активны',
      'settingsCurrenciesTitle': 'Валюты',
      'settingsCurrenciesAddCustom': 'Добавить свою валюту',
      'settingsCurrenciesDefaultList': 'Базовые валюты',
      'settingsCurrenciesCustomList': 'Мои валюты',
      'settingsCurrencyCodeLabel': 'Код',
      'settingsCurrencyNameLabel': 'Название',
      'settingsCurrencySymbolLabel': 'Символ (необязательно)',
      'settingsCurrencyAddAction': 'Сохранить валюту',
      'settingsCurrencyDuplicateError': 'Такая валюта уже есть',
      'settingsCurrencyDeleteConfirm': 'Удалить эту валюту?',
      'settingsCurrencyRatesAutoDownload': 'Загружать курсы из интернета',
      'settingsCurrencyRatesTitle': 'Курсы валют',
      'settingsCurrencyRatesEmpty': 'Пока нет данных',
      'settingsCurrencyRatesSortCurrency': 'По валюте',
      'settingsCurrencyRatesSortDate': 'По дате',
      'settingsCurrencyRatesAdd': 'Добавить курс',
      'settingsCurrencyRatesManualTitle': 'Добавить курс',
      'settingsCurrencyRatesQuoteLabel': 'Валюта',
      'settingsCurrencyRatesValueLabel': 'Курс',
      'settingsCurrencyRatesDateLabel': 'Дата',
      'settingsLoading': 'Загрузка...',
      'settingsClose': 'Закрыть',
      'deleteAction': 'Удалить',
      'themeSystem': 'Системная',
      'themeLight': 'Светлая',
      'themeDark': 'Тёмная',
      'languageSystem': 'Как в системе',
      'currencyPickerTitle': 'Выбор валюты',
      'currencySearchPlaceholder': 'Поиск валюты',
      'currencySearchEmpty': 'Валюты не найдены',
      'newSubscriptionTitle': 'Новая подписка',
      'editSubscriptionTitle': 'Редактировать подписку',
      'subscriptionNameLabel': 'Название',
      'subscriptionNamePlaceholder': 'Например, Netflix',
      'subscriptionNameError': 'Введите название',
      'amountLabel': 'Стоимость',
      'amountPlaceholder': '0.00',
      'amountError': 'Введите корректную сумму',
      'currencyLabel': 'Валюта',
      'periodLabel': 'Продолжительность',
      'purchaseDateLabel': 'Дата покупки',
      'purchaseDatePlaceholder': 'Выберите дату',
      'purchaseDateError': 'Укажите дату покупки',
      'subscriptionTagLabel': 'Тег',
      'subscriptionTagNone': 'Без тега',
      'subscriptionDeleteConfirm': 'Удалить эту подписку?',
      'subscriptionActiveLabel': 'Активна',
      'tagPickerTitle': 'Выберите тег',
      'tagSearchPlaceholder': 'Поиск тега',
      'tagSearchEmpty': 'Теги не найдены',
      'nextPaymentLabel': 'Следующий платеж',
      'nextPaymentPlaceholder': 'Заполните данные выше',
      'addAction': 'Добавить',
      'done': 'Готово',
      'nextPaymentPrefix': 'Следующий платеж',
      'emptyStateTitle': 'Пока нет подписок',
      'emptyStateMessage':
          'Добавьте первую подписку, чтобы отслеживать платежи.',
      'subscriptionSearchPlaceholder': 'Поиск подписки',
      'subscriptionSearchEmpty': 'Подписки не найдены',
      'baseCurrencyValue': '≈ {amount}',
      'billingCycleMonthly': 'Ежемесячно',
      'billingCycleQuarterly': 'Ежеквартально',
      'billingCycleYearly': 'Ежегодно',
      'billingCycleDaily': 'Ежедневно',
      'billingCycleWeekly': 'Еженедельно',
      'billingCycleBiweekly': 'Каждые 2 недели',
      'billingCycleFourWeekly': 'Каждые 4 недели',
      'billingCycleSemiannual': 'Каждые 6 месяцев',
      'billingCycleMonthlyShort': 'Месяц',
      'billingCycleQuarterlyShort': 'Квартал',
      'billingCycleYearlyShort': 'Год',
      'billingCycleDailyShort': 'День',
      'billingCycleWeeklyShort': 'Нед',
      'billingCycleBiweeklyShort': '2 нед',
      'billingCycleFourWeeklyShort': '4 нед',
      'billingCycleSemiannualShort': '6 мес',
    },
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Map<String, String> get _strings {
    if (_localizedValues.containsKey(locale.languageCode)) {
      return _localizedValues[locale.languageCode]!;
    }
    return _localizedValues['en']!;
  }

  String get localeName => locale.toLanguageTag();

  String get subscriptionsTitle => _strings['subscriptionsTitle']!;
  String get analyticsTitle => _strings['analyticsTitle']!;
  String get analyticsPlaceholder => _strings['analyticsPlaceholder']!;
  String get analyticsFiltersTitle => _strings['analyticsFiltersTitle']!;
  String get analyticsFiltersPeriodTitle =>
      _strings['analyticsFiltersPeriodTitle']!;
  String get analyticsFiltersTagsTitle =>
      _strings['analyticsFiltersTagsTitle']!;
  String get analyticsFiltersTagsEmpty =>
      _strings['analyticsFiltersTagsEmpty']!;
  String get analyticsPeriodAllTime => _strings['analyticsPeriodAllTime']!;
  String get analyticsPeriodMonth => _strings['analyticsPeriodMonth']!;
  String get analyticsPeriodQuarter => _strings['analyticsPeriodQuarter']!;
  String get analyticsPeriodYear => _strings['analyticsPeriodYear']!;
  String get analyticsFiltersClear => _strings['analyticsFiltersClear']!;
  String get analyticsSummaryPeriodLabel =>
      _strings['analyticsSummaryPeriodLabel']!;
  String get analyticsSummarySpentLabel =>
      _strings['analyticsSummarySpentLabel']!;
  String get analyticsSummaryTotalLabel =>
      _strings['analyticsSummaryTotalLabel']!;
  String analyticsBreakdownPaidLabel(String amount) =>
      _strings['analyticsBreakdownPaidLabel']!.replaceAll('{amount}', amount);
  String analyticsBreakdownUpcomingLabel(String amount) =>
      _strings['analyticsBreakdownUpcomingLabel']!.replaceAll(
        '{amount}',
        amount,
      );
  String get addButtonLabel => _strings['addButtonLabel']!;
  String get settingsTitle => _strings['settingsTitle']!;
  String get settingsGeneralSection => _strings['settingsGeneralSection']!;
  String get settingsBaseCurrency => _strings['settingsBaseCurrency']!;
  String get settingsBaseCurrencyUnset =>
      _strings['settingsBaseCurrencyUnset']!;
  String get settingsThemeSection => _strings['settingsThemeSection']!;
  String get settingsLanguageSection => _strings['settingsLanguageSection']!;
  String get settingsNotificationsLabel =>
      _strings['settingsNotificationsLabel']!;
  String get settingsNotificationsPermissionDenied =>
      _strings['settingsNotificationsPermissionDenied']!;
  String get settingsNotificationsOpenSettings =>
      _strings['settingsNotificationsOpenSettings']!;
  String get settingsNotificationsTitle =>
      _strings['settingsNotificationsTitle']!;
  String get settingsNotificationsStatusOn =>
      _strings['settingsNotificationsStatusOn']!;
  String get settingsNotificationsStatusOff =>
      _strings['settingsNotificationsStatusOff']!;
  String get settingsNotificationsWhen =>
      _strings['settingsNotificationsWhen']!;
  String get settingsNotificationsWeekBefore =>
      _strings['settingsNotificationsWeekBefore']!;
  String get settingsNotificationsTwoDaysBefore =>
      _strings['settingsNotificationsTwoDaysBefore']!;
  String get settingsNotificationsDayBefore =>
      _strings['settingsNotificationsDayBefore']!;
  String get settingsNotificationsSameDay =>
      _strings['settingsNotificationsSameDay']!;
  String get notificationReminderTitle =>
      _strings['notificationReminderTitle']!;
  String notificationReminderBody(String name, String date) {
    final template = _strings['notificationReminderBody']!;
    return template.replaceAll('{name}', name).replaceAll('{date}', date);
  }

  String get settingsCurrenciesSection =>
      _strings['settingsCurrenciesSection']!;
  String get settingsCurrenciesManage => _strings['settingsCurrenciesManage']!;
  String get settingsTagsSection => _strings['settingsTagsSection']!;
  String get settingsTagsManage => _strings['settingsTagsManage']!;
  String get settingsTagsTitle => _strings['settingsTagsTitle']!;
  String get settingsTagsAdd => _strings['settingsTagsAdd']!;
  String get settingsTagsEdit => _strings['settingsTagsEdit']!;
  String get settingsTagNameLabel => _strings['settingsTagNameLabel']!;
  String get settingsTagColorLabel => _strings['settingsTagColorLabel']!;
  String get settingsTagColorCustomLabel =>
      _strings['settingsTagColorCustomLabel']!;
  String get settingsTagColorPickerBrightness =>
      _strings['settingsTagColorPickerBrightness']!;
  String get settingsTagEmpty => _strings['settingsTagEmpty']!;
  String get settingsTagDeleteConfirm => _strings['settingsTagDeleteConfirm']!;
  String get settingsTagSearchPlaceholder =>
      _strings['settingsTagSearchPlaceholder']!;
  String get settingsTagDuplicateError =>
      _strings['settingsTagDuplicateError']!;
  String get settingsAboutSection => _strings['settingsAboutSection']!;
  String get settingsAboutAuthor => _strings['settingsAboutAuthor']!;
  String get settingsAboutProjects => _strings['settingsAboutProjects']!;
  String get settingsAboutTelegram => _strings['settingsAboutTelegram']!;
  String get settingsAboutSupport => _strings['settingsAboutSupport']!;
  String get settingsAboutVersion => _strings['settingsAboutVersion']!;
  String get settingsCopyAction => _strings['settingsCopyAction']!;
  String get settingsCopySuccess => _strings['settingsCopySuccess']!;
  String get settingsVersionUnknown => _strings['settingsVersionUnknown']!;
  String get settingsCurrenciesTitle => _strings['settingsCurrenciesTitle']!;
  String get settingsCurrenciesAddCustom =>
      _strings['settingsCurrenciesAddCustom']!;
  String get settingsCurrenciesDefaultList =>
      _strings['settingsCurrenciesDefaultList']!;
  String get settingsCurrenciesCustomList =>
      _strings['settingsCurrenciesCustomList']!;
  String get settingsCurrencyCodeLabel =>
      _strings['settingsCurrencyCodeLabel']!;
  String get settingsCurrencyNameLabel =>
      _strings['settingsCurrencyNameLabel']!;
  String get settingsCurrencySymbolLabel =>
      _strings['settingsCurrencySymbolLabel']!;
  String get settingsCurrencyAddAction =>
      _strings['settingsCurrencyAddAction']!;
  String get settingsCurrencyDuplicateError =>
      _strings['settingsCurrencyDuplicateError']!;
  String get settingsCurrencyDeleteConfirm =>
      _strings['settingsCurrencyDeleteConfirm']!;
  String get settingsCurrencyRatesAutoDownload =>
      _strings['settingsCurrencyRatesAutoDownload']!;
  String get settingsCurrencyRatesTitle =>
      _strings['settingsCurrencyRatesTitle']!;
  String get settingsCurrencyRatesEmpty =>
      _strings['settingsCurrencyRatesEmpty']!;
  String get settingsCurrencyRatesSortCurrency =>
      _strings['settingsCurrencyRatesSortCurrency']!;
  String get settingsCurrencyRatesSortDate =>
      _strings['settingsCurrencyRatesSortDate']!;
  String get settingsCurrencyRatesAdd => _strings['settingsCurrencyRatesAdd']!;
  String get settingsCurrencyRatesManualTitle =>
      _strings['settingsCurrencyRatesManualTitle']!;
  String get settingsCurrencyRatesQuoteLabel =>
      _strings['settingsCurrencyRatesQuoteLabel']!;
  String get settingsCurrencyRatesValueLabel =>
      _strings['settingsCurrencyRatesValueLabel']!;
  String get settingsCurrencyRatesDateLabel =>
      _strings['settingsCurrencyRatesDateLabel']!;
  String get settingsLoading => _strings['settingsLoading']!;
  String get settingsClose => _strings['settingsClose']!;
  String get deleteAction => _strings['deleteAction']!;
  String get themeSystem => _strings['themeSystem']!;
  String get themeLight => _strings['themeLight']!;
  String get themeDark => _strings['themeDark']!;
  String get languageSystem => _strings['languageSystem']!;
  String get currencyPickerTitle => _strings['currencyPickerTitle']!;
  String get currencySearchPlaceholder =>
      _strings['currencySearchPlaceholder']!;
  String get currencySearchEmpty => _strings['currencySearchEmpty']!;
  String get newSubscriptionTitle => _strings['newSubscriptionTitle']!;
  String get editSubscriptionTitle => _strings['editSubscriptionTitle']!;
  String get subscriptionNameLabel => _strings['subscriptionNameLabel']!;
  String get subscriptionNamePlaceholder =>
      _strings['subscriptionNamePlaceholder']!;
  String get subscriptionNameError => _strings['subscriptionNameError']!;
  String get amountLabel => _strings['amountLabel']!;
  String get amountPlaceholder => _strings['amountPlaceholder']!;
  String get amountError => _strings['amountError']!;
  String get currencyLabel => _strings['currencyLabel']!;
  String get periodLabel => _strings['periodLabel']!;
  String get purchaseDateLabel => _strings['purchaseDateLabel']!;
  String get purchaseDatePlaceholder => _strings['purchaseDatePlaceholder']!;
  String get purchaseDateError => _strings['purchaseDateError']!;
  String get subscriptionTagLabel => _strings['subscriptionTagLabel']!;
  String get subscriptionTagNone => _strings['subscriptionTagNone']!;
  String get subscriptionDeleteConfirm =>
      _strings['subscriptionDeleteConfirm']!;
  String get subscriptionActiveLabel => _strings['subscriptionActiveLabel']!;
  String get tagPickerTitle => _strings['tagPickerTitle']!;
  String get tagSearchPlaceholder => _strings['tagSearchPlaceholder']!;
  String get tagSearchEmpty => _strings['tagSearchEmpty']!;
  String get nextPaymentLabel => _strings['nextPaymentLabel']!;
  String get nextPaymentPlaceholder => _strings['nextPaymentPlaceholder']!;
  String get addAction => _strings['addAction']!;
  String get done => _strings['done']!;
  String get nextPaymentPrefix => _strings['nextPaymentPrefix']!;
  String get emptyStateTitle => _strings['emptyStateTitle']!;
  String get emptyStateMessage => _strings['emptyStateMessage']!;
  String get subscriptionSearchPlaceholder =>
      _strings['subscriptionSearchPlaceholder']!;
  String get subscriptionSearchEmpty => _strings['subscriptionSearchEmpty']!;
  String baseCurrencyValue(String amount) =>
      _strings['baseCurrencyValue']!.replaceAll('{amount}', amount);
  String get billingCycleMonthly => _strings['billingCycleMonthly']!;
  String get billingCycleQuarterly => _strings['billingCycleQuarterly']!;
  String get billingCycleYearly => _strings['billingCycleYearly']!;
  String get billingCycleDaily => _strings['billingCycleDaily']!;
  String get billingCycleWeekly => _strings['billingCycleWeekly']!;
  String get billingCycleBiweekly => _strings['billingCycleBiweekly']!;
  String get billingCycleFourWeekly => _strings['billingCycleFourWeekly']!;
  String get billingCycleSemiannual => _strings['billingCycleSemiannual']!;
  String get billingCycleMonthlyShort => _strings['billingCycleMonthlyShort']!;
  String get billingCycleQuarterlyShort =>
      _strings['billingCycleQuarterlyShort']!;
  String get billingCycleYearlyShort => _strings['billingCycleYearlyShort']!;
  String get billingCycleDailyShort => _strings['billingCycleDailyShort']!;
  String get billingCycleWeeklyShort => _strings['billingCycleWeeklyShort']!;
  String get billingCycleBiweeklyShort =>
      _strings['billingCycleBiweeklyShort']!;
  String get billingCycleFourWeeklyShort =>
      _strings['billingCycleFourWeeklyShort']!;
  String get billingCycleSemiannualShort =>
      _strings['billingCycleSemiannualShort']!;
  String settingsCurrenciesEnabledLabel(int count) {
    final template = _strings['settingsCurrenciesEnabledLabel'];
    if (template == null) return '$count';
    return template.replaceAll('{count}', '$count');
  }

  static String languageNameForLocale(Locale locale) {
    return _localizedValues[locale.languageCode]?['languageName'] ??
        locale.languageCode;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
