import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:subtrackr/domain/entities/currency.dart';
import 'package:subtrackr/domain/entities/currency_rate.dart';
import 'package:subtrackr/infrastructure/persistence/database.dart';
import 'package:subtrackr/infrastructure/repositories/currency_rate_repository.dart';
import 'package:subtrackr/infrastructure/repositories/currency_repository.dart';
import 'package:subtrackr/presentation/l10n/app_localizations.dart';
import 'package:subtrackr/presentation/theme/app_theme.dart';

enum CurrencyRatesSort { currency, date }

class CurrencyRatesScreen extends StatefulWidget {
  const CurrencyRatesScreen({super.key, required this.baseCurrencyCode});

  final String baseCurrencyCode;

  @override
  State<CurrencyRatesScreen> createState() => _CurrencyRatesScreenState();
}

class _CurrencyRatesScreenState extends State<CurrencyRatesScreen> {
  late final CurrencyRateRepository _repository;
  late final CurrencyRepository _currencyRepository;
  StreamSubscription<List<CurrencyRate>>? _subscription;
  List<CurrencyRate> _rates = const [];
  bool _isLoading = true;
  CurrencyRatesSort _sort = CurrencyRatesSort.currency;
  List<Currency> _currencies = const [];
  bool _isLoadingCurrencies = true;

