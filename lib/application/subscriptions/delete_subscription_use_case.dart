import 'package:subtrackr/domain/repositories/subscription_repository.dart';

class DeleteSubscriptionUseCase {
  DeleteSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call(int id) {
    return _repository.deleteSubscription(id);
  }
}
