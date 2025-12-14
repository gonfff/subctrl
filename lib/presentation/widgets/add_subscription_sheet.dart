import 'package:flutter/cupertino.dart';
import 'package:subtrackr/domain/entities/currency.dart';
import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/domain/entities/tag.dart';
import 'package:subtrackr/presentation/formatters/date_formatter.dart';
import 'package:subtrackr/presentation/l10n/app_localizations.dart';
import 'package:subtrackr/presentation/mappers/billing_cycle_labels.dart';
import 'package:subtrackr/presentation/widgets/currency_picker.dart';
import 'package:subtrackr/presentation/widgets/tag_picker.dart';

class AddSubscriptionSheet extends StatefulWidget {
  const AddSubscriptionSheet({
    super.key,
    required this.currencies,
    this.defaultCurrencyCode,
    required this.tags,
    this.initialSubscription,
  });

  final List<Currency> currencies;
  final String? defaultCurrencyCode;
  final List<Tag> tags;
  final Subscription? initialSubscription;

  @override
  State<AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class SubscriptionSheetResult {
  const SubscriptionSheetResult({this.subscription, this.deleted = false});

  final Subscription? subscription;
  final bool deleted;
}

class _AddSubscriptionSheetState extends State<AddSubscriptionSheet> {
  static const _orderedCycles = [
    BillingCycle.daily,
    BillingCycle.weekly,
    BillingCycle.biweekly,
    BillingCycle.fourWeekly,
    BillingCycle.monthly,
    BillingCycle.quarterly,
    BillingCycle.semiannual,
    BillingCycle.yearly,
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  late BillingCycle _cycle;
  late String _currencyCode;
  late DateTime _purchaseDate;
  int? _selectedTagId;
  bool _isSaving = false;
  late bool _isActive;

  Map<String, Currency> _currencyMap = {};

  bool get _isEditing => widget.initialSubscription != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSubscription;
    _purchaseDate = initial?.purchaseDate ?? DateTime.now();
    _cycle = initial?.cycle ?? BillingCycle.monthly;
    _currencyCode =
        widget.defaultCurrencyCode?.toUpperCase() ??
        (widget.currencies.isNotEmpty
            ? widget.currencies.first.code.toUpperCase()
            : 'USD');
    if (initial != null) {
      _nameController.text = initial.name;
      _amountController.text = initial.amount.toStringAsFixed(2);
      _currencyCode = initial.currency.toUpperCase();
      _selectedTagId = initial.tagId;
      _isActive = initial.isActive;
    } else {
      _selectedTagId = null;
      _isActive = true;
    }
    _hydrateCurrencies();
  }

