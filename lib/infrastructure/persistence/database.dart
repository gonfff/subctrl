import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:subtrackr/infrastructure/persistence/seeds/currency_seed_data.dart';
import 'package:subtrackr/infrastructure/persistence/tables/currencies_table.dart';
import 'package:subtrackr/infrastructure/persistence/tables/currency_rates_table.dart';
import 'package:subtrackr/infrastructure/persistence/tables/settings_table.dart';
import 'package:subtrackr/infrastructure/persistence/tables/subscriptions_table.dart';
import 'package:subtrackr/infrastructure/persistence/tables/tags_table.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'subtrackr.db'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(
  tables: [
    SubscriptionsTable,
    CurrenciesTable,
    SettingsTable,
    CurrencyRatesTable,
    TagsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  factory AppDatabase() => instance;

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(currenciesTable);
      }
      if (from < 3) {
        await migrator.addColumn(
          subscriptionsTable,
          subscriptionsTable.isActive,
        );
        await migrator.addColumn(
          subscriptionsTable,
          subscriptionsTable.statusChangedAt,
        );
        await customStatement('''
              UPDATE subscriptions_table
              SET is_active = 1,
                  status_changed_at = COALESCE(status_changed_at, CURRENT_TIMESTAMP)
              WHERE status_changed_at IS NULL
            ''');
      }
      if (from < 4) {
        await migrator.addColumn(currenciesTable, currenciesTable.isEnabled);
        await migrator.createTable(settingsTable);
        await customStatement('''
              UPDATE currencies_table
              SET is_enabled = 1
              WHERE is_enabled IS NULL
            ''');
      }
      if (from < 5) {
        await customStatement(
          'ALTER TABLE currencies_table RENAME TO currencies_table_old',
        );
        await migrator.createTable(currenciesTable);
        await customStatement('''
              INSERT INTO currencies_table (code, name, symbol, is_enabled, is_custom)
              SELECT code, name, symbol, is_enabled, 0
              FROM currencies_table_old
            ''');
        final defaultCodes = currencySeeds
            .map((seed) => "'${seed.code}'")
            .join(', ');
        await customStatement('''
              UPDATE currencies_table
              SET is_custom = 1
              WHERE code NOT IN ($defaultCodes)
            ''');
        await customStatement('DROP TABLE currencies_table_old');
      }
      if (from < 6) {
        await migrator.createTable(currencyRatesTable);
      }
      if (from < 7) {
        await migrator.createTable(tagsTable);
      }
      if (from < 8) {
        await migrator.addColumn(subscriptionsTable, subscriptionsTable.tagId);
      }
    },
  );

  Stream<List<SubscriptionsTableData>> watchSubscriptions() {
    final query = select(subscriptionsTable)
      ..orderBy([(t) => OrderingTerm(expression: t.nextPaymentDate)]);
    return query.watch();
  }

  Future<int> addSubscription(SubscriptionsTableCompanion entry) {
    return into(subscriptionsTable).insert(entry);
  }

  Future<SubscriptionsTableData?> findById(int id) {
    return (select(
      subscriptionsTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<SubscriptionsTableData?> firstSubscription() {
    return (select(subscriptionsTable)..limit(1)).getSingleOrNull();
  }

  Future<int> deleteAll() => delete(subscriptionsTable).go();

  Future<void> ensureCurrenciesSeeded() async {
    final existing = await (select(
      currenciesTable,
    )..limit(1)).getSingleOrNull();
    if (existing != null) return;

    await batch((batch) {
      batch.insertAll(
        currenciesTable,
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

  Future<List<CurrenciesTableData>> getCurrencies({bool onlyEnabled = false}) {
    final query = select(currenciesTable)
      ..orderBy([(t) => OrderingTerm(expression: t.code)]);
    if (onlyEnabled) {
      query.where((tbl) => tbl.isEnabled.equals(true));
    }
    return query.get();
  }

  Stream<List<CurrenciesTableData>> watchCurrencies({
    bool onlyEnabled = false,
  }) {
    final query = select(currenciesTable)
      ..orderBy([(t) => OrderingTerm(expression: t.code)]);
    if (onlyEnabled) {
      query.where((tbl) => tbl.isEnabled.equals(true));
    }
    return query.watch();
  }

  Future<CurrenciesTableData?> findCurrency(String code) {
    return (select(
      currenciesTable,
    )..where((tbl) => tbl.code.equals(code))).getSingleOrNull();
  }

  Future<void> setCurrencyEnabled(String code, bool isEnabled) {
    return (update(currenciesTable)..where((tbl) => tbl.code.equals(code)))
        .write(CurrenciesTableCompanion(isEnabled: Value(isEnabled)));
  }

  Future<void> upsertCurrency(CurrenciesTableCompanion companion) {
    return into(currenciesTable).insertOnConflictUpdate(companion);
  }

  Future<void> deleteCurrency(String code) {
    return (delete(
      currenciesTable,
    )..where((tbl) => tbl.code.equals(code))).go();
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(
      settingsTable,
    )..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> saveSetting(String key, String? value) {
    return into(settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion(key: Value(key), value: Value(value)),
    );
  }

  Future<void> upsertCurrencyRate({
    required String baseCode,
    required String quoteCode,
    required double rate,
    required DateTime fetchedAt,
  }) {
    return into(currencyRatesTable).insertOnConflictUpdate(
      CurrencyRatesTableCompanion(
        baseCode: Value(baseCode.toUpperCase()),
        quoteCode: Value(quoteCode.toUpperCase()),
        rate: Value(rate),
        fetchedAt: Value(fetchedAt),
      ),
    );
  }

  Future<void> upsertCurrencyRates(
    Iterable<CurrencyRatesTableCompanion> companions,
  ) async {
    if (companions.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(currencyRatesTable, companions.toList());
    });
  }

  Future<List<CurrencyRatesTableData>> getCurrencyRates(String baseCode) {
    return (select(currencyRatesTable)
          ..where((tbl) => tbl.baseCode.equals(baseCode.toUpperCase()))
          ..orderBy([(t) => OrderingTerm(expression: t.quoteCode)]))
        .get();
  }

  Stream<List<CurrencyRatesTableData>> watchCurrencyRates(String baseCode) {
    return (select(currencyRatesTable)
          ..where((tbl) => tbl.baseCode.equals(baseCode.toUpperCase())))
        .watch();
  }

  Future<CurrencyRatesTableData?> findCurrencyRate({
    required String baseCode,
    required String quoteCode,
  }) {
    return (select(currencyRatesTable)
          ..where(
            (tbl) =>
                tbl.baseCode.equals(baseCode.toUpperCase()) &
                tbl.quoteCode.equals(quoteCode.toUpperCase()),
          ))
        .getSingleOrNull();
  }

  Future<int> deleteCurrencyRates(String baseCode) {
    return (delete(currencyRatesTable)
          ..where((tbl) => tbl.baseCode.equals(baseCode.toUpperCase())))
        .go();
  }

  Future<void> deleteCurrencyRate({
    required String baseCode,
    required String quoteCode,
  }) {
    return (delete(currencyRatesTable)
          ..where(
            (tbl) =>
                tbl.baseCode.equals(baseCode.toUpperCase()) &
                tbl.quoteCode.equals(quoteCode.toUpperCase()),
          ))
        .go();
  }

  Future<List<TagsTableData>> getTags() {
    return (select(tagsTable)..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Stream<List<TagsTableData>> watchTags() {
    return (select(tagsTable)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<int> insertTag(TagsTableCompanion companion) {
    return into(tagsTable).insert(companion);
  }

  Future<void> updateTag(int id, TagsTableCompanion companion) {
    return (update(tagsTable)..where((tbl) => tbl.id.equals(id))).write(
      companion,
    );
  }

  Future<void> deleteTag(int id) {
    return (delete(tagsTable)..where((tbl) => tbl.id.equals(id))).go();
  }
}
