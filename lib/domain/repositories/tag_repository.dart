import 'package:subtrackr/domain/entities/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getTags();

  Stream<List<Tag>> watchTags();

  Future<Tag> createTag({
    required String name,
    required String colorHex,
  });

  Future<void> updateTag(Tag tag);

  Future<void> deleteTag(int id);
}
