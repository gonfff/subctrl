import 'package:flutter/cupertino.dart';

import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/presentation/formatters/currency_formatter.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';

Future<String?> showCurrencyPicker({
  required BuildContext context,
  required List<Currency> currencies,
  String? selectedCode,
  bool showSearch = true,
}) {
  final localizations = AppLocalizations.of(context);
  String query = '';
  final normalizedSelected = selectedCode?.toUpperCase();

  return showCupertinoModalPopup<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final backgroundColor = CupertinoColors.systemBackground.resolveFrom(
            context,
          );
          final filtered = currencies.where((currency) {
            if (query.isEmpty) return true;
            final normalizedQuery = query.toLowerCase();
            final label = currencyDisplayLabel(currency).toLowerCase();
            return label.contains(normalizedQuery);
          }).toList();

          final visibleCurrencies = showSearch ? filtered : currencies;
          return CupertinoActionSheet(
            title: Text(localizations.currencyPickerTitle),
            message: SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: [
                  if (showSearch) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CupertinoSearchTextField(
                        placeholder: localizations.currencySearchPlaceholder,
                        onChanged: (value) =>
                            setModalState(() => query = value),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Expanded(
                    child: visibleCurrencies.isEmpty
                        ? Center(
                            child: Text(
                              localizations.currencySearchEmpty,
                              style: CupertinoTheme.of(
                                context,
                              ).textTheme.textStyle,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            itemBuilder: (context, index) {
                              final currency = visibleCurrencies[index];
                              final code = currency.code;
                              final isSelected =
                                  normalizedSelected != null &&
                                  code.toUpperCase() == normalizedSelected;

                              return CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () =>
                                    Navigator.of(context).pop(code),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? CupertinoColors.systemGrey5
                                              .resolveFrom(context)
                                        : backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          currencyDisplayLabel(currency),
                                          style: CupertinoTheme.of(
                                            context,
                                          ).textTheme.textStyle,
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          CupertinoIcons.check_mark,
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemCount: visibleCurrencies.length,
                          ),
                  ),
                ],
              ),
            ),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.settingsClose),
            ),
          );
        },
      );
    },
  );
}
