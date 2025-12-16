import 'package:subtrackr/domain/entities/tag.dart';
import 'package:subtrackr/domain/repositories/tag_repository.dart';

class WatchTagsUseCase {
  WatchTagsUseCase(this._repository);

  final TagRepository _repository;

  Stream<List<Tag>> call() {
    return _repository.watchTags();
  }
}
