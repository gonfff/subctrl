enum BillingCycle {
  monthly,
  quarterly,
  yearly,
  daily,
  weekly,
  biweekly,
  fourWeekly,
  semiannual,
}

class Subscription {
  Subscription({
    this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.cycle,
    required this.purchaseDate,
    DateTime? nextPaymentDate,
    this.isActive = true,
    DateTime? statusChangedAt,
    this.tagId,
  })  : nextPaymentDate =
            nextPaymentDate ?? cycle.nextPaymentDate(purchaseDate),
        statusChangedAt = statusChangedAt ?? DateTime.now();

  final int? id;
  final String name;
  final double amount;
  final String currency;
  final BillingCycle cycle;
  final DateTime purchaseDate;
  final DateTime nextPaymentDate;
  final bool isActive;
  final DateTime statusChangedAt;
  final int? tagId;

  Subscription copyWith({
    int? id,
    String? name,
    double? amount,
    String? currency,
    BillingCycle? cycle,
    DateTime? purchaseDate,
    bool? isActive,
    DateTime? statusChangedAt,
    DateTime? nextPaymentDate,
    int? tagId,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      cycle: cycle ?? this.cycle,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      isActive: isActive ?? this.isActive,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      tagId: tagId ?? this.tagId,
    );
  }
}

extension BillingCycleX on BillingCycle {
  int? get _months {
    switch (this) {
      case BillingCycle.monthly:
        return 1;
      case BillingCycle.quarterly:
        return 3;
      case BillingCycle.yearly:
        return 12;
      case BillingCycle.semiannual:
        return 6;
      case BillingCycle.daily:
      case BillingCycle.weekly:
      case BillingCycle.biweekly:
      case BillingCycle.fourWeekly:
        return null;
    }
  }

  int? get _days {
    switch (this) {
      case BillingCycle.daily:
        return 1;
      case BillingCycle.weekly:
        return 7;
      case BillingCycle.biweekly:
        return 14;
      case BillingCycle.fourWeekly:
        return 28;
      case BillingCycle.monthly:
      case BillingCycle.quarterly:
      case BillingCycle.yearly:
      case BillingCycle.semiannual:
        return null;
    }
  }

  DateTime addTo(DateTime date) {
    final months = _months;
    if (months != null) {
      return DateTime(date.year, date.month + months, date.day);
    }
    final days = _days;
    if (days != null) {
      return date.add(Duration(days: days));
    }
    throw StateError('Unsupported billing cycle $this');
  }

  DateTime nextPaymentDate(DateTime startDate, [DateTime? reference]) {
    final anchor = reference ?? DateTime.now();
    var candidate = addTo(startDate);
    while (!candidate.isAfter(anchor)) {
      candidate = addTo(candidate);
    }
    return candidate;
  }
}
