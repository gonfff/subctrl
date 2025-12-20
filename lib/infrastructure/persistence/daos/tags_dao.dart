import 'package:drift/drift.dart';

import 'package:subctrl/infrastructure/persistence/database.dart';

class TagsDao {
  TagsDao(this._database);

  final AppDatabase _database;

  Future<List<TagsTableData>> getTags() {
    return (_database.select(_database.tagsTable)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Stream<List<TagsTableData>> watchTags() {
    return (_database.select(_database.tagsTable)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  Future<int> insert(TagsTableCompanion companion) {
    return _database.into(_database.tagsTable).insert(companion);
  }

  Future<void> update(int id, TagsTableCompanion companion) {
    return (_database.update(_database.tagsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .write(companion);
  }

  Future<void> delete(int id) {
    return (_database.delete(_database.tagsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<int?> findIdByNormalizedName(String normalizedName) async {
    final row = await _database
        .customSelect(
          'SELECT id FROM tags_table WHERE LOWER(name) = ? LIMIT 1',
          variables: [Variable<String>(normalizedName)],
          readsFrom: {_database.tagsTable},
        )
        .getSingleOrNull();
    return row?.read<int>('id');
  }
}
