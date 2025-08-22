import 'package:flutter/material.dart';

Future<void> showSmoothDialog(
  BuildContext context,
  Widget dialog, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
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
