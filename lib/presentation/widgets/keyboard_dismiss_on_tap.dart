import 'package:flutter/cupertino.dart';

/// Wraps a subtree and dismisses the keyboard when tapping outside of inputs.
class KeyboardDismissOnTap extends StatelessWidget {
  const KeyboardDismissOnTap({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.unfocus();
        }
      },
      child: child,
    );
  }
}
