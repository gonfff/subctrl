import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:subctrl/infrastructure/persistence/tables/currencies_table.dart';
import 'package:subctrl/infrastructure/persistence/tables/currency_rates_table.dart';
import 'package:subctrl/infrastructure/persistence/tables/settings_table.dart';
import 'package:subctrl/infrastructure/persistence/tables/subscriptions_table.dart';
import 'package:subctrl/infrastructure/persistence/tables/tags_table.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'subctrl.db'));
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        final legacyRates = await _readLegacyRates();
        await migrator.deleteTable(currencyRatesTable.actualTableName);
        await migrator.createTable(currencyRatesTable);
        if (legacyRates.isNotEmpty) {
          await batch((batch) {
            batch.insertAll(
              currencyRatesTable,
              legacyRates.map(
                (row) => CurrencyRatesTableCompanion.insert(
                  baseCode: row.baseCode,
                  quoteCode: row.quoteCode,
                  rate: row.rate,
                  rateDate: _stripDate(row.fetchedAt),
                  fetchedAt: row.fetchedAt,
                ),
              ),
            );
          });
        }
      }
    },
  );

  DateTime _stripDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  Future<List<_LegacyCurrencyRateRow>> _readLegacyRates() async {
    final rows = await customSelect(
      'SELECT base_code, quote_code, rate, fetched_at '
      'FROM ${currencyRatesTable.actualTableName}',
      readsFrom: {currencyRatesTable},
    ).get();
    return rows
        .map((row) {
          final base = row.readNullable<String>('base_code');
          final quote = row.readNullable<String>('quote_code');
          final rate = row.readNullable<double>('rate');
          final fetchedAt = row.readNullable<DateTime>('fetched_at');
          if (base == null || quote == null || rate == null || fetchedAt == null) {
            return null;
          }
          return _LegacyCurrencyRateRow(
            baseCode: base.toUpperCase(),
            quoteCode: quote.toUpperCase(),
            rate: rate,
            fetchedAt: fetchedAt,
          );
        })
        .whereType<_LegacyCurrencyRateRow>()
        .toList(growable: false);
  }
}

class _LegacyCurrencyRateRow {
  _LegacyCurrencyRateRow({
    required this.baseCode,
    required this.quoteCode,
    required this.rate,
    required this.fetchedAt,
  });

  final String baseCode;
  final String quoteCode;
  final double rate;
  final DateTime fetchedAt;
}
