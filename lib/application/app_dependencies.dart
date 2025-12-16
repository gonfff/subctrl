import 'package:subtrackr/application/currencies/add_custom_currency_use_case.dart';
import 'package:subtrackr/application/currencies/delete_custom_currency_use_case.dart';
import 'package:subtrackr/application/currencies/get_currencies_use_case.dart';
import 'package:subtrackr/application/currencies/set_currency_enabled_use_case.dart';
import 'package:subtrackr/application/currencies/watch_currencies_use_case.dart';
import 'package:subtrackr/application/currency_rates/delete_currency_rate_use_case.dart';
import 'package:subtrackr/application/currency_rates/fetch_subscription_rates_use_case.dart';
import 'package:subtrackr/application/currency_rates/get_currency_rates_use_case.dart';
import 'package:subtrackr/application/currency_rates/save_currency_rates_use_case.dart';
import 'package:subtrackr/application/currency_rates/watch_currency_rates_use_case.dart';
import 'package:subtrackr/application/settings/get_base_currency_code_use_case.dart';
import 'package:subtrackr/application/settings/get_currency_rates_auto_download_use_case.dart';
import 'package:subtrackr/application/settings/get_locale_code_use_case.dart';
import 'package:subtrackr/application/settings/get_theme_preference_use_case.dart';
import 'package:subtrackr/application/settings/set_base_currency_code_use_case.dart';
import 'package:subtrackr/application/settings/set_currency_rates_auto_download_use_case.dart';
import 'package:subtrackr/application/settings/set_locale_code_use_case.dart';
import 'package:subtrackr/application/settings/set_theme_preference_use_case.dart';
import 'package:subtrackr/application/subscriptions/add_subscription_use_case.dart';
import 'package:subtrackr/application/subscriptions/delete_subscription_use_case.dart';
import 'package:subtrackr/application/subscriptions/update_subscription_use_case.dart';
import 'package:subtrackr/application/subscriptions/watch_subscriptions_use_case.dart';
import 'package:subtrackr/application/tags/create_tag_use_case.dart';
import 'package:subtrackr/application/tags/delete_tag_use_case.dart';
import 'package:subtrackr/application/tags/update_tag_use_case.dart';
import 'package:subtrackr/application/tags/watch_tags_use_case.dart';
import 'package:subtrackr/infrastructure/currency/subscription_currency_rates_client.dart';
import 'package:subtrackr/infrastructure/currency/yahoo_finance_client.dart';
import 'package:subtrackr/infrastructure/persistence/database.dart';
import 'package:subtrackr/infrastructure/repositories/drift_currency_rate_repository.dart';
import 'package:subtrackr/infrastructure/repositories/drift_currency_repository.dart';
import 'package:subtrackr/infrastructure/repositories/drift_settings_repository.dart';
import 'package:subtrackr/infrastructure/repositories/drift_subscription_repository.dart';
import 'package:subtrackr/infrastructure/repositories/drift_tag_repository.dart';

class AppDependencies {
  AppDependencies._({
    required this.watchSubscriptionsUseCase,
    required this.addSubscriptionUseCase,
    required this.updateSubscriptionUseCase,
    required this.deleteSubscriptionUseCase,
    required this.watchCurrenciesUseCase,
    required this.getCurrenciesUseCase,
    required this.setCurrencyEnabledUseCase,
    required this.addCustomCurrencyUseCase,
    required this.deleteCustomCurrencyUseCase,
    required this.watchCurrencyRatesUseCase,
    required this.getCurrencyRatesUseCase,
    required this.saveCurrencyRatesUseCase,
    required this.deleteCurrencyRateUseCase,
    required this.fetchSubscriptionRatesUseCase,
    required this.watchTagsUseCase,
    required this.createTagUseCase,
    required this.updateTagUseCase,
    required this.deleteTagUseCase,
    required this.getBaseCurrencyCodeUseCase,
    required this.setBaseCurrencyCodeUseCase,
    required this.getThemePreferenceUseCase,
    required this.setThemePreferenceUseCase,
    required this.getLocaleCodeUseCase,
    required this.setLocaleCodeUseCase,
    required this.getCurrencyRatesAutoDownloadUseCase,
    required this.setCurrencyRatesAutoDownloadUseCase,
    required YahooFinanceCurrencyClient yahooFinanceCurrencyClient,
  }) : _yahooFinanceCurrencyClient = yahooFinanceCurrencyClient;

