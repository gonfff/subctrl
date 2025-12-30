import 'package:flutter/cupertino.dart';

import 'package:subctrl/domain/entities/tag.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';
import 'package:subctrl/presentation/theme/app_theme.dart';
import 'package:subctrl/presentation/viewmodels/analytics_view_model.dart';

class AnalyticsFiltersSheet extends StatefulWidget {
  const AnalyticsFiltersSheet({
    super.key,
    required this.initialPeriod,
    required this.availableTags,
    required this.initialTagIds,
    required this.onClear,
  });

  final AnalyticsPeriod initialPeriod;
  final List<Tag> availableTags;
  final Set<int> initialTagIds;
  final VoidCallback onClear;

  @override
  State<AnalyticsFiltersSheet> createState() => _AnalyticsFiltersSheetState();
}

class AnalyticsFiltersResult {
  const AnalyticsFiltersResult({required this.period, required this.tagIds});

  final AnalyticsPeriod period;
  final Set<int> tagIds;
}

class _AnalyticsFiltersSheetState extends State<AnalyticsFiltersSheet> {
  static const List<AnalyticsPeriod> _periodOptions = [
    AnalyticsPeriod.month,
    AnalyticsPeriod.quarter,
    AnalyticsPeriod.year,
    AnalyticsPeriod.allTime,
  ];

  late AnalyticsPeriod _period;
  late Set<int> _selectedTagIds;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _period = widget.initialPeriod;
    _selectedTagIds = Set<int>.from(widget.initialTagIds);
  }

  void _apply() {
    if (_isClosing) return;
    _isClosing = true;
    Navigator.of(context).maybePop(
      AnalyticsFiltersResult(
        period: _period,
        tagIds: Set<int>.from(_selectedTagIds),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final backgroundColor = AppTheme.scaffoldBackgroundColor(context);
    final handleColor = CupertinoColors.systemGrey4.resolveFrom(context);

    return PopScope(
      canPop: _isClosing,
      onPopInvoked: (didPop) {
        if (didPop) {
          _isClosing = false;
          return;
        }
        _apply();
      },
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 250) {
            _apply();
          }
        },
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.75,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: Container(
                color: backgroundColor,
                child: SafeArea(
                  top: false,
                  child: Column(
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
                      const SizedBox(height: 12),
                      _FiltersHeader(onClose: _apply),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          children: [
                            _PeriodSection(
                              selected: _period,
                              onSelected: (cycle) {
                                setState(() {
                                  _period = cycle;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            _TagsSection(
                              tags: widget.availableTags,
                              selected: _selectedTagIds,
                              onToggle: (tagId) {
                                setState(() {
                                  if (_selectedTagIds.contains(tagId)) {
                                    _selectedTagIds.remove(tagId);
                                  } else {
                                    _selectedTagIds.add(tagId);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: () {
                              setState(() {
                                _period = AnalyticsPeriod.allTime;
                                _selectedTagIds.clear();
                              });
                              widget.onClear();
                            },
                            child: Text(localizations.analyticsFiltersClear),
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

class _FiltersHeader extends StatelessWidget {
  const _FiltersHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = CupertinoTheme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            localizations.analyticsFiltersTitle,
            style: textTheme.navTitleTextStyle,
          ),
          const Spacer(),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onClose,
            child: Icon(
              CupertinoIcons.clear_circled_solid,
              size: 28,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSection extends StatelessWidget {
  const _PeriodSection({required this.selected, required this.onSelected});

  final AnalyticsPeriod selected;
  final ValueChanged<AnalyticsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.analyticsFiltersPeriodTitle,
          style: textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _AnalyticsFiltersSheetState._periodOptions.map((period) {
            final label = switch (period) {
              AnalyticsPeriod.month => localizations.analyticsPeriodMonth,
              AnalyticsPeriod.quarter => localizations.analyticsPeriodQuarter,
              AnalyticsPeriod.year => localizations.analyticsPeriodYear,
              AnalyticsPeriod.allTime => localizations.analyticsPeriodAllTime,
            };
            final isSelected = period == selected;
            return _FilterChip(
              label: label,
              selected: isSelected,
              onPressed: () => onSelected(period),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TagsSection extends StatelessWidget {
  const _TagsSection({
    required this.tags,
    required this.selected,
    required this.onToggle,
  });

  final List<Tag> tags;
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final placeholderStyle = textStyle.copyWith(
      color: CupertinoColors.systemGrey.resolveFrom(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.analyticsFiltersTagsTitle,
          style: textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (tags.isEmpty)
          Text(localizations.analyticsFiltersTagsEmpty, style: placeholderStyle)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => _TagChip(
                    label: tag.name,
                    selected: selected.contains(tag.id),
                    color: _colorFromHex(tag.colorHex),
                    onPressed: () => onToggle(tag.id),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? color
        : CupertinoColors.systemGrey4.resolveFrom(context);
    final textColor = selected
        ? color
        : CupertinoColors.label.resolveFrom(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6.resolveFrom(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

Color _colorFromHex(String hexColor) {
  var hex = hexColor.replaceFirst('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? CupertinoColors.activeBlue.resolveFrom(context)
        : CupertinoColors.systemGrey5.resolveFrom(context);
    final textColor = selected
        ? CupertinoColors.white
        : CupertinoColors.label.resolveFrom(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
