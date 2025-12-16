import 'package:subtrackr/domain/entities/tag.dart';
import 'package:subtrackr/domain/repositories/tag_repository.dart';

class CreateTagUseCase {
  CreateTagUseCase(this._repository);

  final TagRepository _repository;

  Future<Tag> call({
    required String name,
    required String colorHex,
  }) {
    return _repository.createTag(name: name, colorHex: colorHex);
  }
}
