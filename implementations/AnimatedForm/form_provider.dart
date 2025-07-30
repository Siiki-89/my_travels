import 'package:estudando_flutter/models/person.dart';
import 'package:flutter/material.dart';

class FormProvider extends ChangeNotifier {
  bool isExpanded = false;
  String? submittedName;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final placeController = TextEditingController();

  final List<Person> _people = [];
  List<Person> get people => List.unmodifiable(_people);

  int? editingIndex; // null = adicionando; não-nulo = editando

  void expand({int? index}) {
    isExpanded = true;
    submittedName = null;
    editingIndex = index;

    if (index != null) {
      // preenchendo para edição
      final person = _people[index];
      nameController.text = person.name;
      ageController.text = person.age;
      placeController.text = person.place;
    } else {
      // novo cadastro
      nameController.clear();
      ageController.clear();
      placeController.clear();
    }

    notifyListeners();
  }

  void submit() {
    if (nameController.text.isEmpty ||
        ageController.text.isEmpty ||
        placeController.text.isEmpty)
      return;

    final person = Person(
      name: nameController.text,
      age: ageController.text,
      place: placeController.text,
    );

    if (editingIndex == null) {
      _people.add(person);
    } else {
      _people[editingIndex!] = person;
    }

    submittedName = person.name;
    isExpanded = false;
    editingIndex = null;
    nameController.clear();
    notifyListeners();
  }

  void delete(int index) {
    _people.removeAt(index);
    notifyListeners();
  }
}
