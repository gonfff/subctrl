import 'package:subctrl/domain/entities/tag.dart';
import 'package:subctrl/domain/repositories/tag_repository.dart';

class WatchTagsUseCase {
  WatchTagsUseCase(this._repository);

  final TagRepository _repository;

  Stream<List<Tag>> call() {
    return _repository.watchTags();
  }
}
