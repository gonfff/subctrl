import 'package:drift/drift.dart';

import 'package:subctrl/infrastructure/persistence/database.dart';

class SettingsDao {
  SettingsDao(this._database);

  final AppDatabase _database;

  Future<String?> getSetting(String key) async {
    final row = await (_database.select(_database.settingsTable)
          ..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> saveSetting(String key, String? value) {
    return _database.into(_database.settingsTable).insertOnConflictUpdate(
          SettingsTableCompanion(key: Value(key), value: Value(value)),
        );
  }
}
