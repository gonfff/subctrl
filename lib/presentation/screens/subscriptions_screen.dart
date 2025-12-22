import 'package:flutter/cupertino.dart';

import 'package:subctrl/application/app_dependencies.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';
import 'package:subctrl/presentation/theme/app_theme.dart';
import 'package:subctrl/presentation/theme/theme_preference.dart';
import 'package:subctrl/domain/entities/notification_reminder_option.dart';
import 'package:subctrl/presentation/types/settings_callbacks.dart';
import 'package:subctrl/presentation/viewmodels/subscriptions_view_model.dart';
import 'package:subctrl/presentation/widgets/add_subscription_sheet.dart';
import 'package:subctrl/presentation/widgets/empty_subscriptions_state.dart';
import 'package:subctrl/presentation/widgets/settings_sheet.dart';
import 'package:subctrl/presentation/widgets/subscription_card.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({
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
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late final SubscriptionsViewModel _viewModel;
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _viewModel = SubscriptionsViewModel(
      watchSubscriptionsUseCase: widget.dependencies.watchSubscriptionsUseCase,
      addSubscriptionUseCase: widget.dependencies.addSubscriptionUseCase,
      updateSubscriptionUseCase: widget.dependencies.updateSubscriptionUseCase,
      deleteSubscriptionUseCase: widget.dependencies.deleteSubscriptionUseCase,
      watchCurrenciesUseCase: widget.dependencies.watchCurrenciesUseCase,
      getCurrenciesUseCase: widget.dependencies.getCurrenciesUseCase,
      watchCurrencyRatesUseCase: widget.dependencies.watchCurrencyRatesUseCase,
      getCurrencyRatesUseCase: widget.dependencies.getCurrencyRatesUseCase,
      saveCurrencyRatesUseCase: widget.dependencies.saveCurrencyRatesUseCase,
      fetchSubscriptionRatesUseCase:
          widget.dependencies.fetchSubscriptionRatesUseCase,
      watchTagsUseCase: widget.dependencies.watchTagsUseCase,
      initialBaseCurrencyCode: widget.baseCurrencyCode,
      initialAutoDownloadEnabled: widget.currencyRatesAutoDownloadEnabled,
      localNotificationsService: widget.dependencies.localNotificationsService,
      notificationsEnabled: widget.notificationsEnabled,
      notificationReminderOption: widget.notificationReminderOption,
      initialLocale: widget.selectedLocale,
    );
    _searchController.addListener(() {
      _viewModel.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SubscriptionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseCurrencyCode != widget.baseCurrencyCode) {
      _viewModel.updateBaseCurrencyCode(widget.baseCurrencyCode);
    }
    if (oldWidget.currencyRatesAutoDownloadEnabled !=
        widget.currencyRatesAutoDownloadEnabled) {
      _viewModel.updateAutoDownloadEnabled(
        widget.currencyRatesAutoDownloadEnabled,
      );
    }
    if (oldWidget.notificationsEnabled != widget.notificationsEnabled ||
        oldWidget.notificationReminderOption !=
            widget.notificationReminderOption ||
        oldWidget.selectedLocale != widget.selectedLocale) {
      _viewModel.updateNotificationPreferences(
        notificationsEnabled: widget.notificationsEnabled,
        reminderOption: widget.notificationReminderOption,
        locale: widget.selectedLocale,
      );
    }
  }

  Future<void> _openAddSubscriptionSheet() async {
    await _viewModel.ensureCurrenciesLoaded();
    if (!mounted) return;
    final currencies = _viewModel.activeCurrencies;
    if (currencies.isEmpty) return;

    final result = await showCupertinoModalPopup<SubscriptionSheetResult>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: AddSubscriptionSheet(
            currencies: currencies,
            defaultCurrencyCode: _viewModel.baseCurrencyCode,
            tags: _viewModel.tags,
          ),
        );
      },
    );

    final subscription = result?.subscription;
    if (subscription != null && !(result?.deleted ?? false)) {
      await _viewModel.addSubscription(subscription);
      await _viewModel.refreshRatesManually();
    }
  }

  Future<void> _openEditSubscriptionSheet(Subscription subscription) async {
    await _viewModel.ensureCurrenciesLoaded();
    if (!mounted) return;
    final result = await showCupertinoModalPopup<SubscriptionSheetResult>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: AddSubscriptionSheet(
            currencies: _viewModel.activeCurrencies,
            defaultCurrencyCode: _viewModel.baseCurrencyCode,
            tags: _viewModel.tags,
            initialSubscription: subscription,
          ),
        );
      },
    );
    if (result == null) return;
    if (result.deleted) {
      final id = subscription.id;
      if (id != null) {
        await _viewModel.deleteSubscription(id);
      }
      return;
    }
    final updated = result.subscription;
    if (updated != null && updated.id != null) {
      await _viewModel.updateSubscription(updated);
      await _viewModel.refreshRatesManually();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final filteredSubscriptions = _viewModel.filteredSubscriptions;
        final content = CupertinoScrollbar(
          controller: _scrollController,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: _buildContentSlivers(filteredSubscriptions),
          ),
        );

        return CupertinoPageScaffold(
          backgroundColor: AppTheme.scaffoldBackgroundColor(context),
          navigationBar: CupertinoNavigationBar(
            middle: Text(localizations.subscriptionsTitle),
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _openSettings,
              child: const Icon(CupertinoIcons.gear_alt_fill),
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(child: content),
                Positioned(
                  right: 20,
                  bottom: 24,
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    onPressed: _viewModel.activeCurrencies.isEmpty
                        ? null
                        : _openAddSubscriptionSheet,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.add),
                        const SizedBox(width: 8),
                        Text(localizations.addButtonLabel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSettings() async {
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
          currencyRatesAutoDownloadEnabled: _viewModel.autoDownloadEnabled,
          onCurrencyRatesAutoDownloadChanged:
              _handleCurrencyRatesAutoDownloadPreferenceChanged,
          notificationsEnabled: widget.notificationsEnabled,
          onNotificationsPreferenceChanged:
              widget.onNotificationsPreferenceChanged,
          notificationReminderOption: widget.notificationReminderOption,
          onNotificationReminderChanged: widget.onNotificationReminderChanged,
        );
      },
    );
  }

  List<Widget> _buildContentSlivers(List<Subscription> subscriptions) {
    final searchField = SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: CupertinoSearchTextField(
          controller: _searchController,
          placeholder: AppLocalizations.of(
            context,
          ).subscriptionSearchPlaceholder,
        ),
      ),
    );

    if (_viewModel.isLoading) {
      return const [
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ];
    }

    if (_viewModel.subscriptions.isEmpty) {
      return [
        searchField,
        const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptySubscriptionsState(),
        ),
      ];
    }

    if (subscriptions.isEmpty) {
      return [
        searchField,
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(AppLocalizations.of(context).subscriptionSearchEmpty),
          ),
        ),
      ];
    }

    final totalItems = subscriptions.length * 2 - 1;
    final currencyMap = _viewModel.currencyMap;
    final tagMap = _viewModel.tagMap;
    final baseCode = _viewModel.baseCurrencyCode;
    final baseCurrency = baseCode != null ? currencyMap[baseCode] : null;

    return [
      searchField,
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index.isOdd) {
              return const SizedBox(height: 12);
            }
            final subscriptionIndex = index ~/ 2;
            final subscription = subscriptions[subscriptionIndex];
            final currency = currencyMap[subscription.currency.toUpperCase()];
            final tag = subscription.tagId != null
                ? tagMap[subscription.tagId!]
                : null;
            return SubscriptionCard(
              subscription: subscription,
              currency: currency,
              rateMap: _viewModel.rateMap,
              baseCurrency: baseCurrency,
              baseCurrencyCode: baseCode,
              tag: tag,
              onTap: () => _openEditSubscriptionSheet(subscription),
            );
          }, childCount: totalItems),
        ),
      ),
    ];
  }

  void _handleCurrencyRatesAutoDownloadPreferenceChanged(bool value) {
    _viewModel.updateAutoDownloadEnabled(value);
    widget.onCurrencyRatesAutoDownloadChanged(value);
  }
}
