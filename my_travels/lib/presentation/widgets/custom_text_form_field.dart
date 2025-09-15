// In lib/presentation/widgets/custom_text_form_field.dart

import 'package:flutter/material.dart';

/// A customized, reusable text form field with a consistent style.
class CustomTextFormField extends StatelessWidget {
  /// The text to display as the label for the field.
  final String labelText;

  /// The controller for the text field.
  final TextEditingController controller;

  /// The maximum number of characters allowed.
  final int? maxLength;

  /// The validation function for the field's input.
  final String? Function(String?)? validator;

  /// The type of keyboard to display.
  final TextInputType keyboardType;

  /// If `true`, uses a light color scheme suitable for dark backgrounds.
  final bool onDarkMode;

  /// Creates an instance of [CustomTextFormField].
  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.controller,
    this.maxLength,
    this.validator,
    this.keyboardType = TextInputType.text,
    // Defaults to `false`, so you don't need to change anything on other screens.
    this.onDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // If onDarkMode is true, use a specific light color scheme.
    // Otherwise, use the app's default theme color scheme.
    final colorScheme = onDarkMode
        ? const ColorScheme.dark(
            primary: Colors.white, // Focus color
            onSurface: Colors.white, // Typed text color
            onSurfaceVariant: Colors.white70, // Label/hint color
            outline: Colors.white54, // Border color
            error: Color.fromARGB(255, 122, 32, 26), // Light error color
          )
        : Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        errorStyle: TextStyle(color: colorScheme.error),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
