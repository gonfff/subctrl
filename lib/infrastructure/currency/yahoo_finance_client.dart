import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:subtrackr/domain/entities/currency_rate.dart';
import 'package:subtrackr/domain/services/currency_rates_provider.dart';

class YahooFinanceCurrencyClient {
  YahooFinanceCurrencyClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const _host = 'query1.finance.yahoo.com';
  static const _crumbEndpoint = '/v1/test/getcrumb';
  static const _quoteEndpoint = '/v7/finance/quote';

  final String _userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36';

  static String? _sharedCrumb;
  static String? _sharedCookie;
  static Future<void>? _sharedSessionInitialization;

  Future<void> _ensureSessionInitialized() async {
    if (_sharedCrumb != null && _sharedCookie != null) {
      return;
    }
    if (_sharedSessionInitialization != null) {
      await _sharedSessionInitialization;
      return;
    }
    _sharedSessionInitialization = _createSession();
    try {
      await _sharedSessionInitialization;
    } finally {
      _sharedSessionInitialization = null;
    }
  }

  /// Retrieves Yahoo Finance authentication cookie and crumb.
  Future<void> _createSession() async {
    try {
      // First request to fc.yahoo.com to obtain the cookie.
      _log('Fetching cookie from fc.yahoo.com...');
      final initResponse = await _httpClient.get(
        Uri.parse('https://fc.yahoo.com'),
        headers: _defaultHeaders(),
      );
      _log('fc.yahoo.com response: ${initResponse.statusCode}');

      // Extract cookie from response headers.
      final setCookieHeader = initResponse.headers['set-cookie'];
      if (setCookieHeader != null) {
        _sharedCookie = setCookieHeader.split(';').first;
        _log('Cookie extracted: ${_sharedCookie?.substring(0, 20)}...');
      } else {
        _log('WARNING: No set-cookie header found');
      }

      // Fetch crumb token.
      _log('Fetching crumb from query1.finance.yahoo.com...');
      final crumbResponse = await _httpClient.get(
        Uri.parse('https://$_host$_crumbEndpoint'),
        headers: {
          ..._defaultHeaders(),
          if (_sharedCookie != null) 'Cookie': _sharedCookie!,
        },
      );
      _log('Crumb response: ${crumbResponse.statusCode}');

      if (crumbResponse.statusCode == 200) {
        _sharedCrumb = crumbResponse.body.trim();
        _log('Crumb received: $_sharedCrumb');
      } else {
        _log(
          'ERROR: Crumb fetch failed with status ${crumbResponse.statusCode}',
        );
        _log('Response body: ${crumbResponse.body}');
        throw CurrencyRatesFetchException(
          'Failed to fetch crumb: ${crumbResponse.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _log('Exception in _fetchCrumb', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<CurrencyRate>> fetchRates({
    required String baseCode,
    required Iterable<String> quoteCodes,
  }) async {
    try {
      _log('fetchRates called: base=$baseCode, quotes=$quoteCodes');

      await _ensureSessionInitialized();

      final normalizedBase = baseCode.toUpperCase();
      final normalizedQuotes = quoteCodes
          .map((code) => code.toUpperCase())
          .where((code) => code != normalizedBase)
          .toSet()
          .toList();
      if (normalizedQuotes.isEmpty) {
        _log('No quotes to fetch after normalization');
        return const [];
      }
      final symbolMap = <String, String>{
        for (final quote in normalizedQuotes)
          '${quote}${normalizedBase}=X': quote,
      };
      _log('Symbol map: $symbolMap');

      final uri = Uri.https(_host, _quoteEndpoint, {
        'symbols': symbolMap.keys.join(','),
        'region': 'US',
        'lang': 'en-US',
        if (_sharedCrumb != null) 'crumb': _sharedCrumb!,
      });
      _log('Request URI: $uri');

      final response = await _httpClient.get(
        uri,
        headers: _quoteHeaders(),
      );
      _log('Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        _log('Request failed: ${response.body}');
        throw CurrencyRatesFetchException(
          'Yahoo Finance request failed with status ${response.statusCode}',
        );
      }

      _log('Parsing first response...');
      return _parseRates(response.body, symbolMap, normalizedBase);
    } catch (e, stackTrace) {
      _log('Exception in fetchRates', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Parses Yahoo Finance response and produces currency rates.
  List<CurrencyRate> _parseRates(
    String responseBody,
    Map<String, String> symbolMap,
    String normalizedBase,
  ) {
    _log('Parsing response body (length: ${responseBody.length})');
    final decoded = json.decode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      _log('ERROR: Response is not a Map');
      throw CurrencyRatesFetchException('Malformed Yahoo Finance response.');
    }
    final quoteResponse =
        decoded['quoteResponse'] as Map<String, dynamic>? ?? const {};
    final results = quoteResponse['result'] as List<dynamic>? ?? const [];
    _log('Found ${results.length} results in response');

    final now = DateTime.now().toUtc();
    final rates = <CurrencyRate>[];
    for (final entry in results) {
      if (entry is! Map<String, dynamic>) continue;
      final symbol = entry['symbol'] as String?;
      if (symbol == null) continue;
      final quoteCode = symbolMap[symbol];
      if (quoteCode == null) {
        _log('WARNING: Symbol $symbol not found in symbolMap');
        continue;
      }
      final priceValue = entry['regularMarketPrice'];
      if (priceValue is! num) {
        _log('WARNING: No valid price for $symbol');
        continue;
      }
      final timeValue = entry['regularMarketTime'];
      final fetchedAt = timeValue is num
          ? DateTime.fromMillisecondsSinceEpoch(
              timeValue.toInt() * 1000,
              isUtc: true,
            )
          : now;
      _log('Parsed rate: $quoteCode/$normalizedBase = $priceValue');
      rates.add(
        CurrencyRate(
          baseCode: normalizedBase,
          quoteCode: quoteCode,
          rate: priceValue.toDouble(),
          fetchedAt: fetchedAt,
        ),
      );
    }
    _log('Successfully parsed ${rates.length} rates');
    return rates;
  }

  void close() => _httpClient.close();

  Map<String, String> _defaultHeaders() {
    return {
      'User-Agent': _userAgent,
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
    };
  }

  Map<String, String> _quoteHeaders() {
    return {
      ..._defaultHeaders(),
      'Accept': 'application/json, text/plain, */*',
      if (_sharedCookie != null) 'Cookie': _sharedCookie!,
      if (_sharedCrumb != null) 'x-yahoo-request-id': _sharedCrumb!,
    };
  }

  void _log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'YahooFinance',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
