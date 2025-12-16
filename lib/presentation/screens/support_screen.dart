import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:subctrl/presentation/l10n/app_localizations.dart';
import 'package:subctrl/presentation/theme/app_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const List<_DonationEntry> _donations = [
    _DonationEntry(
      label: 'BTC',
      value: 'bc1qjtjzlxel5mn3pvtps2u2wnfease44783r5nmhl',
    ),
    _DonationEntry(
      label: 'USDT (TRON)',
      value: '0xDf3275d97DF7Ba76d12ec0F82378C1e0628A5F6F',
    ),
    _DonationEntry(
      label: 'ETH',
      value: '0xDf3275d97DF7Ba76d12ec0F82378C1e0628A5F6F',
    ),
    _DonationEntry(
      label: 'TON',
      value: 'UQCYgQSiRx5pk5E0ALzhz6WsFjuK3SyPiAe7vYG5uhidsyqj',
    ),
  ];

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
        middle: Text(localizations.settingsAboutSupport),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: Text(localizations.settingsAboutSupport),
              children: [
                _DonationTile(
                  entries: _donations,
                  copyLabel: localizations.settingsCopyAction,
                  onCopy: _copyValue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DonationTile extends StatelessWidget {
  const _DonationTile({
    required this.entries,
    required this.copyLabel,
    required this.onCopy,
  });

  final List<_DonationEntry> entries;
  final String copyLabel;
  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final secondary = CupertinoColors.systemGrey.resolveFrom(context);
    return CupertinoFormRow(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == entries.length - 1 ? 0 : 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entries[i].label,
                          style: textStyle.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entries[i].value,
                          style: textStyle.copyWith(
                            fontSize: 13,
                            color: secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    onPressed: () => onCopy(entries[i].value),
                    child: Text(copyLabel),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DonationEntry {
  const _DonationEntry({required this.label, required this.value});

  final String label;
  final String value;
}
