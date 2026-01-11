import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:subctrl/application/currencies/get_currencies_use_case.dart';
import 'package:subctrl/application/currencies/watch_currencies_use_case.dart';
import 'package:subctrl/application/currency_rates/fetch_subscription_rates_use_case.dart';
import 'package:subctrl/application/currency_rates/get_currency_rates_use_case.dart';
import 'package:subctrl/application/currency_rates/save_currency_rates_use_case.dart';
import 'package:subctrl/application/currency_rates/watch_currency_rates_use_case.dart';
import 'package:subctrl/application/notifications/cancel_notifications_use_case.dart';
import 'package:subctrl/application/notifications/get_pending_notifications_use_case.dart';
import 'package:subctrl/application/notifications/schedule_notifications_use_case.dart';
import 'package:subctrl/application/subscriptions/add_subscription_use_case.dart';
import 'package:subctrl/application/subscriptions/delete_subscription_use_case.dart';
import 'package:subctrl/application/subscriptions/refresh_overdue_next_payments_use_case.dart';
import 'package:subctrl/application/subscriptions/update_subscription_use_case.dart';
import 'package:subctrl/application/subscriptions/watch_subscriptions_use_case.dart';
import 'package:subctrl/application/tags/watch_tags_use_case.dart';
import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/entities/notification_reminder_option.dart';
import 'package:subctrl/domain/entities/planned_notification.dart';
import 'package:subctrl/domain/entities/pending_notification.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/entities/tag.dart';
import 'package:subctrl/domain/services/currency_rates_provider.dart';
import 'package:subctrl/domain/services/subscription_notification_planner.dart';
import 'package:subctrl/presentation/formatters/date_formatter.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';

class SubscriptionsViewModel extends ChangeNotifier {
  SubscriptionsViewModel({
    required WatchSubscriptionsUseCase watchSubscriptionsUseCase,
    required AddSubscriptionUseCase addSubscriptionUseCase,
    required UpdateSubscriptionUseCase updateSubscriptionUseCase,
    required DeleteSubscriptionUseCase deleteSubscriptionUseCase,
    required RefreshOverdueNextPaymentsUseCase refreshOverdueNextPaymentsUseCase,
    required WatchCurrenciesUseCase watchCurrenciesUseCase,
    required GetCurrenciesUseCase getCurrenciesUseCase,
    required WatchCurrencyRatesUseCase watchCurrencyRatesUseCase,
    required GetCurrencyRatesUseCase getCurrencyRatesUseCase,
    required SaveCurrencyRatesUseCase saveCurrencyRatesUseCase,
    required FetchSubscriptionRatesUseCase fetchSubscriptionRatesUseCase,
    required WatchTagsUseCase watchTagsUseCase,
    required String? initialBaseCurrencyCode,
    required bool initialAutoDownloadEnabled,
    required GetPendingNotificationsUseCase getPendingNotificationsUseCase,
    required CancelNotificationsUseCase cancelNotificationsUseCase,
    required ScheduleNotificationsUseCase scheduleNotificationsUseCase,
    required bool notificationsEnabled,
    required NotificationReminderOption notificationReminderOption,
    required Locale? initialLocale,
  }) : _watchSubscriptionsUseCase = watchSubscriptionsUseCase,
       _addSubscriptionUseCase = addSubscriptionUseCase,
       _updateSubscriptionUseCase = updateSubscriptionUseCase,
       _deleteSubscriptionUseCase = deleteSubscriptionUseCase,
       _refreshOverdueNextPaymentsUseCase = refreshOverdueNextPaymentsUseCase,
       _watchCurrenciesUseCase = watchCurrenciesUseCase,
       _getCurrenciesUseCase = getCurrenciesUseCase,
       _watchCurrencyRatesUseCase = watchCurrencyRatesUseCase,
       _getCurrencyRatesUseCase = getCurrencyRatesUseCase,
       _saveCurrencyRatesUseCase = saveCurrencyRatesUseCase,
       _fetchSubscriptionRatesUseCase = fetchSubscriptionRatesUseCase,
       _watchTagsUseCase = watchTagsUseCase,
       _getPendingNotificationsUseCase = getPendingNotificationsUseCase,
       _cancelNotificationsUseCase = cancelNotificationsUseCase,
       _scheduleNotificationsUseCase = scheduleNotificationsUseCase,
       _notificationsEnabled = notificationsEnabled,
       _notificationReminderOption = notificationReminderOption,
       _locale = initialLocale {
    _baseCurrencyCode = initialBaseCurrencyCode?.toUpperCase();
    _autoDownloadEnabled = initialAutoDownloadEnabled;
    _listenToSubscriptions();
    _listenToTags();
    _listenToCurrencies();
    _listenToCurrencyRates();
  }

