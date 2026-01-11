import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/repositories/subscription_repository.dart';

class RefreshOverdueNextPaymentsUseCase {
  RefreshOverdueNextPaymentsUseCase(
    this._repository, {
    DateTime Function()? nowProvider,
  }) : _nowProvider = nowProvider ?? DateTime.now;

  final SubscriptionRepository _repository;
  final DateTime Function() _nowProvider;

  Future<void> call(List<Subscription> subscriptions) async {
    if (subscriptions.isEmpty) {
      return;
    }
    final now = _nowProvider();
    for (final subscription in subscriptions) {
      if (!isBeforeDay(subscription.nextPaymentDate, now)) {
        continue;
      }
      final nextPaymentDate = subscription.cycle.nextPaymentDate(
        subscription.purchaseDate,
        now,
      );
      if (nextPaymentDate == subscription.nextPaymentDate) {
        continue;
      }
      await _repository.updateSubscription(
        subscription.copyWith(nextPaymentDate: nextPaymentDate),
      );
    }
  }
}