  @override
  void initState() {
    super.initState();
    _repository = CurrencyRateRepository(AppDatabase());
    _currencyRepository = CurrencyRepository(AppDatabase());
    _listenRates();
    unawaited(_loadCurrencies());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _listenRates() {
    _subscription?.cancel();
    _subscription = _repository.watchRates(widget.baseCurrencyCode).listen((
      rates,
    ) {
      if (!mounted) return;
      setState(() {
        _rates = rates;
        _isLoading = false;
      });
    });
  }

  Future<void> _loadCurrencies() async {
    final currencies = await _currencyRepository.getCurrencies();
    if (!mounted) return;
    setState(() {
      _currencies = currencies;
      _isLoadingCurrencies = false;
    });
  }

  void _handleSortChanged(CurrencyRatesSort? value) {
    if (value == null) return;
    setState(() {
      _sort = value;
    });
  }

  List<CurrencyRate> _sortedRates() {
    final rates = List<CurrencyRate>.from(_rates);
    switch (_sort) {
      case CurrencyRatesSort.currency:
        rates.sort((a, b) => a.quoteCode.compareTo(b.quoteCode));
        break;
      case CurrencyRatesSort.date:
        rates.sort((a, b) => b.fetchedAt.compareTo(a.fetchedAt));
        break;
    }
    return rates;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final header = _buildSortControl(localizations);
    final quoteCurrencies = _availableQuoteCurrencies();
    final canAddManualRate =
        !_isLoadingCurrencies && quoteCurrencies.isNotEmpty;
    final sortedRates = _sortedRates();
    final body = _isLoading
        ? const Center(child: CupertinoActivityIndicator())
        : _rates.isEmpty
        ? Center(
            child: Text(
              localizations.settingsCurrencyRatesEmpty,
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemBuilder: (context, index) {
              final rate = sortedRates[index];
              return _CurrencyRateRow(
                rate: rate,
                baseCurrencyCode: widget.baseCurrencyCode,
                onDelete: () => _deleteRate(rate),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: sortedRates.length,
          );

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(localizations.settingsCurrencyRatesTitle),
      ),
      child: SafeArea(
        child: Column(
          children: [
            header,
            Expanded(child: body),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: canAddManualRate
                      ? () => _addManualRate(quoteCurrencies)
                      : null,
                  child: Text(localizations.settingsCurrencyRatesAdd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortControl(AppLocalizations localizations) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: CupertinoSlidingSegmentedControl<CurrencyRatesSort>(
        groupValue: _sort,
        onValueChanged: _handleSortChanged,
        children: {
          CurrencyRatesSort.currency: Text(
            localizations.settingsCurrencyRatesSortCurrency,
          ),
          CurrencyRatesSort.date: Text(
            localizations.settingsCurrencyRatesSortDate,
          ),
        },
      ),
    );
  }

  List<Currency> _availableQuoteCurrencies() {
    final normalizedBase = widget.baseCurrencyCode.toUpperCase();
    final quotes = _currencies
        .where(
          (currency) =>
              currency.isEnabled &&
              currency.code.toUpperCase() != normalizedBase,
        )
        .toList(growable: false);
    quotes.sort((a, b) => a.code.compareTo(b.code));
    return quotes;
  }

  Future<void> _addManualRate(List<Currency> quotes) async {
    final data = await _promptManualRate(quotes);
    if (data == null) return;
    final manualRate = CurrencyRate(
      baseCode: widget.baseCurrencyCode.toUpperCase(),
      quoteCode: data.quoteCode,
      rate: data.rate,
      fetchedAt: data.date,
    );
    await _repository.saveRates(
      baseCode: widget.baseCurrencyCode,
      rates: [manualRate],
    );
  }

  Future<void> _deleteRate(CurrencyRate rate) {
    return _repository.deleteRate(
      baseCode: widget.baseCurrencyCode,
      quoteCode: rate.quoteCode,
    );
  }

  Future<_ManualRateData?> _promptManualRate(List<Currency> quotes) {
    final localizations = AppLocalizations.of(context);
    return showCupertinoModalPopup<_ManualRateData>(
      context: context,
      builder: (context) => _ManualRateSheet(
        quotes: quotes,
        baseCurrencyCode: widget.baseCurrencyCode,
        localizations: localizations,
      ),
    );
  }
}

class _CurrencyRateRow extends StatelessWidget {
  const _CurrencyRateRow({
    required this.rate,
    required this.baseCurrencyCode,
    required this.onDelete,
  });

  final CurrencyRate rate;
  final String baseCurrencyCode;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme.textStyle;
    final locale = Localizations.localeOf(context);
    final dateFormatter = DateFormat.yMMMd(locale.toLanguageTag()).add_Hm();
    final deleteColor = CupertinoColors.systemRed.resolveFrom(context);
    final localizations = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1 ${rate.quoteCode} = ${rate.rate.toStringAsFixed(4)} $baseCurrencyCode',
                  style: textTheme.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormatter.format(rate.fetchedAt.toLocal()),
                  style: textTheme.copyWith(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              onPressed: onDelete,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minSize: 0,
              child: Text(
                localizations.deleteAction,
                style: textTheme.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: deleteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualRateSheet extends StatefulWidget {
  const _ManualRateSheet({
    required this.quotes,
    required this.baseCurrencyCode,
    required this.localizations,
  });

  final List<Currency> quotes;
  final String baseCurrencyCode;
  final AppLocalizations localizations;

  @override
  State<_ManualRateSheet> createState() => _ManualRateSheetState();
}

class _ManualRateSheetState extends State<_ManualRateSheet> {
  late Currency _selectedCurrency = widget.quotes.first;
  late DateTime _selectedDate = DateTime.now();
  final TextEditingController _rateController = TextEditingController();
  late final FixedExtentScrollController _pickerController =
      FixedExtentScrollController(initialItem: 0);

  double? get _parsedRate {
    final normalized = _rateController.text.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  bool get _canSubmit => _parsedRate != null;

  @override
  void dispose() {
    _rateController.dispose();
    _pickerController.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = _parsedRate;
    if (parsed == null) return;
    Navigator.of(context).pop(
      _ManualRateData(
        quoteCode: _selectedCurrency.code.toUpperCase(),
        rate: parsed,
        date: _selectedDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context).textTheme.textStyle;
    final background = CupertinoColors.systemBackground.resolveFrom(context);
    return CupertinoPopupSurface(
      child: Container(
        color: background,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.localizations.settingsCurrencyRatesManualTitle,
                        style: theme.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.localizations.settingsCurrencyRatesQuoteLabel,
                      style: theme.copyWith(
                        fontSize: 13,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: _pickerController,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedCurrency = widget.quotes[index];
                          });
                        },
                        children: widget.quotes
                            .map(
                              (currency) => Center(
                                child: Text(
                                  '${currency.code} - ${currency.name}',
                                  style: theme,
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.localizations.settingsCurrencyRatesValueLabel,
                      style: theme.copyWith(
                        fontSize: 13,
                        color:
                            CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    CupertinoTextField(
                      controller: _rateController,
                      placeholder:
                          '1 ${_selectedCurrency.code} = ? ${widget.baseCurrencyCode.toUpperCase()}',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.localizations.settingsCurrencyRatesDateLabel,
                      style: theme.copyWith(
                        fontSize: 13,
                        color:
                            CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: _selectedDate,
                        maximumDate:
                            DateTime.now().add(const Duration(days: 3650)),
                        onDateTimeChanged: (value) {
                          setState(() {
                            _selectedDate = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(widget.localizations.settingsClose),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoButton.filled(
                    onPressed: _canSubmit ? _submit : null,
                    child: Text(widget.localizations.settingsCurrencyRatesAdd),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualRateData {
  const _ManualRateData({
    required this.quoteCode,
    required this.rate,
    required this.date,
  });

  final String quoteCode;
  final double rate;
  final DateTime date;
}
