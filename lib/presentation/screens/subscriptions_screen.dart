import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:subtrackr/domain/entities/currency.dart';
import 'package:subtrackr/domain/entities/currency_rate.dart';
import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/domain/entities/tag.dart';
import 'package:subtrackr/infrastructure/currency/subscription_currency_rates_client.dart';
import 'package:subtrackr/infrastructure/currency/yahoo_finance_client.dart';
import 'package:subtrackr/infrastructure/persistence/database.dart';
import 'package:subtrackr/infrastructure/repositories/currency_rate_repository.dart';
import 'package:subtrackr/infrastructure/repositories/currency_repository.dart';
import 'package:subtrackr/infrastructure/repositories/subscription_repository.dart';
import 'package:subtrackr/infrastructure/repositories/tag_repository.dart';
import 'package:subtrackr/presentation/l10n/app_localizations.dart';
import 'package:subtrackr/presentation/theme/theme_preference.dart';
import 'package:subtrackr/presentation/types/settings_callbacks.dart';
import 'package:subtrackr/presentation/widgets/add_subscription_sheet.dart';
import 'package:subtrackr/presentation/widgets/empty_subscriptions_state.dart';
import 'package:subtrackr/presentation/widgets/settings_sheet.dart';
import 'package:subtrackr/presentation/widgets/subscription_card.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({
    super.key,
    required this.themePreference,
    required this.onThemePreferenceChanged,
    required this.selectedLocale,
    required this.onLocaleChanged,
    required this.baseCurrencyCode,
    required this.onBaseCurrencyChanged,
    required this.currencyRatesAutoDownloadEnabled,
    required this.onCurrencyRatesAutoDownloadChanged,
  });

  final ThemePreference themePreference;
  final ValueChanged<ThemePreference> onThemePreferenceChanged;
  final Locale? selectedLocale;
  final ValueChanged<Locale?> onLocaleChanged;
  final String? baseCurrencyCode;
  final BaseCurrencyChangedCallback onBaseCurrencyChanged;
  final bool currencyRatesAutoDownloadEnabled;
  final ValueChanged<bool> onCurrencyRatesAutoDownloadChanged;

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late final SubscriptionRepository _repository;
  late final CurrencyRepository _currencyRepository;
  late final CurrencyRateRepository _currencyRateRepository;
  late final TagRepository _tagRepository;
  late final YahooFinanceCurrencyClient _yahooFinanceClient;
  late final SubscriptionCurrencyRatesClient _subscriptionRatesClient;
  late final ScrollController _scrollController;
  StreamSubscription<List<Subscription>>? _subscription;
  List<Subscription> _subscriptions = const [];
  StreamSubscription<List<Tag>>? _tagSubscription;
  List<Tag> _tags = const [];
  Map<int, Tag> _tagMap = const {};
  StreamSubscription<List<CurrencyRate>>? _rateSubscription;
  Map<String, CurrencyRate> _rateMap = const {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  List<Currency> _activeCurrencies = const [];
  Map<String, Currency> _currencyMap = const {};
  bool _isLoadingCurrencies = true;
  bool _isFetchingRates = false;
  late bool _autoDownloadEnabled;
  String? _currentBaseCurrencyCode;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _repository = SubscriptionRepository(AppDatabase());
    _currencyRepository = CurrencyRepository(AppDatabase());
    _currencyRateRepository = CurrencyRateRepository(AppDatabase());
    _tagRepository = TagRepository(AppDatabase());
    _yahooFinanceClient = YahooFinanceCurrencyClient();
    _subscriptionRatesClient = SubscriptionCurrencyRatesClient(
      yahooFinanceCurrencyClient: _yahooFinanceClient,
      currencyRepository: _currencyRepository,
    );
    _autoDownloadEnabled = widget.currencyRatesAutoDownloadEnabled;
    _currentBaseCurrencyCode = widget.baseCurrencyCode?.toUpperCase();
    _subscription = _repository.watchSubscriptions().listen((subscriptions) {
      setState(() {
        _subscriptions = subscriptions;
        _isLoading = false;
      });
      if (_autoDownloadEnabled) {
        unawaited(_refreshCurrencyRatesForSubscriptions());
      }
    });
    _tagSubscription = _tagRepository.watchTags().listen((tags) {
      if (!mounted) return;
      setState(() {
        _tags = tags;
        _tagMap = {for (final tag in tags) tag.id: tag};
      });
    });
    _listenRates();
    unawaited(_loadCurrencies());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _tagSubscription?.cancel();
    _rateSubscription?.cancel();
    _scrollController.dispose();
    _yahooFinanceClient.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SubscriptionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseCurrencyCode != widget.baseCurrencyCode) {
      _currentBaseCurrencyCode = widget.baseCurrencyCode?.toUpperCase();
      _listenRates();
      if (_autoDownloadEnabled) {
        unawaited(_refreshCurrencyRatesForSubscriptions());
      }
    }
    if (oldWidget.currencyRatesAutoDownloadEnabled !=
        widget.currencyRatesAutoDownloadEnabled) {
      _autoDownloadEnabled = widget.currencyRatesAutoDownloadEnabled;
      if (_autoDownloadEnabled) {
        unawaited(_refreshCurrencyRatesForSubscriptions());
      }
    }
  }

  Future<void> _loadCurrencies() async {
    await _currencyRepository.seedIfEmpty();
    final currencies = await _currencyRepository.getCurrencies();
    final active = currencies.where((currency) => currency.isEnabled).toList();
    if (!mounted) return;
    setState(() {
      _activeCurrencies = active;
      _currencyMap = {
        for (final currency in currencies)
          currency.code.toUpperCase(): currency,
      };
      _isLoadingCurrencies = false;
    });
  }

  Future<void> _openAddSubscriptionSheet() async {
    if (_isLoadingCurrencies) {
      await _loadCurrencies();
      if (!mounted) return;
    }
    if (_activeCurrencies.isEmpty) {
      return;
    }
    final result = await showCupertinoModalPopup<SubscriptionSheetResult>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: AddSubscriptionSheet(
            currencies: _activeCurrencies,
            defaultCurrencyCode: _currentBaseCurrencyCode,
            tags: _tags,
          ),
        );
      },
    );

    final subscription = result?.subscription;
    if (subscription != null && !(result?.deleted ?? false)) {
      await _repository.addSubscription(subscription);
      await _refreshCurrencyRatesForSubscriptions();
    }
  }

  Future<void> _openEditSubscriptionSheet(Subscription subscription) async {
    final result = await showCupertinoModalPopup<SubscriptionSheetResult>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: AddSubscriptionSheet(
            currencies: _activeCurrencies,
            defaultCurrencyCode: _currentBaseCurrencyCode,
            tags: _tags,
            initialSubscription: subscription,
          ),
        );
      },
    );
    if (result == null) return;
    if (result.deleted) {
      final id = subscription.id;
      if (id != null) {
        await _repository.deleteSubscription(id);
      }
      return;
    }
    final updated = result.subscription;
    if (updated != null && updated.id != null) {
      await _repository.updateSubscription(updated);
      await _refreshCurrencyRatesForSubscriptions();
    }
  }

  Future<void> _refreshCurrencyRatesForSubscriptions() async {
    _log('_refreshCurrencyRatesForSubscriptions called');
    _log('autoDownloadEnabled: $_autoDownloadEnabled');
    if (!_autoDownloadEnabled) {
      _log('Auto download disabled, skipping');
      return;
    }
    final baseCode = _currentBaseCurrencyCode;
    _log('Base currency: $baseCode');
    if (baseCode == null) {
      _log('No base currency set, skipping');
      return;
    }
    if (_subscriptions.isEmpty) {
      _log('No subscriptions, skipping');
      return;
    }
    if (_isFetchingRates) {
      _log('Already fetching rates, skipping');
      return;
    }
    _isFetchingRates = true;
    try {
      final existingRates = await _currencyRateRepository.getRates(baseCode);
      _log('Found ${existingRates.length} existing rates');
      final storedQuotes = existingRates
          .map((rate) => rate.quoteCode.toUpperCase())
          .toSet();
      final subscriptionQuotes = _subscriptions
          .map((subscription) => subscription.currency.toUpperCase())
          .where((code) => code != baseCode)
          .toSet();
      _log('Subscription quotes: $subscriptionQuotes');
      final missingQuotes = subscriptionQuotes.difference(storedQuotes);
      _log('Missing quotes: $missingQuotes');
      DateTime? latestUpdate;
      for (final rate in existingRates) {
        if (latestUpdate == null || rate.fetchedAt.isAfter(latestUpdate)) {
          latestUpdate = rate.fetchedAt;
        }
      }
      final nowUtc = DateTime.now().toUtc();
      final isStale =
          latestUpdate == null ||
          nowUtc.difference(latestUpdate.toUtc()) >= const Duration(days: 1);
      _log('Latest update: $latestUpdate, isStale: $isStale');
      if (!isStale && missingQuotes.isEmpty) {
        _log('Rates are fresh and complete, skipping fetch');
        return;
      }
      _log('Fetching rates from Yahoo Finance...');
      final rates = await _subscriptionRatesClient.fetchRates(
        baseCurrencyCode: baseCode,
        subscriptions: _subscriptions,
      );
      _log('Received ${rates.length} rates');
      if (rates.isEmpty) {
        _log('No rates received, skipping save');
        return;
      }
      await _currencyRateRepository.saveRates(baseCode: baseCode, rates: rates);
      _log('Rates saved successfully');
    } on CurrencyRatesFetchException catch (error) {
      _log(
        'Failed to refresh currency rates: ${error.message}',
        error: error,
      );
    } catch (error, stackTrace) {
      _log(
        'Unexpected error while refreshing currency rates',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isFetchingRates = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final filteredSubscriptions = _filteredSubscriptions();
    final content = CupertinoScrollbar(
      controller: _scrollController,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: _buildContentSlivers(filteredSubscriptions),
      ),
    );

    return CupertinoPageScaffold(
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
                onPressed: _activeCurrencies.isEmpty
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
  }

  Future<void> _openSettings() async {
    await showCupertinoModalPopup<void>(
      context: context,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.45),
      builder: (context) {
        return SettingsSheet(
          themePreference: widget.themePreference,
          onThemePreferenceChanged: widget.onThemePreferenceChanged,
          selectedLocale: widget.selectedLocale,
          onLocaleChanged: widget.onLocaleChanged,
          baseCurrencyCode: widget.baseCurrencyCode,
          onBaseCurrencyChanged: widget.onBaseCurrencyChanged,
          currencyRatesAutoDownloadEnabled: _autoDownloadEnabled,
          onCurrencyRatesAutoDownloadChanged:
              _handleCurrencyRatesAutoDownloadPreferenceChanged,
        );
      },
    );
    if (mounted) {
      await _loadCurrencies();
    }
  }

  List<Subscription> _filteredSubscriptions() {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _subscriptions;
    return _subscriptions
        .where(
          (subscription) => subscription.name.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  List<Widget> _buildContentSlivers(List<Subscription> subscriptions) {
    final searchField = SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: CupertinoSearchTextField(
          controller: _searchController,
          placeholder: AppLocalizations.of(context).subscriptionSearchPlaceholder,
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );

    if (_isLoading) {
      return const [
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CupertinoActivityIndicator()),
        ),
      ];
    }

    if (_subscriptions.isEmpty) {
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
            child: Text(
              AppLocalizations.of(context).subscriptionSearchEmpty,
            ),
          ),
        ),
      ];
    }

    final totalItems = subscriptions.length * 2 - 1;
    return [
      searchField,
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index.isOdd) {
              return const SizedBox(height: 12); // spacing between cards
            }
            final subscriptionIndex = index ~/ 2;
            final subscription = subscriptions[subscriptionIndex];
            final currency = _currencyMap[subscription.currency.toUpperCase()];
            final tag = subscription.tagId != null
                ? _tagMap[subscription.tagId!]
                : null;
            final baseCode = _currentBaseCurrencyCode?.toUpperCase();
            final baseCurrency =
                baseCode != null ? _currencyMap[baseCode] : null;
            return SubscriptionCard(
              subscription: subscription,
              currency: currency,
              rateMap: _rateMap,
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
    setState(() {
      _autoDownloadEnabled = value;
    });
    if (_autoDownloadEnabled) {
      unawaited(_refreshCurrencyRatesForSubscriptions());
    }
    widget.onCurrencyRatesAutoDownloadChanged(value);
  }

  void _listenRates() {
    final base = (_currentBaseCurrencyCode ?? 'USD').toUpperCase();
    _rateSubscription?.cancel();
    _rateSubscription =
        _currencyRateRepository.watchRates(base).listen((rates) {
      if (!mounted) return;
      setState(() {
        _rateMap = {
          for (final rate in rates)
            rate.quoteCode.toUpperCase(): rate,
        };
      });
    });
  }

  void _log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: 'SubscriptionsScreen',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
