import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/application/currencies/get_currencies_use_case.dart';
import 'package:subctrl/application/currency_rates/delete_currency_rate_use_case.dart';
import 'package:subctrl/application/currency_rates/save_currency_rates_use_case.dart';
import 'package:subctrl/application/currency_rates/watch_currency_rates_use_case.dart';
import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/presentation/viewmodels/currency_rates_view_model.dart';

class _MockWatchCurrencyRatesUseCase extends Mock
    implements WatchCurrencyRatesUseCase {}

class _MockSaveCurrencyRatesUseCase extends Mock
    implements SaveCurrencyRatesUseCase {}

class _MockDeleteCurrencyRateUseCase extends Mock
    implements DeleteCurrencyRateUseCase {}

class _MockGetCurrenciesUseCase extends Mock implements GetCurrenciesUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      CurrencyRate(
        baseCode: 'USD',
        quoteCode: 'EUR',
        rate: 1.1,
        fetchedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  late _MockWatchCurrencyRatesUseCase watchCurrencyRatesUseCase;
  late _MockSaveCurrencyRatesUseCase saveCurrencyRatesUseCase;
  late _MockDeleteCurrencyRateUseCase deleteCurrencyRateUseCase;
  late _MockGetCurrenciesUseCase getCurrenciesUseCase;
  late StreamController<List<CurrencyRate>> ratesController;
  late CurrencyRatesViewModel viewModel;

  setUp(() {
    watchCurrencyRatesUseCase = _MockWatchCurrencyRatesUseCase();
    saveCurrencyRatesUseCase = _MockSaveCurrencyRatesUseCase();
    deleteCurrencyRateUseCase = _MockDeleteCurrencyRateUseCase();
    getCurrenciesUseCase = _MockGetCurrenciesUseCase();
    ratesController = StreamController<List<CurrencyRate>>();

    when(
      () => watchCurrencyRatesUseCase(any()),
    ).thenAnswer((_) => ratesController.stream);
    when(
      () => saveCurrencyRatesUseCase(
        baseCurrencyCode: any(named: 'baseCurrencyCode'),
        rates: any(named: 'rates'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => deleteCurrencyRateUseCase(
        baseCurrencyCode: any(named: 'baseCurrencyCode'),
        quoteCurrencyCode: any(named: 'quoteCurrencyCode'),
      ),
    ).thenAnswer((_) async {});
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

    viewModel = CurrencyRatesViewModel(
      watchCurrencyRatesUseCase: watchCurrencyRatesUseCase,
      saveCurrencyRatesUseCase: saveCurrencyRatesUseCase,
      deleteCurrencyRateUseCase: deleteCurrencyRateUseCase,
      getCurrenciesUseCase: getCurrenciesUseCase,
      baseCurrencyCode: 'usd',
    );
  });

  tearDown(() async {
    await ratesController.close();
    viewModel.dispose();
  });

  test('updates rates when stream emits values', () async {
    final rate = CurrencyRate(
      baseCode: 'USD',
      quoteCode: 'JPY',
      rate: 150,
      fetchedAt: DateTime(2024, 1, 1),
    );
    ratesController.add([rate]);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.rates, equals([rate]));
    expect(viewModel.isLoadingRates, isFalse);
  });

  test('load currencies eagerly and exposes them', () async {
    await Future<void>.delayed(Duration.zero);
    expect(viewModel.currencies, isNotEmpty);
    expect(viewModel.isLoadingCurrencies, isFalse);
  });

  test('addManualRate and deleteRate delegate to use cases', () async {
    final rate = CurrencyRate(
      baseCode: 'USD',
      quoteCode: 'CAD',
      rate: 1.3,
      fetchedAt: DateTime.now(),
    );
    await viewModel.addManualRate(rate);
    verify(
      () => saveCurrencyRatesUseCase(baseCurrencyCode: 'USD', rates: [rate]),
    ).called(1);

    await viewModel.deleteRate('CAD');
    verify(
      () => deleteCurrencyRateUseCase(
        baseCurrencyCode: 'USD',
        quoteCurrencyCode: 'CAD',
      ),
    ).called(1);
  });
}
