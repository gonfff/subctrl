import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:subtrackr/application/currencies/add_custom_currency_use_case.dart';
import 'package:subtrackr/application/currencies/delete_custom_currency_use_case.dart';
import 'package:subtrackr/application/currencies/set_currency_enabled_use_case.dart';
import 'package:subtrackr/application/currencies/watch_currencies_use_case.dart';
import 'package:subtrackr/domain/entities/currency.dart';

class CurrencySettingsViewModel extends ChangeNotifier {
  CurrencySettingsViewModel({
    required WatchCurrenciesUseCase watchCurrenciesUseCase,
    required SetCurrencyEnabledUseCase setCurrencyEnabledUseCase,
    required AddCustomCurrencyUseCase addCustomCurrencyUseCase,
    required DeleteCustomCurrencyUseCase deleteCustomCurrencyUseCase,
  })  : _watchCurrenciesUseCase = watchCurrenciesUseCase,
        _setCurrencyEnabledUseCase = setCurrencyEnabledUseCase,
        _addCustomCurrencyUseCase = addCustomCurrencyUseCase,
        _deleteCustomCurrencyUseCase = deleteCustomCurrencyUseCase {
    _subscribe();
  }

  final WatchCurrenciesUseCase _watchCurrenciesUseCase;
  final SetCurrencyEnabledUseCase _setCurrencyEnabledUseCase;
  final AddCustomCurrencyUseCase _addCustomCurrencyUseCase;
  final DeleteCustomCurrencyUseCase _deleteCustomCurrencyUseCase;

  StreamSubscription<List<Currency>>? _subscription;
  List<Currency> _currencies = const [];
  bool _isLoading = true;

  List<Currency> get currencies => _currencies;
  bool get isLoading => _isLoading;

  Future<void> toggleCurrency({
    required String code,
    required bool isEnabled,
  }) {
    return _setCurrencyEnabledUseCase(code: code, isEnabled: isEnabled);
  }

  Future<void> deleteCustomCurrency(String code) {
    return _deleteCustomCurrencyUseCase(code);
  }

  Future<Currency> addCustomCurrency({
    required String code,
    required String name,
    String? symbol,
  }) {
    return _addCustomCurrencyUseCase(
      code: code,
      name: name,
      symbol: symbol,
    );
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _watchCurrenciesUseCase().listen((currencies) {
      _currencies = currencies;
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
