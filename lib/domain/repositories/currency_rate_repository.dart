import 'package:subctrl/domain/entities/currency_rate.dart';

abstract class CurrencyRateRepository {
  Future<void> saveRates({
    required String baseCode,
    required List<CurrencyRate> rates,
  });

  Future<List<CurrencyRate>> getRates(String baseCode);

  Future<CurrencyRate?> findRate({
    required String baseCode,
    required String quoteCode,
  });

  Future<void> clearRates(String baseCode);

  Future<void> deleteRate({
    required String baseCode,
    required String quoteCode,
  });

  Stream<List<CurrencyRate>> watchRates(String baseCode);
}
