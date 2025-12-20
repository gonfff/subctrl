import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:subctrl/presentation/l10n/app_localizations.dart';
import 'package:subctrl/presentation/theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const _authorName = 'Denis Dementev';
  static const _projectsUrl = 'https://gonfff.github.io';
  static const _telegramUrl = 'https://t.me/gonff';

  String? _version;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _version = '${info.version}+${info.buildNumber}';
      });
    } catch (_) {
      // Ignore errors; the UI will fallback to "unknown".
    }
  }

  Future<void> _copyValue(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    await HapticFeedback.selectionClick();
  }

  void _handleBackPressed() {
    Navigator.of(context).maybePop().then((didPop) {
      if (!didPop) {
        widget.onClose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: CupertinoNavigationBarBackButton(
          onPressed: _handleBackPressed,
        ),
        middle: Text(localizations.settingsAboutSection),
        trailing: null,
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: Text(localizations.settingsAboutSection),
              children: [
                _SettingsTile(
                  label: localizations.settingsAboutVersion,
                  value: _version ?? localizations.settingsVersionUnknown,
                ),
                _SettingsTile(
                  label: localizations.settingsAboutAuthor,
                  value: _authorName,
                ),
                _CopyableValueTile(
                  label: localizations.settingsAboutProjects,
                  value: _projectsUrl,
                  copyLabel: localizations.settingsCopyAction,
                  onCopy: () => _copyValue(_projectsUrl),
                ),
                _CopyableValueTile(
                  label: localizations.settingsAboutTelegram,
                  value: _telegramUrl,
                  copyLabel: localizations.settingsCopyAction,
                  onCopy: () => _copyValue(_telegramUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final secondary = CupertinoColors.systemGrey.resolveFrom(context);
    return CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(label, style: textStyle)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: textStyle.copyWith(color: secondary, fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyableValueTile extends StatelessWidget {
  const _CopyableValueTile({
    required this.label,
    required this.value,
    required this.copyLabel,
    required this.onCopy,
  });

  final String label;
  final String value;
  final String copyLabel;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final secondary = CupertinoColors.systemGrey.resolveFrom(context);
    return CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textStyle),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textStyle.copyWith(fontSize: 13, color: secondary),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onPressed: onCopy,
            child: Text(copyLabel),
          ),
        ],
      ),
    );
  }
}
