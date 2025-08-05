import 'package:flutter/material.dart';

abstract class AppButtonStyles {
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
  static final ButtonStyle saveButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF43AA8B),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
  static final ButtonStyle deleteButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF9C3133),
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
