import 'package:subctrl/domain/entities/currency.dart';

abstract class CurrencyRepository {
  Future<void> seedIfEmpty();

  Future<List<Currency>> getCurrencies({bool onlyEnabled = false});

  Stream<List<Currency>> watchCurrencies({bool onlyEnabled = false});

  Future<Currency?> findByCode(String code);

  Future<void> setCurrencyEnabled(String code, bool isEnabled);

  Future<Currency> addCustomCurrency({
    required String code,
    required String name,
    String? symbol,
  });

  Future<void> deleteCustomCurrency(String code);
}
