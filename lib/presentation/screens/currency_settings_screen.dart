import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:subtrackr/domain/entities/currency.dart';
import 'package:subtrackr/infrastructure/persistence/database.dart';
import 'package:subtrackr/infrastructure/repositories/currency_repository.dart';
import 'package:subtrackr/presentation/formatters/currency_formatter.dart';
import 'package:subtrackr/presentation/l10n/app_localizations.dart';

enum CurrencyListCategory { builtIn, custom }

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({
    super.key,
    required this.onClose,
    required this.category,
  });

  final VoidCallback onClose;
  final CurrencyListCategory category;

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  late final CurrencyRepository _currencyRepository;
  StreamSubscription<List<Currency>>? _subscription;
  List<Currency> _currencies = const [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currencyRepository = CurrencyRepository(AppDatabase());
    unawaited(_listenCurrencies());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _listenCurrencies() async {
    await _currencyRepository.seedIfEmpty();
    _subscription?.cancel();
    _subscription = _currencyRepository.watchCurrencies().listen((currencies) {
      if (!mounted) return;
      setState(() {
        _currencies = currencies;
        _isLoading = false;
      });
    });
  }

  Future<void> _toggleCurrency(Currency currency, bool value) async {
    await _currencyRepository.setCurrencyEnabled(currency.code, value);
  }

  Future<void> _deleteCurrency(Currency currency) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(currencyDisplayLabel(currency)),
          content: Text(localizations.settingsCurrencyDeleteConfirm),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.settingsClose),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.deleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await _currencyRepository.deleteCustomCurrency(currency.code);
  }

  Future<void> _addCustomCurrency() async {
    final data = await _promptNewCurrency();
    if (data == null) return;
    try {
      await _currencyRepository.addCustomCurrency(
        code: data.code,
        name: data.name,
        symbol: data.symbol,
      );
    } on ArgumentError {
      final localizations = AppLocalizations.of(context);
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(localizations.settingsCurrenciesAddCustom),
            content: Text(localizations.settingsCurrencyDuplicateError),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localizations.settingsClose),
              ),
            ],
          );
        },
      );
    }
  }

  List<Currency> _filterByQuery(List<Currency> currencies) {
    final normalized = _searchQuery.trim().toLowerCase();
    if (normalized.isEmpty) {
      return currencies;
    }
    return currencies.where((currency) {
      final code = currency.code.toLowerCase();
      final name = currency.name.toLowerCase();
      final symbol = currency.symbol?.toLowerCase() ?? '';
      return code.contains(normalized) ||
          name.contains(normalized) ||
          symbol.contains(normalized);
    }).toList(growable: false);
  }

  Future<_NewCurrencyData?> _promptNewCurrency() async {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final symbolController = TextEditingController();

    bool isValid() {
      return codeController.text.trim().length >= 2 &&
          nameController.text.trim().isNotEmpty;
    }

    try {
      return await showCupertinoDialog<_NewCurrencyData>(
        context: context,
        builder: (context) {
          final localizations = AppLocalizations.of(context);
          return StatefulBuilder(
            builder: (context, setModalState) {
              return CupertinoAlertDialog(
                title: Text(localizations.settingsCurrenciesAddCustom),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    _DialogTextField(
                      controller: codeController,
                      placeholder: localizations.settingsCurrencyCodeLabel,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 8),
                    _DialogTextField(
                      controller: nameController,
                      placeholder: localizations.settingsCurrencyNameLabel,
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 8),
                    _DialogTextField(
                      controller: symbolController,
                      placeholder: localizations.settingsCurrencySymbolLabel,
                    ),
                  ],
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(localizations.settingsClose),
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: isValid()
                        ? () {
                            Navigator.of(context).pop(
                              _NewCurrencyData(
                                code: codeController.text.trim(),
                                name: nameController.text.trim(),
                                symbol: symbolController.text.trim().isEmpty
                                    ? null
                                    : symbolController.text.trim(),
                              ),
                            );
                          }
                        : null,
                    child: Text(localizations.settingsCurrencyAddAction),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      codeController.dispose();
      nameController.dispose();
      symbolController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isCustomCategory = widget.category == CurrencyListCategory.custom;
    final headerText = isCustomCategory
        ? localizations.settingsCurrenciesCustomList
        : localizations.settingsCurrenciesDefaultList;
    final relevantCurrencies = _currencies
        .where((currency) =>
            isCustomCategory ? currency.isCustom : !currency.isCustom)
        .toList(growable: false);
    final filtered = _filterByQuery(relevantCurrencies);
    final theme = CupertinoTheme.of(context).textTheme.textStyle;
    final Widget listContent;
    if (_isLoading) {
      listContent = const Center(child: CupertinoActivityIndicator());
    } else if (filtered.isEmpty) {
      listContent = Center(
        child: Text(
          localizations.currencySearchEmpty,
          style: theme,
        ),
      );
    } else {
      listContent = ListView(
        padding: EdgeInsets.zero,
        children: [
          CupertinoFormSection.insetGrouped(
            header: Text(headerText),
            children: filtered
                .map(
                  (currency) => _CurrencyRow(
                    currency: currency,
                    onChanged: (value) =>
                        unawaited(_toggleCurrency(currency, value)),
                    onDelete: isCustomCategory
                        ? () => unawaited(_deleteCurrency(currency))
                        : null,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      );
    }
    final searchField = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: CupertinoSearchTextField(
        controller: _searchController,
        placeholder: localizations.currencySearchPlaceholder,
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
    final bodyChildren = <Widget>[
      searchField,
      Expanded(child: listContent),
      if (isCustomCategory)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: _isLoading ? null : _addCustomCurrency,
              child: Text(localizations.settingsCurrenciesAddCustom),
            ),
          ),
        ),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(localizations.settingsCurrenciesTitle),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: widget.onClose,
          child: Text(localizations.settingsClose),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: bodyChildren,
        ),
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.currency,
    required this.onChanged,
    this.onDelete,
  });

  final Currency currency;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final baseStyle = textTheme.textStyle;
    final secondaryColor = CupertinoColors.systemGrey.resolveFrom(context);
    final symbol = currency.symbol?.trim();
    final codeLine = symbol != null && symbol.isNotEmpty
        ? '${currency.code.toUpperCase()} $symbol'
        : currency.code.toUpperCase();

    return CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefix: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              codeLine,
              style: baseStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              currency.name,
              style: baseStyle.copyWith(
                fontSize: 13,
                color: secondaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoSwitch(value: currency.isEnabled, onChanged: onChanged),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onDelete,
              child: const Icon(
                CupertinoIcons.delete,
                size: 22,
                color: CupertinoColors.systemRed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NewCurrencyData {
  const _NewCurrencyData({required this.code, required this.name, this.symbol});

  final String code;
  final String name;
  final String? symbol;
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.placeholder,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
    );
  }
}
