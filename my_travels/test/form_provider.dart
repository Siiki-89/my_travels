import 'package:flutter/material.dart';

class FormProvider extends ChangeNotifier {
  bool isExpanded = false;
  String? submittedName;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final placeController = TextEditingController();

  void expand() {
    isExpanded = true;
    submittedName = null;
    notifyListeners();
  }

  void submit() {
    submittedName = nameController.text;
    isExpanded = false;
    ageController.clear();
    placeController.clear();
    notifyListeners();
  }
}
