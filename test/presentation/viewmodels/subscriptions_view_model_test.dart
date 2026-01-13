import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
import 'package:subctrl/presentation/viewmodels/subscriptions_view_model.dart';

class _MockWatchSubscriptionsUseCase extends Mock
    implements WatchSubscriptionsUseCase {}

class _MockAddSubscriptionUseCase extends Mock
    implements AddSubscriptionUseCase {}

class _MockUpdateSubscriptionUseCase extends Mock
    implements UpdateSubscriptionUseCase {}

class _MockDeleteSubscriptionUseCase extends Mock
    implements DeleteSubscriptionUseCase {}

class _MockRefreshOverdueNextPaymentsUseCase extends Mock
    implements RefreshOverdueNextPaymentsUseCase {}

class _MockWatchCurrenciesUseCase extends Mock
    implements WatchCurrenciesUseCase {}

class _MockGetCurrenciesUseCase extends Mock implements GetCurrenciesUseCase {}

class _MockWatchCurrencyRatesUseCase extends Mock
    implements WatchCurrencyRatesUseCase {}

class _MockGetCurrencyRatesUseCase extends Mock
    implements GetCurrencyRatesUseCase {}

class _MockSaveCurrencyRatesUseCase extends Mock
    implements SaveCurrencyRatesUseCase {}

class _MockFetchSubscriptionRatesUseCase extends Mock
    implements FetchSubscriptionRatesUseCase {}

class _MockWatchTagsUseCase extends Mock implements WatchTagsUseCase {}

class _MockGetPendingNotificationsUseCase extends Mock
    implements GetPendingNotificationsUseCase {}

class _MockCancelNotificationsUseCase extends Mock
    implements CancelNotificationsUseCase {}

