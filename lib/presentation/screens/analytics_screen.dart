import 'package:flutter/cupertino.dart';

import 'package:subtrackr/presentation/l10n/app_localizations.dart';
import 'package:subtrackr/presentation/theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor(context),
      navigationBar: CupertinoNavigationBar(
        middle: Text(localizations.analyticsTitle),
        border: null,
      ),
      child: SafeArea(
        child: Center(
          child: Text(
            localizations.analyticsPlaceholder,
            textAlign: TextAlign.center,
            style: textStyle.copyWith(
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
        ),
      ),
    );
  }
}
