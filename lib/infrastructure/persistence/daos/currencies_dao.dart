import 'package:drift/drift.dart';

import 'package:subctrl/infrastructure/persistence/database.dart';
import 'package:subctrl/infrastructure/persistence/seeds/currency_seed_data.dart';

class CurrenciesDao {
  CurrenciesDao(this._database);

  final AppDatabase _database;

  Future<void> seedIfEmpty() async {
    final existing =
        await (_database.select(_database.currenciesTable)..limit(1))
            .getSingleOrNull();
    if (existing != null) return;

    await _database.batch((batch) {
      batch.insertAll(
        _database.currenciesTable,
        currencySeeds.map(
          (seed) => CurrenciesTableCompanion.insert(
            code: seed.code,
            name: seed.name,
            symbol: Value(seed.symbol),
            isEnabled: const Value(true),
            isCustom: const Value(false),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<List<CurrenciesTableData>> getCurrencies({
    bool onlyEnabled = false,
  }) {
    final query = _database.select(_database.currenciesTable)
      ..orderBy([(t) => OrderingTerm(expression: t.code)]);
    if (onlyEnabled) {
      query.where((tbl) => tbl.isEnabled.equals(true));
    }
    return query.get();
  }

  Stream<List<CurrenciesTableData>> watchCurrencies({
    bool onlyEnabled = false,
  }) {
    final query = _database.select(_database.currenciesTable)
      ..orderBy([(t) => OrderingTerm(expression: t.code)]);
    if (onlyEnabled) {
      query.where((tbl) => tbl.isEnabled.equals(true));
    }
    return query.watch();
  }

  Future<CurrenciesTableData?> findByCode(String code) {
    return (_database.select(_database.currenciesTable)
          ..where((tbl) => tbl.code.equals(code)))
        .getSingleOrNull();
  }

  Future<void> setCurrencyEnabled(String code, bool isEnabled) {
    return (_database.update(_database.currenciesTable)
          ..where((tbl) => tbl.code.equals(code)))
        .write(CurrenciesTableCompanion(isEnabled: Value(isEnabled)));
  }

  Future<void> upsert(CurrenciesTableCompanion companion) {
    return _database
        .into(_database.currenciesTable)
        .insertOnConflictUpdate(companion);
  }

  Future<void> delete(String code) {
    return (_database.delete(_database.currenciesTable)
          ..where((tbl) => tbl.code.equals(code)))
        .go();
  }
}
