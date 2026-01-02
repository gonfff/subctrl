import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:subctrl/application/app_dependencies.dart';
import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/entities/notification_reminder_option.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/entities/tag.dart';
import 'package:subctrl/domain/services/subscription_occurrence_calculator.dart';
import 'package:subctrl/domain/utils/date_utils.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';
import 'package:subctrl/presentation/theme/app_theme.dart';
import 'package:subctrl/presentation/theme/theme_preference.dart';
import 'package:subctrl/presentation/types/settings_callbacks.dart';
import 'package:subctrl/presentation/utils/color_utils.dart';
import 'package:subctrl/presentation/viewmodels/analytics_view_model.dart';
import 'package:subctrl/presentation/widgets/analytics_breakdown_bars.dart';
import 'package:subctrl/presentation/widgets/analytics_filters_sheet.dart';
import 'package:subctrl/presentation/widgets/analytics_pie_chart.dart';
import 'package:subctrl/presentation/widgets/settings_sheet.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    super.key,
    required this.dependencies,
    required this.themePreference,
    required this.onThemePreferenceChanged,
    required this.selectedLocale,
    required this.onLocaleChanged,
    required this.baseCurrencyCode,
    required this.onBaseCurrencyChanged,
    required this.currencyRatesAutoDownloadEnabled,
    required this.onCurrencyRatesAutoDownloadChanged,
    required this.notificationsEnabled,
    required this.onNotificationsPreferenceChanged,
    required this.notificationReminderOption,
    required this.onNotificationReminderChanged,
  });

  final AppDependencies dependencies;
  final ThemePreference themePreference;
  final ValueChanged<ThemePreference> onThemePreferenceChanged;
  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleChanged;
  final String? baseCurrencyCode;
  final BaseCurrencyChangedCallback onBaseCurrencyChanged;
  final bool currencyRatesAutoDownloadEnabled;
  final ValueChanged<bool> onCurrencyRatesAutoDownloadChanged;
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsPreferenceChanged;
  final NotificationReminderOption notificationReminderOption;
  final NotificationReminderChangedCallback onNotificationReminderChanged;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month;
  Set<int> _selectedTagIds = <int>{};
  List<Tag> _tags = const [];
  Map<int, Tag> _tagMap = const {};
  List<Subscription> _subscriptions = const [];
  StreamSubscription<List<Tag>>? _tagsSubscription;
  StreamSubscription<List<Subscription>>? _subscriptionsSubscription;
  StreamSubscription<List<CurrencyRate>>? _currencyRatesSubscription;
  Map<String, double> _latestRateMap = const <String, double>{};
  Map<String, List<_HistoricalRateEntry>> _rateHistory =
      const <String, List<_HistoricalRateEntry>>{};

  @override
  void initState() {
    super.initState();
    _tagsSubscription = widget.dependencies.watchTagsUseCase().listen((tags) {
      if (!mounted) return;
      setState(() {
        _tags = tags;
        _tagMap = {for (final tag in tags) tag.id: tag};
        _selectedTagIds = _selectedTagIds
            .where((id) => _tagMap.containsKey(id))
            .toSet();
      });
    });
    _subscriptionsSubscription = widget.dependencies
        .watchSubscriptionsUseCase()
        .listen((subs) {
          if (!mounted) return;
          setState(() {
            _subscriptions = subs;
          });
        });
    _listenToCurrencyRates();
  }

  @override
  void dispose() {
    _tagsSubscription?.cancel();
    _subscriptionsSubscription?.cancel();
    _currencyRatesSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnalyticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseCurrencyCode != widget.baseCurrencyCode) {
      _listenToCurrencyRates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final periodLabel = switch (_selectedPeriod) {
      AnalyticsPeriod.month => localizations.analyticsPeriodMonth,
      AnalyticsPeriod.quarter => localizations.analyticsPeriodQuarter,
      AnalyticsPeriod.year => localizations.analyticsPeriodYear,
      AnalyticsPeriod.allTime => localizations.analyticsPeriodAllTime,
    };
    final range = _currentRange();
    final today = stripTime(DateTime.now());
    final filteredSubscriptions = _filteredSubscriptions(range, today);
    final filteredTotals = _sumAmounts(filteredSubscriptions, range, today);
    final breakdowns = _buildBreakdowns(filteredSubscriptions, range, today);
    final slices = breakdowns
        .map(
          (data) => AnalyticsPieSlice(
            label: data.label,
            amount: data.totalAmount,
            color: data.color,
          ),
        )
        .toList();
    final barItems = breakdowns
        .map(
          (data) => AnalyticsBarData(
            label: data.label,
            color: data.color,
            total: data.totalAmount,
            paid: data.paidAmount,
          ),
        )
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(localizations.analyticsTitle),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _openFilters,
          child: const Icon(CupertinoIcons.slider_horizontal_3),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _openSettings(context),
          child: const Icon(CupertinoIcons.gear_alt_fill),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            _AnalyticsSummaryCard(
              periodLabel: periodLabel,
              spentLabel: _formatAmount(filteredTotals.paidAmount),
              totalLabel: _formatAmount(filteredTotals.totalAmount),
              localizations: localizations,
            ),
            if (slices.isNotEmpty)
              AnalyticsPieChart(slices: slices, formatAmount: _formatAmount)
            else
              _AnalyticsEmptyMessage(
                message: localizations.analyticsPlaceholder,
              ),
            if (barItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              AnalyticsBreakdownBars(
                items: barItems,
                period: _selectedPeriod,
                formatAmount: _formatBarAmount,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAmount(double value) {
    final currencyCode = widget.baseCurrencyCode;
    final formatted = value.toStringAsFixed(2);
    if (currencyCode == null || currencyCode.isEmpty) {
      return formatted;
    }
    return '$formatted $currencyCode';
  }

  String _formatBarAmount(double value) {
    return value.toStringAsFixed(2);
  }

  Future<void> _openFilters() async {
    final availableTags = _tags;
    final initialTagIds = _selectedTagIds
        .where((id) => _tagMap.containsKey(id))
        .toSet();
    final result = await showCupertinoModalPopup<AnalyticsFiltersResult>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      builder: (sheetContext) {
        return AnalyticsFiltersSheet(
          initialPeriod: _selectedPeriod,
          availableTags: availableTags,
          initialTagIds: initialTagIds,
          onClear: _handleFiltersCleared,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedPeriod = result.period;
        _selectedTagIds = result.tagIds;
      });
    }
  }

  void _handleFiltersCleared() {
    setState(() {
      _selectedPeriod = AnalyticsPeriod.month;
      _selectedTagIds.clear();
    });
  }

  Future<void> _openSettings(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      builder: (context) {
        return SettingsSheet(
          dependencies: widget.dependencies,
          themePreference: widget.themePreference,
          onThemePreferenceChanged: widget.onThemePreferenceChanged,
          selectedLocale: widget.selectedLocale,
          onLocaleChanged: widget.onLocaleChanged,
          baseCurrencyCode: widget.baseCurrencyCode,
          onBaseCurrencyChanged: widget.onBaseCurrencyChanged,
          currencyRatesAutoDownloadEnabled:
              widget.currencyRatesAutoDownloadEnabled,
          onCurrencyRatesAutoDownloadChanged:
              widget.onCurrencyRatesAutoDownloadChanged,
          notificationsEnabled: widget.notificationsEnabled,
          onNotificationsPreferenceChanged:
              widget.onNotificationsPreferenceChanged,
          notificationReminderOption: widget.notificationReminderOption,
          onNotificationReminderChanged: widget.onNotificationReminderChanged,
        );
      },
    );
  }

  List<Subscription> _filteredSubscriptions(
    _DateRange range,
    DateTime today,
  ) {
    return _subscriptions.where((subscription) {
      if (_selectedTagIds.isNotEmpty) {
        final tagId = subscription.tagId;
        if (tagId == null || !_selectedTagIds.contains(tagId)) {
          return false;
        }
      }
      return _subscriptionHasOccurrencesInRange(subscription, range, today);
    }).toList();
  }

  _DateRange _currentRange() {
    final now = DateTime.now();
    final today = stripTime(now);
    switch (_selectedPeriod) {
      case AnalyticsPeriod.month:
        final start = DateTime(today.year, today.month, 1);
        final nextMonth = DateTime(today.year, today.month + 1, 1);
        final end = nextMonth.subtract(const Duration(days: 1));
        return _DateRange(start: start, end: end);
      case AnalyticsPeriod.quarter:
        final quarter = ((today.month - 1) ~/ 3) + 1;
        final startMonth = (quarter - 1) * 3 + 1;
        final start = DateTime(today.year, startMonth, 1);
        final nextQuarter = DateTime(today.year, startMonth + 3, 1);
        final end = nextQuarter.subtract(const Duration(days: 1));
        return _DateRange(start: start, end: end);
      case AnalyticsPeriod.year:
        final start = DateTime(today.year, 1, 1);
        final end = DateTime(today.year, 12, 31);
        return _DateRange(start: start, end: end);
      case AnalyticsPeriod.allTime:
        return _DateRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: today,
        );
    }
  }

  _SubscriptionAmounts _sumAmounts(
    List<Subscription> subscriptions,
    _DateRange range,
    DateTime today,
  ) {
    var total = 0.0;
    var paid = 0.0;
    for (final subscription in subscriptions) {
      final amounts =
          _subscriptionAmountsForRange(subscription, range, today);
      total += amounts.totalAmount;
      paid += amounts.paidAmount;
    }
    return _SubscriptionAmounts(totalAmount: total, paidAmount: paid);
  }

  double _convertAmountForOccurrence(
    Subscription subscription,
    DateTime occurrenceDate,
    DateTime today,
  ) {
    final baseCode = widget.baseCurrencyCode?.toUpperCase();
    if (baseCode == null || baseCode.isEmpty) {
      return subscription.amount;
    }
    final quoteCode = subscription.currency.toUpperCase();
    if (quoteCode == baseCode) {
      return subscription.amount;
    }
    final rate = _rateForDate(quoteCode, occurrenceDate, today);
    if (rate == null) {
      return subscription.amount;
    }
    return subscription.amount * rate;
  }

  _SubscriptionAmounts _subscriptionAmountsForRange(
    Subscription subscription,
    _DateRange range,
    DateTime today,
  ) {
    final occurrences =
        _subscriptionOccurrencesInRange(subscription, range, today);
    if (occurrences.dates.isEmpty) {
      return _SubscriptionAmounts.empty;
    }
    var totalAmount = 0.0;
    var paidAmount = 0.0;
    for (final occurrenceDate in occurrences.dates) {
      final converted =
          _convertAmountForOccurrence(subscription, occurrenceDate, today);
      if (converted <= 0) {
        continue;
      }
      totalAmount += converted;
      if (!occurrenceDate.isAfter(today)) {
        paidAmount += converted;
      }
    }
    if (totalAmount <= 0 && paidAmount <= 0) {
      return _SubscriptionAmounts.empty;
    }
    return _SubscriptionAmounts(
      totalAmount: totalAmount,
      paidAmount: paidAmount,
    );
  }

  double? _rateForDate(
    String quoteCurrencyCode,
    DateTime occurrenceDate,
    DateTime today,
  ) {
    final normalizedQuote = quoteCurrencyCode.toUpperCase();
    final normalizedOccurrence = stripTime(occurrenceDate);
    final todayDate = stripTime(today);
    if (normalizedOccurrence.isAfter(todayDate)) {
      return _latestRateMap[normalizedQuote];
    }
    final history = _rateHistory[normalizedQuote];
    if (history == null || history.isEmpty) {
      return _latestRateMap[normalizedQuote];
    }
    _HistoricalRateEntry? candidate;
    for (final entry in history) {
      if (entry.date.isAfter(normalizedOccurrence)) {
        break;
      }
      candidate = entry;
    }
    if (candidate != null) {
      return candidate.value;
    }
    return history.first.value;
  }

  SubscriptionOccurrences _subscriptionOccurrencesInRange(
    Subscription subscription,
    _DateRange range,
    DateTime today,
  ) {
    final statusAwareRange = _rangeWithinSubscriptionStatus(
      subscription,
      range,
    );
    if (statusAwareRange == null) {
      return SubscriptionOccurrences.empty;
    }
    return calculateSubscriptionOccurrences(
      cycle: subscription.cycle,
      purchaseDate: subscription.purchaseDate,
      rangeStart: statusAwareRange.start,
      rangeEnd: statusAwareRange.end,
      today: today,
    );
  }

  bool _subscriptionHasOccurrencesInRange(
    Subscription subscription,
    _DateRange range,
    DateTime today,
  ) {
    final occurrences =
        _subscriptionOccurrencesInRange(subscription, range, today);
    return occurrences.totalOccurrences > 0;
  }

  void _listenToCurrencyRates() {
    _currencyRatesSubscription?.cancel();
    final baseCode = widget.baseCurrencyCode?.toUpperCase();
    if (baseCode == null || baseCode.isEmpty) {
      if (_latestRateMap.isNotEmpty || _rateHistory.isNotEmpty) {
        setState(() {
          _latestRateMap = const <String, double>{};
          _rateHistory = const <String, List<_HistoricalRateEntry>>{};
        });
      }
      return;
    }
    _currencyRatesSubscription = widget.dependencies
        .watchCurrencyRatesUseCase(baseCode)
        .listen((rates) {
          if (!mounted) return;
          final history = <String, List<_HistoricalRateEntry>>{};
          final latestRates = <String, CurrencyRate>{};
          for (final rate in rates) {
            final quote = rate.quoteCode.toUpperCase();
            final normalizedDate = stripTime(rate.fetchedAt.toLocal());
            final entries = history.putIfAbsent(
              quote,
              () => <_HistoricalRateEntry>[],
            );
            entries.add(
              _HistoricalRateEntry(
                date: normalizedDate,
                value: rate.rate,
              ),
            );
            final existing = latestRates[quote];
            if (existing == null || rate.fetchedAt.isAfter(existing.fetchedAt)) {
              latestRates[quote] = rate;
            }
          }
          for (final entries in history.values) {
            entries.sort((a, b) => a.date.compareTo(b.date));
          }
          setState(() {
            _rateHistory = history.map(
              (key, value) => MapEntry(key, List.unmodifiable(value)),
            );
            _latestRateMap = latestRates.map(
              (key, value) => MapEntry(key, value.rate),
            );
          });
        });
  }

  List<_AggregatedBreakdown> _buildBreakdowns(
    List<Subscription> subscriptions,
    _DateRange range,
    DateTime today,
  ) {
    if (subscriptions.isEmpty) return const [];
    final Map<String, _AggregatedBreakdown> totals = {};
    for (final subscription in subscriptions) {
      final tag = subscription.tagId != null
          ? _tagMap[subscription.tagId!]
          : null;
      final key = tag != null
          ? 'tag-${tag.id}'
          : 'subscription-${subscription.id ?? subscription.name}';
      final label = tag?.name ?? subscription.name;
      final color = tag != null
          ? colorFromHex(
              tag.colorHex,
              fallbackColor: _fallbackColors.first,
            )
          : _colorForLabel(label);
      final amounts =
          _subscriptionAmountsForRange(subscription, range, today);
      if (amounts.totalAmount <= 0) continue;
      final existing = totals[key];
      if (existing == null) {
        totals[key] = _AggregatedBreakdown(label: label, color: color)
          ..totalAmount = amounts.totalAmount
          ..paidAmount = amounts.paidAmount;
      } else {
        existing.totalAmount += amounts.totalAmount;
        existing.paidAmount += amounts.paidAmount;
      }
    }
    return totals.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  }

  Color _colorForLabel(String label) {
    final hash = label.hashCode;
    final index = hash.abs() % _fallbackColors.length;
    return _fallbackColors[index];
  }

  _DateRange? _rangeWithinSubscriptionStatus(
    Subscription subscription,
    _DateRange range,
  ) {
    final statusDate = stripTime(subscription.statusChangedAt);
    if (subscription.isActive) {
      final adjustedStart =
          statusDate.isAfter(range.start) ? statusDate : range.start;
      if (adjustedStart.isAfter(range.end)) {
        return null;
      }
      return _DateRange(start: adjustedStart, end: range.end);
    }
    final inactiveEnd = statusDate.subtract(const Duration(days: 1));
    final adjustedEnd =
        inactiveEnd.isBefore(range.end) ? inactiveEnd : range.end;
    if (adjustedEnd.isBefore(range.start)) {
      return null;
    }
    return _DateRange(start: range.start, end: adjustedEnd);
  }
}

