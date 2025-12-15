import 'package:flutter/cupertino.dart';

/// Centralized helpers for light/dark specific colors.
class AppTheme {
  const AppTheme._();

  static Brightness _effectiveBrightness(BuildContext context) {
    return CupertinoTheme.of(context).brightness ??
        MediaQuery.platformBrightnessOf(context);
  }

  static Color scaffoldBackgroundColor(BuildContext context) {
    final brightness = _effectiveBrightness(context);
    if (brightness == Brightness.light) {
      return CupertinoColors.systemGrey6;
    }
    return CupertinoColors.systemBackground.resolveFrom(context);
  }

  static Color cardBackgroundColor(BuildContext context) {
    final brightness = _effectiveBrightness(context);
    if (brightness == Brightness.light) {
      return CupertinoColors.white;
    }
    return CupertinoColors.systemGrey6.resolveFrom(context);
  }
}