  @override
  void didUpdateWidget(covariant AddSubscriptionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currencies != widget.currencies) {
      _hydrateCurrencies();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _hydrateCurrencies() {
    _currencyMap = {
      for (final currency in widget.currencies)
        currency.code.toUpperCase(): currency,
    };
    if (_currencyMap.isEmpty) return;
    if (!_currencyMap.containsKey(_currencyCode.toUpperCase())) {
      _currencyCode = widget.currencies.first.code.toUpperCase();
    }
  }

  Currency? get _selectedCurrency => _currencyMap[_currencyCode];

  DateTime? get _nextPaymentDate => _cycle.nextPaymentDate(_purchaseDate);

  double _parseAmount(String text) {
    final normalized = text.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  Future<void> _pickCurrency(FormFieldState<String> state) async {
    final selected = await showCurrencyPicker(
      context: context,
      currencies: widget.currencies,
      selectedCode: _currencyCode,
    );
    if (selected != null) {
      setState(() => _currencyCode = selected.toUpperCase());
      state.didChange(_currencyCode);
    }
  }

  Future<void> _pickCycle(FormFieldState<BillingCycle> state) async {
    final localizations = AppLocalizations.of(context);
    final cycle = await showCupertinoModalPopup<BillingCycle>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(localizations.periodLabel),
          actions: [
            for (final option in _orderedCycles)
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(option),
                child: Text(billingCycleLongLabel(option, localizations)),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.settingsClose),
          ),
        );
      },
    );
    if (cycle != null) {
      setState(() => _cycle = cycle);
      state.didChange(cycle);
    }
  }

  Future<void> _pickPurchaseDate(FormFieldState<DateTime?> state) async {
    var tempDate = _purchaseDate;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        final background = CupertinoColors.systemBackground.resolveFrom(
          context,
        );
        return Container(
          color: background,
          height: 320,
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(localizations.done),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate,
                  minimumDate: DateTime(DateTime.now().year - 10),
                  maximumDate: DateTime(DateTime.now().year + 5),
                  onDateTimeChanged: (value) => tempDate = value,
                ),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    setState(() => _purchaseDate = tempDate);
    state.didChange(tempDate);
  }

  Future<void> _pickTag(FormFieldState<int?> state) async {
    if (widget.tags.isEmpty) return;
    final result = await showTagPicker(
      context: context,
      tags: widget.tags,
      selectedTagId: _selectedTagId,
    );
    if (result == null) return;
    if (!mounted) return;
    if (result == -1) {
      setState(() => _selectedTagId = null);
      state.didChange(null);
    } else {
      setState(() => _selectedTagId = result);
      state.didChange(result);
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final nextPayment = _nextPaymentDate;
    if (nextPayment == null) return;

    final initial = widget.initialSubscription;
    final subscription = Subscription(
      id: initial?.id,
      name: _nameController.text.trim(),
      amount: _parseAmount(_amountController.text),
      currency: _currencyCode,
      cycle: _cycle,
      purchaseDate: _purchaseDate,
      nextPaymentDate: nextPayment,
      isActive: _isActive,
      statusChangedAt: initial?.statusChangedAt ?? DateTime.now(),
      tagId: _selectedTagId,
    );

    if (_isSaving) return;
    setState(() => _isSaving = true);
    Navigator.of(
      context,
    ).pop(SubscriptionSheetResult(subscription: subscription));
  }

  Future<void> _handleDelete() async {
    final initial = widget.initialSubscription;
    if (initial?.id == null) return;

    final localizations = AppLocalizations.of(context);
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(localizations.subscriptionDeleteConfirm),
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

    if (!mounted) return;
    if (confirmed == true) {
      Navigator.of(
        context,
      ).pop(SubscriptionSheetResult(subscription: initial, deleted: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    final background = CupertinoColors.systemGroupedBackground.resolveFrom(
      context,
    );
    final sectionBackground = CupertinoColors.secondarySystemGroupedBackground
        .resolveFrom(context);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final handleColor = CupertinoColors.systemGrey4.resolveFrom(context);

    const prefixWidth = 132.0;
    const rowPadding = EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12);
    final sectionRadius = BorderRadius.circular(16);

    Widget prefix(String text) => SizedBox(
      width: prefixWidth,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );

    String tagName() {
      if (_selectedTagId == null) return localizations.subscriptionTagNone;
      for (final tag in widget.tags) {
        if (tag.id == _selectedTagId) return tag.name;
      }
      return localizations.subscriptionTagNone;
    }

    Widget pickerRow({
      required String label,
      required String value,
      required VoidCallback? onTap,
      String? helperText,
      bool enabled = true,
    }) {
      final accent = CupertinoTheme.of(context).primaryColor;
      final disabled = CupertinoColors.systemGrey.resolveFrom(context);

      final valueStyle = CupertinoTheme.of(
        context,
      ).textTheme.textStyle.copyWith(color: enabled ? null : disabled);

      return CupertinoFormRow(
        padding: rowPadding,
        prefix: prefix(label),
        helper: helperText == null ? null : Text(helperText),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          alignment: Alignment.centerRight,
          onPressed: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 16,
                color: enabled ? accent : disabled,
              ),
            ],
          ),
        ),
      );
    }

    // Скругление insetGrouped надежнее делать через ClipRRect.
    Widget roundedSection({required List<Widget> children, Widget? header}) {
      final section = CupertinoFormSection.insetGrouped(
        margin: EdgeInsets.zero,
        header: header,
        decoration: BoxDecoration(color: sectionBackground),
        backgroundColor: sectionBackground,
        children: children,
      );

      return ClipRRect(borderRadius: sectionRadius, child: section);
    }

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 250) {
          Navigator.of(context).maybePop();
        }
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: viewInsets),
            child: CupertinoPopupSurface(
              isSurfacePainted: true,
              child: Container(
                color: background,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: handleColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.of(context).maybePop(),
                              child: Text(localizations.settingsClose),
                            ),
                            Text(
                              _isEditing
                                  ? localizations.editSubscriptionTitle
                                  : localizations.newSubscriptionTitle,
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .copyWith(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _isSaving ? null : _handleSubmit,
                              child: Text(
                                _isEditing
                                    ? localizations.done
                                    : localizations.addAction,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoScrollbar(
                          child: Form(
                            key: _formKey,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                12,
                                20,
                                32,
                              ),
                              children: [
                                roundedSection(
                                  children: [
                                    CupertinoTextFormFieldRow(
                                      padding: rowPadding,
                                      controller: _nameController,
                                      placeholder: localizations
                                          .subscriptionNamePlaceholder,
                                      prefix: prefix(
                                        localizations.subscriptionNameLabel,
                                      ),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      textAlign: TextAlign.right,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return localizations
                                              .subscriptionNameError;
                                        }
                                        return null;
                                      },
                                    ),
                                    CupertinoTextFormFieldRow(
                                      padding: rowPadding,
                                      controller: _amountController,
                                      placeholder:
                                          localizations.amountPlaceholder,
                                      prefix: prefix(localizations.amountLabel),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.right,
                                      validator: (value) {
                                        if (_parseAmount(value ?? '') <= 0) {
                                          return localizations.amountError;
                                        }
                                        return null;
                                      },
                                    ),
                                    FormField<String>(
                                      initialValue: _currencyCode,
                                      builder: (state) {
                                        final selected = _selectedCurrency;
                                        final value =
                                            selected?.code ?? _currencyCode;
                                        final enabled =
                                            widget.currencies.isNotEmpty;
                                        return pickerRow(
                                          label: localizations.currencyLabel,
                                          value: value,
                                          enabled: enabled,
                                          helperText: state.hasError
                                              ? state.errorText
                                              : null,
                                          onTap: enabled
                                              ? () => _pickCurrency(state)
                                              : null,
                                        );
                                      },
                                    ),
                                    FormField<BillingCycle>(
                                      initialValue: _cycle,
                                      builder: (state) {
                                        return pickerRow(
                                          label: localizations.periodLabel,
                                          value: billingCycleLongLabel(
                                            _cycle,
                                            localizations,
                                          ),
                                          onTap: () => _pickCycle(state),
                                        );
                                      },
                                    ),
                                    FormField<DateTime?>(
                                      initialValue: _purchaseDate,
                                      validator: (value) {
                                        if (value == null) {
                                          return localizations
                                              .purchaseDateError;
                                        }
                                        return null;
                                      },
                                      builder: (state) {
                                        return pickerRow(
                                          label:
                                              localizations.purchaseDateLabel,
                                          value: formatDate(
                                            _purchaseDate,
                                            locale,
                                          ),
                                          helperText: state.hasError
                                              ? state.errorText
                                              : null,
                                          onTap: () => _pickPurchaseDate(state),
                                        );
                                      },
                                    ),
                                    FormField<int?>(
                                      initialValue: _selectedTagId,
                                      builder: (state) {
                                        final hasTags = widget.tags.isNotEmpty;
                                        return pickerRow(
                                          label: localizations
                                              .subscriptionTagLabel,
                                          value: tagName(),
                                          enabled: hasTags,
                                          onTap: hasTags
                                              ? () => _pickTag(state)
                                              : null,
                                        );
                                      },
                                    ),
                                    if (_isEditing)
                                      CupertinoFormRow(
                                        padding: rowPadding,
                                        prefix: prefix(
                                          localizations.subscriptionActiveLabel,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: CupertinoSwitch(
                                            value: _isActive,
                                            onChanged: (value) => setState(
                                              () => _isActive = value,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                roundedSection(
                                  children: [
                                    CupertinoFormRow(
                                      padding: rowPadding,
                                      prefix: prefix(
                                        localizations.nextPaymentLabel,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _nextPaymentDate == null
                                              ? localizations
                                                    .nextPaymentPlaceholder
                                              : formatDate(
                                                  _nextPaymentDate!,
                                                  locale,
                                                ),
                                          textAlign: TextAlign.right,
                                          style: CupertinoTheme.of(context)
                                              .textTheme
                                              .textStyle
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: CupertinoColors
                                                    .systemGrey
                                                    .resolveFrom(context),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isEditing)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: CupertinoButton(
                                      onPressed: _handleDelete,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        localizations.deleteAction,
                                        style: TextStyle(
                                          color: CupertinoColors.systemRed
                                              .resolveFrom(context),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
