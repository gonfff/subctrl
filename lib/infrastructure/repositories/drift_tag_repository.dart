import 'package:drift/drift.dart';

import 'package:subctrl/domain/entities/tag.dart';
import 'package:subctrl/domain/exceptions/duplicate_tag_name_exception.dart';
import 'package:subctrl/domain/repositories/tag_repository.dart';
import 'package:subctrl/infrastructure/persistence/database.dart';

class DriftTagRepository implements TagRepository {
  DriftTagRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<Tag>> getTags() async {
    final rows = await _database.getTags();
    return rows.map(_mapRow).toList(growable: false);
  }

  @override
  Stream<List<Tag>> watchTags() {
    return _database.watchTags().map(
      (rows) => rows.map(_mapRow).toList(growable: false),
    );
  }

  @override
  Future<Tag> createTag({
    required String name,
    required String colorHex,
  }) async {
    await _ensureUniqueName(name);
    final trimmedName = name.trim();
    final normalizedColor = _normalizeColor(colorHex);
    final id = await _database.insertTag(
      TagsTableCompanion.insert(name: trimmedName, colorHex: normalizedColor),
    );
    return Tag(id: id, name: trimmedName, colorHex: normalizedColor);
  }

  @override
  Future<void> updateTag(Tag tag) async {
    await _ensureUniqueName(tag.name, excludingId: tag.id);
    await _database.updateTag(
      tag.id,
      TagsTableCompanion(
        name: Value(tag.name.trim()),
        colorHex: Value(_normalizeColor(tag.colorHex)),
      ),
    );
  }

  @override
  Future<void> deleteTag(int id) {
    return _database.deleteTag(id);
  }

  Tag _mapRow(TagsTableData data) {
    return Tag(id: data.id, name: data.name, colorHex: data.colorHex);
  }

  String _normalizeColor(String colorHex) {
    if (colorHex.startsWith('#')) {
      return colorHex.toUpperCase();
    }
    return '#${colorHex.toUpperCase()}';
  }

  Future<void> _ensureUniqueName(String name, {int? excludingId}) async {
    final normalized = name.trim().toLowerCase();
    final row = await _database
        .customSelect(
          'SELECT id FROM tags_table WHERE LOWER(name) = ? LIMIT 1',
          variables: [Variable<String>(normalized)],
          readsFrom: {_database.tagsTable},
        )
        .getSingleOrNull();
    if (row == null) return;
    final existingId = row.read<int>('id');
    if (excludingId != null && existingId == excludingId) return;
    throw DuplicateTagNameException(name.trim());
  }
}
