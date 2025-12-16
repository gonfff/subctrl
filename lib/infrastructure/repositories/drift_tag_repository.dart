import 'package:drift/drift.dart';

import 'package:subctrl/domain/entities/tag.dart';
import 'package:subctrl/domain/exceptions/duplicate_tag_name_exception.dart';
import 'package:subctrl/domain/repositories/tag_repository.dart';
import 'package:subctrl/infrastructure/persistence/daos/tags_dao.dart';
import 'package:subctrl/infrastructure/persistence/database.dart';

class DriftTagRepository implements TagRepository {
  DriftTagRepository(this._dao);

  final TagsDao _dao;

  @override
  Future<List<Tag>> getTags() async {
    final rows = await _dao.getTags();
    return rows.map(_mapRow).toList(growable: false);
  }

  @override
  Stream<List<Tag>> watchTags() {
    return _dao.watchTags().map(
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
    final id = await _dao.insert(
      TagsTableCompanion.insert(name: trimmedName, colorHex: normalizedColor),
    );
    return Tag(id: id, name: trimmedName, colorHex: normalizedColor);
  }

  @override
  Future<void> updateTag(Tag tag) async {
    await _ensureUniqueName(tag.name, excludingId: tag.id);
    await _dao.update(
      tag.id,
      TagsTableCompanion(
        name: Value(tag.name.trim()),
        colorHex: Value(_normalizeColor(tag.colorHex)),
      ),
    );
  }

  @override
  Future<void> deleteTag(int id) {
    return _dao.delete(id);
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
    final existingId = await _dao.findIdByNormalizedName(normalized);
    if (existingId == null) return;
    if (excludingId != null && existingId == excludingId) return;
    throw DuplicateTagNameException(name.trim());
  }
}
