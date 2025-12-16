import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/application/currencies/add_custom_currency_use_case.dart';
import 'package:subctrl/application/currencies/delete_custom_currency_use_case.dart';
import 'package:subctrl/application/currencies/set_currency_enabled_use_case.dart';
import 'package:subctrl/application/currencies/watch_currencies_use_case.dart';
import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/presentation/viewmodels/currency_settings_view_model.dart';

class _MockWatchCurrenciesUseCase extends Mock
    implements WatchCurrenciesUseCase {}

class _MockSetCurrencyEnabledUseCase extends Mock
    implements SetCurrencyEnabledUseCase {}

class _MockAddCustomCurrencyUseCase extends Mock
    implements AddCustomCurrencyUseCase {}

class _MockDeleteCustomCurrencyUseCase extends Mock
    implements DeleteCustomCurrencyUseCase {}

void main() {
  late _MockWatchCurrenciesUseCase watchCurrenciesUseCase;
  late _MockSetCurrencyEnabledUseCase setCurrencyEnabledUseCase;
  late _MockAddCustomCurrencyUseCase addCustomCurrencyUseCase;
  late _MockDeleteCustomCurrencyUseCase deleteCustomCurrencyUseCase;
  late StreamController<List<Currency>> controller;
  late CurrencySettingsViewModel viewModel;

  setUp(() {
    watchCurrenciesUseCase = _MockWatchCurrenciesUseCase();
    setCurrencyEnabledUseCase = _MockSetCurrencyEnabledUseCase();
    addCustomCurrencyUseCase = _MockAddCustomCurrencyUseCase();
    deleteCustomCurrencyUseCase = _MockDeleteCustomCurrencyUseCase();
    controller = StreamController<List<Currency>>();

    when(() => watchCurrenciesUseCase()).thenAnswer((_) => controller.stream);
    when(
      () => setCurrencyEnabledUseCase(
        code: any(named: 'code'),
        isEnabled: any(named: 'isEnabled'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => addCustomCurrencyUseCase(
        code: any(named: 'code'),
        name: any(named: 'name'),
        symbol: any(named: 'symbol'),
      ),
    ).thenAnswer(
      (_) async => const Currency(
        code: 'BTC',
        name: 'Bitcoin',
        symbol: '₿',
        isEnabled: true,
        isCustom: true,
      ),
    );
    when(() => deleteCustomCurrencyUseCase(any())).thenAnswer((_) async {});

    viewModel = CurrencySettingsViewModel(
      watchCurrenciesUseCase: watchCurrenciesUseCase,
      setCurrencyEnabledUseCase: setCurrencyEnabledUseCase,
      addCustomCurrencyUseCase: addCustomCurrencyUseCase,
      deleteCustomCurrencyUseCase: deleteCustomCurrencyUseCase,
    );
  });

  tearDown(() async {
    await controller.close();
    viewModel.dispose();
  });

  test('exposes currencies emitted by the watch use case', () async {
    final usd = Currency(
      code: 'USD',
      name: 'US Dollar',
      symbol: r'$',
      isEnabled: true,
      isCustom: false,
    );
    controller.add([usd]);
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.currencies, equals([usd]));
    expect(viewModel.isLoading, isFalse);
  });

  test('toggleCurrency delegates to setCurrencyEnabled use case', () async {
    await viewModel.toggleCurrency(code: 'EUR', isEnabled: false);

    verify(
      () => setCurrencyEnabledUseCase(code: 'EUR', isEnabled: false),
    ).called(1);
  });
}