  final WatchSubscriptionsUseCase _watchSubscriptionsUseCase;
  final AddSubscriptionUseCase _addSubscriptionUseCase;
  final UpdateSubscriptionUseCase _updateSubscriptionUseCase;
  final DeleteSubscriptionUseCase _deleteSubscriptionUseCase;
  final RefreshOverdueNextPaymentsUseCase _refreshOverdueNextPaymentsUseCase;
  final WatchCurrenciesUseCase _watchCurrenciesUseCase;
  final GetCurrenciesUseCase _getCurrenciesUseCase;
  final WatchCurrencyRatesUseCase _watchCurrencyRatesUseCase;
  final GetCurrencyRatesUseCase _getCurrencyRatesUseCase;
  final SaveCurrencyRatesUseCase _saveCurrencyRatesUseCase;
  final FetchSubscriptionRatesUseCase _fetchSubscriptionRatesUseCase;
  final WatchTagsUseCase _watchTagsUseCase;
  final GetPendingNotificationsUseCase _getPendingNotificationsUseCase;
  final CancelNotificationsUseCase _cancelNotificationsUseCase;
  final ScheduleNotificationsUseCase _scheduleNotificationsUseCase;

  bool _notificationsEnabled;
  NotificationReminderOption _notificationReminderOption;
  Locale? _locale;

  StreamSubscription<List<Subscription>>? _subscriptionsSubscription;
  StreamSubscription<List<Tag>>? _tagsSubscription;
  StreamSubscription<List<Currency>>? _currenciesSubscription;
  StreamSubscription<List<CurrencyRate>>? _currencyRatesSubscription;

  bool _isLoadingSubscriptions = true;
  bool _isLoadingCurrencies = true;
  bool _isFetchingRates = false;
  bool _autoDownloadEnabled = true;
  bool _isSyncingNotifications = false;
  bool _isUpdatingNextPayments = false;

  List<Subscription> _subscriptions = const [];
  List<Tag> _tags = const [];
  List<Currency> _currencies = const [];
  Map<int, Tag> _tagMap = const {};
  Map<String, Currency> _currencyMap = const {};
  Map<String, CurrencyRate> _rateMap = const {};
  String _searchQuery = '';
  String? _baseCurrencyCode;

  bool get isLoading => _isLoadingSubscriptions;
  bool get isLoadingCurrencies => _isLoadingCurrencies;
  bool get isFetchingRates => _isFetchingRates;
  bool get autoDownloadEnabled => _autoDownloadEnabled;

  String? get baseCurrencyCode => _baseCurrencyCode;

  Currency? get baseCurrency {
    final code = _baseCurrencyCode;
    if (code == null) return null;
    return _currencyMap[code];
  }

  List<Currency> get currencies => _currencies;
  List<Currency> get activeCurrencies =>
      _currencies.where((currency) => currency.isEnabled).toList();

  List<Tag> get tags => _tags;
  Map<int, Tag> get tagMap => _tagMap;
  Map<String, Currency> get currencyMap => _currencyMap;
  Map<String, CurrencyRate> get rateMap => _rateMap;

  String get searchQuery => _searchQuery;

  List<Subscription> get subscriptions => _subscriptions;

