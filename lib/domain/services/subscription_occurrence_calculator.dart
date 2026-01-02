import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/utils/date_utils.dart';

class SubscriptionOccurrences {
  SubscriptionOccurrences({
    required List<DateTime> dates,
    required this.occurredOccurrences,
  }) : dates = List.unmodifiable(dates);

  const SubscriptionOccurrences._({
    required this.dates,
    required this.occurredOccurrences,
  });

  final List<DateTime> dates;
  int get totalOccurrences => dates.length;
  final int occurredOccurrences;

  static const empty = SubscriptionOccurrences._(
    dates: <DateTime>[],
    occurredOccurrences: 0,
  );
}

SubscriptionOccurrences calculateSubscriptionOccurrences({
  required BillingCycle cycle,
  required DateTime purchaseDate,
  required DateTime rangeStart,
  required DateTime rangeEnd,
  required DateTime today,
}) {
  final normalizedStart = stripTime(rangeStart);
  final normalizedEnd = stripTime(rangeEnd);
  if (normalizedEnd.isBefore(normalizedStart)) {
    return SubscriptionOccurrences.empty;
  }

  var occurrence = stripTime(purchaseDate);
  if (occurrence.isAfter(normalizedEnd)) {
    return SubscriptionOccurrences.empty;
  }

  final normalizedToday = stripTime(today);

  // Advance to the first occurrence within the range.
  while (occurrence.isBefore(normalizedStart)) {
    final next = stripTime(cycle.addTo(occurrence));
    if (!next.isAfter(occurrence)) {
      return SubscriptionOccurrences.empty;
    }
    occurrence = next;
    if (occurrence.isAfter(normalizedEnd)) {
      return SubscriptionOccurrences.empty;
    }
  }

  final occurrences = <DateTime>[];
  var occurred = 0;
  while (!occurrence.isAfter(normalizedEnd)) {
    occurrences.add(occurrence);
    if (!occurrence.isAfter(normalizedToday)) {
      occurred++;
    }
    final next = stripTime(cycle.addTo(occurrence));
    if (!next.isAfter(occurrence)) {
      break;
    }
    occurrence = next;
  }

  if (occurrences.isEmpty) {
    return SubscriptionOccurrences.empty;
  }

  return SubscriptionOccurrences(
    dates: occurrences,
    occurredOccurrences: occurred,
  );
}
