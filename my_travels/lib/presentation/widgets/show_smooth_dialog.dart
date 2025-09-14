// In lib/presentation/widgets/show_smooth_dialog.dart

import 'package:flutter/material.dart';

/// Displays a dialog with a smooth scale and fade transition.
///
/// This function wraps Flutter's [showGeneralDialog] to provide a
/// consistent and pleasant animation for all dialogs in the app.
Future<T?> showSmoothDialog<T>({
  required BuildContext context,
  required Widget dialog,
  Duration duration = const Duration(milliseconds: 300),
  bool isDismissible = false,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierLabel: "Dialog",
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return Transform.scale(
        scale: curvedAnimation.value,
        child: Opacity(opacity: animation.value, child: dialog),
      );
    },
    transitionDuration: duration,
  );
}