class _DateRange {
  const _DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class _HistoricalRateEntry {
  const _HistoricalRateEntry({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class _AggregatedBreakdown {
  _AggregatedBreakdown({required this.label, required this.color});

  final String label;
  final Color color;
  double totalAmount = 0;
  double paidAmount = 0;
}

class _SubscriptionAmounts {
  const _SubscriptionAmounts({
    required this.totalAmount,
    required this.paidAmount,
  });

  final double totalAmount;
  final double paidAmount;

  static const empty = _SubscriptionAmounts(totalAmount: 0, paidAmount: 0);
}

const List<Color> _fallbackColors = [
  Color(0xFF34C759),
  Color(0xFFFF9500),
  Color(0xFFFF2D55),
  Color(0xFF5856D6),
  Color(0xFF5AC8FA),
  Color(0xFFFFC0CB),
  Color(0xFF50B848),
  Color(0xFFAF52DE),
];

class _AnalyticsSummaryCard extends StatelessWidget {
  const _AnalyticsSummaryCard({
    required this.periodLabel,
    required this.spentLabel,
    required this.totalLabel,
    required this.localizations,
  });

  final String periodLabel;
  final String spentLabel;
  final String totalLabel;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = CupertinoColors.systemGrey6.resolveFrom(context);
    final textTheme = CupertinoTheme.of(context).textTheme;
    final valueStyle = textTheme.textStyle.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                localizations.analyticsSummaryPeriodLabel,
                style: textTheme.textStyle.copyWith(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  periodLabel,
                  style: valueStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryColumn(
                  label: localizations.analyticsSummarySpentLabel,
                  value: spentLabel,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: CupertinoColors.systemGrey4.resolveFrom(context),
              ),
              Expanded(
                child: _SummaryColumn(
                  label: localizations.analyticsSummaryTotalLabel,
                  value: totalLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsEmptyMessage extends StatelessWidget {
  const _AnalyticsEmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          color: CupertinoColors.systemGrey.resolveFrom(context),
        ),
      ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  const _SummaryColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final labelStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
      color: CupertinoColors.secondaryLabel.resolveFrom(context),
    );
    final valueStyle = CupertinoTheme.of(
      context,
    ).textTheme.textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 8),
        Text(value, style: valueStyle),
      ],
    );
  }
}
