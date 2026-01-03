import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';
import 'package:subctrl/presentation/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const _authorName = 'Denis Dementev';
  static const _authorUrl = 'https://gonfff.com';
  static const _projectsUrl = 'https://github.com/gonfff/subctrl';
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

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        // Ignore launch failures to keep the UI responsive.
      }
    }
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
                  onTap: () => _openUrl(_authorUrl),
                ),
                _LinkValueTile(
                  label: localizations.settingsAboutProjects,
                  value: _projectsUrl,
                  linkLabel: 'GitHub',
                  onTap: () => _openUrl(_projectsUrl),
                ),
                _LinkValueTile(
                  label: localizations.settingsAboutTelegram,
                  value: _telegramUrl,
                  linkLabel: '@gonff',
                  onTap: () => _openUrl(_telegramUrl),
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
  const _SettingsTile({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final secondary = CupertinoColors.systemGrey.resolveFrom(context);
    final linkColor = CupertinoColors.activeBlue.resolveFrom(context);
    final isLink = onTap != null;
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(label, style: textStyle)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          alignment: Alignment.centerRight,
          child: Text(
            value,
            style: textStyle.copyWith(
              color: isLink ? linkColor : secondary,
              fontSize: 15,
              decoration: isLink ? TextDecoration.underline : null,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
    final formRow = CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Semantics(button: isLink, child: row),
    );
    if (onTap == null) {
      return formRow;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: formRow,
    );
  }
}

class _LinkValueTile extends StatelessWidget {
  const _LinkValueTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.linkLabel,
  });

  final String label;
  final String value;
  final String? linkLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final linkColor = CupertinoColors.activeBlue.resolveFrom(context);
    return CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(label, style: textStyle)),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            alignment: Alignment.centerRight,
            onPressed: onTap,
            child: Text(
              linkLabel ?? value,
              style: textStyle.copyWith(
                fontSize: 15,
                color: linkColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
