import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/infrastructure/currency/proxy_currency_client.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  late _MockHttpClient httpClient;
  late ProxyCurrencyRatesClient client;

  setUp(() {
    httpClient = _MockHttpClient();
    client = ProxyCurrencyRatesClient(
      baseUrl: 'https://proxy.example.com',
      httpClient: httpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  test('fetchRates returns parsed rates from proxy response', () async {
    final body = jsonEncode({
      'base': 'USD',
      'rates': [
        {'quote': 'EUR', 'rate': 1.1, 'fetched_at': '2026-01-23T12:00:00Z'},
      ],
      'as_of': '2026-01-23T12:00:05Z',
    });
    when(
      () => httpClient.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response(body, 200));

    final rates = await client.fetchRates(
      baseCode: 'usd',
      quoteCodes: const ['eur'],
    );

    expect(rates, hasLength(1));
    expect(rates.first.baseCode, 'USD');
    expect(rates.first.quoteCode, 'EUR');
    final captured = verify(
      () => httpClient.get(captureAny(), headers: any(named: 'headers')),
    ).captured;
    expect(captured, hasLength(1));
    final requestUri = captured.first as Uri;
    expect(requestUri.path, '/v1/rates');
    expect(requestUri.queryParameters['base'], 'USD');
    expect(requestUri.queryParametersAll['quotes'], ['EUR']);
  });
}
