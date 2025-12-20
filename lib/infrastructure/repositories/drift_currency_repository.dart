import 'package:drift/drift.dart';

import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/domain/repositories/currency_repository.dart';
import 'package:subctrl/infrastructure/persistence/daos/currencies_dao.dart';
import 'package:subctrl/infrastructure/persistence/database.dart';

class DriftCurrencyRepository implements CurrencyRepository {
  DriftCurrencyRepository(this._dao);

  final CurrenciesDao _dao;

  @override
  Future<void> seedIfEmpty() => _dao.seedIfEmpty();

  @override
  Future<List<Currency>> getCurrencies({bool onlyEnabled = false}) async {
    final rows = await _dao.getCurrencies(onlyEnabled: onlyEnabled);
    return rows.map(_mapToDomain).toList(growable: false);
  }

  @override
  Stream<List<Currency>> watchCurrencies({bool onlyEnabled = false}) {
    return _dao
        .watchCurrencies(onlyEnabled: onlyEnabled)
        .map((rows) => rows.map(_mapToDomain).toList(growable: false));
  }

  @override
  Future<Currency?> findByCode(String code) async {
    final row = await _dao.findByCode(code.toUpperCase());
    if (row == null) return null;
    return _mapToDomain(row);
  }

  @override
  Future<void> setCurrencyEnabled(String code, bool isEnabled) {
    return _dao.setCurrencyEnabled(code.toUpperCase(), isEnabled);
  }

  @override
  Future<Currency> addCustomCurrency({
    required String code,
    required String name,
    String? symbol,
  }) async {
    final normalizedCode = code.toUpperCase();
    final existing = await _dao.findByCode(normalizedCode);
    if (existing != null) {
      throw ArgumentError('Currency $normalizedCode already exists');
    }
    await _dao.upsert(
      CurrenciesTableCompanion.insert(
        code: normalizedCode,
        name: name,
        symbol: Value(symbol),
        isEnabled: const Value(true),
        isCustom: const Value(true),
      ),
    );
    final row = await _dao.findByCode(normalizedCode);
    if (row == null) {
      throw StateError('Currency $normalizedCode was not persisted');
    }
    return _mapToDomain(row);
  }

  @override
  Future<void> deleteCustomCurrency(String code) async {
    final normalized = code.toUpperCase();
    final existing = await _dao.findByCode(normalized);
    if (existing == null) return;
    if (!existing.isCustom) {
      throw StateError('Cannot delete built-in currency $normalized');
    }
    await _dao.delete(normalized);
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
