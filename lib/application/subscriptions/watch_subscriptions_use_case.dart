import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/domain/repositories/subscription_repository.dart';

class WatchSubscriptionsUseCase {
  WatchSubscriptionsUseCase(this._repository);

  final SubscriptionRepository _repository;

  Stream<List<Subscription>> call() {
    return _repository.watchSubscriptions();
  }
}
