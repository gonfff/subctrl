import 'package:drift/drift.dart';

import 'package:subtrackr/domain/entities/currency.dart';
import 'package:subtrackr/infrastructure/persistence/database.dart';

class CurrencyRepository {
  CurrencyRepository(this._database);

  final AppDatabase _database;

  Future<void> seedIfEmpty() => _database.ensureCurrenciesSeeded();

  Future<List<Currency>> getCurrencies({bool onlyEnabled = false}) async {
    final rows = await _database.getCurrencies(onlyEnabled: onlyEnabled);
    return rows.map(_mapToDomain).toList(growable: false);
  }

  Stream<List<Currency>> watchCurrencies({bool onlyEnabled = false}) {
    return _database
        .watchCurrencies(onlyEnabled: onlyEnabled)
        .map((rows) => rows.map(_mapToDomain).toList(growable: false));
  }

  Future<Currency?> findByCode(String code) async {
    final row = await _database.findCurrency(code.toUpperCase());
    if (row == null) return null;
    return _mapToDomain(row);
  }

  Future<void> setCurrencyEnabled(String code, bool isEnabled) {
    return _database.setCurrencyEnabled(code.toUpperCase(), isEnabled);
  }

  Future<Currency> addCustomCurrency({
    required String code,
    required String name,
    String? symbol,
  }) async {
    final normalizedCode = code.toUpperCase();
    final existing = await _database.findCurrency(normalizedCode);
    if (existing != null) {
      throw ArgumentError('Currency $normalizedCode already exists');
    }
    await _database.upsertCurrency(
      CurrenciesTableCompanion.insert(
        code: normalizedCode,
        name: name,
        symbol: Value(symbol),
        isEnabled: const Value(true),
        isCustom: const Value(true),
      ),
    );
    final row = await _database.findCurrency(normalizedCode);
    if (row == null) {
      throw StateError('Currency $normalizedCode was not persisted');
    }
    return _mapToDomain(row);
  }

  Future<void> deleteCustomCurrency(String code) async {
    final normalized = code.toUpperCase();
    final existing = await _database.findCurrency(normalized);
    if (existing == null) return;
    if (!existing.isCustom) {
      throw StateError('Cannot delete built-in currency $normalized');
    }
    await _database.deleteCurrency(normalized);
  }

  Currency _mapToDomain(CurrenciesTableData data) {
    return Currency(
      code: data.code,
      name: data.name,
      symbol: data.symbol,
      isEnabled: data.isEnabled,
      isCustom: data.isCustom,
    );
  }
}
