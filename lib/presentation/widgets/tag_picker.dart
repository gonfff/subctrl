import 'package:flutter/cupertino.dart';

import 'package:subctrl/domain/entities/tag.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';

Future<int?> showTagPicker({
  required BuildContext context,
  required List<Tag> tags,
  int? selectedTagId,
  bool allowNoTag = true,
}) {
  final localizations = AppLocalizations.of(context);
  String query = '';

  return showCupertinoModalPopup<int?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final backgroundColor = CupertinoColors.systemBackground.resolveFrom(
            context,
          );
          final filtered = tags
              .where((tag) {
                if (query.isEmpty) return true;
                final normalized = query.toLowerCase();
                return tag.name.toLowerCase().contains(normalized);
              })
              .toList(growable: false);

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            color: backgroundColor,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            localizations.tagPickerTitle,
                            style: CupertinoTheme.of(
                              context,
                            ).textTheme.navTitleTextStyle,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(localizations.settingsClose),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: CupertinoSearchTextField(
                      placeholder: localizations.tagSearchPlaceholder,
                      onChanged: (value) => setModalState(() => query = value),
                    ),
                  ),
                  if (allowNoTag)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        onPressed: () => Navigator.of(context).pop(-1),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(localizations.subscriptionTagNone),
                        ),
                      ),
                    ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              localizations.tagSearchEmpty,
                              style: CupertinoTheme.of(
                                context,
                              ).textTheme.textStyle,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemBuilder: (context, index) {
                              final tag = filtered[index];
                              final isSelected =
                                  selectedTagId != null &&
                                  tag.id == selectedTagId;
                              return CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () =>
                                    Navigator.of(context).pop(tag.id),
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
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: _colorFromHex(tag.colorHex),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          tag.name,
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
                            itemCount: filtered.length,
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Color _colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '').padLeft(6, '0');
  final value = int.parse(normalized, radix: 16);
  return Color(0xFF000000 | value);
}
