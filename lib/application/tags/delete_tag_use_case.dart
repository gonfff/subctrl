import 'package:subctrl/domain/repositories/tag_repository.dart';

class DeleteTagUseCase {
  DeleteTagUseCase(this._repository);

  final TagRepository _repository;

  Future<void> call(int id) {
    return _repository.deleteTag(id);
  }
}
