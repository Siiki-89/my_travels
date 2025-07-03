import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String name = 'Nome do Usuário';
  String age = 'Idade';
  // String? imagePath; // Para usar futuramente com imagem

  void setName(String newName) {
    name = newName;
    notifyListeners();
  }

  void setAge(String newAge) {
    age = newAge;
    notifyListeners();
  }
}
