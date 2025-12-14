import 'dart:developer' as developer;

import 'package:subtrackr/infrastructure/currency/yahoo_finance_client.dart';

void main() async {
  developer.log('Testing Yahoo Finance Client...', name: 'YahooClientSample');

  final client = YahooFinanceCurrencyClient();

  try {
    developer.log(
      'Fetching EUR and GBP rates in USD...',
      name: 'YahooClientSample',
    );
    final rates = await client.fetchRates(
      baseCode: 'USD',
      quoteCodes: ['EUR', 'GBP'],
    );

    developer.log(
      'Received ${rates.length} rates:',
      name: 'YahooClientSample',
    );
    for (final rate in rates) {
      developer.log(
        '${rate.quoteCode}/${rate.baseCode} = ${rate.rate} (fetched at ${rate.fetchedAt})',
        name: 'YahooClientSample',
      );
    }

    if (rates.isEmpty) {
      developer.log(
        'ERROR: No rates received!',
        name: 'YahooClientSample',
        level: 1000,
      );
    } else {
      developer.log(
        'SUCCESS: Rates fetched successfully!',
        name: 'YahooClientSample',
      );
    }
  } catch (e) {
    developer.log(
      'ERROR: $e',
      name: 'YahooClientSample',
      level: 1000,
      error: e,
    );
  } finally {
    client.close();
  }
}
