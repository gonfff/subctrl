import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:subctrl/infrastructure/persistence/seeds/currency_seed_data.dart';
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
  );

}
