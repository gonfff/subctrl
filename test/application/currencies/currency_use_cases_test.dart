import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/application/currencies/add_custom_currency_use_case.dart';
import 'package:subctrl/application/currencies/delete_custom_currency_use_case.dart';
import 'package:subctrl/application/currencies/get_currencies_use_case.dart';
import 'package:subctrl/application/currencies/set_currency_enabled_use_case.dart';
import 'package:subctrl/application/currencies/watch_currencies_use_case.dart';
import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/domain/repositories/currency_repository.dart';

class _MockCurrencyRepository extends Mock implements CurrencyRepository {}

void main() {
  late _MockCurrencyRepository repository;

  setUp(() {
    repository = _MockCurrencyRepository();
  });

  test('GetCurrenciesUseCase seeds before fetching', () async {
    when(repository.seedIfEmpty).thenAnswer((_) async {});
    when(() => repository.getCurrencies(onlyEnabled: true)).thenAnswer(
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
    final useCase = GetCurrenciesUseCase(repository);
    final result = await useCase(onlyEnabled: true);
    expect(result, hasLength(1));
    verify(repository.seedIfEmpty).called(1);
    verify(() => repository.getCurrencies(onlyEnabled: true)).called(1);
  });

  test('WatchCurrenciesUseCase seeds then yields stream', () async {
    when(repository.seedIfEmpty).thenAnswer((_) async {});
    final controller = StreamController<List<Currency>>();
    when(
      () => repository.watchCurrencies(onlyEnabled: false),
    ).thenAnswer((_) => controller.stream);
    final useCase = WatchCurrenciesUseCase(repository);
    final currency = const Currency(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      isEnabled: true,
      isCustom: false,
    );
    final expectation = expectLater(
      useCase(),
      emitsInOrder([
        [currency],
      ]),
    );
    controller.add([currency]);
    await controller.close();
    await expectation;
    verify(repository.seedIfEmpty).called(1);
  });

  test('SetCurrencyEnabledUseCase forwards normalized code', () async {
    when(
      () => repository.setCurrencyEnabled(any(), any()),
    ).thenAnswer((_) async {});
    final useCase = SetCurrencyEnabledUseCase(repository);
    await useCase(code: 'eur', isEnabled: false);
    verify(() => repository.setCurrencyEnabled('eur', false)).called(1);
  });

  test('AddCustomCurrencyUseCase delegates to repository', () async {
    when(
      () => repository.addCustomCurrency(
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
    final useCase = AddCustomCurrencyUseCase(repository);
    final result = await useCase(code: 'btc', name: 'Bitcoin', symbol: '₿');
    expect(result.code, 'BTC');
    verify(
      () => repository.addCustomCurrency(
        code: 'btc',
        name: 'Bitcoin',
        symbol: '₿',
      ),
    ).called(1);
  });

  test('DeleteCustomCurrencyUseCase delegates to repository', () async {
    when(() => repository.deleteCustomCurrency(any())).thenAnswer((_) async {});
    final useCase = DeleteCustomCurrencyUseCase(repository);
    await useCase('gbp');
    verify(() => repository.deleteCustomCurrency('gbp')).called(1);
  });
}
