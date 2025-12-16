import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/domain/repositories/subscription_repository.dart';

class UpdateSubscriptionUseCase {
  UpdateSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call(Subscription subscription) {
    return _repository.updateSubscription(subscription);
  }
}
