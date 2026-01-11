import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/application/subscriptions/add_subscription_use_case.dart';
import 'package:subctrl/application/subscriptions/delete_subscription_use_case.dart';
import 'package:subctrl/application/subscriptions/refresh_overdue_next_payments_use_case.dart';
import 'package:subctrl/application/subscriptions/update_subscription_use_case.dart';
import 'package:subctrl/application/subscriptions/watch_subscriptions_use_case.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/repositories/subscription_repository.dart';

class _MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Subscription(
        name: 'Test',
        amount: 10,
        currency: 'USD',
        cycle: BillingCycle.monthly,
        purchaseDate: DateTime(2024, 1, 1),
      ),
    );
  });

  late _MockSubscriptionRepository repository;
  late WatchSubscriptionsUseCase watchUseCase;
  late AddSubscriptionUseCase addUseCase;
  late UpdateSubscriptionUseCase updateUseCase;
  late DeleteSubscriptionUseCase deleteUseCase;
  late RefreshOverdueNextPaymentsUseCase refreshOverdueNextPaymentsUseCase;

  setUp(() {
    repository = _MockSubscriptionRepository();
    watchUseCase = WatchSubscriptionsUseCase(repository);
    addUseCase = AddSubscriptionUseCase(repository);
    updateUseCase = UpdateSubscriptionUseCase(repository);
    deleteUseCase = DeleteSubscriptionUseCase(repository);
    refreshOverdueNextPaymentsUseCase = RefreshOverdueNextPaymentsUseCase(
      repository,
      nowProvider: () => DateTime(2024, 2, 15),
    );
  });

  test('watch use case delegates to repository stream', () async {
    final controller = StreamController<List<Subscription>>();
    when(repository.watchSubscriptions).thenAnswer((_) => controller.stream);
    final sample = Subscription(
      name: 'Netflix',
      amount: 9.99,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
    );
    final expectation = expectLater(
      watchUseCase(),
      emitsInOrder([
        [sample],
      ]),
    );
    controller.add([sample]);
    await controller.close();
    await expectation;
  });

  test('add use case forwards subscription to repository', () async {
    when(() => repository.addSubscription(any())).thenAnswer((_) async {});
    final subscription = Subscription(
      name: 'Spotify',
      amount: 12,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
    );
    await addUseCase(subscription);
    verify(() => repository.addSubscription(subscription)).called(1);
  });

  test('update use case forwards subscription to repository', () async {
    when(() => repository.updateSubscription(any())).thenAnswer((_) async {});
    final subscription = Subscription(
      id: 1,
      name: 'Spotify',
      amount: 12,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
    );
    await updateUseCase(subscription);
    verify(() => repository.updateSubscription(subscription)).called(1);
  });

  test('delete use case forwards id to repository', () async {
    when(() => repository.deleteSubscription(any())).thenAnswer((_) async {});
    await deleteUseCase(42);
    verify(() => repository.deleteSubscription(42)).called(1);
  });

  test('refresh overdue next payments updates stored subscriptions', () async {
    when(() => repository.updateSubscription(any())).thenAnswer((_) async {});
    final stale = Subscription(
      id: 1,
      name: 'Stale',
      amount: 5,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 1, 1),
      nextPaymentDate: DateTime(2024, 2, 1),
    );
    final fresh = Subscription(
      id: 2,
      name: 'Fresh',
      amount: 5,
      currency: 'USD',
      cycle: BillingCycle.monthly,
      purchaseDate: DateTime(2024, 2, 1),
      nextPaymentDate: DateTime(2024, 3, 1),
    );

    await refreshOverdueNextPaymentsUseCase([stale, fresh]);

    verify(
      () => repository.updateSubscription(
        any(
          that: predicate<Subscription>(
            (updated) =>
                updated.id == 1 &&
                updated.nextPaymentDate == DateTime(2024, 3, 1),
          ),
        ),
      ),
    ).called(1);
    verifyNever(() => repository.updateSubscription(fresh));
  });
}
