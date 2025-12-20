import 'package:subctrl/domain/entities/subscription.dart';

abstract class SubscriptionRepository {
  Stream<List<Subscription>> watchSubscriptions();

  Future<void> addSubscription(Subscription subscription);

  Future<void> updateSubscription(Subscription subscription);

  Future<void> deleteSubscription(int id);
}
