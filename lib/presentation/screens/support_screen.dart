import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:subctrl/application/support/fetch_donation_wallets_use_case.dart';
import 'package:subctrl/domain/entities/donation_wallet.dart';
import 'package:subctrl/presentation/l10n/app_localizations.dart';
import 'package:subctrl/presentation/theme/app_theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({
    super.key,
    required this.onClose,
    required this.fetchDonationWalletsUseCase,
  });

  final VoidCallback onClose;
  final FetchDonationWalletsUseCase fetchDonationWalletsUseCase;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late Future<List<DonationWallet>> _walletsFuture;

  @override
  void initState() {
    super.initState();
    _walletsFuture = widget.fetchDonationWalletsUseCase();
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

  void _reloadWallets() {
    setState(() {
      _walletsFuture = widget.fetchDonationWalletsUseCase();
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
        child: FutureBuilder<List<DonationWallet>>(
          future: _walletsFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                return _SupportMessageView(
                  message: localizations.settingsSupportLoading,
                  child: const CupertinoActivityIndicator(radius: 12),
                );
              case ConnectionState.none:
                return _SupportErrorView(
                  message: localizations.settingsSupportError,
                  retryLabel: localizations.settingsSupportRetry,
                  onRetry: _reloadWallets,
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return _SupportErrorView(
                    message: localizations.settingsSupportError,
                    retryLabel: localizations.settingsSupportRetry,
                    onRetry: _reloadWallets,
                  );
                }
                final wallets = snapshot.data ?? const [];
                if (wallets.isEmpty) {
                  return _SupportMessageView(
                    message: localizations.settingsSupportEmpty,
                  );
                }
                return ListView(
                  children: [
                    CupertinoFormSection.insetGrouped(
                      header: Text(localizations.settingsAboutSupport),
                      children: [
                        _DonationTile(
                          entries: wallets,
                          copyLabel: localizations.settingsCopyAction,
                          onCopy: _copyValue,
                        ),
                      ],
                    ),
                  ],
                );
            }
          },
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

  final List<DonationWallet> entries;
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
                          entries[i].address,
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
                    onPressed: () => onCopy(entries[i].address),
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

class _SupportMessageView extends StatelessWidget {
  const _SupportMessageView({required this.message, this.child});

  final String message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (child != null) ...[child!, const SizedBox(height: 12)],
            Text(
              message,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportErrorView extends StatelessWidget {
  const _SupportErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SupportMessageView(
      message: message,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        onPressed: onRetry,
        child: Text(retryLabel),
      ),
    );
  }
}
