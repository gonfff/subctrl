import 'package:flutter/cupertino.dart';

import 'package:subtrackr/presentation/l10n/app_localizations.dart';

class EmptySubscriptionsState extends StatelessWidget {
  const EmptySubscriptionsState({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    final secondaryColor = CupertinoColors.systemGrey.resolveFrom(context);
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.square_list, size: 56, color: secondaryColor),
          const SizedBox(height: 16),
          Text(
            localizations.emptyStateTitle,
            style: textStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.emptyStateMessage,
            style: textStyle.copyWith(color: secondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