class _MockScheduleNotificationsUseCase extends Mock
    implements ScheduleNotificationsUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Subscription(
        name: 'Fallback',
        amount: 0,
        currency: 'USD',
        cycle: BillingCycle.monthly,
        purchaseDate: DateTime(2024, 1, 1),
      ),
    );
    registerFallbackValue(<PlannedNotification>[]);
    registerFallbackValue(<int>[]);
  });

  late _MockWatchSubscriptionsUseCase watchSubscriptionsUseCase;
  late _MockAddSubscriptionUseCase addSubscriptionUseCase;
  late _MockUpdateSubscriptionUseCase updateSubscriptionUseCase;
  late _MockDeleteSubscriptionUseCase deleteSubscriptionUseCase;
  late _MockRefreshOverdueNextPaymentsUseCase refreshOverdueNextPaymentsUseCase;
  late _MockWatchCurrenciesUseCase watchCurrenciesUseCase;
  late _MockGetCurrenciesUseCase getCurrenciesUseCase;
  late _MockWatchCurrencyRatesUseCase watchCurrencyRatesUseCase;
  late _MockGetCurrencyRatesUseCase getCurrencyRatesUseCase;
  late _MockSaveCurrencyRatesUseCase saveCurrencyRatesUseCase;
  late _MockFetchSubscriptionRatesUseCase fetchSubscriptionRatesUseCase;
  late _MockWatchTagsUseCase watchTagsUseCase;
  late _MockGetPendingNotificationsUseCase getPendingNotificationsUseCase;
  late _MockCancelNotificationsUseCase cancelNotificationsUseCase;
  late _MockScheduleNotificationsUseCase scheduleNotificationsUseCase;

  late StreamController<List<Subscription>> subscriptionsController;
  late StreamController<List<Tag>> tagsController;
  late StreamController<List<Currency>> currenciesController;
  late StreamController<List<CurrencyRate>> ratesController;
  late SubscriptionsViewModel viewModel;

  setUp(() {
    watchSubscriptionsUseCase = _MockWatchSubscriptionsUseCase();
    addSubscriptionUseCase = _MockAddSubscriptionUseCase();
    updateSubscriptionUseCase = _MockUpdateSubscriptionUseCase();
    deleteSubscriptionUseCase = _MockDeleteSubscriptionUseCase();
    refreshOverdueNextPaymentsUseCase =
        _MockRefreshOverdueNextPaymentsUseCase();
    watchCurrenciesUseCase = _MockWatchCurrenciesUseCase();
    getCurrenciesUseCase = _MockGetCurrenciesUseCase();
    watchCurrencyRatesUseCase = _MockWatchCurrencyRatesUseCase();
    getCurrencyRatesUseCase = _MockGetCurrencyRatesUseCase();
    saveCurrencyRatesUseCase = _MockSaveCurrencyRatesUseCase();
    fetchSubscriptionRatesUseCase = _MockFetchSubscriptionRatesUseCase();
    watchTagsUseCase = _MockWatchTagsUseCase();
    getPendingNotificationsUseCase = _MockGetPendingNotificationsUseCase();
    cancelNotificationsUseCase = _MockCancelNotificationsUseCase();
    scheduleNotificationsUseCase = _MockScheduleNotificationsUseCase();

    subscriptionsController = StreamController<List<Subscription>>.broadcast();
    tagsController = StreamController<List<Tag>>.broadcast();
    currenciesController = StreamController<List<Currency>>.broadcast();
    ratesController = StreamController<List<CurrencyRate>>.broadcast();

    when(
      () => watchSubscriptionsUseCase(),
    ).thenAnswer((_) => subscriptionsController.stream);
    when(() => watchTagsUseCase()).thenAnswer((_) => tagsController.stream);
    when(
      () => watchCurrenciesUseCase(),
    ).thenAnswer((_) => currenciesController.stream);
    when(
      () => watchCurrencyRatesUseCase(any()),
    ).thenAnswer((_) => ratesController.stream);
    when(() => getCurrenciesUseCase()).thenAnswer((_) async => const []);
    when(
      () => getCurrencyRatesUseCase(any()),
    ).thenAnswer((_) async => const []);
    when(
      () => getPendingNotificationsUseCase(),
    ).thenAnswer((_) async => const <PendingNotification>[]);
    when(
      () => cancelNotificationsUseCase(any()),
    ).thenAnswer((_) async {});
    when(
      () => scheduleNotificationsUseCase(any()),
    ).thenAnswer((_) async {});
    when(
      () => saveCurrencyRatesUseCase(
        baseCurrencyCode: any(named: 'baseCurrencyCode'),
        rates: any(named: 'rates'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => fetchSubscriptionRatesUseCase(
        baseCurrencyCode: any(named: 'baseCurrencyCode'),
        subscriptions: any(named: 'subscriptions'),
      ),
    ).thenAnswer((_) async => const []);
    when(() => addSubscriptionUseCase(any())).thenAnswer((_) async {});
    when(() => updateSubscriptionUseCase(any())).thenAnswer((_) async {});
    when(() => deleteSubscriptionUseCase(any())).thenAnswer((_) async {});
    when(
      () => refreshOverdueNextPaymentsUseCase(any()),
    ).thenAnswer((_) async {});

    viewModel = SubscriptionsViewModel(
      watchSubscriptionsUseCase: watchSubscriptionsUseCase,
      addSubscriptionUseCase: addSubscriptionUseCase,
      updateSubscriptionUseCase: updateSubscriptionUseCase,
      deleteSubscriptionUseCase: deleteSubscriptionUseCase,
      refreshOverdueNextPaymentsUseCase: refreshOverdueNextPaymentsUseCase,
      watchCurrenciesUseCase: watchCurrenciesUseCase,
      getCurrenciesUseCase: getCurrenciesUseCase,
      watchCurrencyRatesUseCase: watchCurrencyRatesUseCase,
      getCurrencyRatesUseCase: getCurrencyRatesUseCase,
      saveCurrencyRatesUseCase: saveCurrencyRatesUseCase,
      fetchSubscriptionRatesUseCase: fetchSubscriptionRatesUseCase,
      watchTagsUseCase: watchTagsUseCase,
      initialBaseCurrencyCode: 'USD',
      initialAutoDownloadEnabled: false,
      getPendingNotificationsUseCase: getPendingNotificationsUseCase,
      cancelNotificationsUseCase: cancelNotificationsUseCase,
      scheduleNotificationsUseCase: scheduleNotificationsUseCase,
      notificationsEnabled: false,
      notificationReminderOption: NotificationReminderOption.sameDay,
      initialLocale: const Locale('en'),
    );
  });

  tearDown(() async {
    await subscriptionsController.close();
    await tagsController.close();
    await currenciesController.close();
    await ratesController.close();
    viewModel.dispose();
  });

  test('filters subscriptions by search query', () async {
    final netflix = Subscription(
      name: 'Netflix',
      amount: 15,
      currency: 'usd',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
    );
    final spotify = Subscription(
      name: 'Spotify',
      amount: 10,
      currency: 'usd',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
    );
    subscriptionsController.add([netflix, spotify]);
    tagsController.add(const []);
    currenciesController.add(const [
      Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: r'$',
        isEnabled: true,
        isCustom: false,
      ),
    ]);
    ratesController.add(const []);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.filteredSubscriptions, hasLength(2));
    viewModel.setSearchQuery('net');
    expect(viewModel.filteredSubscriptions, equals([netflix]));
  });

  test('ensureCurrenciesLoaded fetches when stream has no data yet', () async {
    when(() => getCurrenciesUseCase()).thenAnswer(
      (_) async => const [
        Currency(
          code: 'USD',
          name: 'US Dollar',
          symbol: r'$',
          isEnabled: true,
          isCustom: false,
        ),
      ],
    );

    await viewModel.ensureCurrenciesLoaded();

    verify(() => getCurrenciesUseCase()).called(1);
    expect(viewModel.currencies, isNotEmpty);
    expect(viewModel.isLoadingCurrencies, isFalse);
  });

  test('triggers overdue next payment refresh on updates', () async {
    final subscription = Subscription(
      id: 1,
      name: 'Overdue',
      amount: 5,
      currency: 'usd',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
    );
    subscriptionsController.add([subscription]);
    tagsController.add(const []);
    currenciesController.add(const []);
    ratesController.add(const []);
    await Future<void>.delayed(Duration.zero);

    verify(
      () => refreshOverdueNextPaymentsUseCase(
        any(that: predicate<List<Subscription>>((subs) => subs.length == 1)),
      ),
    ).called(1);
  });

  test('refreshOverdueNextPayments uses current subscriptions', () async {
    final subscription = Subscription(
      id: 2,
      name: 'HBO',
      amount: 12,
      currency: 'usd',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
    );
    subscriptionsController.add([subscription]);
    tagsController.add(const []);
    currenciesController.add(const []);
    ratesController.add(const []);
    await Future<void>.delayed(Duration.zero);

    clearInteractions(refreshOverdueNextPaymentsUseCase);
    await viewModel.refreshOverdueNextPayments();

    verify(
      () => refreshOverdueNextPaymentsUseCase(
        any(that: predicate<List<Subscription>>((subs) => subs.length == 1)),
      ),
    ).called(1);
  });

  test('updateBaseCurrencyCode re-listens to currency rates stream', () async {
    viewModel.updateBaseCurrencyCode('eur');
    await Future<void>.delayed(Duration.zero);
    verify(() => watchCurrencyRatesUseCase('EUR')).called(1);
  });

  test(
    'updateAutoDownloadEnabled triggers rate refresh when enabling',
    () async {
      final subscription = Subscription(
        name: 'Prime',
        amount: 15,
        currency: 'eur',
        cycle: BillingCycle.monthly,
        purchaseDate: DateTime(2024, 1, 1),
      );
      subscriptionsController.add([subscription]);
      when(
        () => getCurrencyRatesUseCase(any()),
      ).thenAnswer((_) async => const []);
      final newRate = CurrencyRate(
        baseCode: 'USD',
        quoteCode: 'EUR',
        rate: 1.1,
        fetchedAt: DateTime.now(),
      );
      when(
        () => fetchSubscriptionRatesUseCase(
          baseCurrencyCode: any(named: 'baseCurrencyCode'),
          subscriptions: any(named: 'subscriptions'),
        ),
      ).thenAnswer((_) async => [newRate]);

      viewModel.updateAutoDownloadEnabled(true);
      await Future<void>.delayed(Duration.zero);

      verify(
        () => fetchSubscriptionRatesUseCase(
          baseCurrencyCode: 'USD',
          subscriptions: any(named: 'subscriptions'),
        ),
      ).called(1);
      verify(
        () =>
            saveCurrencyRatesUseCase(baseCurrencyCode: 'USD', rates: [newRate]),
      ).called(1);
    },
  );

  test('exposed mutation methods delegate to respective use cases', () async {
    final subscription = Subscription(
      name: 'Disney',
      amount: 9,
      currency: 'usd',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
    );

    await viewModel.addSubscription(subscription);
    verify(() => addSubscriptionUseCase(subscription)).called(1);

    await viewModel.updateSubscription(subscription);
    verify(() => updateSubscriptionUseCase(subscription)).called(1);

    await viewModel.deleteSubscription(1);
    verify(() => deleteSubscriptionUseCase(1)).called(1);
  });

  test('refreshRatesManually fetches and saves when needed', () async {
    viewModel.dispose();
    viewModel = SubscriptionsViewModel(
      watchSubscriptionsUseCase: watchSubscriptionsUseCase,
      addSubscriptionUseCase: addSubscriptionUseCase,
      updateSubscriptionUseCase: updateSubscriptionUseCase,
      deleteSubscriptionUseCase: deleteSubscriptionUseCase,
      refreshOverdueNextPaymentsUseCase: refreshOverdueNextPaymentsUseCase,
      watchCurrenciesUseCase: watchCurrenciesUseCase,
      getCurrenciesUseCase: getCurrenciesUseCase,
      watchCurrencyRatesUseCase: watchCurrencyRatesUseCase,
      getCurrencyRatesUseCase: getCurrencyRatesUseCase,
      saveCurrencyRatesUseCase: saveCurrencyRatesUseCase,
      fetchSubscriptionRatesUseCase: fetchSubscriptionRatesUseCase,
      watchTagsUseCase: watchTagsUseCase,
      initialBaseCurrencyCode: 'USD',
      initialAutoDownloadEnabled: true,
      getPendingNotificationsUseCase: getPendingNotificationsUseCase,
      cancelNotificationsUseCase: cancelNotificationsUseCase,
      scheduleNotificationsUseCase: scheduleNotificationsUseCase,
      notificationsEnabled: false,
      notificationReminderOption: NotificationReminderOption.sameDay,
      initialLocale: const Locale('en'),
    );
    final subscription = Subscription(
      name: 'Apple TV',
      amount: 7,
      currency: 'eur',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
    );
    subscriptionsController.add([subscription]);
    tagsController.add(const []);
    currenciesController.add(const []);
    ratesController.add(const []);
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.subscriptions, hasLength(1));
    when(
      () => getCurrencyRatesUseCase(any()),
    ).thenAnswer((_) async => const []);
    final fetched = CurrencyRate(
      baseCode: 'USD',
      quoteCode: 'EUR',
      rate: 1.05,
      fetchedAt: DateTime.now(),
    );
    when(
      () => fetchSubscriptionRatesUseCase(
        baseCurrencyCode: any(named: 'baseCurrencyCode'),
        subscriptions: any(named: 'subscriptions'),
      ),
    ).thenAnswer((_) async => [fetched]);

    clearInteractions(fetchSubscriptionRatesUseCase);
    clearInteractions(saveCurrencyRatesUseCase);
    await viewModel.refreshRatesManually();

    verify(
      () => fetchSubscriptionRatesUseCase(
        baseCurrencyCode: 'USD',
        subscriptions: any(named: 'subscriptions'),
      ),
    ).called(1);
    verify(
      () => saveCurrencyRatesUseCase(baseCurrencyCode: 'USD', rates: [fetched]),
    ).called(1);
  });
}
