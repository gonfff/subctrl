import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/services/currency_rates_provider.dart';

class ProxyCurrencyRatesClient {
  ProxyCurrencyRatesClient({String? baseUrl, http.Client? httpClient})
    : _baseUri = Uri.parse(
        baseUrl ??
            const String.fromEnvironment(
              'SUBCTRL_RATES_URL',
              defaultValue: 'https://subctrl.gonfff.com',
            ),
      ),
      _httpClient = httpClient ?? http.Client();

  final Uri _baseUri;
  final http.Client _httpClient;

  Future<List<CurrencyRate>> fetchRates({
    required String baseCode,
    required Iterable<String> quoteCodes,
  }) async {
    final normalizedBase = baseCode.toUpperCase();
    final normalizedQuotes = quoteCodes
        .map((code) => code.toUpperCase())
        .where((code) => code != normalizedBase)
        .toSet()
        .toList();
    if (normalizedQuotes.isEmpty) {
      return const [];
    }

    final uri = _baseUri.replace(
      path: _joinPath(_baseUri.path, '/v1/rates'),
      query: _buildQuery(normalizedBase, normalizedQuotes),
    );

    final response = await _httpClient.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw CurrencyRatesFetchException(
        'Proxy request failed with status ${response.statusCode}',
      );
    }

    return _parseRates(response.body, normalizedBase);
  }

  void close() => _httpClient.close();

  List<CurrencyRate> _parseRates(String body, String normalizedBase) {
    final decoded = json.decode(body);
    if (decoded is! Map<String, dynamic>) {
      throw CurrencyRatesFetchException('Malformed proxy response.');
    }
    final rates = decoded['rates'];
    if (rates is! List) {
      throw CurrencyRatesFetchException('Malformed proxy response.');
    }
    final parsedRates = <CurrencyRate>[];
    for (final entry in rates) {
      if (entry is! Map<String, dynamic>) continue;
      final quote = entry['quote'];
      final rate = entry['rate'];
      final fetchedAtRaw = entry['fetched_at'];
      if (quote is! String || rate is! num || fetchedAtRaw is! String) {
        continue;
      }
      parsedRates.add(
        CurrencyRate(
          baseCode: normalizedBase,
          quoteCode: quote.toUpperCase(),
          rate: rate.toDouble(),
          fetchedAt: DateTime.parse(fetchedAtRaw),
        ),
      );
    }
    return parsedRates;
  }

  String _joinPath(String basePath, String suffix) {
    final trimmedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    if (trimmedBase.isEmpty) {
      return suffix;
    }
    return '$trimmedBase$suffix';
  }

  String _buildQuery(String base, Iterable<String> quotes) {
    final buffer = StringBuffer('base=');
    buffer.write(Uri.encodeQueryComponent(base));
    for (final quote in quotes) {
      buffer.write('&quotes=');
      buffer.write(Uri.encodeQueryComponent(quote));
    }
    return buffer.toString();
  }
}
