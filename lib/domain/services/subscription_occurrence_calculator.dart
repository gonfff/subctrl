import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/utils/date_utils.dart';

class SubscriptionOccurrences {
  const SubscriptionOccurrences({
    required this.totalOccurrences,
    required this.occurredOccurrences,
  });

  final int totalOccurrences;
  final int occurredOccurrences;

  static const empty = SubscriptionOccurrences(
    totalOccurrences: 0,
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

  var total = 0;
  var occurred = 0;
  while (!occurrence.isAfter(normalizedEnd)) {
    total++;
    if (!occurrence.isAfter(normalizedToday)) {
      occurred++;
    }
    final next = stripTime(cycle.addTo(occurrence));
    if (!next.isAfter(occurrence)) {
      break;
    }
    occurrence = next;
  }

  return SubscriptionOccurrences(
    totalOccurrences: total,
    occurredOccurrences: occurred,
  );
}
