import 'package:drift/drift.dart';

import 'package:subctrl/infrastructure/persistence/database.dart';

class CurrencyRatesDao {
  CurrencyRatesDao(this._database);

  final AppDatabase _database;

  Future<void> upsertRates(
    Iterable<CurrencyRatesTableCompanion> companions,
  ) async {
    if (companions.isEmpty) return;
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.currencyRatesTable,
        companions.toList(),
      );
    });
  }

  Future<List<CurrencyRatesTableData>> getRates(String baseCode) {
    final normalized = baseCode.toUpperCase();
    return (_database.select(_database.currencyRatesTable)
          ..where((tbl) => tbl.baseCode.equals(normalized))
          ..orderBy([(t) => OrderingTerm(expression: t.quoteCode)]))
        .get();
  }

  Stream<List<CurrencyRatesTableData>> watchRates(String baseCode) {
    final normalized = baseCode.toUpperCase();
    return (_database.select(_database.currencyRatesTable)
          ..where((tbl) => tbl.baseCode.equals(normalized)))
        .watch();
  }

  Future<CurrencyRatesTableData?> findRate({
    required String baseCode,
    required String quoteCode,
  }) {
    final normalizedBase = baseCode.toUpperCase();
    final normalizedQuote = quoteCode.toUpperCase();
    return (_database.select(_database.currencyRatesTable)
          ..where(
            (tbl) =>
                tbl.baseCode.equals(normalizedBase) &
                tbl.quoteCode.equals(normalizedQuote),
          ))
        .getSingleOrNull();
  }

  Future<int> deleteRates(String baseCode) {
    final normalized = baseCode.toUpperCase();
    return (_database.delete(_database.currencyRatesTable)
          ..where((tbl) => tbl.baseCode.equals(normalized)))
        .go();
  }

  Future<void> deleteRate({
    required String baseCode,
    required String quoteCode,
  }) {
    final normalizedBase = baseCode.toUpperCase();
    final normalizedQuote = quoteCode.toUpperCase();
    return (_database.delete(_database.currencyRatesTable)
          ..where(
            (tbl) =>
                tbl.baseCode.equals(normalizedBase) &
                tbl.quoteCode.equals(normalizedQuote),
          ))
        .go();
  }
}
