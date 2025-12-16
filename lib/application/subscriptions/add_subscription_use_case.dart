import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/domain/repositories/subscription_repository.dart';

class AddSubscriptionUseCase {
  AddSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call(Subscription subscription) {
    return _repository.addSubscription(subscription);
  }
}
