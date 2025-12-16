import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/repositories/subscription_repository.dart';

class AddSubscriptionUseCase {
  AddSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<void> call(Subscription subscription) {
    return _repository.addSubscription(subscription);
  }
}
