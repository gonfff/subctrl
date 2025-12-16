import 'package:drift/drift.dart';

import 'package:subctrl/infrastructure/persistence/database.dart';

class SubscriptionsDao {
  SubscriptionsDao(this._database);

  final AppDatabase _database;

  Stream<List<SubscriptionsTableData>> watchSubscriptions() {
    final query = _database.select(_database.subscriptionsTable)
      ..orderBy([(t) => OrderingTerm(expression: t.nextPaymentDate)]);
    return query.watch();
  }

  Future<int> insert(SubscriptionsTableCompanion companion) {
    return _database.into(_database.subscriptionsTable).insert(companion);
  }

  Future<void> update(int id, SubscriptionsTableCompanion companion) {
    return (_database.update(_database.subscriptionsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .write(companion);
  }

  Future<void> delete(int id) {
    return (_database.delete(_database.subscriptionsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<SubscriptionsTableData?> findById(int id) {
    return (_database.select(_database.subscriptionsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<SubscriptionsTableData?> firstSubscription() {
    return (_database.select(_database.subscriptionsTable)..limit(1))
        .getSingleOrNull();
  }

  Future<int> deleteAll() {
    return _database.delete(_database.subscriptionsTable).go();
  }
}
