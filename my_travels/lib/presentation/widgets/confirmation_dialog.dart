// In lib/presentation/widgets/confirmation_dialog.dart

import 'package:flutter/material.dart';
import 'package:my_travels/presentation/styles/app_button_styles.dart';

/// A generic dialog for confirming an action.
class ConfirmationDialog extends StatelessWidget {
  /// The title displayed at the top of the dialog.
  final String title;

  /// The main content or question of the dialog.
  final String content;

  /// The text for the confirmation button (e.g., "Delete", "Confirm").
  final String confirmText;

  /// The text for the cancellation button (e.g., "Cancel").
  final String cancelText;

  /// The callback function to execute when the confirmation button is pressed.
  final VoidCallback onConfirm;

  /// Creates an instance of [ConfirmationDialog].
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButtonStyle,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      cancelText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: AppButtonStyles.primaryButtonStyle,
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      onConfirm(); // Execute the action
                    },
                    child: Text(
                      confirmText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
