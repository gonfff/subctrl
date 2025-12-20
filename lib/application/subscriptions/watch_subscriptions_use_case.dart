import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/repositories/subscription_repository.dart';

class WatchSubscriptionsUseCase {
  WatchSubscriptionsUseCase(this._repository);

  final SubscriptionRepository _repository;

  Stream<List<Subscription>> call() {
    return _repository.watchSubscriptions();
  }
}
