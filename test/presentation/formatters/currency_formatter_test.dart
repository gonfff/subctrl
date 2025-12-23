import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/presentation/formatters/currency_formatter.dart';

void main() {
  test('formatAmountWithCurrency uses symbol when available', () {
    const currency = Currency(
      code: 'usd',
      name: 'US Dollar',
      symbol: r'$',
      isEnabled: true,
      isCustom: false,
    );

    final result = formatAmountWithCurrency(
      12,
      currency.code,
      currency: currency,
    );

    expect(result, '12.00 \$');
  });

  test('formatAmountWithCurrency falls back to code when no symbol', () {
    const currency = Currency(
      code: 'eur',
      name: 'Euro',
      symbol: '',
      isEnabled: true,
      isCustom: false,
    );

    final result = formatAmountWithCurrency(
      3.5,
      currency.code,
      currency: currency,
    );

    expect(result, '3.50 EUR');
  });

  test('currencyDisplayLabel includes code, symbol, and name', () {
    const currency = Currency(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      isEnabled: true,
      isCustom: false,
    );

    final label = currencyDisplayLabel(currency);

    expect(label, 'GBP (£) – British Pound');
  });
}
