import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/application/currency_rates/delete_currency_rate_use_case.dart';
import 'package:subctrl/application/currency_rates/fetch_subscription_rates_use_case.dart';
import 'package:subctrl/application/currency_rates/get_currency_rates_use_case.dart';
import 'package:subctrl/application/currency_rates/save_currency_rates_use_case.dart';
import 'package:subctrl/application/currency_rates/watch_currency_rates_use_case.dart';
import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/repositories/currency_rate_repository.dart';
import 'package:subctrl/domain/services/currency_rates_provider.dart';

class _MockCurrencyRateRepository extends Mock
    implements CurrencyRateRepository {}

class _MockCurrencyRatesProvider extends Mock
    implements CurrencyRatesProvider {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      CurrencyRate(
        baseCode: 'USD',
        quoteCode: 'JPY',
        rate: 140,
        fetchedAt: DateTime(2024, 1, 1),
      ),
    );
    registerFallbackValue(
      Subscription(
        name: 'Test',
        amount: 10,
        currency: 'USD',
        cycle: BillingCycle.monthly,
        purchaseDate: DateTime(2024, 1, 1),
      ),
    );
  });

  late _MockCurrencyRateRepository repository;
  late _MockCurrencyRatesProvider provider;

  setUp(() {
    repository = _MockCurrencyRateRepository();
    provider = _MockCurrencyRatesProvider();
  });

  test('WatchCurrencyRatesUseCase normalizes base code', () async {
    final controller = StreamController<List<CurrencyRate>>();
    when(
      () => repository.watchRates(any()),
    ).thenAnswer((_) => controller.stream);
    final useCase = WatchCurrencyRatesUseCase(repository);
    final expectation = expectLater(useCase('usd'), emitsDone);
    await controller.close();
    await expectation;
    verify(() => repository.watchRates('USD')).called(1);
  });

  test('GetCurrencyRatesUseCase normalizes code before delegating', () async {
    when(() => repository.getRates(any())).thenAnswer((_) async => const []);
    final useCase = GetCurrencyRatesUseCase(repository);
    await useCase('eur');
    verify(() => repository.getRates('EUR')).called(1);
  });

  test('SaveCurrencyRatesUseCase forwards data', () async {
    when(
      () => repository.saveRates(
        baseCode: any(named: 'baseCode'),
        rates: any(named: 'rates'),
      ),
    ).thenAnswer((_) async {});
    final useCase = SaveCurrencyRatesUseCase(repository);
    final rate = CurrencyRate(
      baseCode: 'USD',
      quoteCode: 'CAD',
      rate: 1.33,
      fetchedAt: DateTime.now(),
    );
    await useCase(baseCurrencyCode: 'usd', rates: [rate]);
    verify(
      () => repository.saveRates(baseCode: 'usd', rates: [rate]),
    ).called(1);
  });

  test('DeleteCurrencyRateUseCase forwards arguments', () async {
    when(
      () => repository.deleteRate(
        baseCode: any(named: 'baseCode'),
        quoteCode: any(named: 'quoteCode'),
      ),
    ).thenAnswer((_) async {});
    final useCase = DeleteCurrencyRateUseCase(repository);
    await useCase(baseCurrencyCode: 'usd', quoteCurrencyCode: 'eur');
    verify(
      () => repository.deleteRate(baseCode: 'usd', quoteCode: 'eur'),
    ).called(1);
  });

  test('FetchSubscriptionRatesUseCase delegates to provider', () async {
    when(
      () => provider.fetchRates(
        baseCurrencyCode: any(named: 'baseCurrencyCode'),
        subscriptions: any(named: 'subscriptions'),
      ),
    ).thenAnswer((_) async => const []);
    final useCase = FetchSubscriptionRatesUseCase(provider);
    await useCase(baseCurrencyCode: 'usd', subscriptions: const []);
    verify(
      () =>
          provider.fetchRates(baseCurrencyCode: 'usd', subscriptions: const []),
    ).called(1);
  });
}
