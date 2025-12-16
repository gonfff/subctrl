import 'package:drift/drift.dart';

import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/repositories/currency_rate_repository.dart';
import 'package:subctrl/infrastructure/persistence/daos/currency_rates_dao.dart';
import 'package:subctrl/infrastructure/persistence/database.dart';

class DriftCurrencyRateRepository implements CurrencyRateRepository {
  DriftCurrencyRateRepository(this._dao);

  final CurrencyRatesDao _dao;

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
    await _dao.upsertRates(companions);
  }

  @override
  Future<List<CurrencyRate>> getRates(String baseCode) async {
    final rows = await _dao.getRates(baseCode);
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
    final row = await _dao.findRate(
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
    return _dao.deleteRates(baseCode);
  }

  @override
  Future<void> deleteRate({
    required String baseCode,
    required String quoteCode,
  }) {
    return _dao.deleteRate(
      baseCode: baseCode,
      quoteCode: quoteCode,
    );
  }

  @override
  Stream<List<CurrencyRate>> watchRates(String baseCode) {
    return _dao
        .watchRates(baseCode)
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