  factory AppDependencies() {
    final database = AppDatabase();
    final subscriptionRepository = DriftSubscriptionRepository(database);
    final currencyRepository = DriftCurrencyRepository(database);
    final currencyRateRepository = DriftCurrencyRateRepository(database);
    final tagRepository = DriftTagRepository(database);
    final settingsRepository = DriftSettingsRepository(database);
    final yahooFinanceClient = YahooFinanceCurrencyClient();
    final subscriptionRatesClient = SubscriptionCurrencyRatesClient(
      yahooFinanceCurrencyClient: yahooFinanceClient,
      currencyRepository: currencyRepository,
    );

    return AppDependencies._(
      watchSubscriptionsUseCase:
          WatchSubscriptionsUseCase(subscriptionRepository),
      addSubscriptionUseCase: AddSubscriptionUseCase(subscriptionRepository),
      updateSubscriptionUseCase:
          UpdateSubscriptionUseCase(subscriptionRepository),
      deleteSubscriptionUseCase:
          DeleteSubscriptionUseCase(subscriptionRepository),
      watchCurrenciesUseCase: WatchCurrenciesUseCase(currencyRepository),
      getCurrenciesUseCase: GetCurrenciesUseCase(currencyRepository),
      setCurrencyEnabledUseCase:
          SetCurrencyEnabledUseCase(currencyRepository),
      addCustomCurrencyUseCase: AddCustomCurrencyUseCase(currencyRepository),
      deleteCustomCurrencyUseCase:
          DeleteCustomCurrencyUseCase(currencyRepository),
      watchCurrencyRatesUseCase:
          WatchCurrencyRatesUseCase(currencyRateRepository),
      getCurrencyRatesUseCase:
          GetCurrencyRatesUseCase(currencyRateRepository),
      saveCurrencyRatesUseCase:
          SaveCurrencyRatesUseCase(currencyRateRepository),
      deleteCurrencyRateUseCase:
          DeleteCurrencyRateUseCase(currencyRateRepository),
      fetchSubscriptionRatesUseCase:
          FetchSubscriptionRatesUseCase(subscriptionRatesClient),
      watchTagsUseCase: WatchTagsUseCase(tagRepository),
      createTagUseCase: CreateTagUseCase(tagRepository),
      updateTagUseCase: UpdateTagUseCase(tagRepository),
      deleteTagUseCase: DeleteTagUseCase(tagRepository),
      getBaseCurrencyCodeUseCase:
          GetBaseCurrencyCodeUseCase(settingsRepository),
      setBaseCurrencyCodeUseCase:
          SetBaseCurrencyCodeUseCase(settingsRepository),
      getThemePreferenceUseCase:
          GetThemePreferenceUseCase(settingsRepository),
      setThemePreferenceUseCase:
          SetThemePreferenceUseCase(settingsRepository),
      getLocaleCodeUseCase: GetLocaleCodeUseCase(settingsRepository),
      setLocaleCodeUseCase: SetLocaleCodeUseCase(settingsRepository),
      getCurrencyRatesAutoDownloadUseCase:
          GetCurrencyRatesAutoDownloadUseCase(settingsRepository),
      setCurrencyRatesAutoDownloadUseCase:
          SetCurrencyRatesAutoDownloadUseCase(settingsRepository),
      yahooFinanceCurrencyClient: yahooFinanceClient,
    );
  }

  final WatchSubscriptionsUseCase watchSubscriptionsUseCase;
  final AddSubscriptionUseCase addSubscriptionUseCase;
  final UpdateSubscriptionUseCase updateSubscriptionUseCase;
  final DeleteSubscriptionUseCase deleteSubscriptionUseCase;

  final WatchCurrenciesUseCase watchCurrenciesUseCase;
  final GetCurrenciesUseCase getCurrenciesUseCase;
  final SetCurrencyEnabledUseCase setCurrencyEnabledUseCase;
  final AddCustomCurrencyUseCase addCustomCurrencyUseCase;
  final DeleteCustomCurrencyUseCase deleteCustomCurrencyUseCase;

  final WatchCurrencyRatesUseCase watchCurrencyRatesUseCase;
  final GetCurrencyRatesUseCase getCurrencyRatesUseCase;
  final SaveCurrencyRatesUseCase saveCurrencyRatesUseCase;
  final DeleteCurrencyRateUseCase deleteCurrencyRateUseCase;
  final FetchSubscriptionRatesUseCase fetchSubscriptionRatesUseCase;

  final WatchTagsUseCase watchTagsUseCase;
  final CreateTagUseCase createTagUseCase;
  final UpdateTagUseCase updateTagUseCase;
  final DeleteTagUseCase deleteTagUseCase;

  final GetBaseCurrencyCodeUseCase getBaseCurrencyCodeUseCase;
  final SetBaseCurrencyCodeUseCase setBaseCurrencyCodeUseCase;
  final GetThemePreferenceUseCase getThemePreferenceUseCase;
  final SetThemePreferenceUseCase setThemePreferenceUseCase;
  final GetLocaleCodeUseCase getLocaleCodeUseCase;
  final SetLocaleCodeUseCase setLocaleCodeUseCase;
  final GetCurrencyRatesAutoDownloadUseCase
      getCurrencyRatesAutoDownloadUseCase;
  final SetCurrencyRatesAutoDownloadUseCase
      setCurrencyRatesAutoDownloadUseCase;

  final YahooFinanceCurrencyClient _yahooFinanceCurrencyClient;

  void dispose() {
    _yahooFinanceCurrencyClient.close();
  }
}
