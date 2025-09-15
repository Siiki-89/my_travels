import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

/// A customized, reusable dropdown widget based on the `dropdown_button2` package.
class CustomDropdown<T> extends StatelessWidget {
  /// The text displayed as a hint when no value is selected.
  final String hintText;

  /// The currently selected value of the dropdown.
  final T? value;

  /// The list of items to display in the dropdown.
  final List<DropdownMenuItem<T>> items;

  /// The callback that is executed when a new item is selected.
  final void Function(T?)? onChanged;

  /// Creates an instance of [CustomDropdown].
  const CustomDropdown({
    super.key,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DropdownButton2<T>(
      isExpanded: true,
      hint: Text(
        hintText,
        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
      buttonStyleData: ButtonStyleData(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      ),
      menuItemStyleData: const MenuItemStyleData(height: 40),
    );
  }
}
