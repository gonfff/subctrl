import 'dart:async';

import 'package:drift/drift.dart';
import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/infrastructure/persistence/database.dart';

class SubscriptionRepository {
  SubscriptionRepository(this._database);

  final AppDatabase _database;

  Stream<List<Subscription>> watchSubscriptions() {
    return _database.watchSubscriptions().map(
      (rows) => rows.map(_mapToDomain).toList(growable: false),
    );
  }

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
    return _database.addSubscription(entry);
  }

  Future<void> updateSubscription(Subscription subscription) {
    final id = subscription.id;
    if (id == null) {
      throw ArgumentError('Subscription id is required for update');
    }
    return (_database.update(_database.subscriptionsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
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

  Future<void> deleteSubscription(int id) {
    return (_database.delete(_database.subscriptionsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
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
