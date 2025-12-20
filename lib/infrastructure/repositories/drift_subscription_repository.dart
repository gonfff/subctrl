import 'dart:async';

import 'package:drift/drift.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/repositories/subscription_repository.dart';
import 'package:subctrl/infrastructure/persistence/daos/subscriptions_dao.dart';
import 'package:subctrl/infrastructure/persistence/database.dart';

class DriftSubscriptionRepository implements SubscriptionRepository {
  DriftSubscriptionRepository(this._dao);

  final SubscriptionsDao _dao;

  @override
  Stream<List<Subscription>> watchSubscriptions() {
    return _dao.watchSubscriptions().map(
      (rows) => rows.map(_mapToDomain).toList(growable: false),
    );
  }

  @override
  Future<void> addSubscription(Subscription subscription) {
    final entry = SubscriptionsTableCompanion.insert(
      name: subscription.name,
      amount: subscription.amount,
      currency: subscription.currency,
      cycle: subscription.cycle.index,
      purchaseDate: subscription.purchaseDate,
      nextPaymentDate: subscription.nextPaymentDate,
      tagId: Value(subscription.tagId),
      isActive: Value(subscription.isActive),
      statusChangedAt: Value(subscription.statusChangedAt),
    );
    return _dao.insert(entry);
  }

  @override
  Future<void> updateSubscription(Subscription subscription) {
    final id = subscription.id;
    if (id == null) {
      throw ArgumentError('Subscription id is required for update');
    }
    return _dao.update(
      id,
      SubscriptionsTableCompanion(
        name: Value(subscription.name),
        amount: Value(subscription.amount),
        currency: Value(subscription.currency),
        cycle: Value(subscription.cycle.index),
        purchaseDate: Value(subscription.purchaseDate),
        nextPaymentDate: Value(subscription.nextPaymentDate),
        tagId: Value(subscription.tagId),
        isActive: Value(subscription.isActive),
        statusChangedAt: Value(subscription.statusChangedAt),
      ),
    );
  }

  @override
  Future<void> deleteSubscription(int id) {
    return _dao.delete(id);
  }

  Subscription _mapToDomain(SubscriptionsTableData data) {
    return Subscription(
      id: data.id,
      name: data.name,
      amount: data.amount,
      currency: data.currency,
      cycle: BillingCycle.values[data.cycle],
      purchaseDate: data.purchaseDate,
      nextPaymentDate: data.nextPaymentDate,
      isActive: data.isActive,
      statusChangedAt: data.statusChangedAt,
      tagId: data.tagId,
    );
  }
}
