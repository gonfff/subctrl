import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:subtrackr/application/currencies/watch_currencies_use_case.dart';
import 'package:subtrackr/domain/entities/currency.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._watchCurrenciesUseCase) {
    _subscribe();
  }

  final WatchCurrenciesUseCase _watchCurrenciesUseCase;

  StreamSubscription<List<Currency>>? _subscription;
  List<Currency> _currencies = const [];
  bool _isLoading = true;

  List<Currency> get currencies => _currencies;
  bool get isLoading => _isLoading;

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
