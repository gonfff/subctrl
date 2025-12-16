import 'package:subtrackr/domain/entities/tag.dart';
import 'package:subtrackr/domain/repositories/tag_repository.dart';

class UpdateTagUseCase {
  UpdateTagUseCase(this._repository);

  final TagRepository _repository;

  Future<void> call(Tag tag) {
    return _repository.updateTag(tag);
  }
}
