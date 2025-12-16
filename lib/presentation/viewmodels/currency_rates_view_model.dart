import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:subtrackr/application/currencies/get_currencies_use_case.dart';
import 'package:subtrackr/application/currency_rates/delete_currency_rate_use_case.dart';
import 'package:subtrackr/application/currency_rates/save_currency_rates_use_case.dart';
import 'package:subtrackr/application/currency_rates/watch_currency_rates_use_case.dart';
import 'package:subtrackr/domain/entities/currency.dart';
import 'package:subtrackr/domain/entities/currency_rate.dart';

class CurrencyRatesViewModel extends ChangeNotifier {
  CurrencyRatesViewModel({
    required WatchCurrencyRatesUseCase watchCurrencyRatesUseCase,
    required SaveCurrencyRatesUseCase saveCurrencyRatesUseCase,
    required DeleteCurrencyRateUseCase deleteCurrencyRateUseCase,
    required GetCurrenciesUseCase getCurrenciesUseCase,
    required String baseCurrencyCode,
  })  : _watchCurrencyRatesUseCase = watchCurrencyRatesUseCase,
        _saveCurrencyRatesUseCase = saveCurrencyRatesUseCase,
        _deleteCurrencyRateUseCase = deleteCurrencyRateUseCase,
        _getCurrenciesUseCase = getCurrenciesUseCase,
        _baseCurrencyCode = baseCurrencyCode.toUpperCase() {
    _subscribeRates();
    unawaited(_loadCurrencies());
  }

  final WatchCurrencyRatesUseCase _watchCurrencyRatesUseCase;
  final SaveCurrencyRatesUseCase _saveCurrencyRatesUseCase;
  final DeleteCurrencyRateUseCase _deleteCurrencyRateUseCase;
  final GetCurrenciesUseCase _getCurrenciesUseCase;

  final String _baseCurrencyCode;

  StreamSubscription<List<CurrencyRate>>? _ratesSubscription;
  List<CurrencyRate> _rates = const [];
  bool _isLoadingRates = true;

  List<Currency> _currencies = const [];
  bool _isLoadingCurrencies = true;

  List<CurrencyRate> get rates => _rates;
  bool get isLoadingRates => _isLoadingRates;
  bool get isLoadingCurrencies => _isLoadingCurrencies;
  List<Currency> get currencies => _currencies;
  String get baseCurrencyCode => _baseCurrencyCode;

  Future<void> addManualRate(CurrencyRate rate) {
    return _saveCurrencyRatesUseCase(
      baseCurrencyCode: _baseCurrencyCode,
      rates: [rate],
    );
  }

  Future<void> deleteRate(String quoteCurrencyCode) {
    return _deleteCurrencyRateUseCase(
      baseCurrencyCode: _baseCurrencyCode,
      quoteCurrencyCode: quoteCurrencyCode,
    );
  }

  void _subscribeRates() {
    _ratesSubscription?.cancel();
    _ratesSubscription =
        _watchCurrencyRatesUseCase(_baseCurrencyCode).listen((rates) {
      _rates = rates;
      _isLoadingRates = false;
      notifyListeners();
    });
  }

  Future<void> _loadCurrencies() async {
    final list = await _getCurrenciesUseCase();
    _currencies = list;
    _isLoadingCurrencies = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _ratesSubscription?.cancel();
    super.dispose();
  }
}