  List<Subscription> get filteredSubscriptions {
    final normalized = _searchQuery.trim().toLowerCase();
    if (normalized.isEmpty) {
      return _subscriptions;
    }
    return _subscriptions
        .where(
          (subscription) =>
              subscription.name.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  void updateBaseCurrencyCode(String? code) {
    final normalized = code?.toUpperCase();
    if (_baseCurrencyCode == normalized) return;
    _baseCurrencyCode = normalized;
    _listenToCurrencyRates();
    if (_autoDownloadEnabled) {
      unawaited(_refreshCurrencyRatesForSubscriptions());
    }
    notifyListeners();
  }

  void updateAutoDownloadEnabled(bool value) {
    if (_autoDownloadEnabled == value) return;
    _autoDownloadEnabled = value;
    if (_autoDownloadEnabled) {
      unawaited(_refreshCurrencyRatesForSubscriptions());
    }
    notifyListeners();
  }

  void updateNotificationPreferences({
    required bool notificationsEnabled,
    required NotificationReminderOption reminderOption,
    required Locale? locale,
  }) {
    final shouldSync =
        _notificationsEnabled != notificationsEnabled ||
        _notificationReminderOption != reminderOption ||
        _locale != locale;
    _notificationsEnabled = notificationsEnabled;
    _notificationReminderOption = reminderOption;
    _locale = locale;
    if (shouldSync) {
      unawaited(_syncNotifications());
    }
  }

  Future<void> addSubscription(Subscription subscription) {
    return _addSubscriptionUseCase(subscription);
  }

  Future<void> updateSubscription(Subscription subscription) {
    return _updateSubscriptionUseCase(subscription);
  }

  Future<void> deleteSubscription(int id) {
    return _deleteSubscriptionUseCase(id);
  }

  Future<void> refreshRatesManually() {
    return _refreshCurrencyRatesForSubscriptions();
  }

  Future<void> ensureCurrenciesLoaded() async {
    if (!_isLoadingCurrencies && _currencies.isNotEmpty) {
      return;
    }
    final currencies = await _getCurrenciesUseCase();
    _currencies = currencies;
    _currencyMap = {
      for (final currency in currencies) currency.code.toUpperCase(): currency,
    };
    _isLoadingCurrencies = false;
    notifyListeners();
  }

  void _listenToSubscriptions() {
    _subscriptionsSubscription?.cancel();
    _subscriptionsSubscription = _watchSubscriptionsUseCase().listen((
      subscriptions,
    ) {
      _subscriptions = subscriptions;
      _isLoadingSubscriptions = false;
      notifyListeners();
      unawaited(_refreshOverdueNextPayments(subscriptions));
      if (_autoDownloadEnabled) {
        unawaited(_refreshCurrencyRatesForSubscriptions());
      }
      unawaited(_syncNotifications());
    });
  }

  void _listenToTags() {
    _tagsSubscription?.cancel();
    _tagsSubscription = _watchTagsUseCase().listen((tags) {
      _tags = tags;
      _tagMap = {for (final tag in tags) tag.id: tag};
      notifyListeners();
    });
  }

  void _listenToCurrencies() {
    _currenciesSubscription?.cancel();
    _currenciesSubscription = _watchCurrenciesUseCase().listen((currencies) {
      _currencies = currencies;
      _currencyMap = {
        for (final currency in currencies)
          currency.code.toUpperCase(): currency,
      };
      _isLoadingCurrencies = false;
      notifyListeners();
    });
  }

  void _listenToCurrencyRates() {
    final baseCode = (_baseCurrencyCode ?? 'USD').toUpperCase();
    _currencyRatesSubscription?.cancel();
    _currencyRatesSubscription = _watchCurrencyRatesUseCase(baseCode).listen((
      rates,
    ) {
      _rateMap = _latestRatesFrom(rates);
      notifyListeners();
    });
  }

  Future<void> _refreshCurrencyRatesForSubscriptions() async {
    if (!_autoDownloadEnabled) return;
    final baseCode = _baseCurrencyCode?.toUpperCase();
    if (baseCode == null || _subscriptions.isEmpty) {
      return;
    }
    if (_isFetchingRates) {
      return;
    }
    _isFetchingRates = true;
    try {
      final existingRates = await _getCurrencyRatesUseCase(baseCode);
      final latestExisting = _latestRatesFrom(existingRates);
      final storedQuotes = latestExisting.keys.toSet();
      final subscriptionQuotes = _subscriptions
          .map((subscription) => subscription.currency.toUpperCase())
          .where((code) => code != baseCode)
          .toSet();
      final missingQuotes = subscriptionQuotes.difference(storedQuotes);
      DateTime? latestUpdate;
      for (final entry in latestExisting.values) {
        if (latestUpdate == null ||
            entry.fetchedAt.isAfter(latestUpdate)) {
          latestUpdate = entry.fetchedAt;
        }
      }
      final nowUtc = DateTime.now().toUtc();
      final needsRefresh =
          latestUpdate == null ||
          nowUtc.difference(latestUpdate.toUtc()) >= const Duration(days: 1);
      if (!needsRefresh && missingQuotes.isEmpty) {
        return;
      }
      final rates = await _fetchSubscriptionRatesUseCase(
        baseCurrencyCode: baseCode,
        subscriptions: _subscriptions,
      );
      if (rates.isEmpty) {
        return;
      }
      await _saveCurrencyRatesUseCase(baseCurrencyCode: baseCode, rates: rates);
    } on CurrencyRatesFetchException catch (error, stackTrace) {
      _log(
        'Failed to refresh currency rates: ${error.message}',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      _log(
        'Unexpected error while refreshing currency rates',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isFetchingRates = false;
    }
  }

  Future<void> _refreshOverdueNextPayments(
    List<Subscription> subscriptions,
  ) async {
    if (_isUpdatingNextPayments) {
      return;
    }
    _isUpdatingNextPayments = true;
    try {
      await _refreshOverdueNextPaymentsUseCase(subscriptions);
    } catch (error, stackTrace) {
      _log(
        'Failed to refresh overdue next payments',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isUpdatingNextPayments = false;
    }
  }

  Map<String, CurrencyRate> _latestRatesFrom(List<CurrencyRate> rates) {
    final Map<String, CurrencyRate> result = {};
    for (final rate in rates) {
      final code = rate.quoteCode.toUpperCase();
      final existing = result[code];
      if (existing == null || rate.fetchedAt.isAfter(existing.fetchedAt)) {
        result[code] = rate;
      }
    }
    return result;
  }

  @override
  void dispose() {
    _subscriptionsSubscription?.cancel();
    _tagsSubscription?.cancel();
    _currenciesSubscription?.cancel();
    _currencyRatesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _syncNotifications() async {
    if (_isSyncingNotifications) return;
    _isSyncingNotifications = true;
    try {
      final resolvedLocale =
          _locale ?? WidgetsBinding.instance.platformDispatcher.locale;
      _log(
        'Syncing notifications (enabled: $_notificationsEnabled, reminder: '
        '$_notificationReminderOption, locale: ${resolvedLocale.toLanguageTag()})',
      );
      final List<PendingNotification> pending =
          await _getPendingNotificationsUseCase();
      final managedIds = pending
          .where((request) {
            return SubscriptionNotificationPlanner.isManagedNotificationId(
              request.id,
            );
          })
          .map((request) => request.id)
          .toList(growable: false);
      _log(
        'Found ${pending.length} pending notifications, '
        '${managedIds.length} managed by subctrl',
      );
      if (!_notificationsEnabled) {
        _log('Notifications disabled, canceling managed notifications');
        await _cancelNotificationsUseCase(managedIds);
        return;
      }
      final localizations = AppLocalizations(resolvedLocale);
      final planner = SubscriptionNotificationPlanner();
      final planned = planner.plan(
        subscriptions: _subscriptions,
        reminderOption: _notificationReminderOption,
      );
      await _cancelNotificationsUseCase(managedIds);
      if (planned.isEmpty) {
        _log('Planner returned no notifications to schedule');
        return;
      }
      _log('Planner returned ${planned.length} notifications');
      final subscriptionMap = {
        for (final subscription in _subscriptions)
          if (subscription.id != null) subscription.id!: subscription,
      };
      final notifications = planned
          .map((item) {
            final subscription = subscriptionMap[item.subscriptionId];
            if (subscription == null) return null;
            final formattedDate = formatDate(item.paymentDate, resolvedLocale);
            return PlannedNotification(
              id: item.notificationId,
              title: localizations.notificationReminderTitle,
              body: localizations.notificationReminderBody(
                subscription.name,
                formattedDate,
              ),
              scheduledDate: item.scheduledDate,
              payload:
                  'subctrl:subscription:${item.subscriptionId}:${item.index}'
                  ':${item.paymentDate.toIso8601String()}',
            );
          })
          .whereType<PlannedNotification>()
          .toList(growable: false);
      _log('Scheduling ${notifications.length} notifications');
      await _scheduleNotificationsUseCase(notifications);
    } catch (error, stackTrace) {
      _log(
        'Failed to sync subscription notifications',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isSyncingNotifications = false;
    }
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint('[SubscriptionsViewModel] $message');
    developer.log(
      message,
      name: 'SubscriptionsViewModel',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
