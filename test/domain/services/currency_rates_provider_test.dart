import 'package:flutter_test/flutter_test.dart';
import 'package:subctrl/domain/services/currency_rates_provider.dart';

void main() {
  test('CurrencyRatesFetchException exposes readable message', () {
    final exception = CurrencyRatesFetchException('oops');
    expect(exception.toString(), 'CurrencyRatesFetchException: oops');
  });
}
