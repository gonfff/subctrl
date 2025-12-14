import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/presentation/l10n/app_localizations.dart';

String billingCycleLongLabel(
  BillingCycle cycle,
  AppLocalizations localizations,
) {
  switch (cycle) {
    case BillingCycle.monthly:
      return localizations.billingCycleMonthly;
    case BillingCycle.quarterly:
      return localizations.billingCycleQuarterly;
    case BillingCycle.yearly:
      return localizations.billingCycleYearly;
    case BillingCycle.daily:
      return localizations.billingCycleDaily;
    case BillingCycle.weekly:
      return localizations.billingCycleWeekly;
    case BillingCycle.biweekly:
      return localizations.billingCycleBiweekly;
    case BillingCycle.fourWeekly:
      return localizations.billingCycleFourWeekly;
    case BillingCycle.semiannual:
      return localizations.billingCycleSemiannual;
  }
}

String billingCycleShortLabel(
  BillingCycle cycle,
  AppLocalizations localizations,
) {
  switch (cycle) {
    case BillingCycle.monthly:
      return localizations.billingCycleMonthlyShort;
    case BillingCycle.quarterly:
      return localizations.billingCycleQuarterlyShort;
    case BillingCycle.yearly:
      return localizations.billingCycleYearlyShort;
    case BillingCycle.daily:
      return localizations.billingCycleDailyShort;
    case BillingCycle.weekly:
      return localizations.billingCycleWeeklyShort;
    case BillingCycle.biweekly:
      return localizations.billingCycleBiweeklyShort;
    case BillingCycle.fourWeekly:
      return localizations.billingCycleFourWeeklyShort;
    case BillingCycle.semiannual:
      return localizations.billingCycleSemiannualShort;
  }
}
