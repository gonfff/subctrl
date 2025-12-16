import 'package:drift/drift.dart';

import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/repositories/currency_rate_repository.dart';
import 'package:subctrl/infrastructure/persistence/database.dart';

class DriftCurrencyRateRepository implements CurrencyRateRepository {
  DriftCurrencyRateRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> saveRates({
    required String baseCode,
    required List<CurrencyRate> rates,
  }) async {
    if (rates.isEmpty) return;
    final normalizedBase = baseCode.toUpperCase();
    final companions = rates.map(
      (rate) => CurrencyRatesTableCompanion(
        baseCode: Value(normalizedBase),
        quoteCode: Value(rate.quoteCode.toUpperCase()),
        rate: Value(rate.rate),
        fetchedAt: Value(rate.fetchedAt),
      ),
    );
    await _database.upsertCurrencyRates(companions);
  }

  @override
  Future<List<CurrencyRate>> getRates(String baseCode) async {
    final rows = await _database.getCurrencyRates(baseCode);
    return rows
        .map(
          (row) => CurrencyRate(
            baseCode: row.baseCode,
            quoteCode: row.quoteCode,
            rate: row.rate,
            fetchedAt: row.fetchedAt,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<CurrencyRate?> findRate({
    required String baseCode,
    required String quoteCode,
  }) async {
    final row = await _database.findCurrencyRate(
      baseCode: baseCode,
      quoteCode: quoteCode,
    );
    if (row == null) return null;
    return CurrencyRate(
      baseCode: row.baseCode,
      quoteCode: row.quoteCode,
      rate: row.rate,
      fetchedAt: row.fetchedAt,
    );
  }

  @override
  Future<void> clearRates(String baseCode) {
    return _database.deleteCurrencyRates(baseCode);
  }

  @override
  Future<void> deleteRate({
    required String baseCode,
    required String quoteCode,
  }) {
    return _database.deleteCurrencyRate(
      baseCode: baseCode,
      quoteCode: quoteCode,
    );
  }

  @override
  Stream<List<CurrencyRate>> watchRates(String baseCode) {
    return _database
        .watchCurrencyRates(baseCode)
        .map(
          (rows) => rows
              .map(
                (row) => CurrencyRate(
                  baseCode: row.baseCode,
                  quoteCode: row.quoteCode,
                  rate: row.rate,
                  fetchedAt: row.fetchedAt,
                ),
              )
              .toList(growable: false),
        );
  }
}
