import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/infrastructure/currency/yahoo_finance_client.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  late _MockHttpClient httpClient;
  late YahooFinanceCurrencyClient client;

  setUp(() {
    httpClient = _MockHttpClient();
    client = YahooFinanceCurrencyClient(httpClient: httpClient);
  });

  tearDown(() {
    client.close();
  });

  test('fetchRates returns parsed rates from Yahoo response', () async {
    when(
      () => httpClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.first as Uri;
      if (uri.host == 'fc.yahoo.com') {
        return http.Response(
          '',
          200,
          headers: {'set-cookie': 'session=ABCDEFGHIJKLMNOPQRST; Path=/'},
        );
      }
      if (uri.path == '/v1/test/getcrumb') {
        return http.Response('crumb-token', 200);
      }
      final body = jsonEncode({
        'quoteResponse': {
          'result': [
            {
              'symbol': 'EURUSD=X',
              'regularMarketPrice': 1.1,
              'regularMarketTime': 1700000000,
            },
          ],
        },
      });
      return http.Response(body, 200);
    });

    final rates = await client.fetchRates(
      baseCode: 'usd',
      quoteCodes: const ['eur'],
    );

    expect(rates, hasLength(1));
    expect(rates.first.baseCode, 'USD');
    expect(rates.first.quoteCode, 'EUR');
    verify(
      () => httpClient.get(any(), headers: any(named: 'headers')),
    ).called(greaterThanOrEqualTo(3));
  });
}
