import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:subctrl/application/app_dependencies.dart';
import 'package:subctrl/domain/entities/tag.dart';
import 'package:subctrl/domain/exceptions/duplicate_tag_name_exception.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';
import 'package:subctrl/presentation/theme/app_theme.dart';
import 'package:subctrl/presentation/theme/tag_colors.dart';
import 'package:subctrl/presentation/viewmodels/tag_settings_view_model.dart';

class TagSettingsScreen extends StatefulWidget {
  const TagSettingsScreen({
    super.key,
    required this.dependencies,
    required this.onClose,
  });

  final AppDependencies dependencies;
  final VoidCallback onClose;

  @override
  State<TagSettingsScreen> createState() => _TagSettingsScreenState();
}

class _TagSettingsScreenState extends State<TagSettingsScreen> {
  late final TagSettingsViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _viewModel = TagSettingsViewModel(
      watchTagsUseCase: widget.dependencies.watchTagsUseCase,
      createTagUseCase: widget.dependencies.createTagUseCase,
      updateTagUseCase: widget.dependencies.updateTagUseCase,
      deleteTagUseCase: widget.dependencies.deleteTagUseCase,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addTag() async {
    final data = await _promptTagForm();
    if (data == null) return;
    try {
      await _viewModel.createTag(name: data.name, colorHex: data.colorHex);
    } on DuplicateTagNameException {
      if (!mounted) return;
      await _showDuplicateNameError();
    }
  }

  Future<void> _editTag(Tag tag) async {
    final data = await _promptTagForm(initial: tag);
    if (data == null) return;
    try {
      await _viewModel.updateTag(
        tag.copyWith(name: data.name, colorHex: data.colorHex),
      );
    } on DuplicateTagNameException {
      if (!mounted) return;
      await _showDuplicateNameError();
    }
  }

  Future<void> _deleteTag(Tag tag) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(tag.name),
          content: Text(localizations.settingsTagDeleteConfirm),
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
    if (confirmed == true) {
      await _viewModel.deleteTag(tag.id);
    }
  }

  Future<_TagFormData?> _promptTagForm({Tag? initial}) async {
    final controller = TextEditingController(text: initial?.name ?? '');
    var selectedColor = initial?.colorHex ?? tagColorOptions.first.hex;

    bool isValid() => controller.text.trim().isNotEmpty;

    try {
      return await showCupertinoDialog<_TagFormData>(
        context: context,
        builder: (context) {
          final localizations = AppLocalizations.of(context);
          return StatefulBuilder(
            builder: (context, setModalState) {
              return CupertinoAlertDialog(
                title: Text(
                  initial == null
                      ? localizations.settingsTagsAdd
                      : localizations.settingsTagsEdit,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: controller,
                      placeholder: localizations.settingsTagNameLabel,
                      onChanged: (_) => setModalState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizations.settingsTagColorLabel,
                        style: CupertinoTheme.of(
                          context,
                        ).textTheme.textStyle.copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tagColorOptions.map((option) {
                        final isSelected =
                            option.hex.toUpperCase() ==
                            selectedColor.toUpperCase();
                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedColor = option.hex),
                          child: _ColorSwatch(
                            color: option.color,
                            isSelected: isSelected,
                          ),
                        );
                      }).toList(),
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
                              _TagFormData(
                                name: controller.text.trim(),
                                colorHex: selectedColor.toUpperCase(),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      initial == null
                          ? localizations.settingsTagsAdd
                          : localizations.settingsTagsEdit,
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = CupertinoTheme.of(context).textTheme.textStyle;

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final filtered = _filterTags(_viewModel.tags);
        final isLoading = _viewModel.isLoading;

        final Widget listContent;
        if (isLoading) {
          listContent = const Center(child: CupertinoActivityIndicator());
        } else if (filtered.isEmpty) {
          listContent = Center(
            child: Text(localizations.settingsTagEmpty, style: textTheme),
          );
        } else {
          listContent = ListView(
            padding: EdgeInsets.zero,
            children: [
              CupertinoFormSection.insetGrouped(
                header: Text(localizations.settingsTagsTitle),
                children: filtered
                    .map(
                      (tag) => _TagRow(
                        tag: tag,
                        onEdit: () => unawaited(_editTag(tag)),
                        onDelete: () => unawaited(_deleteTag(tag)),
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
            placeholder: localizations.settingsTagSearchPlaceholder,
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        );

        final addButton = Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: isLoading ? null : () => unawaited(_addTag()),
              child: Text(localizations.settingsTagsAdd),
            ),
          ),
        );

        return CupertinoPageScaffold(
          backgroundColor: AppTheme.scaffoldBackgroundColor(context),
          navigationBar: CupertinoNavigationBar(
            automaticallyImplyLeading: false,
            leading: CupertinoNavigationBarBackButton(
              onPressed: _handleBackPressed,
            ),
            middle: Text(localizations.settingsTagsTitle),
          ),
          child: SafeArea(
            child: Column(
              children: [
                searchField,
                Expanded(child: listContent),
                addButton,
              ],
            ),
          ),
        );
      },
    );
  }

  List<Tag> _filterTags(List<Tag> tags) {
    final normalized = _searchQuery.trim().toLowerCase();
    if (normalized.isEmpty) {
      return tags;
    }
    return tags
        .where((tag) => tag.name.toLowerCase().contains(normalized))
        .toList(growable: false);
  }

  Future<void> _showDuplicateNameError() {
    final localizations = AppLocalizations.of(context);
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(localizations.settingsTagsAdd),
          content: Text(localizations.settingsTagDuplicateError),
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

  void _handleBackPressed() {
    Navigator.of(context).maybePop().then((didPop) {
      if (!didPop) {
        widget.onClose();
      }
    });
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({
    required this.tag,
    required this.onEdit,
    required this.onDelete,
  });

  final Tag tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(tag.colorHex);
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;

    return CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefix: Row(
        children: [
          _ColorIndicator(color: color),
          const SizedBox(width: 12),
          Text(
            tag.name,
            style: textStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onEdit,
            child: const Icon(CupertinoIcons.pencil, size: 20),
          ),
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
      ),
    );
  }
}

class _ColorIndicator extends StatelessWidget {
  const _ColorIndicator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: CupertinoColors.systemGrey4.resolveFrom(context),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.isSelected});

  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? CupertinoColors.activeBlue.resolveFrom(context)
              : CupertinoColors.systemGrey4.resolveFrom(context),
          width: isSelected ? 3 : 1,
        ),
      ),
    );
  }
}

class _TagFormData {
  const _TagFormData({required this.name, required this.colorHex});

  final String name;
  final String colorHex;
}

Color _colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '').padLeft(6, '0');
  final value = int.parse(normalized, radix: 16);
  return Color(0xFF000000 | value);
}
