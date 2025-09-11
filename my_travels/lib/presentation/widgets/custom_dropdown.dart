import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;

  const CustomDropdown({
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
